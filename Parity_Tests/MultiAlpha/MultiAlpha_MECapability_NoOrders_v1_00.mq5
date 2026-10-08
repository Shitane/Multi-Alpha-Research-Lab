#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Execution_Capability_Gate_v1_00.mqh"
// A14-17 static preview capability only. No trade adapter instance; no order API.
int cases=0,failures=0;
void Check(const string name,const bool ok)
{
 cases++;
 Print("[MA_ME_CAP_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Fixture(SMA_MEAdapterPreview100 &p,const int role,const int state,const string action)
{
 MAResetMEAdapterPreview100(p);
 p.role=role;p.state=state;p.action=action;
 p.slotIndex=99;p.symbol=_Symbol;p.magic=46102031;p.brokerArmed=false;
}
int OnInit()
{
 SMA_MEAdapterPreview100 p;
 SMA_MEExecutionCapability100 c;
 Fixture(p,3,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");
 Check("CLOSE_SIDE_METHOD",MAEvaluateMEExecutionCapability100(p,c)&&
   c.state==MA_ME_CAP_MAPPED&&c.method=="CloseSide"&&!c.brokerArmed);
 Check("SIDE_ARGUMENT_NOT_RESOLVED",c.reason=="SIDE_ARGUMENT_MISSING_PREVIEW_ONLY");
 Fixture(p,3,MA_ME_PREVIEW_ACCEPTED,"CLOSE_OPPOSITE");
 Check("CLOSE_OPPOSITE_REJECT",!MAEvaluateMEExecutionCapability100(p,c)&&
   c.state==MA_ME_CAP_BLOCKED&&c.reason=="OPPOSITE_SIDE_RESOLUTION_REQUIRED");
 Fixture(p,2,MA_ME_PREVIEW_ACCEPTED,"SINGLE_TRAILING");
 Check("SINGLE_TRAILING_REJECT",!MAEvaluateMEExecutionCapability100(p,c)&&c.reason=="NO_DIRECT_V173_METHOD");
 Fixture(p,2,MA_ME_PREVIEW_ACCEPTED,"BASKET_TRAILING");
 Check("BASKET_TRAILING_REJECT",!MAEvaluateMEExecutionCapability100(p,c)&&c.reason=="NO_DIRECT_V173_METHOD");
 Fixture(p,2,MA_ME_PREVIEW_ACCEPTED,"OVERLAP");
 Check("OVERLAP_REJECT",!MAEvaluateMEExecutionCapability100(p,c)&&c.reason=="NO_DIRECT_V173_METHOD");
 Fixture(p,2,MA_ME_PREVIEW_IDLE,"");
 Check("IDLE_ACCEPT",MAEvaluateMEExecutionCapability100(p,c)&&c.state==MA_ME_CAP_IDLE&&c.method=="");
 p.action="CLOSE_SIDE";
 Check("IDLE_ACTION_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 Fixture(p,3,MA_ME_PREVIEW_BLOCKED,"CLOSE_SIDE");
 Check("BLOCKED_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 Fixture(p,3,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");p.brokerArmed=true;
 Check("ARMED_REJECT",!MAEvaluateMEExecutionCapability100(p,c)&&!c.brokerArmed);
 Fixture(p,3,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");p.magic=0;
 Check("ZERO_MAGIC_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 Fixture(p,3,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");p.symbol="";
 Check("EMPTY_SYMBOL_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 Fixture(p,3,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");p.slotIndex=100;
 Check("SLOT_RANGE_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 Fixture(p,1,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");
 Check("WRONG_ROLE_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 Fixture(p,2,MA_ME_PREVIEW_ACCEPTED,"CLOSE_SIDE");
 Check("ROLE_ACTION_REJECT",!MAEvaluateMEExecutionCapability100(p,c));
 if(failures==0)
  Print("[MA_ME_CAP_PASS] cases=",cases," mapping_only=1 side_argument_unresolved=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_CAP_FAIL] cases=",cases," failures=",failures," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
