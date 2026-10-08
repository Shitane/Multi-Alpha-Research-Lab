#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh"
// Synthetic fixtures: NO position reads, NO trade adapter, NO orders.
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_ME_TARGET_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Fixture(SMA_MEAdapterPreview100 &p,SMA_MEExecutionCapability100 &c,
 SMA_MECloseSideResolution100 &s,SMA_MEOwnedSideAudit100 &o)
{
 MAResetMEAdapterPreview100(p);MAResetMEExecutionCapability100(c);
 MAResetMECloseSideResolution100(s);MAResetMEOwnedSideAudit100(o);
 p.state=MA_ME_PREVIEW_ACCEPTED;p.role=3;p.action="CLOSE_SIDE";
 p.symbol=_Symbol;p.magic=46102031;p.slotIndex=99;
 c.state=MA_ME_CAP_MAPPED;c.method="CloseSide";
 s.state=MA_ME_SIDE_CANDIDATE;s.side=(int)POSITION_TYPE_SELL;
 o.state=MA_ME_OWNED_OBSERVED;o.side=(int)POSITION_TYPE_SELL;
 o.ownedCount=1;o.ownedLots=0.01;
}
int OnInit()
{
 SMA_MEAdapterPreview100 p;SMA_MEExecutionCapability100 c;
 SMA_MECloseSideResolution100 s;SMA_MEOwnedSideAudit100 o;
 SMA_MEExplicitTargetPreview100 t;
 Fixture(p,c,s,o);
 Check("SELL_EXPLICIT_PREVIEW",MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t)&&
   t.state==MA_ME_TARGET_PREVIEW&&t.targetSide==(int)POSITION_TYPE_SELL);
 Check("NOT_EXECUTABLE",!t.brokerArmed&&t.reason=="EXPLICIT_TARGET_PREVIEW_ONLY_NOT_EXECUTABLE");
 Check("EMPTY_TARGET_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"",t));
 Check("UNKNOWN_TARGET_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"CURRENT",t));
 Check("OPPOSITE_TARGET_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"BUY",t));
 Fixture(p,c,s,o);s.side=(int)POSITION_TYPE_BUY;o.side=(int)POSITION_TYPE_BUY;
 Check("BUY_EXPLICIT_PREVIEW",MAPreviewMEExplicitTarget100(p,c,s,o,"BUY",t));
 Fixture(p,c,s,o);o.side=(int)POSITION_TYPE_BUY;
 Check("OWNED_MISMATCH_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);o.ownedCount=0;
 Check("ZERO_COUNT_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);o.ownedLots=0.0;
 Check("ZERO_LOTS_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);p.brokerArmed=true;
 Check("PREVIEW_ARMED_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);c.brokerArmed=true;
 Check("CAP_ARMED_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);s.brokerArmed=true;
 Check("SIDE_ARMED_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);o.brokerArmed=true;
 Check("OWNED_ARMED_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);p.action="CLOSE_OPPOSITE";
 Check("ACTION_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);p.role=2;
 Check("ROLE_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);p.slotIndex=100;
 Check("SLOT_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);c.method="";
 Check("CAP_METHOD_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);s.state=MA_ME_SIDE_BLOCKED;
 Check("SIDE_BLOCKED_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 Fixture(p,c,s,o);o.state=MA_ME_OWNED_BLOCKED;
 Check("OWNED_BLOCKED_REJECT",!MAPreviewMEExplicitTarget100(p,c,s,o,"SELL",t));
 if(failures==0)
  Print("[MA_ME_TARGET_PASS] cases=",checks,
   " explicit_target_required=1 target_preview_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_TARGET_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
