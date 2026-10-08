#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Request_Boundary_v1_00.mqh"
// A14-14: NoOrders, no trade calls, no broker permission.
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_ME_REQUEST_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void ResetParts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 MAResetMEReadOnlyDecision100(d);
 d.role=2;d.slotIndex=99;
 Check("BLOCKED_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_BLOCKED&&!r.brokerArmed);
 d.state=MA_ME_DECISION_NO_SIGNAL;d.fire=false;d.action="";
 Check("NO_SIGNAL",MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_NO_SIGNAL&&r.action==""&&!r.brokerArmed);
 d.fire=true;
 Check("NO_SIGNAL_FIRE_CONFLICT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_BLOCKED);
 d.state=MA_ME_DECISION_INTENT_ONLY;d.fire=true;d.action="SINGLE_TRAILING";
 Check("MANAGE_CANDIDATE",MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_CANDIDATE&&r.role==2&&r.slotIndex==99&&r.action=="SINGLE_TRAILING"&&r.magic==46102031&&!r.brokerArmed);
 Check("EMPTY_SYMBOL_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,"",46102031,r));
 Check("NEGATIVE_MAGIC_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,-1,r));
 d.fire=false;
 Check("INTENT_NO_FIRE_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r));
 d.fire=true;d.action="CLOSE_SIDE";
 Check("MANAGE_EXIT_ACTION_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r));
 d.role=3;
 Check("EXIT_CANDIDATE",MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_CANDIDATE&&r.action=="CLOSE_SIDE"&&!r.brokerArmed);
 d.action="BASKET_TRAILING";
 Check("EXIT_MANAGE_ACTION_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r));
 d.role=1;d.action="CLOSE_SIDE";
 Check("ENTRY_ROLE_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r));
 d.role=3;d.slotIndex=100;
 Check("SLOT_100_INDEX_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r));
 d.slotIndex=99;d.state=99;
 Check("UNKNOWN_STATE_REJECT",!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,46102031,r));
 CMultiAlphaModuleLibraryStore101 store;string p[],v[];
 Check("UNSAVED_UPSTREAM_REJECT",!MABuildMESavedRequestBoundary100(store,3,99,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_BLOCKED);
 ResetParts(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=GE;VALUE=0";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT",store.SaveDefinition(3,99,"REQUEST_EXIT",p,v,true));
 Check("SAVED_EXIT_CANDIDATE",MABuildMESavedRequestBoundary100(store,3,99,_Symbol,46102031,r)&&r.state==MA_ME_REQUEST_CANDIDATE&&r.action=="CLOSE_SIDE"&&!r.brokerArmed);
 Print("[MA_ME_REQUEST_INFO] symbol=",_Symbol," magic=46102031 request_state=",r.state," broker_armed=",(int)r.brokerArmed);
 if(failures==0)Print("[MA_ME_REQUEST_PASS] cases=",checks," read_only_boundary=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_REQUEST_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
