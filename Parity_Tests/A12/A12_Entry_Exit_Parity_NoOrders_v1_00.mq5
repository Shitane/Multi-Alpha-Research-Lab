//+------------------------------------------------------------------+
//| A12_Entry_Exit_Parity_NoOrders_v1_00.mq5                        |
//| A12 separated Entry/Exit parity harness. Research only.          |
//| NO ORDERS: virtual lifecycle only.                               |
//+------------------------------------------------------------------+
#property strict

#include "..\..\Include\A12_Entry_Module.mqh"
#include "..\..\Include\A12_Exit_Module_v1_00.mqh"

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

CRenkoBuilder  g_renko;
CRenkoADX      g_adx;
CA12ExitModule g_exit;

double g_tick_size=0.0,g_brick=0.0;
bool g_open=false,g_failed=false;
int g_dir=0,g_cooldown=0;
double g_entry_price=0.0;
datetime g_entry_time=0;
long g_ticks=0,g_bricks=0,g_raw=0,g_entries=0,g_exits=0,g_blocks=0,g_spread_blocks=0;

void CloseVirtual(const MqlTick &tick,const ENUM_A12_EXIT_REASON why)
  {
   const double px=(g_dir>0 ? tick.bid : tick.ask);
   g_exits++;
   PrintFormat("[A12_SPLIT_EXIT] no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      g_exits,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,g_dir,px,g_exit.ReasonText(why));
   g_open=false; g_dir=0; g_entry_price=0.0; g_entry_time=0;
   g_cooldown=InpCooldownBricks;
  }

void OpenVirtual(const MqlTick &tick,const int direction)
  {
   g_open=true; g_dir=direction;
   g_entry_price=(direction>0 ? tick.ask : tick.bid);
   g_entry_time=tick.time; g_entries++;
   PrintFormat("[A12_SPLIT_ENTRY] no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=A12 ADX RENKO NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      g_entries,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,direction,g_entry_price);
  }

int OnInit()
  {
   if(InpBrickSize<=0.0 || InpADXPeriod<2 || InpADXPeriod>100 ||
      InpADXThreshold<0.0 || InpMinDISeparation<0.0 || InpEntryRunBricks<1 ||
      InpTakeProfitBricks<=0.0 || InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 || InpCooldownBricks<0 || InpMaxSpreadFraction<0.0)
      return INIT_PARAMETERS_INCORRECT;

   g_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(g_tick_size<=0.0) return INIT_FAILED;
   const long units=(long)MathMax(1.0,MathRound(InpBrickSize/g_tick_size));
   g_brick=(double)units*g_tick_size;
   g_renko.Init(g_tick_size,units);
   g_adx.Init(InpADXPeriod);
   if(!g_exit.Configure(g_brick,InpTakeProfitBricks,InpStopLossBricks,InpMaxHoldMinutes))
      return INIT_PARAMETERS_INCORRECT;

   g_open=false; g_failed=false; g_dir=0; g_cooldown=0;
   g_entry_price=0.0; g_entry_time=0;
   g_ticks=0; g_bricks=0; g_raw=0; g_entries=0; g_exits=0; g_blocks=0; g_spread_blocks=0;
   Print("[A12_SPLIT_PARITY_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   if(g_failed) return;
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || tick.bid<=0.0 || tick.ask<=0.0 || tick.ask<tick.bid) return;
   g_ticks++;

   bool closed=false;
   if(g_open)
     {
      const ENUM_A12_EXIT_REASON r=g_exit.TickDecision(
         g_open,g_dir,g_entry_price,g_entry_time,tick.bid,tick.ask,tick.time);
      if(r!=A12_EXIT_NONE) { CloseVirtual(tick,r); closed=true; }
     }

   SRenkoBrick bricks[];
   const int n=g_renko.PushPrice(tick.bid,bricks);
   if(n<0)
     {
      g_failed=true;
      Print("[A12_SPLIT_ERROR] renko_builder_stopped NO_ORDERS=1");
      return;
     }
   if(n==0) return;

   int final_signal=0,final_raw=0;
   for(int i=0;i<n;i++)
     {
      int raw=0;
      final_signal=A12_ProcessCompletedBrick(g_adx,bricks[i],
         InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,raw);
      final_raw=raw;
      g_bricks++;
     }

   if(g_cooldown>0)
     {
      const int before=g_cooldown;
      g_cooldown-=n; if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[A12_SPLIT_COOLDOWN] time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         tick.time_msc,before,n,g_cooldown);
     }

   if(g_open)
     {
      const ENUM_A12_EXIT_REASON r=g_exit.CompletedRenkoDecision(g_open,g_dir,final_raw);
      if(r!=A12_EXIT_NONE) CloseVirtual(tick,r);
      return;
     }

   if(final_signal==0) return;
   g_raw++;
   if(closed || g_cooldown>0)
     {
      g_blocks++;
      PrintFormat("[A12_SPLIT_BLOCK] time_msc=%I64d signal=%d gate=%s cooldown=%d NO_ORDERS=1",
         tick.time_msc,final_signal,(closed?"CLOSED_THIS_TICK":"COOLDOWN"),g_cooldown);
      return;
     }

   const double spread=tick.ask-tick.bid;
   const double limit=InpMaxSpreadFraction*g_brick;
   if(spread>limit) { g_blocks++; g_spread_blocks++; return; }
   OpenVirtual(tick,final_signal);
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[A12_SPLIT_PARITY_SUMMARY] ticks=%I64d bricks=%I64d raw=%I64d entries=%I64d exits=%I64d blocks=%I64d spread_blocks=%I64d open=%d cooldown=%d failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      g_ticks,g_bricks,g_raw,g_entries,g_exits,g_blocks,g_spread_blocks,(int)g_open,g_cooldown,(int)g_failed,reason);
  }
