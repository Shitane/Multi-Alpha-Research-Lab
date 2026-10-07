//+------------------------------------------------------------------+
//| MultiAlpha_SavedRole_FilterRef_NoOrders_v1_00.mq5               |
//| B-P0-2G: saved ENTRY/GRID role -> Filter Context -> Interpreter. |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Filter_Context_v1_01.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Part_Schema_v1_04.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Interpreter_v1_05.mqh"

CMultiAlphaBuilderSlotWorkspaceStore103 g_slots;
CMultiAlphaBuilderInterpreter105 g_interpreter;
int g_fail=0;

void Check2G(const string name,const bool got,const bool expected)
{
 bool ok=(got==expected);
 Print("[MA_SAVED2G_CASE] ",name," ",(ok?"PASS":"FAIL")," got=",(got?1:0)," expected=",(expected?1:0));
 if(!ok)g_fail++;
}
bool EvaluateSavedEntry2G(const bool filter_new_ok,const bool rsi_ok,bool &buy)
{
 string name,parts[],params[];
 if(!g_slots.GetRole(1,0,name,parts,params))return false;
 SMA_BuilderFilterContext101 ctx;MABuilderFilterContextDefaults101(ctx);
 MABuilderFilterContextSet101(filter_new_ok,true,filter_new_ok?"ALLOW":"TEST_BLOCK","ALLOW",ctx);
 bool values[];ArrayResize(values,ArraySize(parts));
 for(int i=0;i<ArraySize(parts);i++)
 {
  values[i]=true;
  bool v=false;string why="";
  if(MABuilderFilterPartValue101(parts[i],ctx,v,why))values[i]=v;
  if(parts[i]=="RSI_THRESHOLD")values[i]=rsi_ok;
 }
 bool sell=false;string trace="",reason="";
 bool valid=g_interpreter.EvaluateEntry40(parts,values,buy,sell,trace,reason);
 Print("[MA_SAVED2G_ENTRY] valid=",(valid?1:0)," buy=",(buy?1:0)," sell=",(sell?1:0)," trace=",trace," reason=",reason);
 return valid&&!sell;
}
int OnInit()
{
 string p[],a[];ArrayResize(p,40);ArrayResize(a,40);
 for(int i=0;i<40;i++){p[i]="EMPTY";a[i]="";}
 p[0]="FILTER_NEW_OK";p[1]="AND";p[2]="RSI_THRESHOLD";p[3]="AND";p[4]="BUY";
 string why="";
 Check2G("ENTRY_REF_SCHEMA",MA104ValidatePart(0,p[0],a[0],why),true);
 Check2G("GRID_REF_SCHEMA",MA104ValidatePart(1,"FILTER_ADD_OK","",why),true);
 Check2G("ENTRY_WRONG_ROLE",MA104PartAllowed(1,"FILTER_NEW_OK"),false);
 Check2G("GRID_WRONG_ROLE",MA104PartAllowed(0,"FILTER_ADD_OK"),false);
 Check2G("SAVE_ENTRY",g_slots.PutRole(1,0,"Saved ENTRY",p,a),true);
 for(int i=0;i<40;i++){p[i]="EMPTY";a[i]="";}
 p[0]="FILTER_ADD_OK";
 Check2G("SAVE_GRID",g_slots.PutRole(1,1,"Saved GRID",p,a),true);
 string name,readparts[],readparams[];
 bool read=g_slots.GetRole(1,0,name,readparts,readparams);
 Check2G("LOAD_ENTRY",read&&name=="Saved ENTRY"&&readparts[0]=="FILTER_NEW_OK"&&readparts[4]=="BUY",true);
 read=g_slots.GetRole(1,1,name,readparts,readparams);
 Check2G("LOAD_GRID",read&&name=="Saved GRID"&&readparts[0]=="FILTER_ADD_OK",true);
 bool buy=false;
 bool valid=EvaluateSavedEntry2G(true,true,buy);
 Check2G("NEW_ALLOW_SIGNAL",valid&&buy,true);
 valid=EvaluateSavedEntry2G(false,true,buy);
 Check2G("NEW_BLOCK_SIGNAL",valid&&buy,false);
 valid=EvaluateSavedEntry2G(true,false,buy);
 Check2G("NEW_ALLOW_NO_SIGNAL",valid&&buy,false);
 SMA_BuilderFilterContext101 ctx;MABuilderFilterContextDefaults101(ctx);
 MABuilderFilterContextSet101(true,false,"ALLOW","TEST_ADD_BLOCK",ctx);
 bool add=false;string reason="";
 read=g_slots.GetRole(1,1,name,readparts,readparams);
 bool recognized=read&&MABuilderFilterPartValue101(readparts[0],ctx,add,reason);
 Check2G("SAVED_GRID_ADD_BLOCK",recognized&&add,false);
 MABuilderFilterContextSet101(true,true,"ALLOW","ALLOW",ctx);
 recognized=read&&MABuilderFilterPartValue101(readparts[0],ctx,add,reason);
 Check2G("SAVED_GRID_ADD_ALLOW",recognized&&add,true);
 if(g_fail==0)Print("[MA_SAVED2G_PASS] save_load=PASS filter_refs=PASS entry_interpreter=PASS grid_context=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SAVED2G_FAIL] failed=",g_fail," NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
