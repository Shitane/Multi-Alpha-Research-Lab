//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Part_Schema_v1_03.mqh                        |
//| P1-C: O01 overlap and exit-mode Parts.                           |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PART_SCHEMA_V1_03_MQH
#define MULTIALPHA_BUILDER_PART_SCHEMA_V1_03_MQH
#include "MultiAlpha_Builder_Part_Schema_v1_02.mqh"
#define MA_BUILDER_PART_SCHEMA_103_VERSION "1.03"

bool MA103ExtraPart(const string raw)
{
 string p=MA101CanonicalPart(raw);
 return p=="OVERLAP"||p=="BASKET_FIXED_TP"||p=="SINGLE_MONEY_TP"||p=="CLOSE_OPPOSITE";
}
bool MA103PartAllowed(const int role,const string raw)
{
 string p=MA101CanonicalPart(raw);
 if(p=="OVERLAP")return role==MA_BUILDER_ROLE_MANAGE101;
 if(p=="BASKET_FIXED_TP"||p=="SINGLE_MONEY_TP"||p=="CLOSE_OPPOSITE")return role==MA_BUILDER_ROLE_EXIT101;
 return MA102PartAllowed(role,raw);
}
bool MA103ValidatePart(const int role,const string raw,const string params,string &reason)
{
 string p=MA101CanonicalPart(raw);
 if(!MA103ExtraPart(p))return MA102ValidatePart(role,raw,params,reason);
 if(!MA103PartAllowed(role,p)){reason="PART NOT ALLOWED FOR ROLE: "+p;return false;}

 if(p=="OVERLAP")
 {
  string en=MA101Param(params,"ENABLED","");
  if(!MA101IsBoolText(en)){reason="OVERLAP ENABLED";return false;}
  string orderText=MA101Param(params,"ORDER","");
  int orderNo=(int)StringToInteger(orderText);
  if(orderText=="" || orderNo<2){reason="OVERLAP ORDER";return false;}
  if(!MA101NonNegative(MA101Param(params,"PERCENT","-1"))){reason="OVERLAP PERCENT";return false;}
 }
 else if(p=="BASKET_FIXED_TP")
 {
  if(!MA101NonNegative(MA101Param(params,"POINTS","-1"))){reason="BASKET_FIXED_TP POINTS";return false;}
  string mode=MA101Param(params,"EXIT_MODE","");
  if(mode!="FIXED"){reason="BASKET_FIXED_TP EXIT_MODE";return false;}
 }
 else if(p=="SINGLE_MONEY_TP")
 {
  if(!MA101NonNegative(MA101Param(params,"MONEY","-1"))){reason="SINGLE_MONEY_TP MONEY";return false;}
  string mode=MA101Param(params,"TP_MODE","");
  if(mode!="MONEY"){reason="SINGLE_MONEY_TP TP_MODE";return false;}
 }
 else if(p=="CLOSE_OPPOSITE")
 {
  string en=MA101Param(params,"ENABLED","");
  if(!MA101IsBoolText(en)){reason="CLOSE_OPPOSITE ENABLED";return false;}
  string after=MA101Param(params,"AFTER","");
  if(after!="TP_OR_SL_OR_TRAILING"){reason="CLOSE_OPPOSITE AFTER";return false;}
 }
 reason="OK";return true;
}
#endif
