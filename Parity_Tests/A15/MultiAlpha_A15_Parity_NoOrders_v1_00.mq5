//+------------------------------------------------------------------+
//| MultiAlpha_A15_Parity_NoOrders_v1_00.mq5                        |
//| A15 Core connected to MultiAlpha_Interface_v1_00.                |
//| Baseline parity harness. Research only. NO ORDERS.                |
//+------------------------------------------------------------------+
#property strict

#include "..\..\Include\MultiAlpha_Interface_v1_00.mqh"
#include "..\..\Include\A15_Entry_Module_v1_00.mqh"
#include "..\..\Include\A15_Exit_Decision_Module_v1_00.mqh"

input double InpA15BrickSize=14.0;
input double InpA15TakeProfitBricks=8.0;
input double InpA15StopLossBricks=8.2;
input int    InpA15MaxHoldMinutes=4935;
input int    InpA15DonchianPeriod=25;
input double InpA15BreakoutBufferBricks=0.20;
input int    InpA15EntryRunBricks=1;
input int    InpCooldownBricks=6;
input double InpMaxSpreadFraction=0.35;

CA15RenkoBuilder g_renko;
CA15EntryModule  g_entry;
SMultiAlphaPosition g_position;
int g_cooldown=0;

long g_ticks=0,g_bricks=0,g_raw_signals=0,g_entries=0,g_exits=0,g_spread_blocks=0;
long g_entry_match=0,g_entry_diff=0,g_exit_match=0,g_exit_diff=0;
int g_entry_index=0,g_exit_index=0;

long RefEntryMsc(const int i)
  {
   if(i==0) return 1787248947333;
   if(i==1) return 1787626824126;
   if(i==2) return 1787835772547;
   return 0;
  }
double RefEntryPrice(const int i)
  {
   if(i==0) return 4530.76;
   if(i==1) return 4684.66;
   if(i==2) return 4571.77;
   return 0.0;
  }
int RefEntryDirection(const int i) { return (i==2 ? -1 : 1); }

datetime RefExitTime(const int i)
  {
   if(i==0) return D'2026.08.24 04:17:28';
   if(i==1) return D'2026.08.26 18:15:43';
   if(i==2) return D'2026.08.28 21:17:18';
   return 0;
  }
double RefExitPrice(const int i)
  {
   if(i==0) return 4622.05;
   if(i==1) return 4585.67;
   if(i==2) return 4457.81;
   return 0.0;
  }
string RefExitReason(const int i)
  {
   if(i==0) return "TIME";
   if(i==1) return "OPPOSITE DONCHIAN BREAKOUT";
   if(i==2) return "TP";
   return "";
  }

void ClearVirtualPosition()
  {
   g_position.is_open=false;
   g_position.direction=0;
   g_position.entry_price=0.0;
   g_position.entry_time=0;
   g_position.volume=0.0;
  }

SA15ExitSnapshot A15Snapshot()
  {
   SA15ExitSnapshot s;
   s.is_open=g_position.is_open;
   s.direction=g_position.direction;
   s.entry_price=g_position.entry_price;
   s.entry_time=g_position.entry_time;
   return s;
  }

SA15ExitSettings A15Settings()
  {
   SA15ExitSettings s;
   s.brick_size=InpA15BrickSize;
   s.take_profit_bricks=InpA15TakeProfitBricks;
   s.stop_loss_bricks=InpA15StopLossBricks;
   s.max_hold_minutes=InpA15MaxHoldMinutes;
   return s;
  }

void MakeExitDecision(const SMultiAlphaMarket &market,const string reason,
                      SMultiAlphaDecision &decision)
  {
   MultiAlphaDecisionClear(decision,ALPHA_A15);
   decision.action=ALPHA_ACTION_EXIT;
   decision.direction=g_position.direction;
   decision.reason=reason;
   decision.decision_price=(g_position.direction>0 ? market.bid : market.ask);
   decision.time=market.time;
   decision.time_msc=market.time_msc;
  }

void ApplyDecision(const SMultiAlphaDecision &decision)
  {
   if(decision.action==ALPHA_ACTION_ENTRY)
     {
      const int i=g_entry_index++;
      const double tol=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
      const bool match=(i<3 && decision.time_msc==RefEntryMsc(i) &&
                        decision.direction==RefEntryDirection(i) &&
                        MathAbs(decision.decision_price-RefEntryPrice(i))<=tol);
      if(match) g_entry_match++; else g_entry_diff++;

      g_position.is_open=true;
      g_position.direction=decision.direction;
      g_position.entry_price=decision.decision_price;
      g_position.entry_time=decision.time;
      g_position.volume=0.01;
      g_entries++;

      PrintFormat("[MULTI_ALPHA_A15_ENTRY] index=%d match=%d time=%s time_msc=%I64d dir=%d price=%.8f expected_msc=%I64d expected_dir=%d expected_price=%.8f alpha=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         i+1,(int)match,TimeToString(decision.time,TIME_DATE|TIME_SECONDS),
         decision.time_msc,decision.direction,decision.decision_price,
         (i<3 ? RefEntryMsc(i) : (long)0),(i<3 ? RefEntryDirection(i) : 0),
         (i<3 ? RefEntryPrice(i) : 0.0),(int)decision.alpha_id);
     }
   else if(decision.action==ALPHA_ACTION_EXIT)
     {
      const int i=g_exit_index++;
      const double tol=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
      const bool match=(i<3 && decision.time==RefExitTime(i) &&
                        decision.reason==RefExitReason(i) &&
                        MathAbs(decision.decision_price-RefExitPrice(i))<=tol);
      if(match) g_exit_match++; else g_exit_diff++;

      PrintFormat("[MULTI_ALPHA_A15_EXIT] index=%d match=%d time=%s time_msc=%I64d reason=%s dir=%d price=%.8f expected_time=%s expected_reason=%s expected_price=%.8f alpha=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         i+1,(int)match,TimeToString(decision.time,TIME_DATE|TIME_SECONDS),
         decision.time_msc,decision.reason,decision.direction,decision.decision_price,
         (i<3 ? TimeToString(RefExitTime(i),TIME_DATE|TIME_SECONDS) : "NONE"),
         (i<3 ? RefExitReason(i) : "NONE"),(i<3 ? RefExitPrice(i) : 0.0),
         (int)decision.alpha_id);

      ClearVirtualPosition();
      g_cooldown=InpCooldownBricks;
      g_exits++;
     }
  }

int OnInit()
  {
   if(InpA15BrickSize<=0.0 || InpA15TakeProfitBricks<=0.0 ||
      InpA15StopLossBricks<=0.0 || InpA15MaxHoldMinutes<0 ||
      InpA15DonchianPeriod<2 || InpA15DonchianPeriod>512 ||
      InpA15BreakoutBufferBricks<0.0 || InpA15EntryRunBricks<1 ||
      InpCooldownBricks<0 || InpMaxSpreadFraction<0.0)
      return INIT_PARAMETERS_INCORRECT;

   g_renko.Init(InpA15BrickSize);
   g_entry.Init(InpA15BrickSize,InpA15DonchianPeriod,
                InpA15BreakoutBufferBricks,InpA15EntryRunBricks);
   ClearVirtualPosition();
   g_cooldown=0;
   g_ticks=0; g_bricks=0; g_raw_signals=0; g_entries=0; g_exits=0; g_spread_blocks=0;
   g_entry_match=0; g_entry_diff=0; g_exit_match=0; g_exit_diff=0;
   g_entry_index=0; g_exit_index=0;

   PrintFormat("[MULTI_ALPHA_A15_START] alpha=%d brick=%.4f donchian=%d buffer=%.4f run=%d TP=%.4f SL=%.4f hold=%d cooldown=%d spread_fraction=%.4f NO_ORDERS=1",
      (int)ALPHA_A15,InpA15BrickSize,InpA15DonchianPeriod,
      InpA15BreakoutBufferBricks,InpA15EntryRunBricks,
      InpA15TakeProfitBricks,InpA15StopLossBricks,InpA15MaxHoldMinutes,
      InpCooldownBricks,InpMaxSpreadFraction);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick)) return;

   SMultiAlphaMarket market;
   market.time=tick.time;
   market.time_msc=tick.time_msc;
   market.bid=tick.bid;
   market.ask=tick.ask;
   if(!MultiAlphaMarketValid(market)) return;
   g_ticks++;

   bool closed_this_tick=false;
   SMultiAlphaDecision decision;
   MultiAlphaDecisionClear(decision,ALPHA_A15);

   // 1) Price/time exit before Renko update.
   if(g_position.is_open)
     {
      const string reason=A15ExitPriceTimeDecision(A15Snapshot(),A15Settings(),tick,TimeCurrent());
      if(reason!="")
        {
         MakeExitDecision(market,reason,decision);
         ApplyDecision(decision);
         closed_this_tick=true;
        }
     }

   // 2) BID Renko + A15 Entry module. Only newest brick signal survives this tick.
   SA15Brick bricks[];
   const int n=g_renko.PushPrice(market.bid,bricks);
   int final_signal=0;
   for(int i=0;i<n;i++)
     {
      final_signal=g_entry.ProcessCompletedBrick(bricks[i]);
      g_bricks++;
     }
   if(n>0 && final_signal!=0) g_raw_signals++;

   // 3) Opposite Donchian exit after Renko update.
   if(g_position.is_open && n>0)
     {
      const string reason=A15ExitOppositeDecision(A15Snapshot(),final_signal);
      if(reason!="")
        {
         MakeExitDecision(market,reason,decision);
         ApplyDecision(decision);
         closed_this_tick=true;
        }
     }

   // 4) Cooldown follows the original A15 ordering.
   if(n>0 && g_cooldown>0)
     {
      const int before=g_cooldown;
      g_cooldown-=n;
      if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[MULTI_ALPHA_A15_COOLDOWN] time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         market.time_msc,before,n,g_cooldown);
     }

   // 5) Entry gates; emit common-interface decision.
   if(n>0 && !g_position.is_open && !closed_this_tick && g_cooldown==0 && final_signal!=0)
     {
      const double spread=market.ask-market.bid;
      const double limit=InpMaxSpreadFraction*InpA15BrickSize;
      if(spread<=limit)
        {
         MultiAlphaDecisionClear(decision,ALPHA_A15);
         decision.action=ALPHA_ACTION_ENTRY;
         decision.direction=final_signal;
         decision.reason="A15 DONCHIAN BREAKOUT";
         decision.decision_price=(final_signal>0 ? market.ask : market.bid);
         decision.time=market.time;
         decision.time_msc=market.time_msc;
         ApplyDecision(decision);
        }
      else
        {
         g_spread_blocks++;
         PrintFormat("[MULTI_ALPHA_A15_SPREAD_BLOCK] time_msc=%I64d spread=%.8f limit=%.8f NO_ORDERS=1",
            market.time_msc,spread,limit);
        }
     }
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[MULTI_ALPHA_A15_SUMMARY] alpha=%d ticks=%I64d bricks=%I64d raw_signals=%I64d entries=%I64d exits=%I64d open=%d cooldown=%d spread_blocks=%I64d entry_match=%I64d entry_diff=%I64d exit_match=%I64d exit_diff=%I64d reference_entries=3 reference_exits=3 NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      (int)ALPHA_A15,g_ticks,g_bricks,g_raw_signals,g_entries,g_exits,
      (int)g_position.is_open,g_cooldown,g_spread_blocks,
      g_entry_match,g_entry_diff,g_exit_match,g_exit_diff);
  }
