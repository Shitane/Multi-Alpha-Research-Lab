//+------------------------------------------------------------------+
//| MultiAlpha_Core_NoOrders_v1_00.mq5                              |
//| Unified A12/A15 host using MultiAlpha_Interface_v1_00.           |
//| Research only. NO ORDERS. Select Alpha with InpAlpha.            |
//+------------------------------------------------------------------+
#property strict

#include "..\\..\\Include\\MultiAlpha_Interface_v1_00.mqh"
#include "..\\..\\Include\\A12_Entry_Module.mqh"
#include "..\\..\\Include\\A15_Entry_Module_v1_00.mqh"
#include "..\\..\\Include\\A15_Exit_Decision_Module_v1_00.mqh"

input ENUM_MULTI_ALPHA_ID InpAlpha=ALPHA_A15;

// A12 parameters
input double InpA12BrickSize=16.0;
input int    InpA12ADXPeriod=14;
input double InpA12ADXThreshold=8.5;
input double InpA12MinDISeparation=2.5;
input int    InpA12EntryRunBricks=3;
input double InpA12TakeProfitBricks=9.5;
input double InpA12StopLossBricks=42.0;
input int    InpA12MaxHoldMinutes=1060;

// A15 parameters
input double InpA15BrickSize=14.0;
input double InpA15TakeProfitBricks=8.0;
input double InpA15StopLossBricks=8.2;
input int    InpA15MaxHoldMinutes=4935;
input int    InpA15DonchianPeriod=25;
input double InpA15BreakoutBufferBricks=0.20;
input int    InpA15EntryRunBricks=1;

// Common host gates
input int    InpCooldownBricks=6;
input double InpMaxSpreadFraction=0.35;

SMultiAlphaPosition g_position;
int  g_cooldown=0;
bool g_failed=false;
long g_ticks=0,g_bricks=0,g_raw=0,g_entries=0,g_exits=0,g_blocks=0,g_spread_blocks=0;

// A12 state
CRenkoBuilder g_a12_renko;
CRenkoADX     g_a12_adx;
double g_a12_tick_size=0.0,g_a12_effective_brick=0.0;

// A15 state
CA15RenkoBuilder g_a15_renko;
CA15EntryModule  g_a15_entry;

void ClearPosition()
  {
   g_position.is_open=false; g_position.direction=0; g_position.entry_price=0.0;
   g_position.entry_time=0; g_position.volume=0.0;
  }

void ApplyDecision(const SMultiAlphaDecision &d)
  {
   if(d.action==ALPHA_ACTION_ENTRY)
     {
      g_position.is_open=true; g_position.direction=d.direction;
      g_position.entry_price=d.decision_price; g_position.entry_time=d.time;
      g_position.volume=0.01; g_entries++;
      PrintFormat("[MULTI_ALPHA_CORE_ENTRY] alpha=%d no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         (int)d.alpha_id,g_entries,TimeToString(d.time,TIME_DATE|TIME_SECONDS),
         d.time_msc,d.direction,d.decision_price,d.reason);
     }
   else if(d.action==ALPHA_ACTION_EXIT)
     {
      g_exits++;
      PrintFormat("[MULTI_ALPHA_CORE_EXIT] alpha=%d no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         (int)d.alpha_id,g_exits,TimeToString(d.time,TIME_DATE|TIME_SECONDS),
         d.time_msc,d.direction,d.decision_price,d.reason);
      ClearPosition(); g_cooldown=InpCooldownBricks;
     }
  }

void EmitExit(const SMultiAlphaMarket &m,const string reason,SMultiAlphaDecision &d)
  {
   MultiAlphaDecisionClear(d,InpAlpha);
   d.action=ALPHA_ACTION_EXIT; d.direction=g_position.direction; d.reason=reason;
   d.decision_price=(g_position.direction>0 ? m.bid : m.ask);
   d.time=m.time; d.time_msc=m.time_msc;
  }

string A12TickExit(const SMultiAlphaMarket &m)
  {
   if(!g_position.is_open) return "";
   const double px=(g_position.direction>0 ? m.bid : m.ask);
   const double move=g_position.direction*(px-g_position.entry_price);
   if(move>=InpA12TakeProfitBricks*g_a12_effective_brick) return "TP";
   if(move<=-InpA12StopLossBricks*g_a12_effective_brick) return "SL";
   if(InpA12MaxHoldMinutes>0 &&
      (long)(m.time-g_position.entry_time)>=(long)InpA12MaxHoldMinutes*60) return "TIME";
   return "";
  }

SA15ExitSnapshot A15Snapshot()
  {
   SA15ExitSnapshot s; s.is_open=g_position.is_open; s.direction=g_position.direction;
   s.entry_price=g_position.entry_price; s.entry_time=g_position.entry_time; return s;
  }
SA15ExitSettings A15Settings()
  {
   SA15ExitSettings s; s.brick_size=InpA15BrickSize;
   s.take_profit_bricks=InpA15TakeProfitBricks; s.stop_loss_bricks=InpA15StopLossBricks;
   s.max_hold_minutes=InpA15MaxHoldMinutes; return s;
  }

int InitA12()
  {
   if(InpA12BrickSize<=0.0 || InpA12ADXPeriod<2 || InpA12ADXPeriod>100 ||
      InpA12ADXThreshold<0.0 || InpA12MinDISeparation<0.0 ||
      InpA12EntryRunBricks<1 || InpA12TakeProfitBricks<=0.0 ||
      InpA12StopLossBricks<=0.0 || InpA12MaxHoldMinutes<0) return INIT_PARAMETERS_INCORRECT;
   g_a12_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(g_a12_tick_size<=0.0) return INIT_FAILED;
   const long units=(long)MathMax(1.0,MathRound(InpA12BrickSize/g_a12_tick_size));
   g_a12_effective_brick=(double)units*g_a12_tick_size;
   g_a12_renko.Init(g_a12_tick_size,units); g_a12_adx.Init(InpA12ADXPeriod);
   return INIT_SUCCEEDED;
  }

int InitA15()
  {
   if(InpA15BrickSize<=0.0 || InpA15TakeProfitBricks<=0.0 ||
      InpA15StopLossBricks<=0.0 || InpA15MaxHoldMinutes<0 ||
      InpA15DonchianPeriod<2 || InpA15DonchianPeriod>512 ||
      InpA15BreakoutBufferBricks<0.0 || InpA15EntryRunBricks<1)
      return INIT_PARAMETERS_INCORRECT;
   g_a15_renko.Init(InpA15BrickSize);
   g_a15_entry.Init(InpA15BrickSize,InpA15DonchianPeriod,
                   InpA15BreakoutBufferBricks,InpA15EntryRunBricks);
   return INIT_SUCCEEDED;
  }

int OnInit()
  {
   if(InpAlpha!=ALPHA_A12 && InpAlpha!=ALPHA_A15) return INIT_PARAMETERS_INCORRECT;
   if(InpCooldownBricks<0 || InpMaxSpreadFraction<0.0) return INIT_PARAMETERS_INCORRECT;
   ClearPosition(); g_cooldown=0; g_failed=false;
   g_ticks=0; g_bricks=0; g_raw=0; g_entries=0; g_exits=0; g_blocks=0; g_spread_blocks=0;
   const int rc=(InpAlpha==ALPHA_A12 ? InitA12() : InitA15());
   if(rc!=INIT_SUCCEEDED) return rc;
   PrintFormat("[MULTI_ALPHA_CORE_START] selected_alpha=%d cooldown=%d spread_fraction=%.4f NO_ORDERS=1",
      (int)InpAlpha,InpCooldownBricks,InpMaxSpreadFraction);
   return INIT_SUCCEEDED;
  }

void TickA12(const SMultiAlphaMarket &m)
  {
   bool closed=false; SMultiAlphaDecision d; MultiAlphaDecisionClear(d,ALPHA_A12);
   if(g_position.is_open)
     {
      const string r=A12TickExit(m);
      if(r!="") { EmitExit(m,r,d); ApplyDecision(d); closed=true; }
     }

   SRenkoBrick bricks[];
   const int n=g_a12_renko.PushPrice(m.bid,bricks);
   if(n<0) { g_failed=true; Print("[MULTI_ALPHA_CORE_ERROR] alpha=12 renko_builder_stopped NO_ORDERS=1"); return; }
   if(n==0) return;

   int final_signal=0,final_raw=0;
   for(int i=0;i<n;i++)
     {
      int raw=0;
      final_signal=A12_ProcessCompletedBrick(g_a12_adx,bricks[i],
         InpA12ADXThreshold,InpA12MinDISeparation,InpA12EntryRunBricks,raw);
      final_raw=raw; g_bricks++;
     }

   if(g_cooldown>0)
     {
      const int before=g_cooldown; g_cooldown-=n; if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[MULTI_ALPHA_CORE_COOLDOWN] alpha=12 time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         m.time_msc,before,n,g_cooldown);
     }

   if(g_position.is_open)
     {
      if(final_raw!=0 && final_raw==-g_position.direction)
        { EmitExit(m,"DI_FLIP",d); ApplyDecision(d); }
      return;
     }

   if(final_signal==0) return;
   g_raw++;
   if(closed || g_cooldown>0)
     {
      g_blocks++;
      PrintFormat("[MULTI_ALPHA_CORE_BLOCK] alpha=12 time_msc=%I64d signal=%d gate=%s cooldown=%d NO_ORDERS=1",
         m.time_msc,final_signal,(closed?"CLOSED_THIS_TICK":"COOLDOWN"),g_cooldown);
      return;
     }

   const double spread=m.ask-m.bid,limit=InpMaxSpreadFraction*g_a12_effective_brick;
   if(spread>limit) { g_blocks++; g_spread_blocks++; return; }

   MultiAlphaDecisionClear(d,ALPHA_A12); d.action=ALPHA_ACTION_ENTRY;
   d.direction=final_signal; d.reason="A12 ADX RENKO";
   d.decision_price=(final_signal>0?m.ask:m.bid); d.time=m.time; d.time_msc=m.time_msc;
   ApplyDecision(d);
  }

void TickA15(const SMultiAlphaMarket &m,const MqlTick &tick)
  {
   bool closed=false; SMultiAlphaDecision d; MultiAlphaDecisionClear(d,ALPHA_A15);
   if(g_position.is_open)
     {
      const string r=A15ExitPriceTimeDecision(A15Snapshot(),A15Settings(),tick,TimeCurrent());
      if(r!="") { EmitExit(m,r,d); ApplyDecision(d); closed=true; }
     }

   SA15Brick bricks[];
   const int n=g_a15_renko.PushPrice(m.bid,bricks);
   int final_signal=0;
   for(int i=0;i<n;i++) { final_signal=g_a15_entry.ProcessCompletedBrick(bricks[i]); g_bricks++; }
   if(n>0 && final_signal!=0) g_raw++;

   if(g_position.is_open && n>0)
     {
      const string r=A15ExitOppositeDecision(A15Snapshot(),final_signal);
      if(r!="") { EmitExit(m,r,d); ApplyDecision(d); closed=true; }
     }

   if(n>0 && g_cooldown>0)
     {
      const int before=g_cooldown; g_cooldown-=n; if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[MULTI_ALPHA_CORE_COOLDOWN] alpha=15 time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         m.time_msc,before,n,g_cooldown);
     }

   if(n==0 || g_position.is_open || closed || g_cooldown>0 || final_signal==0) return;
   const double spread=m.ask-m.bid,limit=InpMaxSpreadFraction*InpA15BrickSize;
   if(spread>limit) { g_blocks++; g_spread_blocks++; return; }

   MultiAlphaDecisionClear(d,ALPHA_A15); d.action=ALPHA_ACTION_ENTRY;
   d.direction=final_signal; d.reason="A15 DONCHIAN BREAKOUT";
   d.decision_price=(final_signal>0?m.ask:m.bid); d.time=m.time; d.time_msc=m.time_msc;
   ApplyDecision(d);
  }

void OnTick()
  {
   if(g_failed) return;
   MqlTick tick={}; if(!SymbolInfoTick(_Symbol,tick)) return;
   SMultiAlphaMarket m; m.time=tick.time; m.time_msc=tick.time_msc; m.bid=tick.bid; m.ask=tick.ask;
   if(!MultiAlphaMarketValid(m)) return;
   g_ticks++;
   if(InpAlpha==ALPHA_A12) TickA12(m); else TickA15(m,tick);
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[MULTI_ALPHA_CORE_SUMMARY] selected_alpha=%d ticks=%I64d bricks=%I64d raw=%I64d entries=%I64d exits=%I64d blocks=%I64d spread_blocks=%I64d open=%d cooldown=%d failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      (int)InpAlpha,g_ticks,g_bricks,g_raw,g_entries,g_exits,g_blocks,g_spread_blocks,
      (int)g_position.is_open,g_cooldown,(int)g_failed,reason);
  }
