#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_Four_Role_Audit100_v1_00.mqh"
int failures=0;
void Check(const string label,const bool ok)
{
 Print("[MA_FOUR_ROLE100_CASE] ",label," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void ResetParts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 CMultiAlphaEASlotStore100 ea;
 CMultiAlphaModuleLibraryStore101 logic;
 string p[],v[],why="";
 int refs[4]={1,100,1,1};
 ENUM_MA_SAVED_LAMP100 e,g,m,x;
 Check("UNSAVED_ENTRY_OFF",MAAuditSavedRole100(logic,0,1,why)==MA_SAVED_OFF100);
 Check("UNSAVED_MANAGE_OFF",MAAuditSavedRole100(logic,2,1,why)==MA_SAVED_OFF100);
 Check("INVALID_REF_RED",MAAuditSavedRole100(logic,3,101,why)==MA_SAVED_RED100);
 ResetParts(p,v);p[99]="GRID_OFF";
 Check("SAVE_GRID_OFF",logic.SaveDefinition(1,99,"GRID_OFF",p,v,true));
 Check("GRID_ORANGE",MAAuditSavedRole100(logic,1,100,why)==MA_SAVED_ORANGE100);
 ResetParts(p,v);p[0]="BUY";
 Check("SAVE_BAD_ENTRY",logic.SaveDefinition(0,0,"ENTRY_BAD",p,v,true));
 Check("ENTRY_BAD_RED",MAAuditSavedRole100(logic,0,1,why)==MA_SAVED_RED100);
 ResetParts(p,v);
 Check("SAVE_EMPTY_MANAGE",logic.SaveDefinition(2,0,"MANAGE_EMPTY",p,v,true));
 Check("MANAGE_EMPTY_RED",MAAuditSavedRole100(logic,2,1,why)==MA_SAVED_RED100);
 Check("SAVE_EMPTY_EXIT",logic.SaveDefinition(3,0,"EXIT_EMPTY",p,v,true));
 Check("EXIT_EMPTY_RED",MAAuditSavedRole100(logic,3,1,why)==MA_SAVED_RED100);
 Check("EA_SAVE",ea.Save(100,"EA100",refs,true));
 Check("FOUR_ROLE_NOT_RUNNABLE",!MAAuditFourRole100(ea,logic,100,e,g,m,x,why));
 Check("FOUR_ROLE_LAMPS",e==MA_SAVED_RED100&&g==MA_SAVED_ORANGE100&&m==MA_SAVED_RED100&&x==MA_SAVED_RED100);
 Check("EA_OFF_SAVE",ea.Save(100,"OFF",refs,false));
 Check("EA_OFF_REJECT",!MAAuditFourRole100(ea,logic,100,e,g,m,x,why)&&why=="EA_OFF");
 if(failures==0)Print("[MA_FOUR_ROLE100_PASS] cases=16 structural_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_FOUR_ROLE100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
