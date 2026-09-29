//+------------------------------------------------------------------+
//| MultiAlpha_Route_Controller_v1_85.mqh                            |
//| Registry-backed runtime route safety for O01 and verified A10.   |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_ROUTE_CONTROLLER_V1_85_MQH
#define MULTI_ALPHA_ROUTE_CONTROLLER_V1_85_MQH
#include "MultiAlpha_Module_Registry_v1_85.mqh"
class CMultiAlphaRouteController185{
 SMA_ModuleSelection150 m_active;
 bool Same(const SMA_ModuleSelection150 &a,const SMA_ModuleSelection150 &b)const{return a.structure==b.structure&&a.full_module==b.full_module&&a.entry_module==b.entry_module&&a.manage_module==b.manage_module&&a.exit_module==b.exit_module;}
public:
 void SetInitial(const SMA_ModuleSelection150 &s){m_active=s;}
 SMA_ModuleSelection150 Active()const{return m_active;}
 bool Request(const SMA_ModuleSelection150 &r,const SMA_RouteState150 &state,string &reason){
  reason="";if(Same(r,m_active)){reason="route unchanged";return true;}
  if(!MA185ValidateRoute(r,reason))return false;if(!MA150CanChangeRoute(state,reason))return false;
  m_active=r;reason="route changed";return true;
 }
};
#endif
