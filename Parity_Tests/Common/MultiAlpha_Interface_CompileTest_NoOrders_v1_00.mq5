//+------------------------------------------------------------------+
//| MultiAlpha_Interface_CompileTest_NoOrders_v1_00.mq5             |
//| Compile/smoke test for the common Multi Alpha interface.         |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#include "..\..\Include\MultiAlpha_Interface_v1_00.mqh"

input ENUM_MULTI_ALPHA_ID InpAlpha=ALPHA_A15;

long g_ticks=0;
long g_valid=0;

int OnInit()
  {
   PrintFormat("[MULTI_ALPHA_INTERFACE_START] selected_alpha=%d NO_ORDERS=1",(int)InpAlpha);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick)) return;
   g_ticks++;

   SMultiAlphaMarket market;
   market.time=tick.time;
   market.time_msc=tick.time_msc;
   market.bid=tick.bid;
   market.ask=tick.ask;
   if(!MultiAlphaMarketValid(market)) return;
   g_valid++;

   SMultiAlphaPosition position;
   position.is_open=false;
   position.direction=0;
   position.entry_price=0.0;
   position.entry_time=0;
   position.volume=0.0;

   SMultiAlphaDecision decision;
   MultiAlphaDecisionClear(decision,InpAlpha);

   // Compile-time contract check only. No A12/A15 logic is changed here.
   if(decision.action!=ALPHA_ACTION_NONE)
      Print("[MULTI_ALPHA_INTERFACE_ERROR] unexpected_action NO_ORDERS=1");
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[MULTI_ALPHA_INTERFACE_SUMMARY] selected_alpha=%d ticks=%I64d valid=%I64d NO_ORDERS=1",
      (int)InpAlpha,g_ticks,g_valid);
  }
