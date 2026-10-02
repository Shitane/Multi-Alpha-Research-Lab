//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Runtime_Route_Gate_v1_00.mq5             |
//| LB-01 runtime route recognition gate. NO ORDERS / NO tick eval.  |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Runtime_Route_Bridge_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

int OnInit()
{
 CMultiAlphaBuilderRuntimeRouteBridge100 bridge;
 SMA_BuilderRuntimeRoute100 r={};

 bool f=bridge.SelectFull("BUILDER_O01_FULL",r) && bridge.IsReady(r) &&
        r.route==MA_BUILDER_RUNTIME_ROUTE_O01_FULL100;
 string fr=r.reason;

 bool s=bridge.SelectSplit("BUILDER_E01","BUILDER_M01","BUILDER_X01",r) &&
        bridge.IsReady(r) && r.route==MA_BUILDER_RUNTIME_ROUTE_O01_SPLIT100;
 string sr=r.reason;

 bool uf=!bridge.SelectFull("BUILDER_UNKNOWN",r) && !bridge.IsReady(r);
 string ufr=r.reason;

 bool wr=!bridge.SelectSplit("BUILDER_X01","BUILDER_M01","BUILDER_E01",r) && !bridge.IsReady(r);
 string wrr=r.reason;

 int pass=(f?1:0)+(s?1:0)+(uf?1:0)+(wr?1:0);

 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 RUNTIME ROUTE GATE / NO ORDERS");
 Print("1 FULL BUILDER_O01_FULL ",(f?"PASS":"FAIL")," reason=",fr);
 Print("2 SPLIT E01/M01/X01 ",(s?"PASS":"FAIL")," reason=",sr);
 Print("3 UNKNOWN FULL REJECT ",(uf?"PASS":"FAIL")," reason=",ufr);
 Print("4 WRONG SPLIT ROLE REJECT ",(wr?"PASS":"FAIL")," reason=",wrr);
 Print("TOTAL ",pass,"/4");
 Print(pass==4 ? "RESULT: PASS - O01 Builder runtime route recognition (4/4)"
               : "RESULT: FAIL - O01 Builder runtime route recognition");
 Print("NO ORDERS / VIRTUAL NOT FILL / BUILDER EVALUATION NOT YET CONNECTED");
 Print("============================================================");
 return pass==4 ? INIT_SUCCEEDED : INIT_FAILED;
}
void OnTick(){}
