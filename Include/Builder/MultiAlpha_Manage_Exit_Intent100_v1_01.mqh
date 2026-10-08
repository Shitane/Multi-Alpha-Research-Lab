#ifndef MULTIALPHA_MANAGE_EXIT_INTENT100_V1_01_MQH
#define MULTIALPHA_MANAGE_EXIT_INTENT100_V1_01_MQH
#include "MultiAlpha_Manage_Exit_Grammar_v1_01.mqh"
// Limited semantics: conjunction of supplied condition flags, exactly one terminal action.
// Never modifies positions, sends orders, or certifies the complete role runtime.
bool MAIntent101(const int role,const string &p[],const string &v[],
 const bool &flags[],bool &fire,string &action,string &reason)
{
 fire=false;action="";
 if(ArraySize(flags)!=100){reason="FLAGS_SIZE";return false;}
 if(!MA2KValidateManageExit100(role,p,v,reason))return false;
 int actions=0,conditions=0;bool all=true,seenAction=false;
 for(int i=0;i<100;i++)
 {
  string part=MA101CanonicalPart(p[i]);
  if(part==""||part=="EMPTY")continue;
  if(part=="OR"){reason="OR_UNSUPPORTED";return false;}
  if(part=="AND")continue;
  bool isAction=(role==2&&(part=="SINGLE_TRAILING"||part=="BASKET_TRAILING"||part=="OVERLAP"))
              ||(role==3&&(part=="CLOSE_SIDE"||part=="CLOSE_OPPOSITE"));
  if(isAction)
  {
   actions++;action=part;seenAction=true;
   if(i<99)for(int j=i+1;j<100;j++)
   {
    string after=MA101CanonicalPart(p[j]);
    if(after!=""&&after!="EMPTY"){reason="ACTION_NOT_TERMINAL";fire=false;action="";return false;}
   }
  }
  else
  {
   if(seenAction){reason="CONDITION_AFTER_ACTION";return false;}
   conditions++;all=all&&flags[i];
  }
 }
 if(actions!=1||conditions<1){reason="SINGLE_TERMINAL_ACTION_REQUIRED";fire=false;action="";return false;}
 fire=all;if(!fire)action="";reason="INTENT_ONLY_NO_BROKER_ACTION";return true;
}
#endif
