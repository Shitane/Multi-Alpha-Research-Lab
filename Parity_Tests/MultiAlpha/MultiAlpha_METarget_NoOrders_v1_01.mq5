#property strict
#property version "1.01"
#include "../../../Include/Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh"
// A14-20: fixture-only test, no order functions.
int g_cases=0;
int g_failures=0;
void MA20Check(const string label,const bool success)
{
 g_cases++;
 if(!success)g_failures++;
 Print("[MA_ME_TARGET_CASE] ",label," ",success?"PASS":"FAIL");
}
void MA20Fixture(SMA_MEAdapterPreview100 &preview,
 SMA_MEExecutionCapability100 &capability,
 SMA_MECloseSideResolution100 &candidate,
 SMA_MEOwnedSideAudit100 &owned)
{
 MAResetMEAdapterPreview100(preview);
 MAResetMEExecutionCapability100(capability);
 MAResetMECloseSideResolution100(candidate);
 MAResetMEOwnedSideAudit100(owned);
 preview.state=MA_ME_PREVIEW_ACCEPTED;
 preview.role=3;
 preview.action="CLOSE_SIDE";
 preview.symbol=_Symbol;
 preview.magic=46102031;
 preview.slotIndex=99;
 capability.state=MA_ME_CAP_MAPPED;
 capability.method="CloseSide";
 candidate.state=MA_ME_SIDE_CANDIDATE;
 candidate.side=(int)POSITION_TYPE_SELL;
 owned.state=MA_ME_OWNED_OBSERVED;
 owned.side=(int)POSITION_TYPE_SELL;
 owned.ownedCount=1;
 owned.ownedLots=0.01;
}
int OnInit()
{
 SMA_MEAdapterPreview100 preview;
 SMA_MEExecutionCapability100 capability;
 SMA_MECloseSideResolution100 candidate;
 SMA_MEOwnedSideAudit100 owned;
 SMA_MEExplicitTargetPreview100 result;
 MA20Fixture(preview,capability,candidate,owned);
 bool accepted=MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result);
 MA20Check("SELL_EXPLICIT_PREVIEW",accepted&&result.state==MA_ME_TARGET_PREVIEW&&result.targetSide==(int)POSITION_TYPE_SELL);
 MA20Check("NOT_EXECUTABLE",!result.brokerArmed&&result.reason=="EXPLICIT_TARGET_PREVIEW_ONLY_NOT_EXECUTABLE");
 MA20Check("EMPTY_TARGET_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"",result));
 MA20Check("UNKNOWN_TARGET_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"CURRENT",result));
 MA20Check("OPPOSITE_TARGET_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"BUY",result));
 MA20Fixture(preview,capability,candidate,owned);
 candidate.side=(int)POSITION_TYPE_BUY;
 owned.side=(int)POSITION_TYPE_BUY;
 MA20Check("BUY_EXPLICIT_PREVIEW",MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"BUY",result));
 MA20Fixture(preview,capability,candidate,owned);
 owned.side=(int)POSITION_TYPE_BUY;
 MA20Check("OWNED_MISMATCH_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 owned.ownedCount=0;
 MA20Check("ZERO_COUNT_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 owned.ownedLots=0.0;
 MA20Check("ZERO_LOTS_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 preview.brokerArmed=true;
 MA20Check("PREVIEW_ARMED_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 capability.brokerArmed=true;
 MA20Check("CAP_ARMED_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 candidate.brokerArmed=true;
 MA20Check("SIDE_ARMED_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 owned.brokerArmed=true;
 MA20Check("OWNED_ARMED_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 preview.action="CLOSE_OPPOSITE";
 MA20Check("ACTION_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 preview.role=2;
 MA20Check("ROLE_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 preview.slotIndex=100;
 MA20Check("SLOT_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 capability.method="";
 MA20Check("CAP_METHOD_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 candidate.state=MA_ME_SIDE_BLOCKED;
 MA20Check("SIDE_BLOCKED_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 MA20Fixture(preview,capability,candidate,owned);
 owned.state=MA_ME_OWNED_BLOCKED;
 MA20Check("OWNED_BLOCKED_REJECT",!MAPreviewMEExplicitTarget100(preview,capability,candidate,owned,"SELL",result));
 if(g_failures==0)
  Print("[MA_ME_TARGET_PASS] cases=",g_cases," explicit_target_required=1 target_preview_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_TARGET_FAIL] cases=",g_cases," failures=",g_failures," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
