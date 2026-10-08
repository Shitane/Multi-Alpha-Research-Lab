#ifndef MA_LOGIC_LAMP_V101_MQH
#define MA_LOGIC_LAMP_V101_MQH
#include "MultiAlpha_Logic_Validity_v1_00.mqh"
enum ENUM_MA_LAMP101 { MA_LAMP_OFF101=0,MA_LAMP_RED101=1,MA_LAMP_GREEN101=2,MA_LAMP_ORANGE101=3 };
bool MA101IsGridOffOnly(const string &parts[],const string &params[])
{
 if(ArraySize(parts)!=40||ArraySize(params)!=40)return false;
 int count=0;
 for(int i=0;i<40;i++)
 {
  string p=MA101CanonicalPart(parts[i]);
  if(p==""||p=="EMPTY")continue;
  if(p!="GRID_OFF"&&p!="GRID OFF")return false;
  if(params[i]!="")return false;
  count++;
 }
 return count==1;
}
ENUM_MA_LAMP101 MA101RoleLamp(const int role,const bool saved,const string &parts[],const string &params[],string &reason)
{
 if(!saved){reason="UNSAVED";return MA_LAMP_OFF101;}
 if(role==1)
 {
  bool containsOff=false;
  for(int i=0;i<ArraySize(parts);i++)
  {
   string p=MA101CanonicalPart(parts[i]);
   if(p=="GRID_OFF"||p=="GRID OFF"){containsOff=true;break;}
  }
  if(containsOff)
  {
   if(MA101IsGridOffOnly(parts,params)){reason="GRID_OFF_VALID";return MA_LAMP_ORANGE101;}
   reason="GRID_OFF_CONFLICT";return MA_LAMP_RED101;
  }
 }
 if(!MAValidityRole100(role,saved,parts,params,reason))return MA_LAMP_RED101;
 return MA_LAMP_GREEN101;
}
ENUM_MA_LAMP101 MA101EASlotLamp(const ENUM_MA_LAMP101 entry,const ENUM_MA_LAMP101 grid,const ENUM_MA_LAMP101 manage,const ENUM_MA_LAMP101 exitLamp)
{
 if(entry!=MA_LAMP_GREEN101||manage!=MA_LAMP_GREEN101||exitLamp!=MA_LAMP_GREEN101)return MA_LAMP_RED101;
 if(grid==MA_LAMP_ORANGE101)return MA_LAMP_ORANGE101;
 if(grid==MA_LAMP_GREEN101)return MA_LAMP_GREEN101;
 return MA_LAMP_RED101;
}
#endif
