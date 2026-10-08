#ifndef MULTIALPHA_ME_REQUEST_BOUNDARY_V1_00_MQH
#define MULTIALPHA_ME_REQUEST_BOUNDARY_V1_00_MQH
#include "MultiAlpha_ME_Runtime_Decision_v1_00.mqh"
// A14-14: immutable-style read-only request descriptor, NOT a broker execution request.
// No CTrade, OrderSend, PositionClose, ticket selection, or execution permission.
#define MA_ME_REQUEST_BLOCKED 0
#define MA_ME_REQUEST_NO_SIGNAL 1
#define MA_ME_REQUEST_CANDIDATE 2
struct SMA_MERequestBoundary100
{
 int state;
 int role;
 int slotIndex;
 string symbol;
 long magic;
 string action;
 string reason;
 bool brokerArmed;
};
void MAResetMERequestBoundary100(SMA_MERequestBoundary100 &r)
{
 r.state=MA_ME_REQUEST_BLOCKED;r.role=-1;r.slotIndex=-1;
 r.symbol="";r.magic=-1;r.action="";r.reason="NOT_EVALUATED";
 r.brokerArmed=false;
}
bool MAConvertMEReadOnlyDecisionToRequest100(const SMA_MEReadOnlyDecision100 &d,
 const string symbol,const long magic,SMA_MERequestBoundary100 &r)
{
 MAResetMERequestBoundary100(r);
 if(symbol==""){r.reason="EMPTY_SYMBOL";return false;}
 if(magic<0){r.reason="NEGATIVE_MAGIC";return false;}
 if(d.role!=2&&d.role!=3){r.reason="ROLE_NOT_MANAGE_EXIT";return false;}
 if(d.slotIndex<0||d.slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE)
 {r.reason="SLOT_OUT_OF_RANGE";return false;}
 if(d.state==MA_ME_DECISION_BLOCKED)
 {r.reason="UPSTREAM_BLOCKED";return false;}
 if(d.state==MA_ME_DECISION_NO_SIGNAL)
 {
  if(d.fire||d.action!=""){r.reason="INCONSISTENT_NO_SIGNAL";return false;}
  r.state=MA_ME_REQUEST_NO_SIGNAL;r.role=d.role;r.slotIndex=d.slotIndex;
  r.symbol=symbol;r.magic=magic;r.reason="NO_SIGNAL";return true;
 }
 if(d.state!=MA_ME_DECISION_INTENT_ONLY)
 {r.reason="INVALID_DECISION_STATE";return false;}
 if(!d.fire){r.reason="INTENT_WITHOUT_FIRE";return false;}
 bool allowed=(d.role==2&&(d.action=="SINGLE_TRAILING"||d.action=="BASKET_TRAILING"||d.action=="OVERLAP"))
           ||(d.role==3&&(d.action=="CLOSE_SIDE"||d.action=="CLOSE_OPPOSITE"));
 if(!allowed){r.reason="ROLE_ACTION_MISMATCH";return false;}
 r.state=MA_ME_REQUEST_CANDIDATE;r.role=d.role;r.slotIndex=d.slotIndex;
 r.symbol=symbol;r.magic=magic;r.action=d.action;
 r.reason="READ_ONLY_CANDIDATE_NOT_EXECUTABLE";
 return true;
}
bool MABuildMESavedRequestBoundary100(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slotIndex,const string symbol,const long magic,
 SMA_MERequestBoundary100 &r)
{
 SMA_MEReadOnlyDecision100 d;
 if(!MABuildMEReadOnlyDecision100(store,role,slotIndex,symbol,magic,d))
 {
  MAResetMERequestBoundary100(r);r.reason="UPSTREAM_"+d.reason;return false;
 }
 return MAConvertMEReadOnlyDecisionToRequest100(d,symbol,magic,r);
}
#endif
