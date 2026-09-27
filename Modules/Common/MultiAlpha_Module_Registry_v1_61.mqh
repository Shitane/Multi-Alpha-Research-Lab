//+------------------------------------------------------------------+
//| MultiAlpha_Module_Registry_v1_61.mqh                             |
//| Capability registry. Architecture only. NO broker orders.        |
//| Unsupported capability MUST fail; never fallback to O01.         |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_MODULE_REGISTRY_V1_61_MQH
#define MULTI_ALPHA_MODULE_REGISTRY_V1_61_MQH

#include "MultiAlpha_Module_Contract_v1_50.mqh"

enum ENUM_MA_MODULE_CAPABILITY_V161
  {
   MA_CAP_FULL_V161=0,
   MA_CAP_ENTRY_V161=1,
   MA_CAP_MANAGE_V161=2,
   MA_CAP_EXIT_V161=3
  };

string MA161CapabilityName(const ENUM_MA_MODULE_CAPABILITY_V161 cap)
  {
   if(cap==MA_CAP_FULL_V161) return "FULL";
   if(cap==MA_CAP_ENTRY_V161) return "ENTRY";
   if(cap==MA_CAP_MANAGE_V161) return "MANAGE";
   if(cap==MA_CAP_EXIT_V161) return "EXIT";
   return "UNKNOWN";
  }

// Registry reflects only adapters/contracts that are actually connected
// to the current Multi Alpha host.
// O01: verified for all four responsibilities.
// A10: source exists, but its isolated Entry adapter is not connected yet.
// Therefore A10 remains NOT REGISTERED until the next gate.
bool MA161IsRegistered(const ENUM_MA_LOGIC_ID_V150 id,
                       const ENUM_MA_MODULE_CAPABILITY_V161 cap)
  {
   if(id==MA_LOGIC_O01_V150) return true;
   return false;
  }

string MA161RegistrationText(const ENUM_MA_LOGIC_ID_V150 id,
                             const ENUM_MA_MODULE_CAPABILITY_V161 cap)
  {
   return MA150LogicName(id)+" "+MA161CapabilityName(cap)+
          (MA161IsRegistered(id,cap) ? " REGISTERED" : " NOT REGISTERED");
  }

bool MA161ValidateRoute(const SMA_ModuleSelection150 &s,string &reason)
  {
   reason="";
   if(s.structure==MA_STRUCTURE_FULL_V150)
     {
      if(!MA161IsRegistered(s.full_module,MA_CAP_FULL_V161))
        {
         reason=MA161RegistrationText(s.full_module,MA_CAP_FULL_V161);
         return false;
        }
      return true;
     }

   if(!MA161IsRegistered(s.entry_module,MA_CAP_ENTRY_V161))
     {
      reason=MA161RegistrationText(s.entry_module,MA_CAP_ENTRY_V161);
      return false;
     }
   if(!MA161IsRegistered(s.manage_module,MA_CAP_MANAGE_V161))
     {
      reason=MA161RegistrationText(s.manage_module,MA_CAP_MANAGE_V161);
      return false;
     }
   if(!MA161IsRegistered(s.exit_module,MA_CAP_EXIT_V161))
     {
      reason=MA161RegistrationText(s.exit_module,MA_CAP_EXIT_V161);
      return false;
     }
   return true;
  }

#endif
