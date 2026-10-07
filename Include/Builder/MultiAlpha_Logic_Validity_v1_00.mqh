#ifndef MA_LOGIC_VALIDITY_100_MQH
#define MA_LOGIC_VALIDITY_100_MQH
#include "MultiAlpha_Builder_Part_Schema_v1_04.mqh"
#include "MultiAlpha_Builder_Interpreter_v1_05.mqh"
#define MA_LOGIC_VALIDITY_PARTS100 40
enum ENUM_MA_LOGIC_VALIDITY100 { MA_LOGIC_EMPTY100=0, MA_LOGIC_INVALID100=1, MA_LOGIC_VALID100=2 };
bool MAValidityEmpty100(const string p){return p==""||p=="EMPTY";}
bool MAValidityRole100(const int role,const bool saved,const string &parts[],const string &params[],string &reason)
{
 if(!saved){reason="UNSAVED";return false;}
 if(role<0||role>3||ArraySize(parts)!=40||ArraySize(params)!=40){reason="ROLE_OR_SIZE";return false;}
 int n=0;bool off=false;
 for(int i=0;i<40;i++)
 {
  string p=MA101CanonicalPart(parts[i]);
  if(MAValidityEmpty100(p))continue;
  n++;
  if(role==1&&(p=="GRID OFF"||p=="GRID_OFF")){if(params[i]!=""){reason="GRID_OFF_PARAMS";return false;}off=true;continue;}
  if(role==1&&(p=="GRID ON"||p=="GRID_ON")){if(params[i]!=""){reason="GRID_ON_PARAMS";return false;}continue;}
  if(p=="AND"||p=="OR")continue;
  if(!MA104ValidatePart(role,p,params[i],reason))return false;
 }
 if(n==0){reason="EMPTY_DEFINITION";return false;}
 if(role==1&&off){reason="GRID_OFF_VALID";return true;}
 if(role==1&&n==1){reason="GRID_INCOMPLETE";return false;}
 if(role==0)
 {
  CMultiAlphaBuilderInterpreter105 it;int map[],act[],bc=0;
  return it.BuildEntryBranchMap(parts,map,act,bc,reason);
 }
 // Non-ENTRY grammar is not yet fully generic. Do not green-light unproven roles.
 reason="ROLE_INTERPRETER_NOT_PROVEN";return false;
}
ENUM_MA_LOGIC_VALIDITY100 MAValidityState100(const int role,const bool saved,const string &parts[],const string &params[],string &reason)
{
 if(!saved){reason="UNSAVED";return MA_LOGIC_EMPTY100;}
 return MAValidityRole100(role,saved,parts,params,reason)?MA_LOGIC_VALID100:MA_LOGIC_INVALID100;
}
bool MAValidityEASlot100(const bool entry_valid,const bool grid_valid,const bool manage_valid,const bool exit_valid)
{return entry_valid&&grid_valid&&manage_valid&&exit_valid;}
#endif
