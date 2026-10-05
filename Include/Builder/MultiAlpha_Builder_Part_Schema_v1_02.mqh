//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Part_Schema_v1_02.mqh                        |
//| P1-A: generic GRID guard/distance Parts added to v1_01.          |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PART_SCHEMA_V1_02_MQH
#define MULTIALPHA_BUILDER_PART_SCHEMA_V1_02_MQH
#include "MultiAlpha_Builder_Part_Schema_v1_01.mqh"
#define MA_BUILDER_PART_SCHEMA_102_VERSION "1.02"

bool MA102GridExtraPart(const string raw)
{
 string p=MA101CanonicalPart(raw);
 return p=="DD_BELOW"||p=="GRID_TIME_ALLOWED"||p=="GRID_NEWS_CLEAR"||p=="DISTANCE_REACHED";
}
bool MA102PartAllowed(const int role,const string raw)
{
 if(MA102GridExtraPart(raw))return role==MA_BUILDER_ROLE_GRID101;
 return MA101PartAllowed(role,raw);
}
bool MA102ValidatePart(const int role,const string raw,const string params,string &reason)
{
 string p=MA101CanonicalPart(raw);
 if(!MA102GridExtraPart(p))return MA101ValidatePart(role,raw,params,reason);
 if(role!=MA_BUILDER_ROLE_GRID101){reason="PART NOT ALLOWED FOR ROLE: "+p;return false;}

 if(p=="DD_BELOW")
 {
  string en=MA101Param(params,"ENABLED","");
  if(!MA101IsBoolText(en)){reason="DD_BELOW ENABLED";return false;}
  if(!MA101NonNegative(MA101Param(params,"PERCENT","-1"))){reason="DD_BELOW PERCENT";return false;}
 }
 else if(p=="GRID_TIME_ALLOWED")
 {
  string allow=MA101Param(params,"ALLOW_OUTSIDE","");
  if(!MA101IsBoolText(allow)){reason="GRID_TIME_ALLOWED ALLOW_OUTSIDE";return false;}
 }
 else if(p=="GRID_NEWS_CLEAR")
 {
  string mode=MA101Param(params,"MODE","");
  if(!(mode=="MANAGE_ONLY"||mode=="STOP_NEW_CYCLE_ONLY"||mode=="OFF")){reason="GRID_NEWS_CLEAR MODE";return false;}
 }
 else if(p=="DISTANCE_REACHED")
 {
  string side=MA101Param(params,"SIDE","");
  if(!(side=="BUY"||side=="SELL"||side=="CURRENT")){reason="DISTANCE_REACHED SIDE";return false;}
  string basis=MA101Param(params,"BASIS","");
  if(basis!="NEWEST_POSITION"){reason="DISTANCE_REACHED BASIS";return false;}
 }
 reason="OK";return true;
}
#endif
