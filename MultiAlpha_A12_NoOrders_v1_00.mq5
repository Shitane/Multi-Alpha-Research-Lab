//+------------------------------------------------------------------+
//| MultiAlpha_A12_NoOrders_v1_00.mq5                               |
//| A12 connected to MultiAlpha_Interface_v1_00.                     |
//| Research-only modular Alpha adapter. NO ORDERS.                  |
//+------------------------------------------------------------------+
#property strict

#include "..\..\Include\MultiAlpha_Interface_v1_00.mqh"
#include "..\..\Include\A12_Entry_Module.mqh"

input double InpBrickSize=16.0;
input int    InpADXPeriod=14;
input double InpADXThreshold=8.5;
input double InpMinDISeparation=2.5;
input int    InpEntryRunBricks=3;
input double InpTakeProfitBricks=9.5;
input double InpStopLossBricks=42.0;
input int    InpMaxHoldMinutes=1060;
input int    InpCooldownBricks=6;
input double InpMaxSpreadFraction=0.35;

CRenkoBuilder g_renko;
CRenkoADX     g_adx;
SMultiAlphaPosition g_position;

double g_tick_size=0.0;
double g_effective_brick=0.0;
int g_cooldown=0;
bool g_failed=false;

long g_ticks=0,g_bricks=0,g_raw_candidates=0;
long g_entries=0,g_exits=0,g_blocks=0,g_spread_blocks=0;
long g_exit_tp=0,g_exit_sl=0,g_exit_time=0,g_exit_di_flip=0;

void ClearPosition()
  {
   g_position.is_open=false;
   g_position.direction=0;
   g_position.entry_price=0.0;
   g_position.entry_time=0;
   g_position.volume=0.0;
  }

string A12TickExitReason(const SMultiAlphaMarket &market)
  {
   if(!g_position.is_open) return "";
   const double executable=(g_position.direction>0 ? market.bid : market.ask);
   const double move=g_position.direction*(executable-g_position.entry_price);
   if(move>=InpTakeProfitBricks*g_effective_brick) return "TP";
   if(move<=-InpStopLossBricks*g_effective_brick) return "SL";
   if(InpMaxHoldMinutes>0 &&
      (long)(market.time-g_position.entry_time)>=(long)InpMaxHoldMinutes*60)
      return "TIME";
   return "";
  }

string A12BrickExitReason(const int raw_direction)
  {
   if(!g_position.is_open) return "";
   if(raw_direction!=0 && raw_direction==-g_position.direction) return "DI_FLIP";
   return "";
  }

void EmitExit(const SMultiAlphaMarket &market,const string reason,
              SMultiAlphaDecision &decision)
  {
   MultiAlphaDecisionClear(decision,ALPHA_A12);
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
      g_position.is_open=true;
      g_position.direction=decision.direction;
      g_position.entry_price=decision.decision_price;
      g_position.entry_time=decision.time;
      g_position.volume=0.01;
      g_entries++;
      PrintFormat("[MULTI_ALPHA_A12_ENTRY] no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s alpha=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         g_entries,TimeToString(decision.time,TIME_DATE|TIME_SECONDS),
         decision.time_msc,decision.direction,decision.decision_price,
         decision.reason,(int)decision.alpha_id);
     }
   else if(decision.action==ALPHA_ACTION_EXIT)
     {
      g_exits++;
      if(decision.reason=="TP") g_exit_tp++;
      else if(decision.reason=="SL") g_exit_sl++;
      else if(decision.reason=="TIME") g_exit_time++;
      else if(decision.reason=="DI_FLIP") g_exit_di_flip++;

      PrintFormat("[MULTI_ALPHA_A12_EXIT] no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s alpha=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         g_exits,TimeToString(decision.time,TIME_DATE|TIME_SECONDS),
         decision.time_msc,decision.direction,decision.decision_price,
         decision.reason,(int)decision.alpha_id);
      ClearPosition();
      g_cooldown=InpCooldownBricks;
     }
  }

int OnInit()
  {
   if(!MathIsValidNumber(InpBrickSize) || InpBrickSize<=0.0 ||
      InpADXPeriod<2 || InpADXPeriod>100 ||
      !MathIsValidNumber(InpADXThreshold) || InpADXThreshold<0.0 || InpADXThreshold>100.0 ||
      !MathIsValidNumber(InpMinDISeparation) || InpMinDISeparation<0.0 || InpMinDISeparation>100.0 ||
      InpEntryRunBricks<1 || InpEntryRunBricks>50 ||
      InpTakeProfitBricks<=0.0 || InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 || InpCooldownBricks<0 || InpMaxSpreadFraction<0.0)
      return INIT_PARAMETERS_INCORRECT;

   g_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(!MathIsValidNumber(g_tick_size) || g_tick_size<=0.0) return INIT_FAILED;

   const double raw_units=InpBrickSize/g_tick_size;
   if(!MathIsValidNumber(raw_units) || raw_units<0.5 || raw_units>1e9) return INIT_FAILED;
   const long units=(long)MathMax(1.0,MathRound(raw_units));
   g_effective_brick=(double)units*g_tick_size;

   g_renko.Init(g_tick_size,units);
   g_adx.Init(InpADXPeriod);
   ClearPosition();
   g_cooldown=0; g_failed=false;
   g_ticks=0; g_bricks=0; g_raw_candidates=0;
   g_entries=0; g_exits=0; g_blocks=0; g_spread_blocks=0;
   g_exit_tp=0; g_exit_sl=0; g_exit_time=0; g_exit_di_flip=0;

   PrintFormat("[MULTI_ALPHA_A12_START] alpha=%d brick_input=%.8f effective_brick=%.8f ADX_period=%d threshold=%.4f min_di=%.4f run=%d TP=%.4f SL=%.4f hold=%d cooldown=%d spread_fraction=%.4f NO_ORDERS=1",
      (int)ALPHA_A12,InpBrickSize,g_effective_brick,InpADXPeriod,
      InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,
      InpTakeProfitBricks,InpStopLossBricks,InpMaxHoldMinutes,
      InpCooldownBricks,InpMaxSpreadFraction);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   if(g_failed) return;

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
   MultiAlphaDecisionClear(decision,ALPHA_A12);

   // Original A12 sequence: tick TP/SL/TIME before Renko update.
   if(g_position.is_open)
     {
      const string reason=A12TickExitReason(market);
      if(reason!="")
        {
         EmitExit(market,reason,decision);
         ApplyDecision(decision);
         closed_this_tick=true;
        }
     }

   SRenkoBrick bricks[];
   const int n=g_renko.PushPrice(market.bid,bricks);
   if(n<0)
     {
      g_failed=true;
      Print("[MULTI_ALPHA_A12_ERROR] renko_builder_stopped NO_ORDERS=1");
      return;
     }
   if(n==0) return;

   int final_signal=0;
   int final_raw_direction=0;
   for(int i=0;i<n;i++)
     {
      int raw_direction=0;
      final_signal=A12_ProcessCompletedBrick(g_adx,bricks[i],
         InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,raw_direction);
      final_raw_direction=raw_direction;
      g_bricks++;
     }

   // Preserve original ordering: cooldown decrements before brick exit/entry gate.
   if(g_cooldown>0)
     {
      const int before=g_cooldown;
      g_cooldown-=n;
      if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[MULTI_ALPHA_A12_COOLDOWN] time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         market.time_msc,before,n,g_cooldown);
     }

   if(g_position.is_open)
     {
      const string reason=A12BrickExitReason(final_raw_direction);
      if(reason!="")
        {
         EmitExit(market,reason,decision);
         ApplyDecision(decision);
        }
      return;
     }

   // Original A12 uses only the final completed brick's signal on each tick.
   if(final_signal==0) return;
   g_raw_candidates++;

   string gate="ENTRY_CANDIDATE";
   if(closed_this_tick) gate="CLOSED_THIS_TICK";
   else if(g_cooldown>0) gate="COOLDOWN";

   if(gate!="ENTRY_CANDIDATE")
     {
      g_blocks++;
      PrintFormat("[MULTI_ALPHA_A12_ENTRY_BLOCK] time_msc=%I64d signal=%d gate=%s cooldown=%d NO_ORDERS=1",
         market.time_msc,final_signal,gate,g_cooldown);
      return;
     }

   const double spread=market.ask-market.bid;
   const double limit=InpMaxSpreadFraction*g_effective_brick;
   if(spread>limit)
     {
      g_blocks++; g_spread_blocks++;
      PrintFormat("[MULTI_ALPHA_A12_ENTRY_BLOCK] time_msc=%I64d signal=%d gate=SPREAD spread=%.8f limit=%.8f NO_ORDERS=1",
         market.time_msc,final_signal,spread,limit);
      return;
     }

   MultiAlphaDecisionClear(decision,ALPHA_A12);
   decision.action=ALPHA_ACTION_ENTRY;
   decision.direction=final_signal;
   decision.reason="A12 ADX RENKO";
   decision.decision_price=(final_signal>0 ? market.ask : market.bid);
   decision.time=market.time;
   decision.time_msc=market.time_msc;
   ApplyDecision(decision);
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[MULTI_ALPHA_A12_SUMMARY] alpha=%d ticks=%I64d bricks=%I64d raw_candidates=%I64d entries=%I64d exits=%I64d blocks=%I64d spread_blocks=%I64d open=%d cooldown=%d TP=%I64d SL=%I64d TIME=%I64d DI_FLIP=%I64d failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      (int)ALPHA_A12,g_ticks,g_bricks,g_raw_candidates,g_entries,g_exits,
      g_blocks,g_spread_blocks,(int)g_position.is_open,g_cooldown,
      g_exit_tp,g_exit_sl,g_exit_time,g_exit_di_flip,(int)g_failed,reason);
  }
