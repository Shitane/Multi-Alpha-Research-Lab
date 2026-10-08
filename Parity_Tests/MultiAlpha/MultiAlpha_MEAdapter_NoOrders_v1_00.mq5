#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Adapter_Preview_v1_00.mqh"
// A14-15: NO_ORDERS. Only in-memory request handoff validation.
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_ME_ADAPTER_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
int OnInit()
{
 SMA_MERequestBoundary100 r;SMA_MEAdapterPreview100 out;
 MAResetMERequestBoundary100(r);
 r.role=2;r.slotIndex=99;r.symbol=_Symbol;r.magic=46102031;
 Check("BLOCKED_REJECT",!MAPreviewMERequest100(r,out)&&out.state==MA_ME_PREVIEW_BLOCKED);
 r.state=MA_ME_REQUEST_NO_SIGNAL;
 Check("IDLE_ACCEPT",MAPreviewMERequest100(r,out)&&out.state==MA_ME_PREVIEW_IDLE&&!out.brokerArmed);
 r.action="CLOSE_SIDE";
 Check("IDLE_ACTION_REJECT",!MAPreviewMERequest100(r,out));
 r.state=MA_ME_REQUEST_CANDIDATE;r.action="SINGLE_TRAILING";
 Check("MANAGE_ACCEPT",MAPreviewMERequest100(r,out)&&out.state==MA_ME_PREVIEW_ACCEPTED&&out.action=="SINGLE_TRAILING"&&!out.brokerArmed);
 r.brokerArmed=true;
 Check("ARMED_REJECT",!MAPreviewMERequest100(r,out)&&!out.brokerArmed);
 r.brokerArmed=false;r.symbol="";
 Check("EMPTY_SYMBOL_REJECT",!MAPreviewMERequest100(r,out));
 r.symbol=_Symbol;r.magic=-1;
 Check("NEGATIVE_MAGIC_REJECT",!MAPreviewMERequest100(r,out));
 r.magic=46102031;r.role=3;r.action="CLOSE_SIDE";
 Check("EXIT_ACCEPT",MAPreviewMERequest100(r,out)&&out.state==MA_ME_PREVIEW_ACCEPTED&&out.role==3);
 r.action="BASKET_TRAILING";
 Check("EXIT_MANAGE_REJECT",!MAPreviewMERequest100(r,out));
 r.role=2;r.action="CLOSE_SIDE";
 Check("MANAGE_EXIT_REJECT",!MAPreviewMERequest100(r,out));
 r.role=1;
 Check("ENTRY_ROLE_REJECT",!MAPreviewMERequest100(r,out));
 r.role=3;r.slotIndex=100;
 Check("SLOT_OUT_OF_RANGE",!MAPreviewMERequest100(r,out));
 r.slotIndex=99;r.state=999;
 Check("UNKNOWN_STATE_REJECT",!MAPreviewMERequest100(r,out));
 r.state=MA_ME_REQUEST_CANDIDATE;r.action="CLOSE_OPPOSITE";
 Check("EXIT_OPPOSITE_ACCEPT",MAPreviewMERequest100(r,out)&&out.state==MA_ME_PREVIEW_ACCEPTED&&!out.brokerArmed);
 r.role=2;r.action="OVERLAP";
 Check("MANAGE_OVERLAP_ACCEPT",MAPreviewMERequest100(r,out)&&out.state==MA_ME_PREVIEW_ACCEPTED&&!out.brokerArmed);
 Print("[MA_ME_ADAPTER_INFO] symbol=",out.symbol," magic=",out.magic," state=",out.state," broker_armed=",(int)out.brokerArmed);
 if(failures==0)Print("[MA_ME_ADAPTER_PASS] cases=",checks," preview_only=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_ADAPTER_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
