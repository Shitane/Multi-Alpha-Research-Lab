#ifndef MULTIALPHA_EA_SLOT_STORE_V1_00_MQH
#define MULTIALPHA_EA_SLOT_STORE_V1_00_MQH
#include "MultiAlpha_Capacity_v1_00.mqh"
// Independent EA SLOT configuration storage, in memory only.
// UI IDs 1..100. Four role references are LOGIC SLOT IDs 1..100.
// No orders, no disk save, no semantic validity assertion.
struct SMA_EASlot100
{
 bool saved;
 bool enabled;
 string name;
 int logic_ref[MA_CAP_LOGIC_ROLES];
};
class CMultiAlphaEASlotStore100
{
private:
 SMA_EASlot100 m[MA_CAP_EA_SLOTS];
 bool ValidIndex(const int id)const{return MACapEASlotId(id);}
 bool ValidRefs(const int &refs[])const
 {
  if(ArraySize(refs)!=MA_CAP_LOGIC_ROLES)return false;
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)
   if(!MACapLogicSlotId(refs[r]))return false;
  return true;
 }
public:
 CMultiAlphaEASlotStore100(){ClearAll();}
 void ClearAll()
 {
  for(int i=0;i<MA_CAP_EA_SLOTS;i++)Clear(i+1);
 }
 bool Clear(const int id)
 {
  if(!ValidIndex(id))return false;
  int s=id-1;
  m[s].saved=false;m[s].enabled=false;m[s].name="";
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)m[s].logic_ref[r]=0;
  return true;
 }
 bool Save(const int id,const string name,const int &refs[],const bool enabled)
 {
  if(!ValidIndex(id)||!ValidRefs(refs))return false;
  int s=id-1;
  m[s].name=name;m[s].enabled=enabled;
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)m[s].logic_ref[r]=refs[r];
  m[s].saved=true;
  return true;
 }
 bool Load(const int id,string &name,int &refs[],bool &enabled)const
 {
  if(!IsSaved(id))return false;
  int s=id-1;
  ArrayResize(refs,MA_CAP_LOGIC_ROLES);
  name=m[s].name;enabled=m[s].enabled;
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)refs[r]=m[s].logic_ref[r];
  return true;
 }
 bool IsSaved(const int id)const{return ValidIndex(id)&&m[id-1].saved;}
 bool IsEnabled(const int id)const{return IsSaved(id)&&m[id-1].enabled;}
 // This flag is NOT a claim that referenced role definitions are valid or runnable.
};
#endif
