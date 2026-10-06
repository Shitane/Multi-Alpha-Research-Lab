//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Instance_Composer_v1_04.mqh                  |
//| M4-2 four-role snapshots, 40 Parts per role. NO ORDERS.         |
//| NO ORDERS. No strategy-specific module IDs.                      |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_INSTANCE_COMPOSER_V1_04_MQH
#define MULTIALPHA_BUILDER_INSTANCE_COMPOSER_V1_04_MQH
#define MA_BUILDER_INSTANCE_COMPOSER_VERSION "1.04"
#define MA_BIC103_INSTANCES 50
#define MA_BIC103_ROLES 4
#define MA_BIC103_SLOTS 40

struct SMA_BuilderRoleSnapshot103
{
 string name;
 string part[MA_BIC103_SLOTS];
 string params[MA_BIC103_SLOTS];
 bool valid;
 string validation_reason;
};

struct SMA_BuilderInstanceSnapshot103
{
 bool assigned;
 int instance_id;
 string logical_symbol;
 long magic;
 SMA_BuilderRoleSnapshot103 role[MA_BIC103_ROLES];
 string route_name;
 uint revision;
};

class CMultiAlphaBuilderInstanceComposer103
{
 private:
  SMA_BuilderInstanceSnapshot103 m_inst[MA_BIC103_INSTANCES];

  void ClearRole(SMA_BuilderRoleSnapshot103 &r)
  {
   r.name="";r.valid=false;r.validation_reason="NOT ASSIGNED";
   for(int i=0;i<MA_BIC103_SLOTS;i++){r.part[i]="EMPTY";r.params[i]="";}
  }
  bool HasAction(const int role,SMA_BuilderRoleSnapshot103 &r)
  {
   for(int i=0;i<MA_BIC103_SLOTS;i++)
   {
    string p=r.part[i];
    if(role==0 && (p=="BUY"||p=="SELL"||p=="SIGNAL BUY"||p=="SIGNAL SELL"||p=="SIGNAL BUY/SELL"))return true;
    if(role==1 && (p=="ADD_BUY"||p=="ADD_SELL"||p=="ADD BUY"||p=="ADD SELL"||p=="ADD GRID"))return true;
    // M4-1: role 2 keeps accepting legacy MANAGE action content until M4-3 semantic split.
    if(role==2 && (p=="ADD_BUY"||p=="ADD_SELL"||p=="ADD BUY"||p=="ADD SELL"||p=="ADD GRID"||p=="SINGLE_TRAILING"||p=="BASKET_TRAILING"||p=="OVERLAP"))return true;
    if(role==3 && (p=="CLOSE_SIDE"||p=="CLOSE"||p=="CLOSE SIDE"||p=="FIXED_TP"||p=="VIRTUAL_SL"||p=="SINGLE_TRAILING"||p=="BASKET_TRAILING"))return true;
   }
   return false;
  }
  bool ValidateRole(const int role,SMA_BuilderRoleSnapshot103 &r,string &why)
  {
   int used=0;
   for(int i=0;i<MA_BIC103_SLOTS;i++)if(r.part[i]!=""&&r.part[i]!="EMPTY")used++;
   if(used==0){why="ROLE EMPTY";return false;}
   if(!HasAction(role,r)){why=(role==0?"ENTRY":role==1?"GRID":role==2?"MANAGE":"EXIT")+" ACTION MISSING";return false;}
   why="OK";return true;
  }
 public:
  CMultiAlphaBuilderInstanceComposer103(){Reset();}
  void Reset()
  {
   for(int n=0;n<MA_BIC103_INSTANCES;n++)
   {
    m_inst[n].assigned=false;m_inst[n].instance_id=n+1;m_inst[n].logical_symbol="";m_inst[n].magic=0;
    m_inst[n].route_name="";m_inst[n].revision=0;
    for(int r=0;r<MA_BIC103_ROLES;r++)ClearRole(m_inst[n].role[r]);
   }
  }
  bool AssignRole(const int instance_id,const int role,const string definition_name,string &parts[],string &values[],string &reason)
  {
   if(instance_id<1||instance_id>MA_BIC103_INSTANCES){reason="INSTANCE RANGE";return false;}
   if(role<0||role>=MA_BIC103_ROLES){reason="ROLE RANGE";return false;}
   if(ArraySize(parts)<MA_BIC103_SLOTS||ArraySize(values)<MA_BIC103_SLOTS){reason="40 PARTS REQUIRED";return false;}
   int n=instance_id-1;
   SMA_BuilderRoleSnapshot103 tmp;ClearRole(tmp);tmp.name=definition_name;
   for(int i=0;i<MA_BIC103_SLOTS;i++){tmp.part[i]=parts[i];tmp.params[i]=values[i];}
   string why="";
   tmp.valid=ValidateRole(role,tmp,why);tmp.validation_reason=why;
   if(!tmp.valid){reason=why;return false;}
   m_inst[n].role[role]=tmp;m_inst[n].assigned=true;m_inst[n].revision++;
   reason="ASSIGNED "+(role==0?"ENTRY":role==1?"GRID":role==2?"MANAGE":"EXIT")+" -> #"+IntegerToString(instance_id);
   return true;
  }
  void SetIdentity(const int instance_id,const string logical_symbol,const long magic)
  {
   if(instance_id<1||instance_id>MA_BIC103_INSTANCES)return;
   int n=instance_id-1;m_inst[n].logical_symbol=logical_symbol;m_inst[n].magic=magic;
  }
  bool Ready(const int instance_id,string &reason)
  {
   if(instance_id<1||instance_id>MA_BIC103_INSTANCES){reason="INSTANCE RANGE";return false;}
   int n=instance_id-1;
   if(!m_inst[n].assigned){reason="NO BUILDER DEFINITION";return false;}
   if(m_inst[n].logical_symbol==""){reason="LOGICAL SYMBOL EMPTY";return false;}
   if(m_inst[n].magic<=0){reason="MAGIC INVALID";return false;}
   for(int r=0;r<MA_BIC103_ROLES;r++)if(!m_inst[n].role[r].valid){reason=(r==0?"ENTRY":r==1?"GRID":r==2?"MANAGE":"EXIT")+": "+m_inst[n].role[r].validation_reason;return false;}
   reason="READY";return true;
  }
  string Summary(const int instance_id)
  {
   if(instance_id<1||instance_id>MA_BIC103_INSTANCES)return "INVALID INSTANCE";
   int n=instance_id-1;string why="";bool ok=Ready(instance_id,why);
   return "#"+IntegerToString(instance_id)+" BUILDER "+(ok?"READY":"DRAFT")+
          " E="+m_inst[n].role[0].name+" G="+m_inst[n].role[1].name+" M="+m_inst[n].role[2].name+" X="+m_inst[n].role[3].name+
          " SYMBOL="+m_inst[n].logical_symbol+" MAGIC="+IntegerToString((int)m_inst[n].magic)+
          " REV="+IntegerToString((int)m_inst[n].revision)+" REASON="+why;
  }
  uint Revision(const int instance_id){return (instance_id>=1&&instance_id<=50)?m_inst[instance_id-1].revision:0;}
};
#endif
