#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Manage_Exit_Intent100_v1_00.mqh"
int failures=0,checks=0;
void Check(const string label,const bool ok)
{
 checks++;Print("[MA_ME_INTENT100_CASE] ",label," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Reset(string &p[],string &v[],bool &flags[])
{
 ArrayResize(p,100);ArrayResize(v,100);ArrayResize(flags,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";flags[i]=false;}
}
int OnInit()
{
 string p[],v[],reason="",action="";bool f[],fire=false;
 Reset(p,v,f);
 p[97]="MOVE_POINTS";p[98]="AND";p[99]="SINGLE_TRAILING";v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 f[97]=true;
 Check("MANAGE_TRUE",MAIntent100(2,p,v,f,fire,action,reason)&&fire&&action=="SINGLE_TRAILING");
 f[97]=false;
 Check("MANAGE_FALSE",MAIntent100(2,p,v,f,fire,action,reason)&&!fire);
 Reset(p,v,f);p[39]="MOVE_POINTS";p[40]="AND";p[41]="CLOSE_SIDE";f[39]=true;
 Check("EXIT_TRUE",MAIntent100(3,p,v,f,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 f[39]=false;
 Check("EXIT_FALSE",MAIntent100(3,p,v,f,fire,action,reason)&&!fire);
 Reset(p,v,f);p[0]="MOVE_POINTS";p[1]="OR";p[2]="CLOSE_SIDE";f[0]=true;
 Check("OR_REJECT",!MAIntent100(3,p,v,f,fire,action,reason)&&!fire);
 Reset(p,v,f);p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";p[3]="AND";p[4]="CLOSE_SIDE";f[0]=true;
 Check("MULTI_ACTION_REJECT",!MAIntent100(3,p,v,f,fire,action,reason)&&!fire);
 Reset(p,v,f);p[0]="CLOSE_SIDE";p[1]="AND";p[2]="MOVE_POINTS";
 Check("ACTION_FIRST_REJECT",!MAIntent100(3,p,v,f,fire,action,reason));
 Reset(p,v,f);p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";
 ArrayResize(f,40);
 Check("SHORT_FLAGS_REJECT",!MAIntent100(3,p,v,f,fire,action,reason));
 Reset(p,v,f);p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";f[0]=true;
 Check("WRONG_ROLE_REJECT",!MAIntent100(1,p,v,f,fire,action,reason));
 Check("EXIT_RECOVERY",MAIntent100(3,p,v,f,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 if(failures==0)Print("[MA_ME_INTENT100_PASS] cases=",checks," intent_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_INTENT100_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
