//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Module_Registry_v1_00.mqh                    |
//| LB-01 Builder registration bridge. NO ORDERS / VIRTUAL NOT FILL. |
//| String identities coexist with frozen code-defined module IDs.    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_MODULE_REGISTRY_V1_00_MQH
#define MULTIALPHA_BUILDER_MODULE_REGISTRY_V1_00_MQH

#define MA_BUILDER_MODULE_REGISTRY_VERSION "1.00"

enum ENUM_MA_BUILDER_CAPABILITY100
{
 MA_BUILDER_CAP_FULL100=0,
 MA_BUILDER_CAP_ENTRY100=1,
 MA_BUILDER_CAP_MANAGE100=2,
 MA_BUILDER_CAP_EXIT100=3
};

struct SMA_BuilderModuleRegistration100
{
 string id;
 string label;
 string version;
 ENUM_MA_BUILDER_CAPABILITY100 capability;
 bool verified;
};

class CMultiAlphaBuilderModuleRegistry100
{
private:
 SMA_BuilderModuleRegistration100 m_items[8];
 int m_count;

 void Add(const string id,const string label,const string version,
          const ENUM_MA_BUILDER_CAPABILITY100 capability,const bool verified)
 {
  if(m_count>=8)return;
  m_items[m_count].id=id;
  m_items[m_count].label=label;
  m_items[m_count].version=version;
  m_items[m_count].capability=capability;
  m_items[m_count].verified=verified;
  m_count++;
 }

public:
 CMultiAlphaBuilderModuleRegistry100(){m_count=0;}

 void BuildVerifiedO01()
 {
  m_count=0;
  Add("BUILDER_E01","O01 Builder ENTRY","1.00",MA_BUILDER_CAP_ENTRY100,true);
  Add("BUILDER_M01","O01 Builder MANAGE","1.00",MA_BUILDER_CAP_MANAGE100,true);
  Add("BUILDER_X01","O01 Builder EXIT","1.00",MA_BUILDER_CAP_EXIT100,true);
  Add("BUILDER_O01_FULL","O01 Builder FULL","1.00",MA_BUILDER_CAP_FULL100,true);
 }

 int Count() const { return m_count; }

 bool Get(const int index,SMA_BuilderModuleRegistration100 &out) const
 {
  if(index<0 || index>=m_count)return false;
  out=m_items[index];
  return true;
 }

 bool IsRegistered(const string id,const ENUM_MA_BUILDER_CAPABILITY100 capability) const
 {
  for(int i=0;i<m_count;i++)
   if(m_items[i].id==id && m_items[i].capability==capability && m_items[i].verified)
      return true;
  return false;
 }

 bool ValidateSplit(const string entry_id,const string manage_id,const string exit_id,string &reason) const
 {
  if(!IsRegistered(entry_id,MA_BUILDER_CAP_ENTRY100)){reason=entry_id+" ENTRY NOT REGISTERED";return false;}
  if(!IsRegistered(manage_id,MA_BUILDER_CAP_MANAGE100)){reason=manage_id+" MANAGE NOT REGISTERED";return false;}
  if(!IsRegistered(exit_id,MA_BUILDER_CAP_EXIT100)){reason=exit_id+" EXIT NOT REGISTERED";return false;}
  reason="READY"; return true;
 }

 bool ValidateFull(const string full_id,string &reason) const
 {
  if(!IsRegistered(full_id,MA_BUILDER_CAP_FULL100)){reason=full_id+" FULL NOT REGISTERED";return false;}
  reason="READY"; return true;
 }
};

#endif
