//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Slot_Workspace_Store_v1_00.mqh               |
//| Per-instance Builder workspace: 50 x (ENTRY/MANAGE/EXIT x 24).   |
//| Data only / NO ORDERS.                                           |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_SLOT_WORKSPACE_STORE_V1_00_MQH
#define MULTIALPHA_BUILDER_SLOT_WORKSPACE_STORE_V1_00_MQH
#define MA_BSWS100_INSTANCES 50
#define MA_BSWS100_ROLES 3
#define MA_BSWS100_PARTS 24

struct SMA_BuilderSlotWorkspace100
{
 string name[MA_BSWS100_ROLES];
 string part[MA_BSWS100_ROLES][MA_BSWS100_PARTS];
 string params[MA_BSWS100_ROLES][MA_BSWS100_PARTS];
 bool initialized;
 uint revision;
};

class CMultiAlphaBuilderSlotWorkspaceStore100
{
 private:
  SMA_BuilderSlotWorkspace100 m_slot[MA_BSWS100_INSTANCES];
  bool Valid(const int slot){return slot>=1&&slot<=MA_BSWS100_INSTANCES;}
 public:
  CMultiAlphaBuilderSlotWorkspaceStore100(){Reset();}
  void Reset()
  {
   for(int s=0;s<MA_BSWS100_INSTANCES;s++)
   {
    m_slot[s].initialized=false;m_slot[s].revision=0;
    for(int r=0;r<MA_BSWS100_ROLES;r++)
    {
     m_slot[s].name[r]="";
     for(int i=0;i<MA_BSWS100_PARTS;i++){m_slot[s].part[r][i]="EMPTY";m_slot[s].params[r][i]="";}
    }
   }
  }
  bool PutRole(const int slot,const int role,const string name,string &part[],string &params[])
  {
   if(!Valid(slot)||role<0||role>=3||ArraySize(part)<24||ArraySize(params)<24)return false;
   int s=slot-1;m_slot[s].name[role]=name;
   for(int i=0;i<24;i++){m_slot[s].part[role][i]=part[i];m_slot[s].params[role][i]=params[i];}
   m_slot[s].initialized=true;m_slot[s].revision++;return true;
  }
  bool GetRole(const int slot,const int role,string &name,string &part[],string &params[])
  {
   ArrayResize(part,24);ArrayResize(params,24);
   if(!Valid(slot)||role<0||role>=3)return false;
   int s=slot-1;name=m_slot[s].name[role];
   for(int i=0;i<24;i++){part[i]=m_slot[s].part[role][i];params[i]=m_slot[s].params[role][i];}
   return m_slot[s].initialized;
  }
  bool Initialized(const int slot){return Valid(slot)?m_slot[slot-1].initialized:false;}
  uint Revision(const int slot){return Valid(slot)?m_slot[slot-1].revision:0;}
};
#endif
