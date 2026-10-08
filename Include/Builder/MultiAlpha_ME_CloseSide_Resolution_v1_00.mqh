#ifndef MULTIALPHA_ME_CLOSESIDE_RESOLUTION_V1_00_MQH
#define MULTIALPHA_ME_CLOSESIDE_RESOLUTION_V1_00_MQH
#include "MultiAlpha_ME_Execution_Capability_Gate_v1_00.mqh"
// A14-18: conservative SIDE_COUNT-side inference, NEVER a trade instruction.
// A predicate's SIDE is not automatically a CLOSE_SIDE target in generic grammar.
// Only an unambiguous candidate is reported; brokerArmed is always false.
#define MA_ME_SIDE_BLOCKED 0
#define MA_ME_SIDE_CANDIDATE 1
struct SMA_MECloseSideResolution100
{
 int state;
 int side;
 string reason;
 bool brokerArmed;
};
void MAResetMECloseSideResolution100(SMA_MECloseSideResolution100 &out)
{
 out.state=MA_ME_SIDE_BLOCKED;out.side=-1;
 out.reason="NOT_EVALUATED";out.brokerArmed=false;
}
bool MAResolveCloseSideCandidate100(const CMultiAlphaModuleLibraryStore101 &store,
 const SMA_MEAdapterPreview100 &preview,
 const SMA_MEExecutionCapability100 &cap,
 SMA_MECloseSideResolution100 &out)
{
 MAResetMECloseSideResolution100(out);
 if(preview.brokerArmed||cap.brokerArmed){out.reason="ARMED_REJECT";return false;}
 if(preview.state!=MA_ME_PREVIEW_ACCEPTED||preview.role!=3||
    preview.action!="CLOSE_SIDE"||cap.state!=MA_ME_CAP_MAPPED||
    cap.method!="CloseSide")
 {out.reason="NOT_MAPPED_EXIT_CLOSE_SIDE";return false;}
 if(preview.symbol==""||preview.magic<=0||preview.slotIndex<0||
    preview.slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE)
 {out.reason="INVALID_IDENTITY_OR_SLOT";return false;}
 if(!store.IsSaved(3,preview.slotIndex)||!store.IsEnabled(3,preview.slotIndex))
 {out.reason="UNSAVED_OR_DISABLED";return false;}
 string name="",p[],v[];bool enabled=false;
 if(!store.LoadDefinition(3,preview.slotIndex,name,p,v,enabled)||!enabled)
 {out.reason="LOAD_FAILED";return false;}
 string why="";
 if(!MA2KValidateManageExit100(3,p,v,why))
 {out.reason="GRAMMAR_"+why;return false;}
 int side=-1,conditions=0,actions=0;
 for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
 {
  string part=MA101CanonicalPart(p[i]);
  if(part==""||part=="EMPTY"||part=="AND")continue;
  if(part=="OR"){out.reason="OR_AMBIGUOUS";return false;}
  if(part=="CLOSE_SIDE"){actions++;continue;}
  if(part!="SIDE_COUNT"){out.reason="UNSUPPORTED_PREDICATE_"+part;return false;}
  string s=MA101Param(v[i],"SIDE","");
  if(s!="BUY"&&s!="SELL"){out.reason="SIDE_UNSPECIFIED";return false;}
  int nextSide=s=="BUY"?(int)POSITION_TYPE_BUY:(int)POSITION_TYPE_SELL;
  if(side>=0&&side!=nextSide){out.reason="MIXED_SIDES";return false;}
  side=nextSide;conditions++;
 }
 if(conditions==0||actions!=1||side<0)
 {out.reason="MISSING_CONDITION_OR_ACTION";return false;}
 out.state=MA_ME_SIDE_CANDIDATE;out.side=side;
 out.reason="SIDE_COUNT_PREDICATE_SIDE_ONLY_NOT_AUTHORIZED_TARGET";
 return true;
}
#endif
