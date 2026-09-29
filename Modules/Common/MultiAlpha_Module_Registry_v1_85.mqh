//+------------------------------------------------------------------+
//| MultiAlpha_Module_Registry_v1_85.mqh                             |
//| A10 FULL/ENTRY/MANAGE/EXIT registration after documented parity. |
//| Unsupported/mixed ownership routes fail; never fallback to O01.  |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_MODULE_REGISTRY_V1_85_MQH
#define MULTI_ALPHA_MODULE_REGISTRY_V1_85_MQH
#include "MultiAlpha_Module_Contract_v1_50.mqh"

enum ENUM_MA_MODULE_CAPABILITY_V185 { MA_CAP_FULL_V185=0,MA_CAP_ENTRY_V185=1,MA_CAP_MANAGE_V185=2,MA_CAP_EXIT_V185=3 };

string MA185CapabilityName(const ENUM_MA_MODULE_CAPABILITY_V185 cap){
 if(cap==MA_CAP_FULL_V185)return "FULL";if(cap==MA_CAP_ENTRY_V185)return "ENTRY";
 if(cap==MA_CAP_MANAGE_V185)return "MANAGE";if(cap==MA_CAP_EXIT_V185)return "EXIT";return "UNKNOWN";
}
bool MA185IsRegistered(const ENUM_MA_LOGIC_ID_V150 id,const ENUM_MA_MODULE_CAPABILITY_V185 cap){
 if(id==MA_LOGIC_O01_V150)return true;
 if(id==MA_LOGIC_A10_V150)return true; // FULL + E/M/X documented parity PASS 2026-09-28
 return false;
}
string MA185RegistrationText(const ENUM_MA_LOGIC_ID_V150 id,const ENUM_MA_MODULE_CAPABILITY_V185 cap){
 return MA150LogicName(id)+" "+MA185CapabilityName(cap)+(MA185IsRegistered(id,cap)?" REGISTERED":" NOT REGISTERED");
}
bool MA185ValidateRoute(const SMA_ModuleSelection150 &s,string &reason){
 reason="";
 if(s.structure==MA_STRUCTURE_FULL_V150){
  if(!MA185IsRegistered(s.full_module,MA_CAP_FULL_V185)){reason=MA185RegistrationText(s.full_module,MA_CAP_FULL_V185);return false;}
  return true;
 }
 if(!MA185IsRegistered(s.entry_module,MA_CAP_ENTRY_V185)){reason=MA185RegistrationText(s.entry_module,MA_CAP_ENTRY_V185);return false;}
 if(!MA185IsRegistered(s.manage_module,MA_CAP_MANAGE_V185)){reason=MA185RegistrationText(s.manage_module,MA_CAP_MANAGE_V185);return false;}
 if(!MA185IsRegistered(s.exit_module,MA_CAP_EXIT_V185)){reason=MA185RegistrationText(s.exit_module,MA_CAP_EXIT_V185);return false;}
 // Current runtime ownership contracts are coherent only as complete O01 or complete A10.
 // Mixed E/M/X composition remains fail-safe until the shared position-state contract is connected.
 bool all_o01=(s.entry_module==MA_LOGIC_O01_V150&&s.manage_module==MA_LOGIC_O01_V150&&s.exit_module==MA_LOGIC_O01_V150);
 bool all_a10=(s.entry_module==MA_LOGIC_A10_V150&&s.manage_module==MA_LOGIC_A10_V150&&s.exit_module==MA_LOGIC_A10_V150);
 if(!all_o01&&!all_a10){reason="mixed E/M/X ownership contract not connected yet";return false;}
 return true;
}
#endif
