//+------------------------------------------------------------------+
//| A11_Entry_Exit_Parity_NoOrders_v1_00.mq5                         |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#property description "A11 split Entry/Exit parity harness - NO ORDERS"
#include "..\..\Include\A11_Entry_Module_v1_00.mqh"
#include "..\..\Include\A11_Exit_Module_v1_00.mqh"

input ENUM_MA_METHOD mode_ma=MODE_EMA;
input int period_ma_fast=100;
input int period_ma_slow=200;
input bool use_ma_filter=false;
input ENUM_MA_METHOD mode_ma_filter=MODE_SMA;
input ENUM_TIMEFRAMES timeframe_ma_filter=PERIOD_D1;
input int period_ma_filter=100;
input double takeProfit=0.0;
input double stopLoss=0.0;
input bool useFastMAexit=false;
input double maxLotSize=0.1;
input double minEquity=100.0;
input int MagicNumber=889;

CA11Entry a11_entry;
CA11Exit a11_exit;
bool v_open=false;
ENUM_POSITION_TYPE v_type=POSITION_TYPE_BUY;
long ticks=0,newbars=0,raw=0,entries=0,exits=0;

void ExitVirtual(const ENUM_A11_EXIT_REASON why)
{
 double p=(v_type==POSITION_TYPE_BUY?SymbolInfoDouble(_Symbol,SYMBOL_BID):SymbolInfoDouble(_Symbol,SYMBOL_ASK));
 exits++;
 PrintFormat("[A11_SPLIT_EXIT] no=%I64d reason=%s dir=%s price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
             exits,a11_exit.ReasonText(why),(v_type==POSITION_TYPE_BUY?"BUY":"SELL"),p);
 v_open=false;
}

void ProcessSignal(const int sig)
{
 ENUM_POSITION_TYPE want=(sig==ORDER_TYPE_BUY?POSITION_TYPE_BUY:POSITION_TYPE_SELL);
 bool same=(v_open && v_type==want);
 ENUM_A11_EXIT_REASON why=a11_exit.OnSignal(v_open,v_type,sig);
 if(why!=A11_EXIT_NONE) ExitVirtual(why);
 if(!same)
 {
  double p=(sig==ORDER_TYPE_BUY?SymbolInfoDouble(_Symbol,SYMBOL_ASK):SymbolInfoDouble(_Symbol,SYMBOL_BID));
  v_open=true;v_type=want;entries++;
  PrintFormat("[A11_SPLIT_ENTRY] no=%I64d dir=%s price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
              entries,(sig==ORDER_TYPE_BUY?"BUY":"SELL"),p);
 }
}

int OnInit()
{
 if(period_ma_fast>=period_ma_slow || period_ma_fast<1 || period_ma_slow<1) return INIT_PARAMETERS_INCORRECT;
 if(takeProfit<0 || stopLoss<0 || maxLotSize<0.01 || minEquity<10) return INIT_PARAMETERS_INCORRECT;
 if(!a11_entry.Init(period_ma_fast,period_ma_slow,mode_ma,use_ma_filter,mode_ma_filter,timeframe_ma_filter,period_ma_filter)) return INIT_FAILED;
 Print("[A11_SPLIT_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}

void OnTick()
{
 ticks++;
 if(!a11_entry.Prepare()) return;
 if(AccountInfoDouble(ACCOUNT_EQUITY)<minEquity) return;
 if(!a11_entry.IsNewBar()) return;
 newbars++;
 int sig=a11_entry.Signal();
 if(sig==-1)
 {
  ENUM_A11_EXIT_REASON why=a11_exit.OnNoSignal(useFastMAexit,v_open,v_type,a11_entry.ClosedPrice(),a11_entry.FastClosed());
  if(why!=A11_EXIT_NONE) ExitVirtual(why);
  return;
 }
 raw++;
 ProcessSignal(sig);
}

void OnDeinit(const int reason)
{
 PrintFormat("[A11_SPLIT_PARITY_SUMMARY] ticks=%I64d newbars=%I64d raw=%I64d entries=%I64d exits=%I64d open=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
             ticks,newbars,raw,entries,exits,(int)v_open,reason);
 a11_entry.Release();
}
//+------------------------------------------------------------------+
