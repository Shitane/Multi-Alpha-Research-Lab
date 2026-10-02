//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Full_Parity_NoOrders_v1_00.mq5           |
//| Standalone LB-01 integration gate for O01 Builder FULL parity.    |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

// Parity_Tests/MultiAlpha is deployed below MQL5/Experts.
// Runtime modules are deployed below MQL5/Include.
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Full_Parity_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

CMultiAlphaBuilderO01FullParity100 g_parity;

int OnInit()
{
 string report="";
 bool ok=g_parity.RunAll(report);

 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 FULL INTEGRATION / NO ORDERS");
 Print(report);
 Print(ok ? "RESULT: PASS - O01 BUILDER FULL integration gate (54/54)"
          : "RESULT: FAIL - O01 BUILDER FULL integration mismatch");
 Print("NO ORDERS / VIRTUAL NOT FILL");
 Print("============================================================");

 return ok ? INIT_SUCCEEDED : INIT_FAILED;
}

void OnTick(){}
