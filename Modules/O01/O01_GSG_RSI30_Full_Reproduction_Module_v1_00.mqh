//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Full_Reproduction_Module_v1_00.mqh                |
//| O01 whole-logic compatibility layer.                             |
//| Keeps the already parity-tested monolithic implementation frozen.|
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_FULL_REPRODUCTION_MODULE_V1_00_MQH
#define O01_GSG_RSI30_FULL_REPRODUCTION_MODULE_V1_00_MQH

#include <Original_Logic/O01_GSG_RSI30_Monolithic_Module_v1_00.mqh>

class CO01FullReproductionModule
  {
public:
   int OnInit() { return O01_OnInit(); }
   void OnDeinit(const int reason) { O01_OnDeinit(reason); }
   void OnTick() { O01_OnTick(); }
   void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
     { O01_OnChartEvent(id,lparam,dparam,sparam); }
  };

#endif
