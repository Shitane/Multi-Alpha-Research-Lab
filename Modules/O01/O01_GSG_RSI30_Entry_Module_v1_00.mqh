//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Entry_Module_v1_00.mqh                            |
//| Decision-only extraction of O01 initial-entry gates.             |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_ENTRY_MODULE_V1_00_MQH
#define O01_GSG_RSI30_ENTRY_MODULE_V1_00_MQH

enum ENUM_O01_ENTRY_SIGNAL { O01_ENTRY_NONE=0, O01_ENTRY_BUY=1, O01_ENTRY_SELL=-1 };

struct SO01EntryConfig
  {
   bool new_cycles,trade_buy,trade_sell;
   double rsi_lower,rsi_upper;
  };

struct SO01EntryContext
  {
   bool emergency_lock,time_allowed,news_blocked,spread_ok,filters_ok;
   int buy_count,sell_count;
   double rsi;
  };

class CO01EntryModule
  {
public:
   ENUM_O01_ENTRY_SIGNAL Evaluate(const SO01EntryConfig &c,const SO01EntryContext &x) const
     {
      if(!c.new_cycles || x.emergency_lock || !x.time_allowed || x.news_blocked || !x.spread_ok || !x.filters_ok)
         return O01_ENTRY_NONE;
      if(c.trade_buy && x.buy_count==0 && x.rsi<c.rsi_lower) return O01_ENTRY_BUY;
      if(c.trade_sell && x.sell_count==0 && x.rsi>c.rsi_upper) return O01_ENTRY_SELL;
      return O01_ENTRY_NONE;
     }
  };

#endif
