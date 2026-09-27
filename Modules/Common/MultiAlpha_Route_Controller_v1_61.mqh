//+------------------------------------------------------------------+
//| MultiAlpha_Route_Controller_v1_61.mqh                            |
//| Registry-backed runtime route safety. NO broker orders.          |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_ROUTE_CONTROLLER_V1_61_MQH
#define MULTI_ALPHA_ROUTE_CONTROLLER_V1_61_MQH

#include "MultiAlpha_Module_Registry_v1_61.mqh"

class CMultiAlphaRouteController161
  {
private:
   SMA_ModuleSelection150 m_active;
   bool Same(const SMA_ModuleSelection150 &a,const SMA_ModuleSelection150 &b) const
     {
      return a.structure==b.structure && a.full_module==b.full_module &&
             a.entry_module==b.entry_module && a.manage_module==b.manage_module &&
             a.exit_module==b.exit_module;
     }
public:
   void SetInitial(const SMA_ModuleSelection150 &selection){m_active=selection;}
   SMA_ModuleSelection150 Active() const{return m_active;}
   bool Request(const SMA_ModuleSelection150 &requested,const SMA_RouteState150 &state,string &reason)
     {
      reason="";
      if(Same(requested,m_active)){reason="route unchanged";return true;}
      if(!MA161ValidateRoute(requested,reason))return false;
      if(!MA150CanChangeRoute(state,reason))return false;
      m_active=requested;reason="route changed";return true;
     }
  };
#endif
