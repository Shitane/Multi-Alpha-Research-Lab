//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Entry_Parity_NoOrders_v1_01.mq5                   |
//| Entry-decision parity observer. NO ORDERS.                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"
#include "..\..\Include\O01\O01_GSG_RSI30_Entry_Module_v1_00.mqh"

input int    InpRSIPeriod=8;
input double InpRSILower=30.0;
input double InpRSIUpper=70.0;
input int    InpATR1Period=15;
input int    InpATR2Period=15;
input double InpATR1MinPoints=0.0;
input double InpATR1MaxPoints=10000.0;
input double InpATR2MinPoints=0.0;
input double InpATR2MaxPoints=10000.0;
input bool   InpNewCycles=true;
input bool   InpTradeBuy=true;
input bool   InpTradeSell=true;

// IMPORTANT: v1.01 observes the proven decision ordering.
// Session/news/spread are supplied as explicit gates until their exact
// monolithic helper bodies are extracted into dedicated parity adapters.
input bool InpParityTimeAllowed=true;
input bool InpParityNewsBlocked=false;
input bool InpParitySpreadOK=true;
input bool InpParityEmergencyLock=false;

CO01EntryModule g_entry;
int g_rsi=INVALID_HANDLE,g_atr1=INVALID_HANDLE,g_atr2=INVALID_HANDLE;
ulong g_ticks=0,g_raw_buy=0,g_raw_sell=0,g_signal_buy=0,g_signal_sell=0,g_blocks=0,g_indicator_not_ready=0;

double Buf(const int h,const int shift=0)
  {
   double b[1];
   if(h==INVALID_HANDLE || CopyBuffer(h,0,shift,1,b)!=1) return EMPTY_VALUE;
   return b[0];
  }

int OnInit()
  {
   // These handles are intentionally local parity instrumentation.
   // Do not declare full parity until their construction is checked
   // against the frozen monolithic O01 source.
   g_rsi=iRSI(_Symbol,PERIOD_CURRENT,InpRSIPeriod,PRICE_CLOSE);
   g_atr1=iATR(_Symbol,PERIOD_CURRENT,InpATR1Period);
   g_atr2=iATR(_Symbol,PERIOD_CURRENT,InpATR2Period);
   if(g_rsi==INVALID_HANDLE || g_atr1==INVALID_HANDLE || g_atr2==INVALID_HANDLE)
     {
      Print("[O01_ENTRY_PARITY_INIT_FAIL] indicator_handle NO_ORDERS=1");
      return INIT_FAILED;
     }
   Print("[O01_ENTRY_PARITY_START] version=1.01 NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         " RSI=",InpRSIPeriod," ",DoubleToString(InpRSILower,2),"/",DoubleToString(InpRSIUpper,2),
         " ATR=",InpATR1Period,"/",InpATR2Period,
         " EXTERNAL_GATES=time,news,spread,emergency");
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   if(g_rsi!=INVALID_HANDLE) IndicatorRelease(g_rsi);
   if(g_atr1!=INVALID_HANDLE) IndicatorRelease(g_atr1);
   if(g_atr2!=INVALID_HANDLE) IndicatorRelease(g_atr2);
   Print("[O01_ENTRY_SUMMARY] ticks=",g_ticks,
         " raw_buy=",g_raw_buy," raw_sell=",g_raw_sell,
         " signal_buy=",g_signal_buy," signal_sell=",g_signal_sell,
         " blocks=",g_blocks," indicator_not_ready=",g_indicator_not_ready,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }

void OnTick()
  {
   g_ticks++;
   double rsi=Buf(g_rsi,0),a1=Buf(g_atr1,0),a2=Buf(g_atr2,0);
   if(rsi==EMPTY_VALUE || a1==EMPTY_VALUE || a2==EMPTY_VALUE)
     { g_indicator_not_ready++; return; }

   const double p1=a1/_Point,p2=a2/_Point;
   const bool filters_ok=(p1>=InpATR1MinPoints && p1<=InpATR1MaxPoints &&
                          p2>=InpATR2MinPoints && p2<=InpATR2MaxPoints);
   if(rsi<InpRSILower) g_raw_buy++;
   if(rsi>InpRSIUpper) g_raw_sell++;

   SO01EntryConfig c;
   c.new_cycles=InpNewCycles; c.trade_buy=InpTradeBuy; c.trade_sell=InpTradeSell;
   c.rsi_lower=InpRSILower; c.rsi_upper=InpRSIUpper;
   SO01EntryContext x;
   x.emergency_lock=InpParityEmergencyLock;
   x.time_allowed=InpParityTimeAllowed;
   x.news_blocked=InpParityNewsBlocked;
   x.spread_ok=InpParitySpreadOK;
   x.filters_ok=filters_ok;
   // Entry-only observer has no virtual lifecycle yet; zero means initial-entry eligibility.
   x.buy_count=0; x.sell_count=0; x.rsi=rsi;

   ENUM_O01_ENTRY_SIGNAL s=g_entry.Evaluate(c,x);
   if(s==O01_ENTRY_NONE)
     {
      if((rsi<InpRSILower || rsi>InpRSIUpper) &&
         (!InpNewCycles || x.emergency_lock || !x.time_allowed || x.news_blocked || !x.spread_ok || !x.filters_ok))
        {
         g_blocks++;
         Print("[O01_ENTRY_BLOCK] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
               " rsi=",DoubleToString(rsi,6)," atr_pts=",DoubleToString(p1,2),"/",DoubleToString(p2,2),
               " time=",(int)x.time_allowed," news=",(int)x.news_blocked," spread=",(int)x.spread_ok,
               " filters=",(int)x.filters_ok," emergency=",(int)x.emergency_lock," NO_ORDERS=1");
        }
      return;
     }

   string side=(s==O01_ENTRY_BUY ? "BUY" : "SELL");
   if(s==O01_ENTRY_BUY) g_signal_buy++; else g_signal_sell++;
   Print("[O01_ENTRY_SIGNAL] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
         " side=",side," rsi=",DoubleToString(rsi,6),
         " atr_pts=",DoubleToString(p1,2),"/",DoubleToString(p2,2),
         " bid=",DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits),
         " ask=",DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits),
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }
