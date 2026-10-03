//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Exit_Parity_Tester_v1_01.mq5               |
//| Persisted EXIT parity: trail OFF and trail ON are separate defs.  |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Exit_Module_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Exit_Action_Evaluator_v1_00.mqh"
input string InpTrailOnName="O01_EXIT_GENERIC_V1";
input string InpTrailOffName="O01_EXIT_FIXEDTP_GENERIC_V1";
CO01ExitModule g_ref;CMultiAlphaBuilderSavedExitActionEvaluator100 g_builder;
SMA_BuilderSavedDefinition100 g_on,g_off;int g_n=0,g_match=0,g_vsl=0,g_tp=0,g_single=0,g_basket=0;bool g_done=false;
bool SameState(const SO01TrailState&a,const SO01TrailState&b){return a.active==b.active&&MathAbs(a.peak_pts-b.peak_pts)<1e-9&&MathAbs(a.stop_pts-b.stop_pts)<1e-9&&a.position_count==b.position_count;}
bool LoadDef(const string name,SMA_BuilderSavedDefinition100 &d)
{
 string fn="MultiAlpha_Builder_EXIT_"+name+".csv";int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){Print("RESULT: FAIL - NOT FOUND: ",fn);return false;}
 string sig=FileReadString(h),ver=FileReadString(h);int role=(int)FileReadNumber(h),count=(int)FileReadNumber(h);if(sig!="MA_BUILDER_ROLE"||role!=2||count!=24){FileClose(h);Print("RESULT: FAIL - INVALID EXIT FILE: ",fn);return false;}
 d.role=2;d.name=name;d.loaded=true;d.valid=true;d.reason="READY";d.expression="";for(int i=0;i<24;i++){d.part[i]="EMPTY";d.param[i]="";}
 for(int i=0;i<24&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string p=FileReadString(h),a=FileReadString(h);if(no>=1&&no<=24){d.part[no-1]=p;d.param[no-1]=a;}}FileClose(h);return true;
}
void Eval(SMA_BuilderSavedDefinition100 &d,const bool trail,const int count,const double move,SO01TrailState &ra,SO01TrailState &rb)
{
 SO01ExitConfig c={};c.tp_points=110;c.sl_points=1500;c.trailing=trail;c.trail_start=80;c.trail_lock=20;c.trail_distance=40;c.trail_step=10;
 ENUM_O01_EXIT_DECISION a=g_ref.Evaluate(true,count,move,c,ra),b;string tr,why;if(!g_builder.Evaluate(d,true,count,move,rb,b,tr,why)){Print("RESULT: FAIL - ",why);g_done=true;return;}
 g_n++;if(a==b&&SameState(ra,rb))g_match++;else Print("[SAVED_EXIT_MISMATCH] n=",g_n," trail=",(trail?"ON":"OFF")," ref=",a," saved=",b," trace=",tr);
 if(a==O01_EXIT_VIRTUAL_SL)g_vsl++;if(a==O01_EXIT_FIXED_TP)g_tp++;if(a==O01_EXIT_SINGLE_TRAILING)g_single++;if(a==O01_EXIT_BASKET_TRAILING)g_basket++;
}
int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 if(!LoadDef(InpTrailOnName,g_on)||!LoadDef(InpTrailOffName,g_off))return INIT_FAILED;
 Print("O01 REFERENCE vs SAVED GENERIC BUILDER EXIT / TESTER v1.01");
 Print("TRAIL_ON=",InpTrailOnName," TRAIL_OFF=",InpTrailOffName);Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnTick()
{
 if(g_done)return;MqlTick q;if(!SymbolInfoTick(_Symbol,q))return;SO01TrailState ra={},rb={};
 Eval(g_off,false,1,-1600,ra,rb);ra.active=false;rb.active=false;Eval(g_off,false,1,120,ra,rb);if(g_done)return;
 ra.active=false;rb.active=false;Eval(g_on,true,1,-1600,ra,rb);ra.active=false;rb.active=false;Eval(g_on,true,1,100,ra,rb);Eval(g_on,true,1,50,ra,rb);if(g_done)return;
 ra.active=false;rb.active=false;Eval(g_on,true,2,100,ra,rb);Eval(g_on,true,2,50,ra,rb);if(g_done)return;
 if(g_n>=140){g_done=true;Print("TOTAL SAVED EXIT PARITY ",g_match,"/",g_n," VSL=",g_vsl," TP=",g_tp," SINGLE=",g_single," BASKET=",g_basket);bool ok=(g_match==g_n&&g_vsl>0&&g_tp>0&&g_single>0&&g_basket>0);Print(ok?"RESULT: PASS - O01 reference EXIT == persisted SAVE24 generic Builder EXIT (trail OFF/ON)":"RESULT: INCOMPLETE/FAIL - inspect counters");Print("SCOPE: two persisted SAVE24 EXIT definitions + generic EXIT evaluator + deterministic virtual trailing state + real tester ticks");Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");}
}
