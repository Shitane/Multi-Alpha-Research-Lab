//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Instance_Composer_v1_01.mqh                  |
//| 50-instance Builder route snapshots. UI/runtime bridge only.     |
//| NO ORDERS. No strategy-specific module IDs.                      |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_INSTANCE_COMPOSER_V1_01_MQH
#define MULTIALPHA_BUILDER_INSTANCE_COMPOSER_V1_01_MQH
#define MA_BUILDER_INSTANCE_COMPOSER_VERSION "1.00"
#define MA_BIC101_INSTANCES 50
#define MA_BIC101_ROLES 3
#define MA_BIC101_SLOTS 24

struct SMA_BuilderRoleSnapshot101
{
 string name;
 string part[MA_BIC101_SLOTS];
 string params[MA_BIC101_SLOTS];
 bool valid;
 string validation_reason;
};

struct SMA_BuilderInstanceSnapshot101
{
 bool assigned;
 int instance_id;
 string logical_symbol;
 long magic;
 SMA_BuilderRoleSnapshot101 role[MA_BIC101_ROLES];
 string route_name;
 uint revision;
};

class CMultiAlphaBuilderInstanceComposer101
{
 private:
  SMA_BuilderInstanceSnapshot101 m_inst[MA_BIC101_INSTANCES];

  void ClearRole(SMA_BuilderRoleSnapshot101 &r)
  {
   r.name="";r.valid=false;r.validation_reason="NOT ASSIGNED";
   for(int i=0;i<MA_BIC101_SLOTS;i++){r.part[i]="EMPTY";r.params[i]="";}
  }
  bool HasAction(const int role,SMA_BuilderRoleSnapshot101 &r)
  {
   for(int i=0;i<MA_BIC101_SLOTS;i++)
   {
    string p=r.part[i];
    if(role==0 && (p=="BUY"||p=="SELL"||p=="SIGNAL BUY"||p=="SIGNAL SELL"||p=="SIGNAL BUY/SELL"))return true;
    if(role==1 && (p=="ADD_BUY"||p=="ADD_SELL"||p=="ADD BUY"||p=="ADD SELL"||p=="ADD GRID"))return true;
    if(role==2 && (p=="CLOSE_SIDE"||p=="CLOSE"||p=="CLOSE SIDE"||p=="FIXED_TP"||p=="VIRTUAL_SL"||p=="SINGLE_TRAILING"||p=="BASKET_TRAILING"))return true;
   }
   return false;
  }
  bool ValidateRole(const int role,SMA_BuilderRoleSnapshot101 &r,string &why)
  {
   int used=0;
   for(int i=0;i<MA_BIC101_SLOTS;i++)if(r.part[i]!=""&&r.part[i]!="EMPTY")used++;
   if(used==0){why="ROLE EMPTY";return false;}
   if(!HasAction(role,r)){why=(role==0?"ENTRY":role==1?"MANAGE":"EXIT")+" ACTION MISSING";return false;}
   why="OK";return true;
  }
 public:
  CMultiAlphaBuilderInstanceComposer101(){Reset();}
  void Reset()
  {
   for(int n=0;n<MA_BIC101_INSTANCES;n++)
   {
    m_inst[n].assigned=false;m_inst[n].instance_id=n+1;m_inst[n].logical_symbol="";m_inst[n].magic=0;
    m_inst[n].route_name="";m_inst[n].revision=0;
    for(int r=0;r<MA_BIC101_ROLES;r++)ClearRole(m_inst[n].role[r]);
   }
  }
  bool AssignRole(const int instance_id,const int role,const string definition_name,string &parts[],string &values[],string &reason)
  {
   if(instance_id<1||instance_id>MA_BIC101_INSTANCES){reason="INSTANCE RANGE";return false;}
   if(role<0||role>=MA_BIC101_ROLES){reason="ROLE RANGE";return false;}
   if(ArraySize(parts)<MA_BIC101_SLOTS||ArraySize(values)<MA_BIC101_SLOTS){reason="24 SLOTS REQUIRED";return false;}
   int n=instance_id-1;
   SMA_BuilderRoleSnapshot101 tmp;ClearRole(tmp);tmp.name=definition_name;
   for(int i=0;i<MA_BIC101_SLOTS;i++){tmp.part[i]=parts[i];tmp.params[i]=values[i];}
   string why="";
   tmp.valid=ValidateRole(role,tmp,why);tmp.validation_reason=why;
   if(!tmp.valid){reason=why;return false;}
   m_inst[n].role[role]=tmp;m_inst[n].assigned=true;m_inst[n].revision++;
   reason="ASSIGNED "+(role==0?"ENTRY":role==1?"MANAGE":"EXIT")+" -> #"+IntegerToString(instance_id);
   return true;
  }
  void SetIdentity(const int instance_id,const string logical_symbol,const long magic)
  {
   if(instance_id<1||instance_id>MA_BIC101_INSTANCES)return;
   int n=instance_id-1;m_inst[n].logical_symbol=logical_symbol;m_inst[n].magic=magic;
  }
  bool Ready(const int instance_id,string &reason)
  {
   if(instance_id<1||instance_id>MA_BIC101_INSTANCES){reason="INSTANCE RANGE";return false;}
   int n=instance_id-1;
   if(!m_inst[n].assigned){reason="NO BUILDER DEFINITION";return false;}
   if(m_inst[n].logical_symbol==""){reason="LOGICAL SYMBOL EMPTY";return false;}
   if(m_inst[n].magic<=0){reason="MAGIC INVALID";return false;}
   for(int r=0;r<3;r++)if(!m_inst[n].role[r].valid){reason=(r==0?"ENTRY":r==1?"MANAGE":"EXIT")+": "+m_inst[n].role[r].validation_reason;return false;}
   reason="READY";return true;
  }
  string Summary(const int instance_id)
  {
   if(instance_id<1||instance_id>MA_BIC101_INSTANCES)return "INVALID INSTANCE";
   int n=instance_id-1;string why="";bool ok=Ready(instance_id,why);
   return "#"+IntegerToString(instance_id)+" BUILDER "+(ok?"READY":"DRAFT")+
          " E="+m_inst[n].role[0].name+" M="+m_inst[n].role[1].name+" X="+m_inst[n].role[2].name+
          " SYMBOL="+m_inst[n].logical_symbol+" MAGIC="+IntegerToString((int)m_inst[n].magic)+
          " REV="+IntegerToString((int)m_inst[n].revision)+" REASON="+why;
  }
  uint Revision(const int instance_id){return (instance_id>=1&&instance_id<=50)?m_inst[instance_id-1].revision:0;}
};
#endif
