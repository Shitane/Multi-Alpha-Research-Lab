//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Filter_Context_v1_01.mqh                     |
//| B-P0-2B: Builder-owned typed filter permission context.          |
//| No dependency on Filter UI/store implementation. NO ORDERS.      |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_FILTER_CONTEXT_V1_01_MQH
#define MULTIALPHA_BUILDER_FILTER_CONTEXT_V1_01_MQH
#define MA_BUILDER_FILTER_CONTEXT_101_VERSION "1.01"

struct SMA_BuilderFilterContext101
{
 bool new_entry_ok;
 bool add_entry_ok;
 string new_reason;
 string add_reason;
};

void MABuilderFilterContextDefaults101(SMA_BuilderFilterContext101 &c)
{
 c.new_entry_ok=true;
 c.add_entry_ok=true;
 c.new_reason="";
 c.add_reason="";
}
void MABuilderFilterContextSet101(const bool new_ok,const bool add_ok,
                                  const string new_reason,const string add_reason,
                                  SMA_BuilderFilterContext101 &c)
{
 c.new_entry_ok=new_ok;
 c.add_entry_ok=add_ok;
 c.new_reason=new_reason;
 c.add_reason=add_reason;
}
bool MABuilderFilterPartValue101(const string part,const SMA_BuilderFilterContext101 &c,
                                 bool &value,string &reason)
{
 if(part=="FILTER_NEW_OK"){value=c.new_entry_ok;reason=c.new_reason;return true;}
 if(part=="FILTER_ADD_OK"){value=c.add_entry_ok;reason=c.add_reason;return true;}
 reason="NOT_FILTER_REFERENCE";return false;
}
#endif
