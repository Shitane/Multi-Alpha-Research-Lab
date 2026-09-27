//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Logic_Router_v1_40.mqh                            |
//| Unified FULL/SPLIT route contract. NO ORDERS.                    |
//| This router does not execute broker orders.                       |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_LOGIC_ROUTER_V1_40_MQH
#define O01_GSG_RSI30_LOGIC_ROUTER_V1_40_MQH

#include "O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "O01_GSG_RSI30_Manage_Module_v1_40.mqh"
#include "O01_GSG_RSI30_Exit_Module_v1_00.mqh"

enum ENUM_O01_STRUCTURE_MODE
  {
   O01_STRUCTURE_FULL=0,
   O01_STRUCTURE_SPLIT=1
  };

enum ENUM_MULTI_ALPHA_LOGIC_ID
  {
   MA_LOGIC_NONE=0,
   MA_LOGIC_O01=101
  };

struct SO01RouteSelection140
  {
   ENUM_O01_STRUCTURE_MODE structure;
   ENUM_MULTI_ALPHA_LOGIC_ID entry_module;
   ENUM_MULTI_ALPHA_LOGIC_ID manage_module;
   ENUM_MULTI_ALPHA_LOGIC_ID exit_module;
  };

class CO01LogicRouter140
  {
private:
   CO01EntryModule      m_entry;
   CO01ManageModule140  m_manage;
   CO01ExitModule       m_exit;

public:
   bool ValidateSelection(const SO01RouteSelection140 &r) const
     {
      if(r.structure==O01_STRUCTURE_FULL)
         return true; // FULL is dispatched by the host to the frozen whole-strategy path.
      return r.entry_module==MA_LOGIC_O01 &&
             r.manage_module==MA_LOGIC_O01 &&
             r.exit_module==MA_LOGIC_O01;
     }

   bool CanChangeRoute(const int managed_positions,
                       const bool cycle_none,
                       const bool execution_transition_pending,
                       string &reason) const
     {
      reason="";
      if(managed_positions!=0)
        { reason="managed positions are open"; return false; }
      if(!cycle_none)
        { reason="cycle is active"; return false; }
      if(execution_transition_pending)
        { reason="execution transition is pending"; return false; }
      return true;
     }

   ENUM_O01_ENTRY_SIGNAL EvaluateEntry(const SO01RouteSelection140 &r,
                                       const SO01EntryConfig &cfg,
                                       const SO01EntryContext &ctx) const
     {
      if(r.structure!=O01_STRUCTURE_SPLIT || r.entry_module!=MA_LOGIC_O01)
         return O01_ENTRY_NONE;
      return m_entry.Evaluate(cfg,ctx);
     }

   SO01ManageDecision EvaluateManage(const SO01RouteSelection140 &r,
                                     const bool is_buy,
                                     const SO01ManageConfig &cfg,
                                     const SO01ManageContext &ctx) const
     {
      SO01ManageDecision none;
      none.action=O01_MANAGE_NONE;none.requested_lot=0.0;
      none.required_distance_points=0.0;none.next_grid_number=ctx.position_count+1;
      if(r.structure!=O01_STRUCTURE_SPLIT || r.manage_module!=MA_LOGIC_O01)
         return none;
      return m_manage.Evaluate(is_buy,cfg,ctx);
     }

   ENUM_O01_EXIT_DECISION EvaluateExit(const SO01RouteSelection140 &r,
                                       const bool is_buy,
                                       const int count,
                                       const double move_pts,
                                       const SO01ExitConfig &cfg,
                                       SO01TrailState &state) const
     {
      if(r.structure!=O01_STRUCTURE_SPLIT || r.exit_module!=MA_LOGIC_O01)
         return O01_EXIT_NONE;
      return m_exit.Evaluate(is_buy,count,move_pts,cfg,state);
     }
  };

#endif
