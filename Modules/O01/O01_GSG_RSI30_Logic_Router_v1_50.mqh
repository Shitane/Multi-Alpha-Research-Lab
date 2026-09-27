//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Logic_Router_v1_50.mqh                            |
//| Common MultiAlpha contract -> verified O01 router adapter.        |
//| Architecture only. NO broker orders.                             |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_LOGIC_ROUTER_V1_50_MQH
#define O01_GSG_RSI30_LOGIC_ROUTER_V1_50_MQH

#include "..\Common\MultiAlpha_Module_Contract_v1_50.mqh"
#include "O01_GSG_RSI30_Logic_Router_v1_40.mqh"

class CO01LogicRouter150
  {
private:
   CO01LogicRouter140 m_verified;

   bool ToVerifiedSplit(const SMA_ModuleSelection150 &s,
                        SO01RouteSelection140 &r) const
     {
      string reason="";
      if(!MA150ValidateO01Gate(s,reason))
         return false;
      if(s.structure!=MA_STRUCTURE_SPLIT_V150)
         return false;

      r.structure=O01_STRUCTURE_SPLIT;
      r.entry_module=MA_LOGIC_O01;
      r.manage_module=MA_LOGIC_O01;
      r.exit_module=MA_LOGIC_O01;
      return true;
     }

public:
   bool ValidateSelection(const SMA_ModuleSelection150 &s,string &reason) const
     {
      return MA150ValidateO01Gate(s,reason);
     }

   bool CanChangeRoute(const SMA_RouteState150 &state,string &reason) const
     {
      return MA150CanChangeRoute(state,reason);
     }

   ENUM_O01_ENTRY_SIGNAL EvaluateEntry(const SMA_ModuleSelection150 &s,
                                       const SO01EntryConfig &cfg,
                                       const SO01EntryContext &ctx) const
     {
      SO01RouteSelection140 r;
      if(!ToVerifiedSplit(s,r))
         return O01_ENTRY_NONE;
      return m_verified.EvaluateEntry(r,cfg,ctx);
     }

   SO01ManageDecision EvaluateManage(const SMA_ModuleSelection150 &s,
                                     const bool is_buy,
                                     const SO01ManageConfig &cfg,
                                     const SO01ManageContext &ctx) const
     {
      SO01ManageDecision none;
      none.action=O01_MANAGE_NONE;
      none.requested_lot=0.0;
      none.required_distance_points=0.0;
      none.next_grid_number=ctx.position_count+1;

      SO01RouteSelection140 r;
      if(!ToVerifiedSplit(s,r))
         return none;
      return m_verified.EvaluateManage(r,is_buy,cfg,ctx);
     }

   ENUM_O01_EXIT_DECISION EvaluateExit(const SMA_ModuleSelection150 &s,
                                       const bool is_buy,
                                       const int count,
                                       const double move_pts,
                                       const SO01ExitConfig &cfg,
                                       SO01TrailState &state) const
     {
      SO01RouteSelection140 r;
      if(!ToVerifiedSplit(s,r))
         return O01_EXIT_NONE;
      return m_verified.EvaluateExit(r,is_buy,count,move_pts,cfg,state);
     }
  };

#endif
