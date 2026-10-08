#ifndef MULTIALPHA_ME_EXPLICIT_TARGET_PREVIEW_V1_00_MQH
#define MULTIALPHA_ME_EXPLICIT_TARGET_PREVIEW_V1_00_MQH
#include "MultiAlpha_ME_Owned_Side_Audit_v1_00.mqh"
// A14-20: explicit target is separate from SIDE_COUNT predicate.
// Preview only. Never creates an executable request or authorizes CloseSide.
#define MA_ME_TARGET_BLOCKED 0
#define MA_ME_TARGET_PREVIEW 1
struct SMA_MEExplicitTargetPreview100
{
 int state;
 int targetSide;
 string reason;
 bool brokerArmed;
};
void MAResetMEExplicitTargetPreview100(SMA_MEExplicitTargetPreview100 &out)
{
 out.state=MA_ME_TARGET_BLOCKED;out.targetSide=-1;
 out.reason="NOT_EVALUATED";out.brokerArmed=false;
}
bool MAPreviewMEExplicitTarget100(const SMA_MEAdapterPreview100 &preview,
 const SMA_MEExecutionCapability100 &cap,
 const SMA_MECloseSideResolution100 &predicate,
 const SMA_MEOwnedSideAudit100 &owned,
 const string explicitTarget,
 SMA_MEExplicitTargetPreview100 &out)
{
 MAResetMEExplicitTargetPreview100(out);
 if(preview.brokerArmed||cap.brokerArmed||predicate.brokerArmed||owned.brokerArmed)
 {out.reason="ARMED_REJECT";return false;}
 if(preview.state!=MA_ME_PREVIEW_ACCEPTED||preview.role!=3||
    preview.action!="CLOSE_SIDE"||preview.symbol==""||preview.magic<=0||
    preview.slotIndex<0||preview.slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE||
    cap.state!=MA_ME_CAP_MAPPED||cap.method!="CloseSide"||
    predicate.state!=MA_ME_SIDE_CANDIDATE||
    owned.state!=MA_ME_OWNED_OBSERVED)
 {out.reason="UPSTREAM_NOT_VERIFIED";return false;}
 if(explicitTarget!="BUY"&&explicitTarget!="SELL")
 {out.reason="EXPLICIT_TARGET_REQUIRED";return false;}
 int target=explicitTarget=="BUY"?(int)POSITION_TYPE_BUY:(int)POSITION_TYPE_SELL;
 if(predicate.side!=target||owned.side!=target)
 {out.reason="PREDICATE_OWNED_TARGET_MISMATCH";return false;}
 if(owned.ownedCount<=0||owned.ownedLots<=0.0||
    !MathIsValidNumber(owned.ownedLots))
 {out.reason="INVALID_OWNED_QUANTITY";return false;}
 out.state=MA_ME_TARGET_PREVIEW;out.targetSide=target;
 out.reason="EXPLICIT_TARGET_PREVIEW_ONLY_NOT_EXECUTABLE";
 return true;
}
#endif
