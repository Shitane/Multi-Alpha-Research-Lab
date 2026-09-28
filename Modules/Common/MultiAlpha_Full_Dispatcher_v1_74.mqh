//+------------------------------------------------------------------+
//| MultiAlpha_Full_Dispatcher_v1_74.mqh                            |
//| FULL route dispatcher staging for verified A10 whole path.       |
//| NO BROKER ORDERS. Unsupported routes fail; never fallback.       |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_FULL_DISPATCHER_V1_74_MQH
#define MULTI_ALPHA_FULL_DISPATCHER_V1_74_MQH

#include "MultiAlpha_Module_Contract_v1_50.mqh"
#include "..\\A10\\A10_Full_Module_v1_00.mqh"

class CMultiAlphaFullDispatcher174
  {
private:
   CA10FullModule100 m_a10;
   bool m_a10_ready;

public:
   CMultiAlphaFullDispatcher174(){m_a10_ready=false;}

   bool InitA10(const SA10FullConfig100 &cfg,const double tick_size)
     {
      m_a10_ready=m_a10.Init(cfg,tick_size);
      return m_a10_ready;
     }

   bool A10Ready()const{return m_a10_ready;}

   // Returns true only when a registered staging FULL implementation
   // actually produced an event. O01 remains owned by the frozen O01 host.
   bool OnTick(const SMA_ModuleSelection150 &route,
               const MqlTick &tick,
               SA10FullEvent100 &event)
     {
      event.valid=false;
      event.is_entry=false;
      event.mode=-1;
      event.direction=0;
      event.reason="";
      event.price=0.0;
      event.ticket=0;

      if(route.structure!=MA_STRUCTURE_FULL_V150)
         return false;

      if(route.full_module==MA_LOGIC_A10_V150)
        {
         if(!m_a10_ready)return false;
         return m_a10.OnTick(tick,event);
        }

      // Explicit fail-safe. Never substitute A10 for O01/unknown FULL routes.
      return false;
     }

   long A10Ticks()const{return m_a10.Ticks();}
   long A10Entries()const{return m_a10.Entries();}
   long A10Exits()const{return m_a10.Exits();}
   int  A10OpenCount()const{return m_a10.OpenCount();}
   long A10ModeEntries(const int mode)const{return m_a10.ModeEntries(mode);}
   long A10ModeExits(const int mode)const{return m_a10.ModeExits(mode);}
  };

#endif
