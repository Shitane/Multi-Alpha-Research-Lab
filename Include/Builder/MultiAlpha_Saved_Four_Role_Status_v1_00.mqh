#ifndef MA_SAVED_FOUR_ROLE_STATUS_V100
#define MA_SAVED_FOUR_ROLE_STATUS_V100
#include "MultiAlpha_Module_Library_Store_v1_00.mqh"
#include "MultiAlpha_Logic_Lamp_v1_01.mqh"
// Role-specific slot IDs are 1-based; store indices are 0-based.
// Invalid/missing references fail closed. No broker actions.
ENUM_MA_LAMP101 MASavedRoleLamp100(const CMultiAlphaModuleLibraryStore100 &store,const int role,const int slotId,string &reason)
{
 if(role<0||role>3||slotId<1||slotId>MA_MLS100_SLOT_COUNT){reason="REF_OUT_OF_RANGE";return MA_LAMP_OFF101;}
 string name="",parts[],params[];bool enabled=false;
 if(!store.LoadDefinition(role,slotId-1,name,parts,params,enabled)){reason="UNSAVED";return MA_LAMP_OFF101;}
 return MA101RoleLamp(role,true,parts,params,reason);
}
ENUM_MA_LAMP101 MASavedEASlotLamp100(const CMultiAlphaModuleLibraryStore100 &store,const int entryId,const int gridId,const int manageId,const int exitId,string &reason)
{
 string re="",rg="",rm="",rx="";
 ENUM_MA_LAMP101 e=MASavedRoleLamp100(store,0,entryId,re);
 ENUM_MA_LAMP101 g=MASavedRoleLamp100(store,1,gridId,rg);
 ENUM_MA_LAMP101 m=MASavedRoleLamp100(store,2,manageId,rm);
 ENUM_MA_LAMP101 x=MASavedRoleLamp100(store,3,exitId,rx);
 ENUM_MA_LAMP101 result=MA101EASlotLamp(e,g,m,x);
 reason="ENTRY="+re+" GRID="+rg+" MANAGE="+rm+" EXIT="+rx;
 return result;
}
bool MASavedEASlotRunnable100(const ENUM_MA_LAMP101 lamp,const bool eaSlotOn)
{return eaSlotOn&&(lamp==MA_LAMP_GREEN101||lamp==MA_LAMP_ORANGE101);}
#endif
