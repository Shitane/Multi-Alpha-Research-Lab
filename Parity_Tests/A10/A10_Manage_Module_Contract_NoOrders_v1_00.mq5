//+------------------------------------------------------------------+
//| A10_Manage_Module_Contract_NoOrders_v1_00.mq5                    |
//| Compile/contract harness only. NO BROKER ORDERS.                 |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include "..\\..\\Include\\A10\\A10_Manage_Module_v1_00.mqh"

CA10ManageModule100 g_manage;

int OnInit()
  {
   if(!g_manage.Init(4,true,300))
      return INIT_FAILED;

   if(!g_manage.ConfigureMode(0,true,5,0.35,17.0) ||
      !g_manage.ConfigureMode(1,true,3,0.35,30.0) ||
      !g_manage.ConfigureMode(2,true,3,0.35,30.0) ||
      !g_manage.ConfigureMode(3,true,1,0.35,14.0))
      return INIT_FAILED;

   Print("[A10_MANAGE100_START] NO_ORDERS=1 CONTRACT_ONLY=1");
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick)) return;

   // Deliberately no synthetic trading decisions in this harness.
   // Its first gate is MetaEditor compile/include/API validation.
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[A10_MANAGE100_SUMMARY] open=%d pending_entries=%d exit_pending=%d transition_pending=%d reason=%d NO_ORDERS=1 CONTRACT_ONLY=1",
               g_manage.OpenCount(),g_manage.PendingEntryCount(),
               (int)g_manage.AnyExitPending(),(int)g_manage.TransitionPending(),
               reason);
  }
//+------------------------------------------------------------------+
