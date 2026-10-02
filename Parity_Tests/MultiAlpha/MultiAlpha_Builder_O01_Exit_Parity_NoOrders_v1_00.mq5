//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Exit_Parity_NoOrders_v1_00.mq5           |
//| Standalone LB-01 compile/runtime gate for O01 EXIT parity.        |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

// Parity_Tests/MultiAlpha is deployed below MQL5/Experts.
// Runtime modules are deployed below MQL5/Include.
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Exit_Parity_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

CMultiAlphaBuilderO01ExitParity100 g_parity;

int OnInit()
{
 string report="";
 bool ok=g_parity.RunAll(report);

 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 EXIT PARITY / NO ORDERS");
 Print(report);
 Print(ok ? "RESULT: PASS - O01 EXIT reference == Builder (20/20)"
          : "RESULT: FAIL - O01 EXIT parity mismatch");
 Print("NO ORDERS / VIRTUAL NOT FILL");
 Print("============================================================");

 return ok ? INIT_SUCCEEDED : INIT_FAILED;
}

void OnTick(){}
