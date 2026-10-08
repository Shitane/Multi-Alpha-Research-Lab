#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Manage_Exit_Grammar_v1_00.mqh"
int failures=0;
void Check(const string name,const bool got,const bool expected)
{
 bool pass=got==expected;
 Print("[MA_ROLE2K_CASE] ",name," ",pass?"PASS":"FAIL"," actual=",(int)got," expected=",(int)expected);
 if(!pass)failures++;
}
void Reset(string &p[],string &v[])
{
 ArrayResize(p,40);ArrayResize(v,40);
 for(int i=0;i<40;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 string p[],v[],reason="";
 Reset(p,v);
 Check("MANAGE_EMPTY",MA2KValidateManageExit(2,p,v,reason),false);
 p[0]="MOVE_POINTS";p[1]="AND";p[2]="SINGLE_TRAILING";v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("MANAGE_STRUCTURE",MA2KValidateManageExit(2,p,v,reason),true);
 p[2]="CLOSE_SIDE";v[2]="";
 Check("MANAGE_WRONG_ROLE",MA2KValidateManageExit(2,p,v,reason),false);
 Reset(p,v);
 p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("EXIT_STRUCTURE",MA2KValidateManageExit(3,p,v,reason),true);
 p[1]="OR";p[2]="EMPTY";
 Check("EXIT_TRAILING_OPERATOR",MA2KValidateManageExit(3,p,v,reason),false);
 Reset(p,v);
 p[0]="CLOSE_SIDE";
 Check("EXIT_ACTION_ONLY",MA2KValidateManageExit(3,p,v,reason),false);
 Reset(p,v);
 p[0]="MOVE_POINTS";
 Check("EXIT_CONDITION_ONLY",MA2KValidateManageExit(3,p,v,reason),false);
 Reset(p,v);
 p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("INVALID_ROLE",MA2KValidateManageExit(1,p,v,reason),false);
 if(failures==0)Print("[MA_ROLE2K_PASS] structural_only=PASS RUNTIME_SEMANTICS_PROVEN=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ROLE2K_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
