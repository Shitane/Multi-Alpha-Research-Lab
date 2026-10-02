//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Manage_Parity_NoOrders_v1_01.mq5         |
//| Standalone LB-01 compile/runtime gate for O01 MANAGE parity.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"

// Parity_Tests/MultiAlpha is deployed below MQL5/Experts.
// Runtime modules are deployed below MQL5/Include.
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Manage_Parity_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

CMultiAlphaBuilderO01ManageParity100 g_parity;

int OnInit()
{
 string report="";
 bool ok=g_parity.RunAll(report);

 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 MANAGE PARITY / NO ORDERS");
 Print(report);
 Print(ok ? "RESULT: PASS - O01 MANAGE reference == Builder (18/18)"
          : "RESULT: FAIL - O01 MANAGE parity mismatch");
 Print("NO ORDERS / VIRTUAL NOT FILL");
 Print("============================================================");

 return ok ? INIT_SUCCEEDED : INIT_FAILED;
}

void OnTick(){}
