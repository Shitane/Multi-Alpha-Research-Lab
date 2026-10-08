#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_Manage_Exit_Intent100_v1_00.mqh"
int failures=0,checks=0;
void Check(const string label,const bool ok)
{
 checks++;Print("[MA_SAVED_ME100_CASE] ",label," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Reset(string &p[],string &v[],bool &f[])
{
 ArrayResize(p,100);ArrayResize(v,100);ArrayResize(f,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";f[i]=false;}
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],reason="",action="";bool flags[],fire=false;
 Reset(p,v,flags);
 Check("UNSAVED_REJECT",!MASavedManageExitIntent100(store,2,99,flags,fire,action,reason)&&!fire&&action=="");
 p[97]="MOVE_POINTS";p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";flags[97]=true;
 Check("SAVE_MANAGE100",store.SaveDefinition(2,99,"M100",p,v,true));
 Check("MANAGE_TRUE",MASavedManageExitIntent100(store,2,99,flags,fire,action,reason)&&fire&&action=="SINGLE_TRAILING");
 flags[97]=false;
 Check("MANAGE_FALSE",MASavedManageExitIntent100(store,2,99,flags,fire,action,reason)&&!fire&&action=="SINGLE_TRAILING");
 Reset(p,v,flags);p[39]="MOVE_POINTS";p[40]="AND";p[41]="CLOSE_SIDE";flags[39]=true;
 Check("SAVE_EXIT100",store.SaveDefinition(3,99,"X100",p,v,true));
 Check("EXIT_TRUE",MASavedManageExitIntent100(store,3,99,flags,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 flags[39]=false;
 Check("EXIT_FALSE",MASavedManageExitIntent100(store,3,99,flags,fire,action,reason)&&!fire);
 Check("ROLE_MISMATCH_UNSAVED",!MASavedManageExitIntent100(store,2,98,flags,fire,action,reason)&&!fire);
 Check("WRONG_ROLE_REJECT",!MASavedManageExitIntent100(store,1,99,flags,fire,action,reason)&&!fire);
 Check("INDEX_100_REJECT",!MASavedManageExitIntent100(store,3,100,flags,fire,action,reason)&&!fire);
 Check("INDEX_NEGATIVE_REJECT",!MASavedManageExitIntent100(store,3,-1,flags,fire,action,reason)&&!fire);
 ArrayResize(flags,40);
 Check("SHORT_FLAGS_REJECT",!MASavedManageExitIntent100(store,3,99,flags,fire,action,reason)&&!fire&&action=="");
 Reset(p,v,flags);p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";flags[0]=true;
 Check("SAVE_DISABLED",store.SaveDefinition(3,99,"OFF",p,v,false));
 Check("DISABLED_REJECT",!MASavedManageExitIntent100(store,3,99,flags,fire,action,reason)&&!fire&&action=="");
 p[1]="OR";
 Check("SAVE_INVALID",store.SaveDefinition(3,99,"INVALID",p,v,true));
 Check("INVALID_REJECT",!MASavedManageExitIntent100(store,3,99,flags,fire,action,reason)&&!fire&&action=="");
 p[1]="AND";
 Check("RECOVERY_SAVE",store.SaveDefinition(3,99,"RESTORED",p,v,true));
 Check("RECOVERY_EVALUATE",MASavedManageExitIntent100(store,3,99,flags,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 if(failures==0)Print("[MA_SAVED_ME100_PASS] cases=",checks," saved_intent_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SAVED_ME100_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
