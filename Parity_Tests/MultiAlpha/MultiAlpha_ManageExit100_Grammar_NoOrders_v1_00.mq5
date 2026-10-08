#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Manage_Exit_Grammar_v1_01.mqh"
int failures=0;
void Check(const string label,const bool actual,const bool expected)
{
 bool pass=actual==expected;
 Print("[MA_ROLE100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
void Reset(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 string p[],v[],reason="";
 Reset(p,v);
 Check("MANAGE_EMPTY",MA2KValidateManageExit100(2,p,v,reason),false);
 p[97]="MOVE_POINTS";p[98]="AND";p[99]="SINGLE_TRAILING";v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("MANAGE_PART100",MA2KValidateManageExit100(2,p,v,reason),true);
 p[99]="CLOSE_SIDE";v[99]="";
 Check("MANAGE_WRONG_ROLE",MA2KValidateManageExit100(2,p,v,reason),false);
 Reset(p,v);
 p[39]="MOVE_POINTS";p[40]="AND";p[41]="CLOSE_SIDE";
 Check("EXIT_CROSS_40_41",MA2KValidateManageExit100(3,p,v,reason),true);
 p[41]="EMPTY";p[40]="OR";
 Check("EXIT_TRAILING_OPERATOR",MA2KValidateManageExit100(3,p,v,reason),false);
 Reset(p,v);
 p[99]="CLOSE_SIDE";
 Check("EXIT_ACTION_ONLY",MA2KValidateManageExit100(3,p,v,reason),false);
 Reset(p,v);
 p[99]="MOVE_POINTS";
 Check("EXIT_CONDITION_ONLY",MA2KValidateManageExit100(3,p,v,reason),false);
 Reset(p,v);
 p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("INVALID_ROLE",MA2KValidateManageExit100(1,p,v,reason),false);
 string shortP[],shortV[];ArrayResize(shortP,40);ArrayResize(shortV,40);
 Check("SHORT_40_REJECT",MA2KValidateManageExit100(3,shortP,shortV,reason),false);
 Reset(p,v);p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";v[99]="GHOST=1";
 Check("EMPTY_PARAMS_REJECT",MA2KValidateManageExit100(3,p,v,reason),false);
 if(failures==0)Print("[MA_ROLE100_PASS] structural_only=PASS RUNTIME_SEMANTICS_PROVEN=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ROLE100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
