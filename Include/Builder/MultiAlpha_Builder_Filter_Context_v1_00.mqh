//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Filter_Context_v1_00.mqh                     |
//| Track B B-P0-2B: typed bridge from Common Filter permission      |
//| to generic Logic Builder condition values. NO ORDERS.            |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_FILTER_CONTEXT_V1_00_MQH
#define MULTIALPHA_BUILDER_FILTER_CONTEXT_V1_00_MQH
#include "../../Modules/Common/MultiAlpha_Common_Filter_v1_10.mqh"

struct SMA_BuilderFilterContext100
{
 bool new_entry_ok;
 bool add_entry_ok;
 string new_reason;
 string add_reason;
};

void MABuilderFilterContextDefaults100(SMA_BuilderFilterContext100 &c)
{
 c.new_entry_ok=true;
 c.add_entry_ok=true;
 c.new_reason="";
 c.add_reason="";
}
void MABuilderFilterContextFromPermission100(const SMA_FilterPermission110 &p,SMA_BuilderFilterContext100 &c)
{
 c.new_entry_ok=p.new_entry;
 c.add_entry_ok=p.add_entry;
 c.new_reason=p.new_reason;
 c.add_reason=p.add_reason;
}
bool MABuilderFilterPartValue100(const string part,const SMA_BuilderFilterContext100 &c,bool &value,string &reason)
{
 if(part=="FILTER_NEW_OK"){value=c.new_entry_ok;reason=c.new_reason;return true;}
 if(part=="FILTER_ADD_OK"){value=c.add_entry_ok;reason=c.add_reason;return true;}
 reason="NOT_FILTER_REFERENCE";return false;
}
#endif
