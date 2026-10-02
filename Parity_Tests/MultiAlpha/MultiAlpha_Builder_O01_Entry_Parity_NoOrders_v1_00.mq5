//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Entry_Parity_NoOrders_v1_00.mq5          |
//| Standalone LB-01 compile/runtime gate for O01 ENTRY parity.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include "..\\..\\Modules\\Builder\\MultiAlpha_Builder_O01_Entry_Parity_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

CMultiAlphaBuilderO01EntryParity100 g_parity;

int OnInit()
{
 string report="";
 bool ok=g_parity.RunAll(report);

 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 ENTRY PARITY / NO ORDERS");
 Print(report);
 Print(ok ? "RESULT: PASS - O01 ENTRY reference == Builder (16/16)"
          : "RESULT: FAIL - inspect case report");
 Print("NO ORDERS / VIRTUAL NOT FILL");
 Print("============================================================");

 Comment("MULTI ALPHA / LOGIC BUILDER\n",
         "O01 ENTRY PARITY\n",
         ok ? "PASS 16/16" : "FAIL - see Experts log",
         "\nNO ORDERS / VIRTUAL NOT FILL");

 return ok ? INIT_SUCCEEDED : INIT_FAILED;
}

void OnDeinit(const int reason)
{
 Comment("");
}

void OnTick()
{
 // Deliberately empty. This gate compares deterministic decision cases only.
 // It cannot send, modify, or close broker orders.
}
