#ifndef MULTIALPHA_ME_OWNED_SIDE_AUDIT_V1_00_MQH
#define MULTIALPHA_ME_OWNED_SIDE_AUDIT_V1_00_MQH
#include "MultiAlpha_ME_CloseSide_Resolution_v1_00.mqh"
// A14-19: read-only candidate-side ownership audit; NEVER authorizes CloseSide.
#define MA_ME_OWNED_BLOCKED 0
#define MA_ME_OWNED_OBSERVED 1
struct SMA_MEOwnedSideAudit100
{
 int state;
 int side;
 int ownedCount;
 double ownedLots;
 string reason;
 bool brokerArmed;
};
void MAResetMEOwnedSideAudit100(SMA_MEOwnedSideAudit100 &out)
{
 out.state=MA_ME_OWNED_BLOCKED;out.side=-1;out.ownedCount=0;
 out.ownedLots=0.0;out.reason="NOT_EVALUATED";out.brokerArmed=false;
}
bool MAAuditMEOwnedCandidateSide100(const SMA_MEAdapterPreview100 &preview,
 const SMA_MECloseSideResolution100 &candidate,
 SMA_MEOwnedSideAudit100 &out)
{
 MAResetMEOwnedSideAudit100(out);
 if(preview.brokerArmed||candidate.brokerArmed){out.reason="ARMED_REJECT";return false;}
 if(preview.state!=MA_ME_PREVIEW_ACCEPTED||preview.role!=3||
    preview.action!="CLOSE_SIDE"||candidate.state!=MA_ME_SIDE_CANDIDATE)
 {out.reason="NOT_EXIT_CANDIDATE";return false;}
 if(preview.symbol==""||preview.magic<=0||preview.slotIndex<0||
    preview.slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE)
 {out.reason="INVALID_IDENTITY_OR_SLOT";return false;}
 if(candidate.side!=(int)POSITION_TYPE_BUY&&candidate.side!=(int)POSITION_TYPE_SELL)
 {out.reason="INVALID_CANDIDATE_SIDE";return false;}
 SMA_PositionMetrics100 m;string why="";
 if(!MAReadPositionMetrics100(preview.symbol,preview.magic,m,why))
 {out.reason="METRICS_"+why;return false;}
 int count=candidate.side==(int)POSITION_TYPE_BUY?m.buyCount:m.sellCount;
 double lots=candidate.side==(int)POSITION_TYPE_BUY?m.buyLots:m.sellLots;
 if(count<=0||lots<=0.0||!MathIsValidNumber(lots))
 {out.reason="NO_OWNED_CANDIDATE_SIDE";return false;}
 out.state=MA_ME_OWNED_OBSERVED;out.side=candidate.side;
 out.ownedCount=count;out.ownedLots=lots;
 out.reason="OWNED_OBSERVED_PREDICATE_SIDE_NOT_EXECUTION_TARGET";
 return true;
}
#endif
