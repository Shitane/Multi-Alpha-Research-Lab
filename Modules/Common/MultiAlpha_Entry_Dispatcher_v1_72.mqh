//+------------------------------------------------------------------+
//| MultiAlpha_Entry_Dispatcher_v1_72.mqh                            |
//| Single-EA SPLIT entry dispatcher. NO broker orders.              |
//| O01 preserves existing context path; A10 owns signal state only. |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_ENTRY_DISPATCHER_V1_72_MQH
#define MULTI_ALPHA_ENTRY_DISPATCHER_V1_72_MQH
#include "MultiAlpha_Module_Registry_v1_61.mqh"
#include "..\\A10\\A10_Entry_Module_v1_00.mqh"
#include "..\\O01\\O01_GSG_RSI30_Core_Interface_v1_00.mqh"

class CMultiAlphaEntryDispatcher172
  {
private:
   CA10EntryCoordinator100 m_a10;
   bool m_a10_ready;
public:
   CMultiAlphaEntryDispatcher172(){m_a10_ready=false;}
   bool InitA10(const SA10EntrySettings100 &cfg,const double tick_size)
     {
      m_a10_ready=m_a10.Init(cfg,tick_size);
      return m_a10_ready;
     }
   bool A10Ready()const{return m_a10_ready;}

   ENUM_O01_ENTRY_SIGNAL EvaluateO01(const SMA_ModuleSelection150 &route,
                                     CO01CoreInterface &o01_core,
                                     const SO01EntryConfig &cfg,
                                     const SO01EntryContext &ctx)
     {
      bool o01_selected=false;
      if(route.structure==MA_STRUCTURE_FULL_V150)
         o01_selected=(route.full_module==MA_LOGIC_O01_V150);
      else if(route.structure==MA_STRUCTURE_SPLIT_V150)
         o01_selected=(route.entry_module==MA_LOGIC_O01_V150);
      if(!o01_selected)return O01_ENTRY_NONE;
      return o01_core.EvaluateEntry(cfg,ctx);
     }

   ENUM_O01_ENTRY_SIGNAL EvaluateA10(const SMA_ModuleSelection150 &route,const double bid)
     {
      if(route.structure!=MA_STRUCTURE_SPLIT_V150 || route.entry_module!=MA_LOGIC_A10_V150 || !m_a10_ready)
         return O01_ENTRY_NONE;
      SA10EntryDecision100 d=m_a10.OnPrice(bid);
      if(d.signal>0)return O01_ENTRY_BUY;
      if(d.signal<0)return O01_ENTRY_SELL;
      return O01_ENTRY_NONE;
     }

   ENUM_O01_ENTRY_SIGNAL Evaluate(const SMA_ModuleSelection150 &route,
                                  CO01CoreInterface &o01_core,
                                  const SO01EntryConfig &o01_cfg,
                                  const SO01EntryContext &o01_ctx,
                                  const double bid)
     {
      if(route.structure==MA_STRUCTURE_FULL_V150)
        {
         if(route.full_module==MA_LOGIC_O01_V150)return EvaluateO01(route,o01_core,o01_cfg,o01_ctx);
         return O01_ENTRY_NONE; // explicit FULL fail-safe; never fallback
        }
      if(route.structure==MA_STRUCTURE_SPLIT_V150)
        {
         if(route.entry_module==MA_LOGIC_O01_V150)return EvaluateO01(route,o01_core,o01_cfg,o01_ctx);
         if(route.entry_module==MA_LOGIC_A10_V150)return EvaluateA10(route,bid);
        }
      return O01_ENTRY_NONE; // explicit fail-safe; never fallback
     }
  };
#endif
