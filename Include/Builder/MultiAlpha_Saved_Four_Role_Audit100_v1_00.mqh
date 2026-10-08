#ifndef MULTIALPHA_SAVED_FOUR_ROLE_AUDIT100_V1_00_MQH
#define MULTIALPHA_SAVED_FOUR_ROLE_AUDIT100_V1_00_MQH
#include "MultiAlpha_Saved_Grid_Lamp100_v1_00.mqh"
#include "MultiAlpha_Manage_Exit_Grammar_v1_01.mqh"
#include "MultiAlpha_Builder_Interpreter_v1_06.mqh"
// Conservative 100-Part saved-role audit. Structural validation is NOT runtime certification.
ENUM_MA_SAVED_LAMP100 MAAuditSavedRole100(const CMultiAlphaModuleLibraryStore101 &logic,
 const int role,const int slotId,string &reason)
{
 if(!MACapLogicRole(role)||!MACapLogicSlotId(slotId)){reason="ROLE_OR_REF_INVALID";return MA_SAVED_RED100;}
 if(role==1)return MASavedGridLamp100(logic,slotId,reason);
 int index=slotId-1;
 if(!logic.IsSaved(role,index)){reason="ROLE_UNSAVED";return MA_SAVED_OFF100;}
 if(!logic.IsEnabled(role,index)){reason="ROLE_DISABLED";return MA_SAVED_RED100;}
 string name="",p[],v[];bool enabled=false;
 if(!logic.LoadDefinition(role,index,name,p,v,enabled)){reason="ROLE_LOAD_FAILED";return MA_SAVED_RED100;}
 if(ArraySize(p)!=100||ArraySize(v)!=100){reason="ROLE_SIZE";return MA_SAVED_RED100;}
 if(role==0)
 {
  CMultiAlphaBuilderInterpreter106 it;int map[],actions[],count=0;
  if(!it.BuildEntryBranchMap(p,map,actions,count,reason))return MA_SAVED_RED100;
  reason="ENTRY_STRUCTURE_VALID_RUNTIME_UNPROVEN";return MA_SAVED_RED100;
 }
 if(!MA2KValidateManageExit100(role,p,v,reason))return MA_SAVED_RED100;
 reason="MANAGE_EXIT_STRUCTURE_VALID_RUNTIME_UNPROVEN";return MA_SAVED_RED100;
}
bool MAAuditFourRole100(const CMultiAlphaEASlotStore100 &ea,
 const CMultiAlphaModuleLibraryStore101 &logic,const int eaId,
 ENUM_MA_SAVED_LAMP100 &entry,ENUM_MA_SAVED_LAMP100 &grid,
 ENUM_MA_SAVED_LAMP100 &manage,ENUM_MA_SAVED_LAMP100 &ex,
 string &reason)
{
 entry=MA_SAVED_OFF100;grid=MA_SAVED_OFF100;manage=MA_SAVED_OFF100;ex=MA_SAVED_OFF100;
 string name="";int refs[];bool enabled=false;
 if(!ea.Load(eaId,name,refs,enabled)){reason="EA_UNSAVED";return false;}
 if(!enabled){reason="EA_OFF";return false;}
 if(ArraySize(refs)!=4){reason="EA_REF_COUNT";return false;}
 string r0="",r1="",r2="",r3="";
 entry=MAAuditSavedRole100(logic,0,refs[0],r0);
 grid=MAAuditSavedRole100(logic,1,refs[1],r1);
 manage=MAAuditSavedRole100(logic,2,refs[2],r2);
 ex=MAAuditSavedRole100(logic,3,refs[3],r3);
 reason="ENTRY="+r0+" GRID="+r1+" MANAGE="+r2+" EXIT="+r3;
 // This audit deliberately cannot certify live execution.
 return false;
}
#endif
