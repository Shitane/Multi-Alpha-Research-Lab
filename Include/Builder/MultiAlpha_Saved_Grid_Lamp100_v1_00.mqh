#ifndef MULTIALPHA_SAVED_GRID_LAMP100_V1_00_MQH
#define MULTIALPHA_SAVED_GRID_LAMP100_V1_00_MQH
#include "MultiAlpha_EA_Slot_Store_v1_00.mqh"
#include "MultiAlpha_Module_Library_Store_v1_01.mqh"
#include "MultiAlpha_Grid100_Compatibility_Gate_v1_00.mqh"
// Independent 100-Part GRID lamp. Never converts structural references to runnable.
enum ENUM_MA_SAVED_LAMP100 { MA_SAVED_OFF100=0, MA_SAVED_RED100=1, MA_SAVED_GREEN100=2, MA_SAVED_ORANGE100=3 };
ENUM_MA_SAVED_LAMP100 MASavedGridLamp100(const CMultiAlphaModuleLibraryStore101 &logic,
                                         const int slotId,string &reason)
{
 if(!MACapLogicSlotId(slotId)){reason="GRID_REF_INVALID";return MA_SAVED_RED100;}
 const int index=slotId-1;
 if(!logic.IsSaved(1,index)){reason="GRID_UNSAVED";return MA_SAVED_OFF100;}
 if(!logic.IsEnabled(1,index)){reason="GRID_DISABLED";return MA_SAVED_RED100;}
 string name="",p[],v[];bool enabled=false;
 if(!logic.LoadDefinition(1,index,name,p,v,enabled)){reason="GRID_LOAD_FAILED";return MA_SAVED_RED100;}
 CMultiAlphaGrid100Gate gate;
 ENUM_MA_GRID100_MODE mode=gate.Validate(p,v,reason);
 if(mode==MA_GRID100_OFF)return MA_SAVED_ORANGE100;
 // Legacy O01 structural plan is not sufficient proof of generic runtime equivalence.
 if(mode==MA_GRID100_LEGACY_O01){reason="GRID_LEGACY_SEMANTICS_UNPROVEN";return MA_SAVED_RED100;}
 return MA_SAVED_RED100;
}
ENUM_MA_SAVED_LAMP100 MASavedEASlotGridPreview100(const CMultiAlphaEASlotStore100 &ea,
                                                  const CMultiAlphaModuleLibraryStore101 &logic,
                                                  const int eaId,string &reason)
{
 string name="";int refs[];bool enabled=false;
 if(!ea.Load(eaId,name,refs,enabled)){reason="EA_UNSAVED";return MA_SAVED_OFF100;}
 if(!enabled){reason="EA_OFF";return MA_SAVED_OFF100;}
 if(ArraySize(refs)!=4){reason="EA_REFS_INVALID";return MA_SAVED_RED100;}
 ENUM_MA_SAVED_LAMP100 grid=MASavedGridLamp100(logic,refs[1],reason);
 if(grid==MA_SAVED_ORANGE100){reason="GRID_ORANGE_ONLY_EA_NOT_CERTIFIED";return MA_SAVED_ORANGE100;}
 return grid;
}
// Intentionally false: role-specific semantic validation must precede runnable certification.
bool MASavedEASlotRunnableCertified100(const CMultiAlphaEASlotStore100 &ea,
                                       const CMultiAlphaModuleLibraryStore101 &logic,
                                       const int eaId,string &reason)
{
 ENUM_MA_SAVED_LAMP100 preview=MASavedEASlotGridPreview100(ea,logic,eaId,reason);
 if(preview==MA_SAVED_ORANGE100)reason="OTHER_ROLES_NOT_INTERPRETER_CERTIFIED";
 return false;
}
#endif
