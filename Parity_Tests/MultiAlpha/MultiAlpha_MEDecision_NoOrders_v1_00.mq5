#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Runtime_Decision_v1_00.mqh"
// A14-13. Read-only existing positions. NO broker actions.
input long InpMagic=46102031;
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_ME_DECISION_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void ResetParts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEReadOnlyDecision100 d;
 string p[],v[];int sells=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){Print("[MA_ME_DECISION_FAIL] POSITION_SELECT_FAILED");return INIT_FAILED;}
  if(PositionGetString(POSITION_SYMBOL)==_Symbol&&PositionGetInteger(POSITION_MAGIC)==InpMagic
     &&PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sells++;
 }
 Check("UNSAVED_BLOCKED",!MABuildMEReadOnlyDecision100(store,2,99,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_BLOCKED&&!d.fire&&d.action=="");
 ResetParts(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 p[98]="AND";p[99]="SINGLE_TRAILING";v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE",store.SaveDefinition(2,99,"DECISION_M",p,v,true));
 Check("MANAGE_INTENT",MABuildMEReadOnlyDecision100(store,2,99,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_INTENT_ONLY&&d.fire&&d.action=="SINGLE_TRAILING");
 v[97]="SIDE=SELL;COND=GT;VALUE="+IntegerToString(sells);
 Check("SAVE_MANAGE_FALSE",store.SaveDefinition(2,99,"DECISION_M_FALSE",p,v,true));
 Check("MANAGE_NO_SIGNAL",MABuildMEReadOnlyDecision100(store,2,99,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_NO_SIGNAL&&!d.fire&&d.action=="");
 ResetParts(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT",store.SaveDefinition(3,99,"DECISION_E",p,v,true));
 Check("EXIT_INTENT",MABuildMEReadOnlyDecision100(store,3,99,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_INTENT_ONLY&&d.fire&&d.action=="CLOSE_SIDE");
 ResetParts(p,v);p[0]="AVG_PRICE";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"DECISION_BAD",p,v,true));
 Check("UNSUPPORTED_BLOCKED",!MABuildMEReadOnlyDecision100(store,3,99,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_BLOCKED&&!d.fire&&d.action==""&&d.reason=="UNSUPPORTED_METRIC_CONDITION_AVG_PRICE");
 Check("WRONG_ROLE_BLOCKED",!MABuildMEReadOnlyDecision100(store,1,99,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_BLOCKED&&!d.fire);
 Check("INVALID_SLOT_BLOCKED",!MABuildMEReadOnlyDecision100(store,3,100,_Symbol,InpMagic,d)&&d.state==MA_ME_DECISION_BLOCKED&&!d.fire);
 Print("[MA_ME_DECISION_INFO] symbol=",_Symbol," magic=",InpMagic," owned_sell=",sells);
 if(failures>0)Print("[MA_ME_DECISION_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 else if(sells==0)Print("[MA_ME_DECISION_INCONCLUSIVE] cases=",checks," zero_owned_sell=1 intent_boundary=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_DECISION_PASS] cases=",checks," owned_sell_nonzero=1 intent_boundary=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
