//+------------------------------------------------------------------+
//| MultiAlpha_Filter_To_Builder_Adapter_v1_00.mqh                  |
//| B-P0-2E boundary: Common Filter permission -> Builder Context.    |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_FILTER_TO_BUILDER_ADAPTER_V1_00_MQH
#define MULTIALPHA_FILTER_TO_BUILDER_ADAPTER_V1_00_MQH
#include "../../Modules/Common/MultiAlpha_Common_Filter_v1_10.mqh"
#include "../Builder/MultiAlpha_Builder_Filter_Context_v1_01.mqh"
void MAFilterPermissionToBuilder100(const SMA_FilterPermission110 &p,SMA_BuilderFilterContext101 &c)
{MABuilderFilterContextSet101(p.new_entry,p.add_entry,p.new_reason,p.add_reason,c);}
#endif
