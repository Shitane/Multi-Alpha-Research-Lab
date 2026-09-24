//+------------------------------------------------------------------+
//| Alpha_Template_v1_00.mqh                                        |
//| Starter template for adding a new Alpha to Multi Alpha.          |
//| Research only. Decision/state transport only. NO ORDERS.         |
//+------------------------------------------------------------------+
#ifndef ALPHA_TEMPLATE_V1_00_MQH
#define ALPHA_TEMPLATE_V1_00_MQH

#include "MultiAlpha_Interface_v1_00.mqh"

// Copy this file for a new public/original logic.
// Change ALPHA_A16_TEMPLATE to the new Alpha ID only after registering
// that ID in MultiAlpha_Interface_v1_00.mqh.
class CAlphaTemplate
  {
private:
   long g_ticks;
   long g_raw_signals;

public:
   void Init()
     {
      g_ticks=0;
      g_raw_signals=0;
     }

   // Common interface entry point.
   // Put indicator/Renko/signal calculations here.
   // Return true only when a decision is emitted.
   bool Evaluate(const SMultiAlphaMarket &market,
                 const SMultiAlphaPosition &position,
                 SMultiAlphaDecision &decision)
     {
      MultiAlphaDecisionClear(decision,ALPHA_A16_TEMPLATE);
      if(!MultiAlphaMarketValid(market))
         return false;

      g_ticks++;

      // ------------------------------------------------------------
      // NEW ALPHA LOGIC GOES HERE.
      // Example responsibilities:
      //  1) calculate/update internal state
      //  2) decide ENTRY or EXIT
      //  3) fill decision fields
      // Never call OrderSend/OrderCheck/CTrade from this module.
      // The host owns lifecycle/execution.
      // ------------------------------------------------------------

      // Keep unused snapshot explicit in this empty starter template.
      if(position.is_open)
        {
         // Future exit logic may inspect position here.
        }

      return false;
     }

   long TickCount() const { return g_ticks; }
   long RawSignalCount() const { return g_raw_signals; }
  };

#endif // ALPHA_TEMPLATE_V1_00_MQH
