//+------------------------------------------------------------------+
//| MultiAlpha_Module_Contract_v1_50.mqh                             |
//| Common selection contract for verified Multi Alpha logic paths.  |
//| Architecture only. NO broker orders.                             |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_MODULE_CONTRACT_V1_50_MQH
#define MULTI_ALPHA_MODULE_CONTRACT_V1_50_MQH

enum ENUM_MA_STRUCTURE_MODE_V150
  {
   MA_STRUCTURE_FULL_V150=0,
   MA_STRUCTURE_SPLIT_V150=1
  };

enum ENUM_MA_LOGIC_ID_V150
  {
   MA_LOGIC_NONE_V150=0,
   MA_LOGIC_A10_V150=10,
   MA_LOGIC_A11_V150=11,
   MA_LOGIC_A12_V150=12,
   MA_LOGIC_A13_V150=13,
   MA_LOGIC_A14_V150=14,
   MA_LOGIC_A15_V150=15,
   MA_LOGIC_O01_V150=101
  };

struct SMA_ModuleSelection150
  {
   ENUM_MA_STRUCTURE_MODE_V150 structure;
   ENUM_MA_LOGIC_ID_V150 full_module;
   ENUM_MA_LOGIC_ID_V150 entry_module;
   ENUM_MA_LOGIC_ID_V150 manage_module;
   ENUM_MA_LOGIC_ID_V150 exit_module;
  };

struct SMA_RouteState150
  {
   int  managed_positions;
   bool cycle_none;
   bool execution_transition_pending;
  };

string MA150LogicName(const ENUM_MA_LOGIC_ID_V150 id)
  {
   switch(id)
     {
      case MA_LOGIC_A10_V150:return "A10";
      case MA_LOGIC_A11_V150:return "A11";
      case MA_LOGIC_A12_V150:return "A12";
      case MA_LOGIC_A13_V150:return "A13";
      case MA_LOGIC_A14_V150:return "A14";
      case MA_LOGIC_A15_V150:return "A15";
      case MA_LOGIC_O01_V150:return "O01";
      default:return "NONE";
     }
  }

string MA150StructureName(const ENUM_MA_STRUCTURE_MODE_V150 mode)
  {
   return mode==MA_STRUCTURE_FULL_V150 ? "FULL" : "SPLIT";
  }

bool MA150CanChangeRoute(const SMA_RouteState150 &state,string &reason)
  {
   reason="";
   if(state.managed_positions!=0)
     {
      reason="managed positions are open";
      return false;
     }
   if(!state.cycle_none)
     {
      reason="cycle is active";
      return false;
     }
   if(state.execution_transition_pending)
     {
      reason="execution transition is pending";
      return false;
     }
   return true;
  }

// Registration gate for the current verified O01 architecture.
// Future A-series/O-series combinations are added only after their adapters
// implement this common contract. Unsupported routes fail; never fallback.
bool MA150ValidateO01Gate(const SMA_ModuleSelection150 &s,string &reason)
  {
   reason="";
   if(s.structure==MA_STRUCTURE_FULL_V150)
     {
      if(s.full_module!=MA_LOGIC_O01_V150)
        {
         reason="FULL route requires registered O01 whole-path module";
         return false;
        }
      return true;
     }

   if(s.entry_module!=MA_LOGIC_O01_V150)
     {
      reason="SPLIT entry module is not registered for this gate";
      return false;
     }
   if(s.manage_module!=MA_LOGIC_O01_V150)
     {
      reason="SPLIT manage module is not registered for this gate";
      return false;
     }
   if(s.exit_module!=MA_LOGIC_O01_V150)
     {
      reason="SPLIT exit module is not registered for this gate";
      return false;
     }
   return true;
  }

#endif
