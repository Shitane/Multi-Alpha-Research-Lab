//+------------------------------------------------------------------+
//| MultiAlpha_Module_Registry_v1_75.mqh                             |
//| Capability registry after verified A10 FULL NoOrders parity.     |
//| Unsupported capability MUST fail; never fallback to O01.         |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_MODULE_REGISTRY_V1_75_MQH
#define MULTI_ALPHA_MODULE_REGISTRY_V1_75_MQH

#include "MultiAlpha_Module_Contract_v1_50.mqh"

enum ENUM_MA_MODULE_CAPABILITY_V175
  {
   MA_CAP_FULL_V175=0,
   MA_CAP_ENTRY_V175=1,
   MA_CAP_MANAGE_V175=2,
   MA_CAP_EXIT_V175=3
  };

string MA175CapabilityName(const ENUM_MA_MODULE_CAPABILITY_V175 cap)
  {
   if(cap==MA_CAP_FULL_V175) return "FULL";
   if(cap==MA_CAP_ENTRY_V175) return "ENTRY";
   if(cap==MA_CAP_MANAGE_V175) return "MANAGE";
   if(cap==MA_CAP_EXIT_V175) return "EXIT";
   return "UNKNOWN";
  }

bool MA175IsRegistered(const ENUM_MA_LOGIC_ID_V150 id,
                       const ENUM_MA_MODULE_CAPABILITY_V175 cap)
  {
   if(id==MA_LOGIC_O01_V150) return true;
   if(id==MA_LOGIC_A10_V150 && cap==MA_CAP_FULL_V175) return true;
   if(id==MA_LOGIC_A10_V150 && cap==MA_CAP_ENTRY_V175) return true;
   return false;
  }

string MA175RegistrationText(const ENUM_MA_LOGIC_ID_V150 id,
                             const ENUM_MA_MODULE_CAPABILITY_V175 cap)
  {
   return MA150LogicName(id)+" "+MA175CapabilityName(cap)+
          (MA175IsRegistered(id,cap) ? " REGISTERED" : " NOT REGISTERED");
  }

bool MA175ValidateRoute(const SMA_ModuleSelection150 &s,string &reason)
  {
   reason="";
   if(s.structure==MA_STRUCTURE_FULL_V150)
     {
      if(!MA175IsRegistered(s.full_module,MA_CAP_FULL_V175))
        {reason=MA175RegistrationText(s.full_module,MA_CAP_FULL_V175);return false;}
      return true;
     }
   if(!MA175IsRegistered(s.entry_module,MA_CAP_ENTRY_V175))
     {reason=MA175RegistrationText(s.entry_module,MA_CAP_ENTRY_V175);return false;}
   if(!MA175IsRegistered(s.manage_module,MA_CAP_MANAGE_V175))
     {reason=MA175RegistrationText(s.manage_module,MA_CAP_MANAGE_V175);return false;}
   if(!MA175IsRegistered(s.exit_module,MA_CAP_EXIT_V175))
     {reason=MA175RegistrationText(s.exit_module,MA_CAP_EXIT_V175);return false;}
   return true;
  }
#endif
