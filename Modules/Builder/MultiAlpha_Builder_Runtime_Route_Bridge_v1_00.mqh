//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Runtime_Route_Bridge_v1_00.mqh               |
//| LB-01 Builder route recognition bridge. NO execution side effects.|
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_RUNTIME_ROUTE_BRIDGE_V1_00_MQH
#define MULTIALPHA_BUILDER_RUNTIME_ROUTE_BRIDGE_V1_00_MQH

#include "MultiAlpha_Builder_Module_Registry_v1_00.mqh"

#define MA_BUILDER_RUNTIME_ROUTE_BRIDGE_VERSION "1.00"

enum ENUM_MA_BUILDER_RUNTIME_ROUTE100
{
 MA_BUILDER_RUNTIME_ROUTE_NONE100=0,
 MA_BUILDER_RUNTIME_ROUTE_O01_FULL100=1,
 MA_BUILDER_RUNTIME_ROUTE_O01_SPLIT100=2
};

struct SMA_BuilderRuntimeRoute100
{
 ENUM_MA_BUILDER_RUNTIME_ROUTE100 route;
 string full_id;
 string entry_id;
 string manage_id;
 string exit_id;
 bool ready;
 string reason;
};

class CMultiAlphaBuilderRuntimeRouteBridge100
{
private:
 CMultiAlphaBuilderModuleRegistry100 m_registry;

public:
 CMultiAlphaBuilderRuntimeRouteBridge100(){m_registry.BuildVerifiedO01();}

 bool SelectFull(const string full_id,SMA_BuilderRuntimeRoute100 &out)
 {
  out.route=MA_BUILDER_RUNTIME_ROUTE_NONE100;
  out.full_id=full_id;out.entry_id="";out.manage_id="";out.exit_id="";
  out.ready=false;out.reason="";
  if(!m_registry.ValidateFull(full_id,out.reason))return false;
  if(full_id!="BUILDER_O01_FULL"){out.reason=full_id+" FULL RUNTIME NOT WIRED";return false;}
  out.route=MA_BUILDER_RUNTIME_ROUTE_O01_FULL100;out.ready=true;out.reason="READY";return true;
 }

 bool SelectSplit(const string entry_id,const string manage_id,const string exit_id,SMA_BuilderRuntimeRoute100 &out)
 {
  out.route=MA_BUILDER_RUNTIME_ROUTE_NONE100;
  out.full_id="";out.entry_id=entry_id;out.manage_id=manage_id;out.exit_id=exit_id;
  out.ready=false;out.reason="";
  if(!m_registry.ValidateSplit(entry_id,manage_id,exit_id,out.reason))return false;
  if(entry_id!="BUILDER_E01"||manage_id!="BUILDER_M01"||exit_id!="BUILDER_X01")
   {out.reason="BUILDER SPLIT RUNTIME COMBINATION NOT WIRED";return false;}
  out.route=MA_BUILDER_RUNTIME_ROUTE_O01_SPLIT100;out.ready=true;out.reason="READY";return true;
 }

 bool IsReady(const SMA_BuilderRuntimeRoute100 &r) const
 {
  return r.ready && (r.route==MA_BUILDER_RUNTIME_ROUTE_O01_FULL100 ||
                     r.route==MA_BUILDER_RUNTIME_ROUTE_O01_SPLIT100);
 }
};

#endif
