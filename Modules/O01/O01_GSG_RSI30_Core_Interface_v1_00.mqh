//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Core_Interface_v1_00.mqh                          |
//| Stable NoOrders adapter for Multi Alpha Core integration.        |
//| Decisions only: this interface never sends, modifies or closes   |
//| broker orders.                                                   |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_CORE_INTERFACE_V1_00_MQH
#define O01_GSG_RSI30_CORE_INTERFACE_V1_00_MQH
#include "O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "O01_GSG_RSI30_Exit_Module_v1_00.mqh"

#define O01_CORE_INTERFACE_VERSION "1.00"
#define O01_CORE_NO_ORDERS 1
#define O01_CORE_VIRTUAL_NOT_FILL 1

struct SO01CoreDecision
  {
   ENUM_O01_ENTRY_SIGNAL entry;
   ENUM_O01_EXIT_DECISION exit;
   bool entry_blocked_by_open_side;
  };

class CO01CoreInterface
  {
private:
   CO01EntryModule m_entry;
   CO01ExitModule  m_exit;
public:
   void ResetTrail(SO01TrailState &s) const
     {
      s.active=false; s.peak_pts=0.0; s.stop_pts=0.0; s.position_count=0;
     }

   ENUM_O01_ENTRY_SIGNAL EvaluateEntry(const SO01EntryConfig &cfg,const SO01EntryContext &ctx) const
     {
      return m_entry.Evaluate(cfg,ctx);
     }

   ENUM_O01_EXIT_DECISION EvaluateExit(const bool is_buy,const int count,const double move_pts,
                                       const SO01ExitConfig &cfg,SO01TrailState &state) const
     {
      return m_exit.Evaluate(is_buy,count,move_pts,cfg,state);
     }

   SO01CoreDecision Evaluate(const SO01EntryConfig &entry_cfg,const SO01EntryContext &entry_ctx,
                             const bool manage_side,const int count,const double move_pts,
                             const SO01ExitConfig &exit_cfg,SO01TrailState &trail_state) const
     {
      SO01CoreDecision d;
      d.entry=O01_ENTRY_NONE; d.exit=O01_EXIT_NONE; d.entry_blocked_by_open_side=false;
      if(count>0)
        {
         d.entry_blocked_by_open_side=true;
         d.exit=m_exit.Evaluate(manage_side,count,move_pts,exit_cfg,trail_state);
         return d;
        }
      d.entry=m_entry.Evaluate(entry_cfg,entry_ctx);
      return d;
     }
  };
#endif
