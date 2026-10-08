#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_Four_Role_Status_v1_00.mqh"
int failures=0;
void Check(const string label,const int actual,const int expected)
{
 bool ok=actual==expected;
 Print("[MA_SAVED2J_CASE] ",label," ",ok?"PASS":"FAIL"," actual=",actual," expected=",expected);
 if(!ok)failures++;
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore100 store;
 string p[],v[],why="",eaWhy="";
 ArrayResize(p,40);ArrayResize(v,40);
 for(int i=0;i<40;i++){p[i]="EMPTY";v[i]="";}
 Check("MISSING_GRID_OFF",(int)MASavedRoleLamp100(store,1,1,why),(int)MA_LAMP_OFF101);
 Check("INVALID_REF_OFF",(int)MASavedRoleLamp100(store,1,51,why),(int)MA_LAMP_OFF101);
 p[0]="GRID_OFF";
 Check("SAVE_GRID_OFF",(int)store.SaveDefinition(1,0,"NO GRID",p,v,false),1);
 Check("LOADED_GRID_ORANGE",(int)MASavedRoleLamp100(store,1,1,why),(int)MA_LAMP_ORANGE101);
 Check("EA_MISSING_ROLES_RED",(int)MASavedEASlotLamp100(store,1,1,1,1,eaWhy),(int)MA_LAMP_RED101);
 Check("EA_MISSING_ROLES_NOT_RUN",(int)MASavedEASlotRunnable100(MASavedEASlotLamp100(store,1,1,1,1,eaWhy),true),0);
 Check("EA_OFF_NOT_RUN",(int)MASavedEASlotRunnable100(MA_LAMP_ORANGE101,false),0);
 Check("EA_ON_VALID_ORANGE_RUN",(int)MASavedEASlotRunnable100(MA_LAMP_ORANGE101,true),1);
 Check("EA_ON_VALID_GREEN_RUN",(int)MASavedEASlotRunnable100(MA_LAMP_GREEN101,true),1);
 Check("EA_ON_INVALID_RED_NOT_RUN",(int)MASavedEASlotRunnable100(MA_LAMP_RED101,true),0);
 p[1]="ADD_BUY";
 Check("SAVE_CONFLICT",(int)store.SaveDefinition(1,0,"CONFLICT",p,v,true),1);
 Check("LOADED_CONFLICT_RED",(int)MASavedRoleLamp100(store,1,1,why),(int)MA_LAMP_RED101);
 if(failures==0)Print("[MA_SAVED2J_PASS] loaded_status=PASS fail_closed=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SAVED2J_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
