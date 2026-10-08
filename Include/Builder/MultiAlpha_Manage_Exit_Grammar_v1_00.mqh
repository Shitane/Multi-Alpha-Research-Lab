#ifndef MA_ROLE_GRAMMAR_2K_V100
#define MA_ROLE_GRAMMAR_2K_V100
#include "MultiAlpha_Builder_Part_Schema_v1_04.mqh"
// Conservative structural grammar only. NOT runtime/action parity certification.
// 40 Parts, ordered; no dangling AND/OR, no cross-role Parts.
bool MA2KValidateManageExit(const int role,const string &parts[],const string &params[],string &reason)
{
 if(role!=2&&role!=3){reason="ROLE";return false;}
 if(ArraySize(parts)!=40||ArraySize(params)!=40){reason="SIZE";return false;}
 int n=0,actions=0,conditions=0;bool previousOperator=false;
 for(int i=0;i<40;i++)
 {
  string p=MA101CanonicalPart(parts[i]);
  if(p==""||p=="EMPTY")continue;
  n++;
  if(p=="AND"||p=="OR")
  {
   if(n==1||previousOperator){reason="MISPLACED_OPERATOR";return false;}
   previousOperator=true;continue;
  }
  if(!MA104ValidatePart(role,p,params[i],reason))return false;
  previousOperator=false;
  if(role==2&&(p=="SINGLE_TRAILING"||p=="BASKET_TRAILING"||p=="OVERLAP"))actions++;
  else if(role==3&&(p=="CLOSE_SIDE"||p=="CLOSE_OPPOSITE"))actions++;
  else conditions++;
 }
 if(n==0){reason="EMPTY";return false;}
 if(previousOperator){reason="TRAILING_OPERATOR";return false;}
 if(actions==0){reason="NO_ROLE_ACTION";return false;}
 if(conditions==0){reason="NO_CONDITION";return false;}
 reason="STRUCTURE_VALID_RUNTIME_UNPROVEN";return true;
}
#endif
