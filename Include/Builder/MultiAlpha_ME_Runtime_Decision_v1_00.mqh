#ifndef MULTIALPHA_ME_RUNTIME_DECISION_V1_00_MQH
#define MULTIALPHA_ME_RUNTIME_DECISION_V1_00_MQH
#include "MultiAlpha_Saved_ME_Metrics_Gate_v1_01.mqh"
// A14-13: read-only decision boundary. NOT an execution adapter.
// 0=BLOCKED, 1=NO_SIGNAL, 2=INTENT_ONLY. No trade methods exist here.
#define MA_ME_DECISION_BLOCKED 0
#define MA_ME_DECISION_NO_SIGNAL 1
#define MA_ME_DECISION_INTENT_ONLY 2
struct SMA_MEReadOnlyDecision100
{
 int state;
 int role;
 int slotIndex;
 bool fire;
 string action;
 string reason;
};
void MAResetMEReadOnlyDecision100(SMA_MEReadOnlyDecision100 &d)
{
 d.state=MA_ME_DECISION_BLOCKED;d.role=-1;d.slotIndex=-1;
 d.fire=false;d.action="";d.reason="NOT_EVALUATED";
}
bool MABuildMEReadOnlyDecision100(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slotIndex,const string symbol,const long magic,
 SMA_MEReadOnlyDecision100 &d)
{
 MAResetMEReadOnlyDecision100(d);
 d.role=role;d.slotIndex=slotIndex;
 bool fire=false;string action="",reason="";
 bool ok=MASavedMEMetricsIntent100(store,role,slotIndex,symbol,magic,fire,action,reason);
 if(!ok){d.reason=reason;return false;}
 if(!fire)
 {
  if(action!=""){d.reason="INCONSISTENT_NO_SIGNAL_ACTION";return false;}
  d.state=MA_ME_DECISION_NO_SIGNAL;d.reason=reason;return true;
 }
 bool allowed=(role==2&&(action=="SINGLE_TRAILING"||action=="BASKET_TRAILING"||action=="OVERLAP"))
           ||(role==3&&(action=="CLOSE_SIDE"||action=="CLOSE_OPPOSITE"));
 if(!allowed){d.reason="UNSUPPORTED_ROLE_ACTION";return false;}
 d.state=MA_ME_DECISION_INTENT_ONLY;d.fire=true;d.action=action;d.reason=reason;
 return true;
}
#endif
