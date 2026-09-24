//+------------------------------------------------------------------+
//| A15_Core_Module_NoOrders_v1_00.mq5                              |
//| Standalone A15 core using extracted Entry + Exit modules.        |
//| Baseline reproduction harness. NO ORDERS / NO TRADE CALLS.       |
//+------------------------------------------------------------------+
#property strict

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

bool g_position=false;
int g_direction=0;
double g_entry_price=0.0;
datetime g_entry_time=0;
int g_cooldown=0;

long g_ticks=0,g_bricks=0,g_raw_signals=0;
long g_entries=0,g_exits=0,g_spread_blocks=0;
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

SA15ExitSnapshot Snapshot()
  {
   SA15ExitSnapshot s;
   s.is_open=g_position;
   s.direction=g_direction;
   s.entry_price=g_entry_price;
   s.entry_time=g_entry_time;
   return s;
  }
SA15ExitSettings ExitSettings()
  {
   SA15ExitSettings s;
   s.brick_size=InpA15BrickSize;
   s.take_profit_bricks=InpA15TakeProfitBricks;
   s.stop_loss_bricks=InpA15StopLossBricks;
   s.max_hold_minutes=InpA15MaxHoldMinutes;
   return s;
  }

void VirtualExit(const string reason,const MqlTick &tick)
  {
   if(!g_position) return;
   const int closed_direction=g_direction;
   const double exit_price=(closed_direction>0 ? tick.bid : tick.ask);
   const int i=g_exit_index++;
   const double tol=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
   const bool match=(i<3 && tick.time==RefExitTime(i) &&
                     reason==RefExitReason(i) &&
                     MathAbs(exit_price-RefExitPrice(i))<=tol);
   if(match) g_exit_match++; else g_exit_diff++;

   PrintFormat("[A15_CORE_EXIT] index=%d match=%d time=%s time_msc=%I64d reason=%s dir=%d entry=%.8f exit=%.8f expected_time=%s expected_reason=%s expected_price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      i+1,(int)match,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,
      reason,closed_direction,g_entry_price,exit_price,
      (i<3 ? TimeToString(RefExitTime(i),TIME_DATE|TIME_SECONDS) : "NONE"),
      (i<3 ? RefExitReason(i) : "NONE"),(i<3 ? RefExitPrice(i) : 0.0));

   g_position=false;
   g_direction=0;
   g_entry_price=0.0;
   g_entry_time=0;
   g_cooldown=InpCooldownBricks;
   g_exits++;
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

   g_position=false; g_direction=0; g_entry_price=0.0; g_entry_time=0; g_cooldown=0;
   g_ticks=0; g_bricks=0; g_raw_signals=0; g_entries=0; g_exits=0; g_spread_blocks=0;
   g_entry_match=0; g_entry_diff=0; g_exit_match=0; g_exit_diff=0;
   g_entry_index=0; g_exit_index=0;

   PrintFormat("[A15_CORE_START] brick=%.4f donchian=%d buffer=%.4f run=%d TP=%.4f SL=%.4f hold=%d cooldown=%d spread_fraction=%.4f NO_ORDERS=1",
      InpA15BrickSize,InpA15DonchianPeriod,InpA15BreakoutBufferBricks,
      InpA15EntryRunBricks,InpA15TakeProfitBricks,InpA15StopLossBricks,
      InpA15MaxHoldMinutes,InpCooldownBricks,InpMaxSpreadFraction);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !MathIsValidNumber(tick.bid) ||
      !MathIsValidNumber(tick.ask) || tick.bid<=0.0 || tick.ask<tick.bid || tick.time<=0)
      return;
   g_ticks++;
   bool closed_this_tick=false;

   // Original A15 scheduling: price/time exit BEFORE Renko update.
   if(g_position)
     {
      const string reason=A15ExitPriceTimeDecision(Snapshot(),ExitSettings(),tick,TimeCurrent());
      if(reason!="")
        {
         VirtualExit(reason,tick);
         closed_this_tick=true;
        }
     }

   // Independent BID Renko; retain ONLY newest completed brick signal on this tick.
   SA15Brick bricks[];
   const int n=g_renko.PushPrice(tick.bid,bricks);
   int final_signal=0;
   for(int i=0;i<n;i++)
     {
      final_signal=g_entry.ProcessCompletedBrick(bricks[i]);
      g_bricks++;
     }
   if(n>0 && final_signal!=0) g_raw_signals++;

   // Original A15 opposite Donchian exit occurs after Renko update.
   if(g_position && n>0)
     {
      const string opposite=A15ExitOppositeDecision(Snapshot(),final_signal);
      if(opposite!="")
        {
         VirtualExit(opposite,tick);
         closed_this_tick=true;
        }
     }

   // Original order: decrement cooldown on every completed-brick tick,
   // then position / closed-this-tick / cooldown / signal / spread gates.
   if(n>0 && g_cooldown>0)
     {
      const int before=g_cooldown;
      g_cooldown-=n;
      if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[A15_CORE_COOLDOWN] time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         tick.time_msc,before,n,g_cooldown);
     }

   if(n>0 && !g_position && !closed_this_tick && g_cooldown==0 && final_signal!=0)
     {
      const double spread=tick.ask-tick.bid;
      const double limit=InpMaxSpreadFraction*InpA15BrickSize;
      if(spread<=limit)
        {
         const int dir=final_signal;
         const double price=(dir>0 ? tick.ask : tick.bid);
         const int i=g_entry_index++;
         const double tol=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
         const bool match=(i<3 && tick.time_msc==RefEntryMsc(i) &&
                           dir==RefEntryDirection(i) &&
                           MathAbs(price-RefEntryPrice(i))<=tol);
         if(match) g_entry_match++; else g_entry_diff++;

         g_position=true;
         g_direction=dir;
         g_entry_price=price;
         g_entry_time=tick.time;
         g_entries++;

         PrintFormat("[A15_CORE_ENTRY] index=%d match=%d time=%s time_msc=%I64d dir=%d price=%.8f bid=%.8f ask=%.8f spread=%.8f expected_msc=%I64d expected_dir=%d expected_price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
            i+1,(int)match,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,
            dir,price,tick.bid,tick.ask,spread,
            (i<3 ? RefEntryMsc(i) : (long)0),
            (i<3 ? RefEntryDirection(i) : 0),
            (i<3 ? RefEntryPrice(i) : 0.0));
        }
      else
        {
         g_spread_blocks++;
         PrintFormat("[A15_CORE_SPREAD_BLOCK] time_msc=%I64d spread=%.8f limit=%.8f NO_ORDERS=1",
            tick.time_msc,spread,limit);
        }
     }
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[A15_CORE_SUMMARY] ticks=%I64d bricks=%I64d raw_signals=%I64d entries=%I64d exits=%I64d open=%d cooldown=%d spread_blocks=%I64d entry_match=%I64d entry_diff=%I64d exit_match=%I64d exit_diff=%I64d reference_entries=3 reference_exits=3 NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      g_ticks,g_bricks,g_raw_signals,g_entries,g_exits,(int)g_position,g_cooldown,
      g_spread_blocks,g_entry_match,g_entry_diff,g_exit_match,g_exit_diff);
  }
