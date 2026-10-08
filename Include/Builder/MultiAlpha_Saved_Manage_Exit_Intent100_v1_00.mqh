#ifndef MULTIALPHA_SAVED_MANAGE_EXIT_INTENT100_V1_00_MQH
#define MULTIALPHA_SAVED_MANAGE_EXIT_INTENT100_V1_00_MQH
#include "MultiAlpha_Module_Library_Store_v1_01.mqh"
#include "MultiAlpha_Manage_Exit_Intent100_v1_00.mqh"
// Role index 2=MANAGE, 3=EXIT. Slot index 0..99 (UI slot ID minus one).
// Evaluate a saved, enabled definition; fail closed. Flags are external condition truths.
// Intent only: no broker action and no runtime certification.
bool MASavedManageExitIntent100(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slotIndex,const bool &flags[],
 bool &fire,string &action,string &reason)
{
 fire=false;action="";
 if(role!=2&&role!=3){reason="ROLE_NOT_MANAGE_EXIT";return false;}
 if(slotIndex<0||slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE){reason="SLOT_OUT_OF_RANGE";return false;}
 if(!store.IsSaved(role,slotIndex)){reason="SLOT_UNSAVED";return false;}
 if(!store.IsEnabled(role,slotIndex)){reason="SLOT_DISABLED";return false;}
 string name="",p[],v[];bool enabled=false;
 if(!store.LoadDefinition(role,slotIndex,name,p,v,enabled)||!enabled)
 {reason="LOAD_FAILED";return false;}
 if(!MAIntent100(role,p,v,flags,fire,action,reason))
 {fire=false;action="";return false;}
 return true;
}
#endif
