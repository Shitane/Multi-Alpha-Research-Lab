//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Full_Runtime_Demo_v1_00.mq5                       |
//| Dedicated DEMO execution host for the frozen O01 FULL logic.     |
//|                                                                  |
//| IMPORTANT                                                        |
//| - REAL ORDERS are possible, but O01_OnInit() enforces DEMO only. |
//| - Trading logic lives in the frozen monolithic O01 module.        |
//| - Do not merge this host into NoOrders parity/research hosts.     |
//| - Panel/settings refactoring must not alter the frozen logic.      |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "O01 FULL runtime demo host - DEMO ACCOUNT ONLY"
#property description "Frozen O01 trading logic; separate from NoOrders research hosts."

#include "..\\..\\O01_GSG_RSI30_Monolithic_Module_v1_00.mqh"

int OnInit()
{
   Print("[O01_DEMO_RUNTIME_START] host=1.00 mode=FULL execution=REAL_DEMO_ONLY");
   return O01_OnInit();
}

void OnDeinit(const int reason)
{
   O01_OnDeinit(reason);
   Print("[O01_DEMO_RUNTIME_STOP] host=1.00 reason=",reason);
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
