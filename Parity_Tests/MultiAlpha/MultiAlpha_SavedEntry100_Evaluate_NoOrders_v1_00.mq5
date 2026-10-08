#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Module_Library_Store_v1_01.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Interpreter_v1_06.mqh"
// A14: evaluate saved ENTRY condition vectors; no indicators, broker orders or runtime certification.
int failures=0,checks=0;
void Check(const string label,const bool ok)
{
 checks++;
 Print("[MA_SAVED_ENTRY100_CASE] ",label," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Reset100(string &p[],string &v[],bool &conditions[])
{
 ArrayResize(p,100);ArrayResize(v,100);ArrayResize(conditions,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";conditions[i]=false;}
}
bool EvaluateSaved(CMultiAlphaModuleLibraryStore101 &store,const int slot,
 const bool &conditions[],bool &buy,bool &sell,string &reason)
{
 buy=false;sell=false;
 string name="",p[],v[];bool enabled=false;
 if(!store.LoadDefinition(0,slot-1,name,p,v,enabled)){reason="UNSAVED";return false;}
 if(!enabled){reason="DISABLED";return false;}
 CMultiAlphaBuilderInterpreter106 interpreter;
 string trace="";
 return interpreter.EvaluateEntry100(p,conditions,buy,sell,trace,reason);
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],reason="";
 bool conditions[],buy=false,sell=false;
 Reset100(p,v,conditions);
 Check("UNSAVED_REJECT",!EvaluateSaved(store,100,conditions,buy,sell,reason));
 p[0]="RSI";p[1]="AND";p[2]="ATR";p[3]="BUY";p[4]="OR";p[5]="RSI";p[6]="SELL";
 Check("SAVE_SLOT100",store.SaveDefinition(0,99,"ENTRY100",p,v,true));
 conditions[0]=true;conditions[2]=true;conditions[5]=false;
 Check("BUY_BRANCH",EvaluateSaved(store,100,conditions,buy,sell,reason)&&buy&&!sell);
 conditions[0]=false;conditions[5]=true;
 Check("SELL_BRANCH",EvaluateSaved(store,100,conditions,buy,sell,reason)&&!buy&&sell);
 conditions[0]=true;conditions[2]=true;
 Check("BOTH_BRANCHES",EvaluateSaved(store,100,conditions,buy,sell,reason)&&buy&&sell);
 conditions[0]=false;conditions[2]=false;conditions[5]=false;
 Check("NEITHER_BRANCH",EvaluateSaved(store,100,conditions,buy,sell,reason)&&!buy&&!sell);
 Reset100(p,v,conditions);p[98]="RSI";p[99]="BUY";conditions[98]=true;
 Check("SAVE_PART100",store.SaveDefinition(0,99,"PART100",p,v,true));
 Check("PART100_BUY",EvaluateSaved(store,100,conditions,buy,sell,reason)&&buy&&!sell);
 Reset100(p,v,conditions);p[99]="BUY";
 Check("SAVE_ACTION_ONLY",store.SaveDefinition(0,99,"INVALID",p,v,true));
 Check("ACTION_ONLY_REJECT",!EvaluateSaved(store,100,conditions,buy,sell,reason));
 Reset100(p,v,conditions);p[0]="RSI";p[1]="BUY";conditions[0]=true;
 Check("SAVE_DISABLED",store.SaveDefinition(0,99,"DISABLED",p,v,false));
 Check("DISABLED_REJECT",!EvaluateSaved(store,100,conditions,buy,sell,reason));
 if(failures==0)Print("[MA_SAVED_ENTRY100_PASS] cases=",checks," saved_entry_vector_evaluation=PASS indicator_values_external=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SAVED_ENTRY100_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
