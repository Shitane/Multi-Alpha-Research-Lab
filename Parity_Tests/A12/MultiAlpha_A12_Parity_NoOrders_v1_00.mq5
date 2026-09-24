//+------------------------------------------------------------------+
//| MultiAlpha_A12_Parity_NoOrders_v1_00.mq5                        |
//| Frozen-style A12 path vs Multi Alpha A12 adapter parity harness. |
//| Research only. NO ORDERS.                                       |
//+------------------------------------------------------------------+
#property strict
#include "..\..\Include\MultiAlpha_Interface_v1_00.mqh"
#include "..\..\Include\A12_Entry_Module.mqh"

input double InpBrickSize=16.0;
input int InpADXPeriod=14;
input double InpADXThreshold=8.5;
input double InpMinDISeparation=2.5;
input int InpEntryRunBricks=3;
input double InpTakeProfitBricks=9.5;
input double InpStopLossBricks=42.0;
input int InpMaxHoldMinutes=1060;
input int InpCooldownBricks=6;
input double InpMaxSpreadFraction=0.35;

struct SPathState
  {
   bool open;
   int dir;
   double entry;
   datetime entry_time;
   int cooldown;
   long entries;
   long exits;
   long blocks;
   long raw_candidates;
  };

CRenkoBuilder g_base_renko,g_multi_renko;
CRenkoADX g_base_adx,g_multi_adx;
SPathState g_base,g_multi;
double g_tick_size=0.0,g_brick=0.0;
long g_ticks=0,g_bricks=0,g_brick_mismatch=0,g_signal_mismatch=0;
long g_decision_checks=0,g_decision_mismatch=0,g_state_mismatch=0;
bool g_failed=false;

void ResetState(SPathState &s)
  {
   s.open=false;s.dir=0;s.entry=0.0;s.entry_time=0;s.cooldown=0;
   s.entries=0;s.exits=0;s.blocks=0;s.raw_candidates=0;
  }

string TickExit(const SPathState &s,const MqlTick &t)
  {
   if(!s.open) return "";
   const double px=(s.dir>0?t.bid:t.ask);
   const double move=s.dir*(px-s.entry);
   if(move>=InpTakeProfitBricks*g_brick) return "TP";
   if(move<=-InpStopLossBricks*g_brick) return "SL";
   if(InpMaxHoldMinutes>0 &&
      (long)(t.time-s.entry_time)>=(long)InpMaxHoldMinutes*60) return "TIME";
   return "";
  }

string BrickExit(const SPathState &s,const int raw)
  {
   if(s.open && raw!=0 && raw==-s.dir) return "DI_FLIP";
   return "";
  }

void CloseVirtual(SPathState &s)
  {
   s.open=false;s.dir=0;s.entry=0.0;s.entry_time=0;
   s.cooldown=InpCooldownBricks;s.exits++;
  }

void OpenVirtual(SPathState &s,const int sig,const MqlTick &t)
  {
   s.open=true;s.dir=sig;s.entry=(sig>0?t.ask:t.bid);
   s.entry_time=t.time;s.entries++;
  }

bool SamePrice(const double a,const double b)
  {
   return MathAbs(a-b)<=g_tick_size*0.5+1e-8;
  }

void LogDecisionDiff(const MqlTick &t,const string stage,
                     const string base_reason,const string multi_reason,
                     const int base_sig,const int multi_sig)
  {
   g_decision_mismatch++;
   PrintFormat("[MULTI_ALPHA_A12_PARITY_DIFF] stage=%s time=%s time_msc=%I64d base_reason=%s multi_reason=%s base_sig=%d multi_sig=%d base_open=%d multi_open=%d base_dir=%d multi_dir=%d base_cd=%d multi_cd=%d NO_ORDERS=1",
      stage,TimeToString(t.time,TIME_DATE|TIME_SECONDS),t.time_msc,
      base_reason,multi_reason,base_sig,multi_sig,(int)g_base.open,
      (int)g_multi.open,g_base.dir,g_multi.dir,g_base.cooldown,g_multi.cooldown);
  }

void CheckState(const MqlTick &t,const string stage)
  {
   const bool same=(g_base.open==g_multi.open &&
                    g_base.dir==g_multi.dir &&
                    SamePrice(g_base.entry,g_multi.entry) &&
                    g_base.entry_time==g_multi.entry_time &&
                    g_base.cooldown==g_multi.cooldown &&
                    g_base.entries==g_multi.entries &&
                    g_base.exits==g_multi.exits &&
                    g_base.blocks==g_multi.blocks &&
                    g_base.raw_candidates==g_multi.raw_candidates);
   if(!same)
     {
      g_state_mismatch++;
      PrintFormat("[MULTI_ALPHA_A12_STATE_DIFF] stage=%s time_msc=%I64d base_open=%d multi_open=%d base_dir=%d multi_dir=%d base_entry=%.8f multi_entry=%.8f base_cd=%d multi_cd=%d base_entries=%I64d multi_entries=%I64d base_exits=%I64d multi_exits=%I64d NO_ORDERS=1",
         stage,t.time_msc,(int)g_base.open,(int)g_multi.open,g_base.dir,g_multi.dir,
         g_base.entry,g_multi.entry,g_base.cooldown,g_multi.cooldown,
         g_base.entries,g_multi.entries,g_base.exits,g_multi.exits);
     }
  }

int OnInit()
  {
   if(InpBrickSize<=0.0 || InpADXPeriod<2 || InpADXPeriod>100 ||
      InpADXThreshold<0.0 || InpADXThreshold>100.0 ||
      InpMinDISeparation<0.0 || InpMinDISeparation>100.0 ||
      InpEntryRunBricks<1 || InpTakeProfitBricks<=0.0 ||
      InpStopLossBricks<=0.0 || InpMaxHoldMinutes<0 ||
      InpCooldownBricks<0 || InpMaxSpreadFraction<0.0)
      return INIT_PARAMETERS_INCORRECT;

   g_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(g_tick_size<=0.0) return INIT_FAILED;
   const long units=(long)MathMax(1.0,MathRound(InpBrickSize/g_tick_size));
   g_brick=(double)units*g_tick_size;

   g_base_renko.Init(g_tick_size,units); g_multi_renko.Init(g_tick_size,units);
   g_base_adx.Init(InpADXPeriod); g_multi_adx.Init(InpADXPeriod);
   ResetState(g_base);ResetState(g_multi);
   g_ticks=0;g_bricks=0;g_brick_mismatch=0;g_signal_mismatch=0;
   g_decision_checks=0;g_decision_mismatch=0;g_state_mismatch=0;g_failed=false;
   PrintFormat("[MULTI_ALPHA_A12_PARITY_START] brick=%.8f ADX=%d threshold=%.4f min_di=%.4f run=%d TP=%.4f SL=%.4f hold=%d cooldown=%d spread_fraction=%.4f NO_ORDERS=1",
      g_brick,InpADXPeriod,InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,
      InpTakeProfitBricks,InpStopLossBricks,InpMaxHoldMinutes,InpCooldownBricks,
      InpMaxSpreadFraction);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   if(g_failed) return;
   MqlTick t={}; if(!SymbolInfoTick(_Symbol,t) || t.bid<=0.0 || t.ask<=0.0) return;
   g_ticks++;

   bool base_closed=false,multi_closed=false;
   string br=TickExit(g_base,t),mr=TickExit(g_multi,t);
   g_decision_checks++;
   if(br!=mr) LogDecisionDiff(t,"TICK_EXIT",br,mr,0,0);
   if(br!=""){CloseVirtual(g_base);base_closed=true;}
   if(mr!=""){CloseVirtual(g_multi);multi_closed=true;}
   CheckState(t,"AFTER_TICK_EXIT");

   SRenkoBrick bb[],mb[];
   const int bn=g_base_renko.PushPrice(t.bid,bb);
   const int mn=g_multi_renko.PushPrice(t.bid,mb);
   if(bn<0 || mn<0){g_failed=true;Print("[MULTI_ALPHA_A12_PARITY_ERROR] renko_stopped NO_ORDERS=1");return;}
   if(bn!=mn)
     {
      g_brick_mismatch++;
      PrintFormat("[MULTI_ALPHA_A12_BRICK_COUNT_DIFF] time_msc=%I64d base=%d multi=%d NO_ORDERS=1",t.time_msc,bn,mn);
     }
   if(bn==0 && mn==0) return;

   int bs=0,ms=0,braw=0,mraw=0;
   const int common=MathMin(bn,mn);
   for(int i=0;i<common;i++)
     {
      if(!SamePrice(bb[i].open,mb[i].open)||!SamePrice(bb[i].close,mb[i].close)||
         bb[i].direction!=mb[i].direction||bb[i].run!=mb[i].run)
        {
         g_brick_mismatch++;
         PrintFormat("[MULTI_ALPHA_A12_BRICK_DIFF] time_msc=%I64d i=%d base_open=%.8f multi_open=%.8f base_close=%.8f multi_close=%.8f base_dir=%d multi_dir=%d base_run=%d multi_run=%d NO_ORDERS=1",
            t.time_msc,i,bb[i].open,mb[i].open,bb[i].close,mb[i].close,
            bb[i].direction,mb[i].direction,bb[i].run,mb[i].run);
        }
      int x=0,y=0;
      bs=A12_ProcessCompletedBrick(g_base_adx,bb[i],InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,x);
      ms=A12_ProcessCompletedBrick(g_multi_adx,mb[i],InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,y);
      braw=x;mraw=y;g_bricks++;
      if(bs!=ms || braw!=mraw)
        {
         g_signal_mismatch++;
         PrintFormat("[MULTI_ALPHA_A12_SIGNAL_DIFF] time_msc=%I64d i=%d base_sig=%d multi_sig=%d base_raw=%d multi_raw=%d NO_ORDERS=1",
            t.time_msc,i,bs,ms,braw,mraw);
        }
     }
   if(bn!=mn){g_failed=true;return;}

   if(g_base.cooldown>0){g_base.cooldown-=bn;if(g_base.cooldown<0)g_base.cooldown=0;}
   if(g_multi.cooldown>0){g_multi.cooldown-=mn;if(g_multi.cooldown<0)g_multi.cooldown=0;}

   br=BrickExit(g_base,braw);mr=BrickExit(g_multi,mraw);
   g_decision_checks++;
   if(br!=mr) LogDecisionDiff(t,"BRICK_EXIT",br,mr,bs,ms);
   if(br!="") CloseVirtual(g_base);
   if(mr!="") CloseVirtual(g_multi);
   if(br!=""||mr!=""){CheckState(t,"AFTER_BRICK_EXIT");return;}

   if(g_base.open||g_multi.open){CheckState(t,"OPEN_HOLD");return;}

   if(bs!=0) g_base.raw_candidates++;
   if(ms!=0) g_multi.raw_candidates++;
   g_decision_checks++;
   if(bs!=ms || base_closed!=multi_closed)
      LogDecisionDiff(t,"ENTRY_SIGNAL","", "",bs,ms);

   if(bs!=0)
     {
      if(base_closed || g_base.cooldown>0) g_base.blocks++;
      else if(t.ask-t.bid>InpMaxSpreadFraction*g_brick) g_base.blocks++;
      else OpenVirtual(g_base,bs,t);
     }
   if(ms!=0)
     {
      if(multi_closed || g_multi.cooldown>0) g_multi.blocks++;
      else if(t.ask-t.bid>InpMaxSpreadFraction*g_brick) g_multi.blocks++;
      else OpenVirtual(g_multi,ms,t);
     }
   CheckState(t,"AFTER_ENTRY_GATE");
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[MULTI_ALPHA_A12_PARITY_SUMMARY] ticks=%I64d bricks=%I64d brick_mismatch=%I64d signal_mismatch=%I64d decision_checks=%I64d decision_mismatch=%I64d state_mismatch=%I64d base_entries=%I64d multi_entries=%I64d base_exits=%I64d multi_exits=%I64d base_blocks=%I64d multi_blocks=%I64d base_raw=%I64d multi_raw=%I64d base_open=%d multi_open=%d failed=%d reason=%d NO_ORDERS=1",
      g_ticks,g_bricks,g_brick_mismatch,g_signal_mismatch,g_decision_checks,
      g_decision_mismatch,g_state_mismatch,g_base.entries,g_multi.entries,
      g_base.exits,g_multi.exits,g_base.blocks,g_multi.blocks,
      g_base.raw_candidates,g_multi.raw_candidates,(int)g_base.open,
      (int)g_multi.open,(int)g_failed,reason);
  }
