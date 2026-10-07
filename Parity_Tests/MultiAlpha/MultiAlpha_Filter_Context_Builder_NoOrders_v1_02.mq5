//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Context_Builder_NoOrders_v1_02.mq5            |
//| B-P0-2D deterministic Builder-owned filter context test.         |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.02"
#include "../../../Include/Builder/MultiAlpha_Builder_Part_Schema_v1_04.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Filter_Context_v1_01.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Interpreter_v1_05.mqh"

bool RunCase102(const bool filter_ok,const bool signal_ok,const bool expect_buy,string &why)
{
 string parts[]={"FILTER_NEW_OK","AND","RSI_THRESHOLD","AND","BUY"};
 bool cv[];ArrayResize(cv,ArraySize(parts));for(int i=0;i<ArraySize(cv);i++)cv[i]=true;

 SMA_BuilderFilterContext101 fc;
 MABuilderFilterContextDefaults101(fc);
 MABuilderFilterContextSet101(filter_ok,true,filter_ok?"":"TEST_FILTER_BLOCK","",fc);

 bool fv=false;string fr="";
 if(!MABuilderFilterPartValue101(parts[0],fc,fv,fr)){why="filter context lookup";return false;}
 cv[0]=fv;cv[2]=signal_ok;

 CMultiAlphaBuilderInterpreter105 it;bool buy=false,sell=false;string trace="",reason="";
 if(!it.EvaluateEntry40(parts,cv,buy,sell,trace,reason)){why="interpreter "+reason;return false;}
 if(buy!=expect_buy||sell){why="decision "+trace;return false;}
 why=trace+(fr==""?"":" filter_reason="+fr);return true;
}
int OnInit()
{
 string r="",sr="";
 if(!MA104ValidatePart(MA_BUILDER_ROLE_ENTRY101,"FILTER_NEW_OK","",sr)){Print("[MA_FILTERCTX102_FAIL] schema ENTRY ",sr);return INIT_FAILED;}
 if(!MA104ValidatePart(MA_BUILDER_ROLE_GRID101,"FILTER_ADD_OK","",sr)){Print("[MA_FILTERCTX102_FAIL] schema GRID ",sr);return INIT_FAILED;}
 if(MA104ValidatePart(MA_BUILDER_ROLE_ENTRY101,"FILTER_NEW_OK","START=10",sr)){Print("[MA_FILTERCTX102_FAIL] duplicate params accepted");return INIT_FAILED;}

 if(!RunCase102(true,true,true,r)){Print("[MA_FILTERCTX102_FAIL] case=PASS_FILTER ",r);return INIT_FAILED;}
 Print("[MA_FILTERCTX102_CASE] filter=1 signal=1 BUY=1 ",r);
 if(!RunCase102(false,true,false,r)){Print("[MA_FILTERCTX102_FAIL] case=BLOCK_FILTER ",r);return INIT_FAILED;}
 Print("[MA_FILTERCTX102_CASE] filter=0 signal=1 BUY=0 ",r);
 if(!RunCase102(true,false,false,r)){Print("[MA_FILTERCTX102_FAIL] case=BLOCK_SIGNAL ",r);return INIT_FAILED;}
 Print("[MA_FILTERCTX102_CASE] filter=1 signal=0 BUY=0 ",r);

 Print("[MA_FILTERCTX102_PASS] schema=PASS context=PASS interpreter=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
