#ifndef MULTIALPHA_ME_EXECUTION_CAPABILITY_GATE_V1_00_MQH
#define MULTIALPHA_ME_EXECUTION_CAPABILITY_GATE_V1_00_MQH
#include "MultiAlpha_ME_Adapter_Preview_v1_00.mqh"
// A14-17: descriptive capability mapping only; no broker adapter included or initialized.
// A capability match is NOT execution authorization.
#define MA_ME_CAP_BLOCKED 0
#define MA_ME_CAP_IDLE 1
#define MA_ME_CAP_MAPPED 2
struct SMA_MEExecutionCapability100
{
 int state;
 string method;
 string reason;
 bool brokerArmed;
};
void MAResetMEExecutionCapability100(SMA_MEExecutionCapability100 &out)
{
 out.state=MA_ME_CAP_BLOCKED;out.method="";out.reason="NOT_EVALUATED";
 out.brokerArmed=false;
}
bool MAEvaluateMEExecutionCapability100(const SMA_MEAdapterPreview100 &preview,
 SMA_MEExecutionCapability100 &out)
{
 MAResetMEExecutionCapability100(out);
 if(preview.brokerArmed){out.reason="BROKER_ARMED_REJECT";return false;}
 if(preview.symbol==""||preview.magic<=0){out.reason="INVALID_IDENTITY";return false;}
 if(preview.slotIndex<0||preview.slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE)
 {out.reason="INVALID_SLOT";return false;}
 if(preview.role!=2&&preview.role!=3){out.reason="INVALID_ROLE";return false;}
 if(preview.state==MA_ME_PREVIEW_IDLE)
 {
  if(preview.action!=""){out.reason="IDLE_WITH_ACTION";return false;}
  out.state=MA_ME_CAP_IDLE;out.reason="NO_SIGNAL";return true;
 }
 if(preview.state!=MA_ME_PREVIEW_ACCEPTED)
 {out.reason="NOT_ACCEPTED";return false;}
 if(preview.role==3&&preview.action=="CLOSE_SIDE")
 {
  // Existing v1_73 API: CloseSide(ENUM_POSITION_TYPE side,string &reason).
  // Side is NOT carried by preview; mapping alone must never call the API.
  out.state=MA_ME_CAP_MAPPED;
  out.method="CloseSide";
  out.reason="SIDE_ARGUMENT_MISSING_PREVIEW_ONLY";
  return true;
 }
 if(preview.role==3&&preview.action=="CLOSE_OPPOSITE")
 {out.reason="OPPOSITE_SIDE_RESOLUTION_REQUIRED";return false;}
 if(preview.role==2&&(preview.action=="SINGLE_TRAILING"||
    preview.action=="BASKET_TRAILING"||preview.action=="OVERLAP"))
 {out.reason="NO_DIRECT_V173_METHOD";return false;}
 out.reason="UNSUPPORTED_ROLE_ACTION";
 return false;
}
#endif
