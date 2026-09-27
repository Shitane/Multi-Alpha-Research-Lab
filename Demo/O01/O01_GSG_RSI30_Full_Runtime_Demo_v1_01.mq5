//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Full_Runtime_Demo_v1_01.mq5                       |
//| Dedicated DEMO host for frozen O01 FULL whole-path logic.        |
//| DEMO ACCOUNT ONLY. Separate from NO_ORDERS parity hosts.         |
//+------------------------------------------------------------------+
#property strict
#property version   "1.01"
#property description "O01 FULL runtime demo host - DEMO ACCOUNT ONLY"
#property description "Required instance Magic = 46102031"

#include <Original_Logic/O01_GSG_RSI30_Monolithic_Module_v1_00.mqh>

#define O01_FULL_DEMO_MAGIC 46102031

int OnInit()
{
   // The included frozen O01 module already hard-locks ACCOUNT_TRADE_MODE_DEMO
   // and requires a hedging account. This host adds instance isolation.
   if(InpMagic!=O01_FULL_DEMO_MAGIC)
   {
      Print("[O01_DEMO_FULL101_BLOCK] wrong Magic. Set InpMagic=",O01_FULL_DEMO_MAGIC,
            " (current=",InpMagic,"). Initialization stopped to prevent collision with Original O01.");
      return INIT_PARAMETERS_INCORRECT;
   }

   Print("[O01_DEMO_FULL101_START] structure=FULL magic=",InpMagic,
         " execution=REAL_DEMO_ONLY source=FROZEN_O01_WHOLE_PATH");
   return O01_OnInit();
}

void OnDeinit(const int reason)
{
   O01_OnDeinit(reason);
   Print("[O01_DEMO_FULL101_STOP] structure=FULL magic=",InpMagic," reason=",reason);
}

void OnTick()
{
   O01_OnTick();
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   O01_OnChartEvent(id,lparam,dparam,sparam);
}
