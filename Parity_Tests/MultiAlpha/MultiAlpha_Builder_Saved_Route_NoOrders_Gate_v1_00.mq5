//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Route_NoOrders_Gate_v1_00.mq5          |
//| Loads the exact Builder SAVE24 files as ENTRY/MANAGE/EXIT route. |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Definition_Route_v1_00.mqh"

input string InpEntryName="BUILDER_E01";
input string InpManageName="BUILDER_M01";
input string InpExitName="BUILDER_X01";

CMultiAlphaBuilderSavedDefinitionRoute100 g_route;

int OnInit()
{
 SMA_BuilderSavedDefinition100 e={},m={},x={};
 string reason="";
 bool ok=g_route.LoadRoute(InpEntryName,InpManageName,InpExitName,e,m,x,reason);
 Print("============================================================");
 Print("MULTI ALPHA / SAVED BUILDER ROUTE GATE v1.00");
 Print("ENTRY  name=",InpEntryName," loaded=",(int)e.loaded," valid=",(int)e.valid," reason=",e.reason);
 Print("ENTRY  expression=",e.expression);
 Print("MANAGE name=",InpManageName," loaded=",(int)m.loaded," valid=",(int)m.valid," reason=",m.reason);
 Print("MANAGE expression=",m.expression);
 Print("EXIT   name=",InpExitName," loaded=",(int)x.loaded," valid=",(int)x.valid," reason=",x.reason);
 Print("EXIT   expression=",x.expression);
 Print("ROUTE  ready=",(int)ok," reason=",reason);
 Print(ok?"RESULT: PASS - saved ENTRY/MANAGE/EXIT Builder route is READY":
          "RESULT: FAIL - saved Builder route is NOT READY");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 Print("============================================================");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
