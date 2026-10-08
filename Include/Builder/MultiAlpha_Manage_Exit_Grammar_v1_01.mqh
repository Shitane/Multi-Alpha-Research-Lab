#ifndef MULTIALPHA_MANAGE_EXIT_GRAMMAR_V1_01_MQH
#define MULTIALPHA_MANAGE_EXIT_GRAMMAR_V1_01_MQH
#include "MultiAlpha_Capacity_v1_00.mqh"
#include "MultiAlpha_Builder_Part_Schema_v1_04.mqh"
// 100-Part structural audit only; NOT action execution or GREEN-lamp certification.
bool MA2KValidateManageExit100(const int role,const string &parts[],const string &params[],string &reason)
{
 if(role!=2&&role!=3){reason="ROLE";return false;}
 if(ArraySize(parts)!=MA_CAP_PARTS_PER_LOGIC||ArraySize(params)!=MA_CAP_PARTS_PER_LOGIC){reason="SIZE_100";return false;}
 int count=0,actions=0,conditions=0;bool previousOperator=false;
 for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
 {
  string p=MA101CanonicalPart(parts[i]);
  if(p==""||p=="EMPTY")
  {
   if(params[i]!=""){reason="EMPTY_WITH_PARAMS_AT_"+IntegerToString(i+1);return false;}
   continue;
  }
  count++;
  if(p=="AND"||p=="OR")
  {
   if(params[i]!=""){reason="OPERATOR_WITH_PARAMS";return false;}
   if(count==1||previousOperator){reason="MISPLACED_OPERATOR";return false;}
   previousOperator=true;continue;
  }
  if(!MA104ValidatePart(role,p,params[i],reason))return false;
  previousOperator=false;
  if(role==2&&(p=="SINGLE_TRAILING"||p=="BASKET_TRAILING"||p=="OVERLAP"))actions++;
  else if(role==3&&(p=="CLOSE_SIDE"||p=="CLOSE_OPPOSITE"))actions++;
  else conditions++;
 }
 if(count==0){reason="EMPTY";return false;}
 if(previousOperator){reason="TRAILING_OPERATOR";return false;}
 if(actions==0){reason="NO_ROLE_ACTION";return false;}
 if(conditions==0){reason="NO_CONDITION";return false;}
 reason="STRUCTURE_VALID_RUNTIME_UNPROVEN";return true;
}
#endif
