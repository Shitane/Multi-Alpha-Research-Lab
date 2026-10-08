#ifndef MULTIALPHA_MODULE_LIBRARY_STORE_V1_01_MQH
#define MULTIALPHA_MODULE_LIBRARY_STORE_V1_01_MQH
#include "MultiAlpha_Capacity_v1_00.mqh"
#include "MultiAlpha_Module_Library_Store_v1_00.mqh"
// In-memory, independent role-specific 100 slots x 100 Parts.
// No disk persistence, no broker actions, no semantic validity claim.
struct SMA_ModuleSlot101
{
 bool saved;
 bool enabled;
 string name;
 string part[MA_CAP_PARTS_PER_LOGIC];
 string param[MA_CAP_PARTS_PER_LOGIC];
};
class CMultiAlphaModuleLibraryStore101
{
private:
 SMA_ModuleSlot101 m[MA_CAP_LOGIC_ROLES][MA_CAP_LOGIC_SLOTS_PER_ROLE];
 bool Valid(const int role,const int index)const
 {return MACapLogicRole(role)&&index>=0&&index<MA_CAP_LOGIC_SLOTS_PER_ROLE;}
public:
 CMultiAlphaModuleLibraryStore101(){ClearAll();}
 void ClearAll()
 {
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)
   for(int s=0;s<MA_CAP_LOGIC_SLOTS_PER_ROLE;s++)ClearSlot(r,s);
 }
 bool ClearSlot(const int role,const int index)
 {
  if(!Valid(role,index))return false;
  m[role][index].saved=false;m[role][index].enabled=false;m[role][index].name="";
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
  {m[role][index].part[i]="EMPTY";m[role][index].param[i]="";}
  return true;
 }
 bool SaveDefinition(const int role,const int index,const string name,
                     const string &parts[],const string &params[],const bool enabled)
 {
  if(!Valid(role,index)||ArraySize(parts)!=MA_CAP_PARTS_PER_LOGIC||ArraySize(params)!=MA_CAP_PARTS_PER_LOGIC)return false;
  m[role][index].name=name;m[role][index].enabled=enabled;
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
  {m[role][index].part[i]=parts[i];m[role][index].param[i]=params[i];}
  m[role][index].saved=true;return true;
 }
 bool LoadDefinition(const int role,const int index,string &name,string &parts[],
                     string &params[],bool &enabled)const
 {
  if(!IsSaved(role,index))return false;
  ArrayResize(parts,MA_CAP_PARTS_PER_LOGIC);ArrayResize(params,MA_CAP_PARTS_PER_LOGIC);
  name=m[role][index].name;enabled=m[role][index].enabled;
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
  {parts[i]=m[role][index].part[i];params[i]=m[role][index].param[i];}
  return true;
 }
 bool IsSaved(const int role,const int index)const
 {return Valid(role,index)&&m[role][index].saved;}
 bool IsEnabled(const int role,const int index)const
 {return IsSaved(role,index)&&m[role][index].enabled;}
 // Legacy 40 Parts -> first 40 unchanged; remaining 60 EMPTY.
 // Explicit conversion only; no truncation of newer 100-Part definitions.
 bool ImportLegacy40(const int role,const int index,const string name,
                     const string &oldParts[],const string &oldParams[],const bool enabled)
 {
  if(!Valid(role,index)||ArraySize(oldParts)!=40||ArraySize(oldParams)!=40)return false;
  string p[],v[];ArrayResize(p,MA_CAP_PARTS_PER_LOGIC);ArrayResize(v,MA_CAP_PARTS_PER_LOGIC);
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
  {
   p[i]=(i<40?oldParts[i]:"EMPTY");
   v[i]=(i<40?oldParams[i]:"");
  }
  return SaveDefinition(role,index,name,p,v,enabled);
 }
};
#endif
