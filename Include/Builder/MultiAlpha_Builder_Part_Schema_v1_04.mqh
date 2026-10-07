//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Part_Schema_v1_04.mqh                        |
//| Track B B-P0-2C: generic FILTER permission reference Parts.      |
//| FILTER configuration remains owned by FILTER Panel/Store.        |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PART_SCHEMA_V1_04_MQH
#define MULTIALPHA_BUILDER_PART_SCHEMA_V1_04_MQH
#include "MultiAlpha_Builder_Part_Schema_v1_03.mqh"
#define MA_BUILDER_PART_SCHEMA_104_VERSION "1.04"

bool MA104FilterRefPart(const string raw)
{
 string p=MA101CanonicalPart(raw);
 return p=="FILTER_NEW_OK"||p=="FILTER_ADD_OK";
}
bool MA104PartAllowed(const int role,const string raw)
{
 string p=MA101CanonicalPart(raw);
 if(p=="FILTER_NEW_OK")return role==MA_BUILDER_ROLE_ENTRY101;
 if(p=="FILTER_ADD_OK")return role==MA_BUILDER_ROLE_GRID101;
 return MA103PartAllowed(role,raw);
}
bool MA104ValidatePart(const int role,const string raw,const string params,string &reason)
{
 string p=MA101CanonicalPart(raw);
 if(!MA104FilterRefPart(p))return MA103ValidatePart(role,raw,params,reason);
 if(!MA104PartAllowed(role,p)){reason="PART NOT ALLOWED FOR ROLE: "+p;return false;}
 // Reference Parts intentionally carry no duplicated TIME/NEWS/SPREAD/etc parameters.
 if(params!=""){reason=p+" MUST NOT STORE FILTER PARAMETERS";return false;}
 reason="OK";return true;
}
#endif
