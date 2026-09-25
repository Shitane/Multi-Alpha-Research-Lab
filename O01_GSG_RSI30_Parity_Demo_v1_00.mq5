//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Parity_Demo_v1_00.mq5                             |
//| Demo execution host for Original Logic O01.                      |
//| IMPORTANT: DEMO ACCOUNT ONLY (enforced inside O01 module).       |
//+------------------------------------------------------------------+
#property strict
#property version   "1.00"
#property description "O01 parity demo host for GSG v4 Experimental 03 RSI30"

#include "..\Include\Original_Logic\O01_GSG_RSI30_Monolithic_Module_v1_00.mqh"

int OnInit() { return O01_OnInit(); }
void OnDeinit(const int reason) { O01_OnDeinit(reason); }
void OnTick() { O01_OnTick(); }
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   O01_OnChartEvent(id,lparam,dparam,sparam);
}
