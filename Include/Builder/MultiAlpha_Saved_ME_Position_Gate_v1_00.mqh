#ifndef MULTIALPHA_SAVED_ME_POSITION_GATE_V1_00_MQH
#define MULTIALPHA_SAVED_ME_POSITION_GATE_V1_00_MQH
#include "MultiAlpha_Position_State_Adapter_v1_00.mqh"
#include "MultiAlpha_Saved_Manage_Exit_Intent100_v1_00.mqh"
// A14-6: saved 100-Part MANAGE/EXIT -> exact symbol+magic position counts -> intent.
// Fail closed. Only SIDE_COUNT supported. No trading actions or runtime certification.
bool MASavedMEPositionIntent100(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slotIndex,const string symbol,const long magic,
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
 SMA_MEState100 state;string why="";
 if(!MAPositionState100(symbol,magic,state,why)){reason="POSITION_"+why;return false;}
 bool flags[];
 if(!MAMEStateFlags100(role,p,v,state,flags,why)){reason="CONDITION_"+why;return false;}
 if(!MASavedManageExitIntent100(store,role,slotIndex,flags,fire,action,why))
 {fire=false;action="";reason="INTENT_"+why;return false;}
 reason="READ_ONLY_POSITION_INTENT";return true;
}
#endif
