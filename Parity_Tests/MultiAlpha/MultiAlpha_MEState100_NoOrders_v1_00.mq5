#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_State_Flags100_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_Manage_Exit_Intent100_v1_00.mqh"
int failures=0,checks=0;
void Check(const string name,const bool ok)
{
 checks++;
 Print("[MA_ME_STATE100_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void ResetParts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 string p[],v[],reason="",action="";
 bool flags[],fire=false;
 SMA_MEState100 state;state.buyCount=2;state.sellCount=0;
 ResetParts(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=BUY;COND=GE;VALUE=2";
 p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("BUY_GE_TRUE",MAMEStateFlags100(2,p,v,state,flags,reason)&&flags[97]);
 Check("MANAGE_TRUE",MAIntent100(2,p,v,flags,fire,action,reason)&&fire&&action=="SINGLE_TRAILING");
 state.buyCount=1;
 Check("BUY_GE_FALSE",MAMEStateFlags100(2,p,v,state,flags,reason)&&!flags[97]);
 Check("MANAGE_FALSE",MAIntent100(2,p,v,flags,fire,action,reason)&&!fire);
 ResetParts(p,v);
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE=0";
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SELL_ZERO_TRUE",MAMEStateFlags100(3,p,v,state,flags,reason)&&flags[0]);
 Check("EXIT_TRUE",MAIntent100(3,p,v,flags,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 state.sellCount=1;
 Check("SELL_ZERO_FALSE",MAMEStateFlags100(3,p,v,state,flags,reason)&&!flags[0]);
 ResetParts(p,v);p[0]="MOVE_POINTS";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("MOVE_POINTS_REJECT",!MAMEStateFlags100(3,p,v,state,flags,reason)&&reason=="UNSUPPORTED_CONDITION_MOVE_POINTS");
 ResetParts(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=CURRENT;COND=EQ;VALUE=0";
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("CURRENT_REJECT",!MAMEStateFlags100(3,p,v,state,flags,reason)&&reason=="SIDE_CURRENT_UNSUPPORTED");
 ResetParts(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=BUY;COND=EQ;VALUE=1";
 p[1]="AND";p[2]="CLOSE_SIDE";
 state.buyCount=-1;
 Check("NEGATIVE_STATE_REJECT",!MAMEStateFlags100(3,p,v,state,flags,reason)&&reason=="INVALID_STATE");
 state.buyCount=1;
 Check("RECOVERY",MAMEStateFlags100(3,p,v,state,flags,reason)&&flags[0]&&MAIntent100(3,p,v,flags,fire,action,reason)&&fire);
 if(failures==0)
  Print("[MA_ME_STATE100_PASS] cases=",checks," synthetic_side_count_only=1 real_position_state=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_STATE100_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
