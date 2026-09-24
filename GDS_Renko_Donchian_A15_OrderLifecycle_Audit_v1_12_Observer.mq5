//+------------------------------------------------------------------+
//|              GDS Renko Donchian Demo EA                          |
//|       Educational Renko + Donchian example for MT5               |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "1.12"
#property strict
#property description "Educational Renko + Donchian Expert Advisor for MetaTrader 5."
#property description "Builds classic fixed-size Renko internally from BID ticks."
#property description "The Donchian channel is calculated from completed Renko bricks."
#property description "TP/SL are virtual: the EA and terminal must remain running."
#property description "No external indicators, DLLs, custom symbols or offline charts are required."

#include "A15_Lifecycle_Observer_NoOrders_v1_00.mqh"

input double InpBrickSize             = 14.0;  // Renko brick size in price units
input int    InpDonchianPeriod        = 25;    // Donchian lookback in completed Renko bricks
input double InpBreakoutBufferBricks  = 0.20;  // Extra breakout distance in Renko bricks
input int    InpEntryRunBricks        = 1;     // Renko run required for entry
input double InpTakeProfitBricks      = 8.0;   // Take profit in Renko bricks
input double InpStopLossBricks        = 8.2;   // Stop loss in Renko bricks
input int    InpMaxHoldMinutes        = 4935;   // Maximum holding time
input int    InpCooldownBricks        = 6;     // Completed bricks to wait after exit
input double InpMaxSpreadFraction     = 0.35;  // Max spread as fraction of brick size
input double InpLots                  = 0.01;  // Fixed lot size
// AUDIT ONLY: run in a DEMO strategy tester. This EA sends actual tester orders.
input bool InpLifecycleAudit = true;

const ulong GDS_MAGIC = 26090141;
const int   GDS_MAX_HISTORY = 512;

struct SRenkoBrick
  {
   double open;
   double close;
   int    direction; // +1 up, -1 down
   int    run;       // consecutive bricks in current direction
  };

//+------------------------------------------------------------------+
//| Classic fixed-size Renko builder, two-brick reversal             |
//+------------------------------------------------------------------+
class CRenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;
   int    m_run;

   void AddBrick(SRenkoBrick &out[],const double open_price,
                 const double close_price,const int direction)
     {
      if(direction==m_last_dir)
         m_run++;
      else
        {
         m_last_dir=direction;
         m_run=1;
        }

      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].open=NormalizeDouble(open_price,_Digits);
      out[n].close=NormalizeDouble(close_price,_Digits);
      out[n].direction=direction;
      out[n].run=m_run;
     }

public:
   void Init(const double brick_size)
     {
      m_size=brick_size;
      m_has_anchor=false;
      m_anchor=0.0;
      m_last_close=0.0;
      m_last_dir=0;
      m_run=0;
     }

   int PushPrice(const double price,SRenkoBrick &out[])
     {
      ArrayResize(out,0);
      if(m_size<=0.0 || price<=0.0)
         return 0;

      if(!m_has_anchor)
        {
         m_anchor=price;
         m_has_anchor=true;
         return 0;
        }

      int added=0;

      // First direction: one full brick from the starting anchor.
      if(m_last_dir==0)
        {
         while(price>=m_anchor+m_size)
           {
            const double brick_open=m_anchor;
            m_anchor+=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,+1);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            const double brick_open=m_anchor;
            m_anchor-=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,-1);
            added++;
           }
         return added;
        }

      bool changed=true;
      while(changed)
        {
         changed=false;

         if(m_last_dir>0)
           {
            if(price>=m_last_close+m_size)
              {
               const double brick_open=m_last_close;
               m_last_close+=m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               const double brick_open=m_last_close-m_size;
               m_last_close-=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               const double brick_open=m_last_close;
               m_last_close-=m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               const double brick_open=m_last_close+m_size;
               m_last_close+=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };

CRenkoBuilder g_renko;
SRenkoBrick   g_history[];
int           g_cooldown_left=0;
bool          g_closed_this_tick=false;
bool          g_exit_pending=false;
string        g_exit_reason="";
bool          g_request_this_tick=false;
datetime      g_retry_after=0;
datetime      g_request_session_end=0;
int           g_request_failures=0;
ulong         g_wait_order=0;
bool          g_execution_uncertain=false;
bool          g_uncertain_exit=false;
const int     GDS_MAX_REQUEST_FAILURES=3;

//+------------------------------------------------------------------+
double NormalizeVolume(const double requested)
  {
   const double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   const double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   const double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(!MathIsValidNumber(requested) || vmin<=0.0 || vmax<vmin || step<=0.0)
      return 0.0;
   // Never increase the requested exposure to meet the broker minimum.
   if(requested<vmin-1.0e-10) return 0.0;
   const double volume=NormalizeDouble(
      MathFloor(MathMin(requested,vmax)/step+1.0e-9)*step,8);
   if(volume<vmin-1.0e-10 || volume>vmax+1.0e-10) return 0.0;
   return volume;
  }

//+------------------------------------------------------------------+
bool GetFillingMode(ENUM_ORDER_TYPE_FILLING &filling)
  {
   const long flags=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   const ENUM_SYMBOL_TRADE_EXECUTION execution=(ENUM_SYMBOL_TRADE_EXECUTION)
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE);
   filling=ORDER_FILLING_FOK;
   if(execution==SYMBOL_TRADE_EXECUTION_INSTANT ||
      execution==SYMBOL_TRADE_EXECUTION_REQUEST) return true;
   if((flags & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) return true;
   if((flags & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
     {
      filling=ORDER_FILLING_IOC;
      return true;
     }
   if(execution==SYMBOL_TRADE_EXECUTION_MARKET) return false;
   filling=ORDER_FILLING_RETURN;
   return true;
  }

//+------------------------------------------------------------------+
bool FindOurPosition(ulong &ticket,long &type,double &volume,
                     double &open_price,datetime &open_time)
  {
   ticket=0;
   type=-1;
   volume=0.0;
   open_price=0.0;
   open_time=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      const ulong t=PositionGetTicket(i);
      if(t==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if((ulong)PositionGetInteger(POSITION_MAGIC)!=GDS_MAGIC) continue;

      ticket=t;
      type=PositionGetInteger(POSITION_TYPE);
      volume=PositionGetDouble(POSITION_VOLUME);
      open_price=PositionGetDouble(POSITION_PRICE_OPEN);
      open_time=(datetime)PositionGetInteger(POSITION_TIME);
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool AnyPositionOnSymbol(void)
  {
   for(int i=PositionsTotal()-1;i>=0;i--)
     {
      const ulong t=PositionGetTicket(i);
      if(t==0) continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
bool SpreadIsAcceptable(const MqlTick &tick)
  {
   if(!ValidTick(tick)) return false;
   const double spread=tick.ask-tick.bid;
   return (spread<=InpBrickSize*InpMaxSpreadFraction);
  }

//+------------------------------------------------------------------+
void PushHistory(const SRenkoBrick &brick)
  {
   int n=ArraySize(g_history);

   if(n>=GDS_MAX_HISTORY)
     {
      for(int i=1;i<n;i++)
         g_history[i-1]=g_history[i];
      n--;
      ArrayResize(g_history,n);
     }

   ArrayResize(g_history,n+1);
   g_history[n]=brick;
  }

//+------------------------------------------------------------------+
//| Channel uses PRIOR completed bricks only. Current brick is       |
//| deliberately excluded, so a breakout cannot look ahead.         |
//+------------------------------------------------------------------+
bool GetDonchian(const int lookback,double &upper,double &lower)
  {
   const int n=ArraySize(g_history);
   if(lookback<1 || n<lookback)
      return false;

   upper=-1.0e100;
   lower= 1.0e100;
   const int first=n-lookback;

   for(int i=first;i<n;i++)
     {
      const double high=MathMax(g_history[i].open,g_history[i].close);
      const double low =MathMin(g_history[i].open,g_history[i].close);
      if(high>upper) upper=high;
      if(low <lower) lower=low;
     }
   return true;
  }

//+------------------------------------------------------------------+
//| Returns +1 long breakout, -1 short breakout, or 0.               |
//| The brick is appended to history AFTER the channel test.         |
//+------------------------------------------------------------------+
int ProcessCompletedBrick(const SRenkoBrick &brick)
  {
   double upper=0.0;
   double lower=0.0;
   int signal=0;

   if(GetDonchian(InpDonchianPeriod,upper,lower))
     {
      const double buffer=InpBreakoutBufferBricks*InpBrickSize;

      if(brick.direction>0 &&
         brick.run>=InpEntryRunBricks &&
         brick.close>upper+buffer)
         signal=+1;
      else if(brick.direction<0 &&
              brick.run>=InpEntryRunBricks &&
              brick.close<lower-buffer)
         signal=-1;
     }

   PushHistory(brick);
   return signal;
  }


//+------------------------------------------------------------------+
//| Convert datetime to seconds from midnight.                        |
//+------------------------------------------------------------------+
int SecondsOfDay(const datetime value)
  {
   MqlDateTime part={};
   if(!TimeToStruct(value,part))
      return -1;
   return part.hour*3600+part.min*60+part.sec;
  }

//+------------------------------------------------------------------+
//| Today's sessions plus the overnight tail of the previous day.    |
//| A missing schedule is NOT permission to trade. End is exclusive. |
//+------------------------------------------------------------------+
datetime TradingSessionEnd(const datetime now)
  {
   MqlDateTime current={};
   if(now<=0 || !TimeToStruct(now,current)) return 0;
   const int seconds=current.hour*3600+current.min*60+current.sec;
   const datetime midnight=now-seconds;
   for(int offset=0;offset<=1;offset++)
     {
      const ENUM_DAY_OF_WEEK day=(ENUM_DAY_OF_WEEK)
         ((current.day_of_week-offset+7)%7);
      for(uint session=0;session<24;session++)
        {
         datetime from=0,to=0;
         if(!SymbolInfoSessionTrade(_Symbol,day,session,from,to)) break;
         const int start_seconds=SecondsOfDay(from);
         const int end_seconds=SecondsOfDay(to);
         if(start_seconds<0 || end_seconds<0) continue;
         const datetime start=midnight-offset*86400+start_seconds;
         datetime end=midnight-offset*86400+end_seconds;
         // Equal endpoints in a returned session denote a full day.
         if(end<=start) end+=86400;
         if(now>=start && now<end) return end;
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
bool TradingSessionIsOpen(const datetime when=0)
  {
   return TradingSessionEnd(when>0 ? when : TimeCurrent())>0;
  }

//+------------------------------------------------------------------+
bool ValidTick(const MqlTick &tick)
  {
   return MathIsValidNumber(tick.bid) && MathIsValidNumber(tick.ask) &&
          tick.bid>0.0 && tick.ask>=tick.bid && tick.time>0;
  }

//+------------------------------------------------------------------+
bool HasActiveOrder(const bool only_ours)
  {
   for(int i=OrdersTotal()-1;i>=0;i--)
     {
      if(OrderGetTicket(i)==0) continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol) continue;
      if(!only_ours || (ulong)OrderGetInteger(ORDER_MAGIC)==GDS_MAGIC)
         return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
// Diagnostic-only observer. Never changes order requests or strategy state.
void AuditStage(const string stage,const string details="")
  {
   if(!InpLifecycleAudit) return;
   MqlTick t={};
   SymbolInfoTick(_Symbol,t);
   PrintFormat("[A15_ORDER_LIFECYCLE] stage=%s time=%s time_msc=%I64d bid=%.8f ask=%.8f pending=%d reason=%s cooldown=%d wait_order=%I64u uncertain=%d failures=%d retry_after=%s %s",
      stage,TimeToString(t.time,TIME_DATE|TIME_SECONDS),t.time_msc,t.bid,t.ask,
      (int)g_exit_pending,g_exit_reason,g_cooldown_left,g_wait_order,
      (int)g_execution_uncertain,g_request_failures,
      TimeToString(g_retry_after,TIME_DATE|TIME_SECONDS),details);
  }

//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(!InpLifecycleAudit) return;
   if(trans.symbol!=_Symbol && trans.symbol!="") return;
   A15ObsOnDeal(trans,_Symbol,GDS_MAGIC);
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD)
     {
      if(!HistoryDealSelect(trans.deal)) return;
      if((ulong)HistoryDealGetInteger(trans.deal,DEAL_MAGIC)!=GDS_MAGIC) return;
      PrintFormat("[A15_ORDER_LIFECYCLE] stage=DEAL_CONFIRMED deal=%I64u order=%I64u position_id=%I64d entry=%d type=%d volume=%.8f price=%.8f time_msc=%I64d profit=%.8f",
         trans.deal,trans.order,HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID),
         (int)HistoryDealGetInteger(trans.deal,DEAL_ENTRY),
         (int)HistoryDealGetInteger(trans.deal,DEAL_TYPE),
         HistoryDealGetDouble(trans.deal,DEAL_VOLUME),HistoryDealGetDouble(trans.deal,DEAL_PRICE),
         HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC),HistoryDealGetDouble(trans.deal,DEAL_PROFIT));
     }
   else if(trans.type==TRADE_TRANSACTION_REQUEST && request.magic==GDS_MAGIC)
      PrintFormat("[A15_ORDER_LIFECYCLE] stage=TRANSACTION_REQUEST order=%I64u deal=%I64u retcode=%u volume=%.8f price=%.8f comment=%s",
         result.order,result.deal,result.retcode,result.volume,result.price,result.comment);
  }

//+------------------------------------------------------------------+
void MarkExitCompleted(void)
  {
   A15ObsSnapshotPosition("EXIT_COMPLETED_ABSENT",_Symbol,GDS_MAGIC,g_a15obs.tracked_order);
   g_exit_pending=false;
   g_exit_reason="";
   g_cooldown_left=InpCooldownBricks;
   g_closed_this_tick=true;
   AuditStage("EXIT_COMPLETED_POSITION_ABSENT");
  }

//+------------------------------------------------------------------+
//| An accepted order may still be working. Never submit it again.   |
//+------------------------------------------------------------------+
bool ResolveExecution(void)
  {
   A15ObsCheckTerminal(_Symbol,GDS_MAGIC,g_wait_order,g_execution_uncertain);
   if(g_wait_order!=0)
     {
      if(OrderSelect(g_wait_order)) return false;
      if(!HistoryOrderSelect(g_wait_order)) return false;
      const ENUM_ORDER_STATE state=(ENUM_ORDER_STATE)
         HistoryOrderGetInteger(g_wait_order,ORDER_STATE);
      if(state!=ORDER_STATE_FILLED && state!=ORDER_STATE_CANCELED &&
         state!=ORDER_STATE_REJECTED && state!=ORDER_STATE_EXPIRED)
         return false;
      g_wait_order=0;
      g_execution_uncertain=false;
     }
   if(g_execution_uncertain)
     {
      ulong ticket=0;
      long type=-1;
      double volume=0.0,price=0.0;
      datetime opened=0;
      const bool exists=FindOurPosition(ticket,type,volume,price,opened);
      if((g_uncertain_exit && !exists) || (!g_uncertain_exit && exists))
         g_execution_uncertain=false;
     }
   return !g_execution_uncertain;
  }

//+------------------------------------------------------------------+
bool RequestWindowIsOpen(void)
  {
   if(g_request_this_tick || !ResolveExecution()) return false;
   if(!TerminalInfoInteger(TERMINAL_CONNECTED) ||
      !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ||
      !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return false;
   const datetime now=TimeCurrent();
   const datetime end=TradingSessionEnd(now);
   if(end<=0) return false;
   if(g_request_session_end!=end)
     {
      g_request_session_end=end;
      g_request_failures=0;
      g_retry_after=0;
     }
   return now>=g_retry_after;
  }

//+------------------------------------------------------------------+
void RegisterFailure(const uint retcode,const string details)
  {
   g_request_failures++;
   const datetime now=TimeCurrent();
   const datetime end=TradingSessionEnd(now);
   // Three failed checks/sends per session, or one MARKET_CLOSED.
   // An unexpected closure pauses requests until the scheduled interval ends.
   if(retcode==TRADE_RETCODE_MARKET_CLOSED ||
      g_request_failures>=GDS_MAX_REQUEST_FAILURES)
      g_retry_after=(end>now ? end : now+300);
   else
      g_retry_after=now+(g_request_failures==1 ? 5 : 30);
   Print("GDS Renko Donchian Demo: request deferred. Retcode ",retcode,
         ", ",details,", next attempt no earlier than ",
         TimeToString(g_retry_after,TIME_DATE|TIME_SECONDS));
  }

//+------------------------------------------------------------------+
bool SubmitDeal(MqlTradeRequest &request,const bool is_exit)
  {
   if(!RequestWindowIsOpen())
     {
      AuditStage("REQUEST_WINDOW_BLOCKED",StringFormat("is_exit=%d",(int)is_exit));
      return false;
     }
   AuditStage("PRE_ORDER_CHECK",StringFormat("is_exit=%d type=%d volume=%.8f price=%.8f position=%I64u filling=%d",
      (int)is_exit,(int)request.type,request.volume,request.price,request.position,(int)request.type_filling));
   g_request_this_tick=true;
   MqlTradeCheckResult check={};
   ResetLastError();
   const bool check_ok=OrderCheck(request,check);
   const int check_error=GetLastError();
   AuditStage("ORDER_CHECK_RESULT",StringFormat("ok=%d retcode=%u error=%d comment=%s",
      (int)check_ok,check.retcode,check_error,check.comment));
   if(!check_ok)
     {
      RegisterFailure(check.retcode,check.comment);
      return false;
     }
   // Recheck the current SERVER session immediately before OrderSend.
   if(!TradingSessionIsOpen(TimeCurrent()))
     {
      AuditStage("SESSION_CLOSED_BEFORE_SEND");
      return false;
     }
   AuditStage("PRE_ORDER_SEND");
   MqlTradeResult result={};
   ResetLastError();
   const bool sent=OrderSend(request,result);
   const int error=GetLastError();
   AuditStage("ORDER_SEND_RESULT",StringFormat("sent=%d retcode=%u error=%d order=%I64u deal=%I64u volume=%.8f price=%.8f comment=%s",
      (int)sent,result.retcode,error,result.order,result.deal,result.volume,result.price,result.comment));
   if(!sent || (result.retcode!=TRADE_RETCODE_DONE &&
                result.retcode!=TRADE_RETCODE_DONE_PARTIAL &&
                result.retcode!=TRADE_RETCODE_PLACED))
     {
      if(result.retcode==TRADE_RETCODE_TIMEOUT ||
         result.retcode==TRADE_RETCODE_CONNECTION || result.retcode==0)
        {
         // Unknown execution is reconciled, never blindly retried.
         g_execution_uncertain=true;
         g_uncertain_exit=is_exit;
         g_wait_order=result.order;
         Print("GDS Renko Donchian Demo: execution unconfirmed; requests paused. ",
               "Check account orders/positions if automatic reconciliation cannot finish.");
        }
      RegisterFailure(result.retcode,result.comment+" error="+IntegerToString(error));
      return false;
     }
   // The failure budget is reset only when the session interval changes.
   g_retry_after=0;
   g_wait_order=result.order;
   // Even DONE is not used as evidence that the position has disappeared.
   if(result.order==0)
     {
      g_execution_uncertain=true;
      g_uncertain_exit=is_exit;
      ResolveExecution();
     }
   return true;
  }

//+------------------------------------------------------------------+
bool TradeModeAllowsEntry(const int direction)
  {
   const ENUM_SYMBOL_TRADE_MODE mode=
      (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);

   if(mode==SYMBOL_TRADE_MODE_DISABLED || mode==SYMBOL_TRADE_MODE_CLOSEONLY)
      return false;
   if(mode==SYMBOL_TRADE_MODE_LONGONLY && direction<0)
      return false;
   if(mode==SYMBOL_TRADE_MODE_SHORTONLY && direction>0)
      return false;
   return true;
  }

//+------------------------------------------------------------------+
bool TradeModeAllowsClose(void)
  {
   const ENUM_SYMBOL_TRADE_MODE mode=
      (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   return (mode!=SYMBOL_TRADE_MODE_DISABLED);
  }

//+------------------------------------------------------------------+
void RequestExit(const string reason)
  {
   if(!g_exit_pending)
      g_exit_reason=reason;
   g_exit_pending=true;
   AuditStage("EXIT_DECISION_PENDING",StringFormat("new_reason=%s",reason));
  }

//+------------------------------------------------------------------+
bool SendMarket(const int direction)
  {
   if(direction!=1 && direction!=-1) return false;
   if(g_exit_pending || AnyPositionOnSymbol() || HasActiveOrder(false)) return false;
   if(!TradeModeAllowsEntry(direction)) return false;
   if((SymbolInfoInteger(_Symbol,SYMBOL_ORDER_MODE)&SYMBOL_ORDER_MARKET)==0)
      return false;
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !ValidTick(tick)) return false;
   if(!SpreadIsAcceptable(tick)) return false;
   MqlTradeRequest request={};
   if(!GetFillingMode(request.type_filling)) return false;
   request.volume=NormalizeVolume(InpLots);
   if(request.volume<=0.0) return false;
   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.symbol=_Symbol;
   request.deviation=50;
   request.comment="GDS Renko Donchian";
   request.type=(direction>0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL);
   request.price=(direction>0 ? tick.ask : tick.bid);
   AuditStage("ENTRY_REQUEST_PREPARED",StringFormat("direction=%d volume=%.8f quote=%.8f",direction,request.volume,request.price));
   return SubmitDeal(request,false);
  }

//+------------------------------------------------------------------+
bool CloseOurPosition(const string reason)
  {
   ulong ticket=0;
   long type=-1;
   double volume=0.0,open_price=0.0;
   datetime open_time=0;
   if(!FindOurPosition(ticket,type,volume,open_price,open_time)) return false;
   if(!TradeModeAllowsClose() || HasActiveOrder(true)) return false;
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !ValidTick(tick)) return false;
   MqlTradeRequest request={};
   if(!GetFillingMode(request.type_filling)) return false;
   request.action=TRADE_ACTION_DEAL;
   request.magic=GDS_MAGIC;
   request.position=ticket;
   request.symbol=_Symbol;
   request.volume=volume;
   request.deviation=50;
   request.comment="GDS Donchian exit";
   request.type=(type==POSITION_TYPE_BUY ? ORDER_TYPE_SELL : ORDER_TYPE_BUY);
   request.price=(type==POSITION_TYPE_BUY ? tick.bid : tick.ask);
   AuditStage("EXIT_REQUEST_PREPARED",StringFormat("reason=%s position=%I64u volume=%.8f quote=%.8f",reason,ticket,volume,request.price));
   if(!SubmitDeal(request,true)) return false;
   g_closed_this_tick=true;
   // Partial fills retain the original exit reason and pending flag.
   if(!FindOurPosition(ticket,type,volume,open_price,open_time))
     {
      Print("GDS Renko Donchian Demo exit: ",reason);
      MarkExitCompleted();
     }
   return true;
  }


//+------------------------------------------------------------------+
//| Execute an already-due exit only when trading is possible.       |
//+------------------------------------------------------------------+
void TryPendingExit(void)
  {
   if(!g_exit_pending || !ResolveExecution())
      return;

   A15ObsSnapshotPosition("PENDING_EXIT_POST_RESOLVE",_Symbol,GDS_MAGIC,g_a15obs.tracked_order);

   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;

   if(!FindOurPosition(ticket,type,volume,open_price,open_time))
     {
      MarkExitCompleted();
      return;
     }

   CloseOurPosition(g_exit_reason);
  }

//+------------------------------------------------------------------+
void CheckPriceExit(const MqlTick &tick)
  {
   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   if(!FindOurPosition(ticket,type,volume,open_price,open_time)) return;

   const int direction=(type==POSITION_TYPE_BUY ? +1 : -1);
   const double executable=(direction>0 ? tick.bid : tick.ask);
   if(executable<=0.0) return;

   const double move=direction*(executable-open_price);
   const double tp=InpTakeProfitBricks*InpBrickSize;
   const double sl=InpStopLossBricks*InpBrickSize;

   if(move>=tp)
     {
      RequestExit("TP");
      return;
     }

   if(move<=-sl)
     {
      RequestExit("SL");
      return;
     }

   if(InpMaxHoldMinutes>0 && open_time>0)
     {
      const long held_seconds=(long)(TimeCurrent()-open_time);
      if(held_seconds>=(long)InpMaxHoldMinutes*60)
         RequestExit("TIME");
     }
  }

//+------------------------------------------------------------------+
void UpdateRenkoAndTrade(const double price)
  {
   SRenkoBrick bricks[];
   const int n=g_renko.PushPrice(price,bricks);
   if(n<=0) return;

   // Keep only the signal of the newest completed brick on this tick.
   // This prevents a synthetic same-tick chain from producing stale entries.
   int final_signal=0;
   for(int i=0;i<n;i++)
      final_signal=ProcessCompletedBrick(bricks[i]);

   if(g_cooldown_left>0)
     {
      if(InpLifecycleAudit) AuditStage("COOLDOWN_BEFORE_BRICKS",StringFormat("bricks=%d",n));
      g_cooldown_left-=n;
      if(g_cooldown_left<0) g_cooldown_left=0;
      if(InpLifecycleAudit) AuditStage("COOLDOWN_AFTER_BRICKS",StringFormat("bricks=%d",n));
     }

   ulong ticket=0;
   long type=-1;
   double volume=0.0;
   double open_price=0.0;
   datetime open_time=0;
   const bool have_position=FindOurPosition(ticket,type,volume,open_price,open_time);

   if(have_position)
     {
      const int position_dir=(type==POSITION_TYPE_BUY ? +1 : -1);
      if(final_signal!=0 && final_signal!=position_dir)
        {
         RequestExit("OPPOSITE DONCHIAN BREAKOUT");
         TryPendingExit();
        }
      return;
     }

   if(g_closed_this_tick) return;
   if(AnyPositionOnSymbol()) return;
   if(g_cooldown_left>0) return;
   if(final_signal==0) return;

   SendMarket(final_signal);
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(!MathIsValidNumber(InpBrickSize) || InpBrickSize<_Point ||
      !MathIsValidNumber(InpBreakoutBufferBricks) ||
      !MathIsValidNumber(InpTakeProfitBricks) ||
      !MathIsValidNumber(InpStopLossBricks) ||
      !MathIsValidNumber(InpMaxSpreadFraction) || !MathIsValidNumber(InpLots) ||
      InpDonchianPeriod<2 || InpDonchianPeriod>GDS_MAX_HISTORY ||
      InpBreakoutBufferBricks<0.0 ||
      InpEntryRunBricks<1 ||
      InpTakeProfitBricks<=0.0 ||
      InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 ||
      InpCooldownBricks<0 ||
      InpMaxSpreadFraction<=0.0 ||
      InpLots<=0.0)
     {
      Print("GDS Renko Donchian Demo: invalid inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   g_request_this_tick=false;
   g_retry_after=0;
   g_request_session_end=0;
   g_request_failures=0;
   g_wait_order=0;
   g_execution_uncertain=false;
   g_uncertain_exit=false;
   g_renko.Init(InpBrickSize);
   ArrayResize(g_history,0);
   g_cooldown_left=0;
   g_closed_this_tick=false;
   g_exit_pending=false;
   g_exit_reason="";

   AuditStage("AUDIT_START","TESTER_ORDERS_ENABLED=1 DEMO_TESTER_ONLY=1");
   Print("GDS Renko Donchian Demo v1.11 started. Brick=",
         DoubleToString(InpBrickSize,_Digits),
         ", Donchian=",InpDonchianPeriod,
         ", Buffer=",DoubleToString(InpBreakoutBufferBricks,2),
         ", EntryRun=",InpEntryRunBricks,
         ", TP=",DoubleToString(InpTakeProfitBricks,2),
         ", SL=",DoubleToString(InpStopLossBricks,2),
         ", HoldMin=",InpMaxHoldMinutes,
         ", Lots=",DoubleToString(InpLots,2));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnTick(void)
  {
   g_closed_this_tick=false;
   g_request_this_tick=false;
   ResolveExecution();

   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !ValidTick(tick)) return;

   // A due exit remains pending across a closed trading session and is
   // executed when the session and request guards allow it.
   TryPendingExit();

   // Price-based exits use executable BID/ASK on every tester tick.
   CheckPriceExit(tick);
   TryPendingExit();

   // Renko and Donchian state are updated from completed BID bricks.
   UpdateRenkoAndTrade(tick.bid);
  }
//+------------------------------------------------------------------+
