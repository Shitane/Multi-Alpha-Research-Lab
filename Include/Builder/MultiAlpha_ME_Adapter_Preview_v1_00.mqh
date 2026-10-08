#ifndef MULTIALPHA_ME_ADAPTER_PREVIEW_V1_00_MQH
#define MULTIALPHA_ME_ADAPTER_PREVIEW_V1_00_MQH
#include "MultiAlpha_ME_Request_Boundary_v1_00.mqh"
// A14-15: fail-closed read-only handoff preview. No broker calls or permissions.
#define MA_ME_PREVIEW_BLOCKED 0
#define MA_ME_PREVIEW_IDLE 1
#define MA_ME_PREVIEW_ACCEPTED 2
struct SMA_MEAdapterPreview100
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
void MAResetMEAdapterPreview100(SMA_MEAdapterPreview100 &out)
{
 out.state=MA_ME_PREVIEW_BLOCKED;out.role=-1;out.slotIndex=-1;
 out.symbol="";out.magic=-1;out.action="";out.reason="NOT_EVALUATED";
 out.brokerArmed=false;
}
bool MAPreviewMERequest100(const SMA_MERequestBoundary100 &r,SMA_MEAdapterPreview100 &out)
{
 MAResetMEAdapterPreview100(out);
 if(r.brokerArmed){out.reason="BROKER_ARMED_REJECT";return false;}
 if(r.symbol==""){out.reason="EMPTY_SYMBOL";return false;}
 if(r.magic<0){out.reason="NEGATIVE_MAGIC";return false;}
 if(r.role!=2&&r.role!=3){out.reason="INVALID_ROLE";return false;}
 if(r.slotIndex<0||r.slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE)
 {out.reason="INVALID_SLOT";return false;}
 if(r.state==MA_ME_REQUEST_NO_SIGNAL)
 {
  if(r.action!=""){out.reason="IDLE_WITH_ACTION";return false;}
  out.state=MA_ME_PREVIEW_IDLE;out.role=r.role;out.slotIndex=r.slotIndex;
  out.symbol=r.symbol;out.magic=r.magic;out.reason="NO_SIGNAL";return true;
 }
 if(r.state!=MA_ME_REQUEST_CANDIDATE)
 {out.reason="NOT_CANDIDATE";return false;}
 bool allowed=(r.role==2&&(r.action=="SINGLE_TRAILING"||r.action=="BASKET_TRAILING"||r.action=="OVERLAP"))
           ||(r.role==3&&(r.action=="CLOSE_SIDE"||r.action=="CLOSE_OPPOSITE"));
 if(!allowed){out.reason="ROLE_ACTION_MISMATCH";return false;}
 out.state=MA_ME_PREVIEW_ACCEPTED;out.role=r.role;out.slotIndex=r.slotIndex;
 out.symbol=r.symbol;out.magic=r.magic;out.action=r.action;
 out.reason="PREVIEW_ONLY_NOT_EXECUTABLE";
 return true;
}
#endif
