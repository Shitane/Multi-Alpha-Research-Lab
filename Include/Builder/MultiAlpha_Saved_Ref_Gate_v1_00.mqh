#ifndef MULTIALPHA_SAVED_REF_GATE_V1_00_MQH
#define MULTIALPHA_SAVED_REF_GATE_V1_00_MQH
#include "MultiAlpha_EA_Slot_Store_v1_00.mqh"
#include "MultiAlpha_Module_Library_Store_v1_01.mqh"
// Structural reference check only. Does not certify Interpreter semantics.
// EA references are 1..100; library indices are 0..99.
class CMultiAlphaSavedRefGate100
{
public:
 bool Resolve(const int ea_id,CMultiAlphaEASlotStore100 &ea,
              CMultiAlphaModuleLibraryStore101 &logic,string &reason)
 {
  if(!MACapEASlotId(ea_id)){reason="EA_ID_INVALID";return false;}
  string label="";int refs[];bool enabled=false;
  if(!ea.Load(ea_id,label,refs,enabled)){reason="EA_UNSAVED";return false;}
  if(!enabled){reason="EA_OFF";return false;}
  if(ArraySize(refs)!=MA_CAP_LOGIC_ROLES){reason="REF_COUNT_INVALID";return false;}
  for(int role=0;role<MA_CAP_LOGIC_ROLES;role++)
  {
   int slot_id=refs[role];
   if(!MACapLogicSlotId(slot_id)){reason="REF_ID_INVALID";return false;}
   int index=slot_id-1;
   if(!logic.IsSaved(role,index))
   {reason="ROLE_"+IntegerToString(role)+"_UNSAVED";return false;}
   if(!logic.IsEnabled(role,index))
   {reason="ROLE_"+IntegerToString(role)+"_OFF";return false;}
  }
  reason="REFERENCES_RESOLVED_SEMANTICS_UNPROVEN";
  return true;
 }
};
#endif
