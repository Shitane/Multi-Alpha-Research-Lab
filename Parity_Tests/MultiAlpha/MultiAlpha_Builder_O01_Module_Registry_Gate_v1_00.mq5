//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Module_Registry_Gate_v1_00.mq5           |
//| LB-01 registration bridge compile/runtime gate. NO ORDERS.        |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Module_Registry_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

int OnInit()
{
 CMultiAlphaBuilderModuleRegistry100 registry;
 registry.BuildVerifiedO01();

 string why="";
 bool e=registry.IsRegistered("BUILDER_E01",MA_BUILDER_CAP_ENTRY100);
 bool m=registry.IsRegistered("BUILDER_M01",MA_BUILDER_CAP_MANAGE100);
 bool x=registry.IsRegistered("BUILDER_X01",MA_BUILDER_CAP_EXIT100);
 bool f=registry.IsRegistered("BUILDER_O01_FULL",MA_BUILDER_CAP_FULL100);
 bool split=registry.ValidateSplit("BUILDER_E01","BUILDER_M01","BUILDER_X01",why);
 string split_reason=why;
 bool full=registry.ValidateFull("BUILDER_O01_FULL",why);
 string full_reason=why;

 // Fail-safe / no-silent-fallback checks.
 string bad_reason="";
 bool bad_role=!registry.IsRegistered("BUILDER_E01",MA_BUILDER_CAP_EXIT100);
 bool unknown=!registry.ValidateFull("BUILDER_UNKNOWN",bad_reason);

 int pass=(e?1:0)+(m?1:0)+(x?1:0)+(f?1:0)+(split?1:0)+(full?1:0)+(bad_role?1:0)+(unknown?1:0);

 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 MODULE REGISTRY GATE / NO ORDERS");
 Print("1 BUILDER_E01 ENTRY ",(e?"PASS":"FAIL"));
 Print("2 BUILDER_M01 MANAGE ",(m?"PASS":"FAIL"));
 Print("3 BUILDER_X01 EXIT ",(x?"PASS":"FAIL"));
 Print("4 BUILDER_O01_FULL FULL ",(f?"PASS":"FAIL"));
 Print("5 SPLIT ROUTE ",(split?"PASS":"FAIL")," reason=",split_reason);
 Print("6 FULL ROUTE ",(full?"PASS":"FAIL")," reason=",full_reason);
 Print("7 WRONG ROLE REJECT ",(bad_role?"PASS":"FAIL"));
 Print("8 UNKNOWN MODULE REJECT ",(unknown?"PASS":"FAIL")," reason=",bad_reason);
 Print("TOTAL ",pass,"/8");
 Print(pass==8 ? "RESULT: PASS - O01 Builder module registry bridge (8/8)"
               : "RESULT: FAIL - O01 Builder module registry bridge");
 Print("NO ORDERS / VIRTUAL NOT FILL");
 Print("============================================================");

 return pass==8 ? INIT_SUCCEEDED : INIT_FAILED;
}

void OnTick(){}
