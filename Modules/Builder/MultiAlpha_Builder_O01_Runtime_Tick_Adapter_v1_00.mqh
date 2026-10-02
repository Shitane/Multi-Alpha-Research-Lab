//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Runtime_Tick_Adapter_v1_00.mqh           |
//| LB-01 decision/state adapter for runtime tick-path integration.   |
//| NO ORDERS / VIRTUAL NOT FILL. No broker API calls.                |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_RUNTIME_TICK_ADAPTER_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_RUNTIME_TICK_ADAPTER_V1_00_MQH

#include "MultiAlpha_Builder_Runtime_Route_Bridge_v1_00.mqh"
#include "MultiAlpha_Builder_O01_Entry_Evaluator_v1_00.mqh"
#include "MultiAlpha_Builder_O01_Manage_Evaluator_v1_00.mqh"
#include "MultiAlpha_Builder_O01_Exit_Evaluator_v1_00.mqh"

#define MA_BUILDER_O01_RUNTIME_TICK_ADAPTER_VERSION "1.00"
#define MA_BUILDER_RUNTIME_NO_ORDERS 1
#define MA_BUILDER_RUNTIME_VIRTUAL_NOT_FILL 1

struct SMA_BuilderO01RuntimeDecision100
{
 ENUM_O01_ENTRY_SIGNAL entry_signal;
 SO01ManageDecision manage_decision;
 ENUM_O01_EXIT_DECISION exit_decision;
 bool route_ready;
 string route_reason;
};

class CMultiAlphaBuilderO01RuntimeTickAdapter100
{
private:
 CMultiAlphaBuilderRuntimeRouteBridge100 m_routes;
 CMultiAlphaBuilderO01EntryEvaluator100 m_entry;
 CMultiAlphaBuilderO01ManageEvaluator100 m_manage;
 CMultiAlphaBuilderO01ExitEvaluator100 m_exit;

 void Clear(SMA_BuilderO01RuntimeDecision100 &d) const
 {
  d.entry_signal=O01_ENTRY_NONE;
  d.manage_decision.action=O01_MANAGE_NONE;
  d.manage_decision.requested_lot=0.0;
  d.manage_decision.required_distance_points=0.0;
  d.manage_decision.next_grid_number=0;
  d.exit_decision=O01_EXIT_NONE;
  d.route_ready=false;
  d.route_reason="";
 }

 bool EvaluateReady(const SMA_BuilderRuntimeRoute100 &route,
                    const SO01EntryConfig &ec,const SO01EntryContext &ex,
                    const bool manage_is_buy,const SO01ManageConfig &mc,const SO01ManageContext &mx,
                    const bool exit_is_buy,const int exit_count,const double move_pts,
                    const SO01ExitConfig &xc,SO01TrailState &trail,
                    SMA_BuilderO01RuntimeDecision100 &out) const
 {
  Clear(out);
  if(!m_routes.IsReady(route)){out.route_reason="ROUTE NOT READY";return false;}
  out.entry_signal=m_entry.Evaluate(ec,ex);
  out.manage_decision=m_manage.Evaluate(manage_is_buy,mc,mx);
  out.exit_decision=m_exit.Evaluate(exit_is_buy,exit_count,move_pts,xc,trail);
  out.route_ready=true; out.route_reason="READY";
  return true;
 }

public:
 bool EvaluateFull(const string full_id,
                   const SO01EntryConfig &ec,const SO01EntryContext &ex,
                   const bool manage_is_buy,const SO01ManageConfig &mc,const SO01ManageContext &mx,
                   const bool exit_is_buy,const int exit_count,const double move_pts,
                   const SO01ExitConfig &xc,SO01TrailState &trail,
                   SMA_BuilderO01RuntimeDecision100 &out)
 {
  SMA_BuilderRuntimeRoute100 route={};
  if(!m_routes.SelectFull(full_id,route)){Clear(out);out.route_reason=route.reason;return false;}
  return EvaluateReady(route,ec,ex,manage_is_buy,mc,mx,exit_is_buy,exit_count,move_pts,xc,trail,out);
 }

 bool EvaluateSplit(const string entry_id,const string manage_id,const string exit_id,
                    const SO01EntryConfig &ec,const SO01EntryContext &ex,
                    const bool manage_is_buy,const SO01ManageConfig &mc,const SO01ManageContext &mx,
                    const bool exit_is_buy,const int exit_count,const double move_pts,
                    const SO01ExitConfig &xc,SO01TrailState &trail,
                    SMA_BuilderO01RuntimeDecision100 &out)
 {
  SMA_BuilderRuntimeRoute100 route={};
  if(!m_routes.SelectSplit(entry_id,manage_id,exit_id,route)){Clear(out);out.route_reason=route.reason;return false;}
  return EvaluateReady(route,ec,ex,manage_is_buy,mc,mx,exit_is_buy,exit_count,move_pts,xc,trail,out);
 }
};

#endif
