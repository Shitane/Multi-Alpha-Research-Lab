//+------------------------------------------------------------------+
//| O01_Route_Change_Safety_NoOrders_v1_51.mq5                      |
//| Gate-3A: verify route changes are flat/cycle-none only.          |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.51"

#include "..\..\Include\Common\MultiAlpha_Route_Controller_v1_51.mqh"

input group "Initial route"
input ENUM_MA_STRUCTURE_MODE_V150 InpInitialStructure=MA_STRUCTURE_SPLIT_V150;
input ENUM_MA_LOGIC_ID_V150 InpInitialFull=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpInitialEntry=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpInitialManage=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpInitialExit=MA_LOGIC_O01_V150;

input group "Requested route"
input ENUM_MA_STRUCTURE_MODE_V150 InpRequestedStructure=MA_STRUCTURE_FULL_V150;
input ENUM_MA_LOGIC_ID_V150 InpRequestedFull=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpRequestedEntry=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpRequestedManage=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpRequestedExit=MA_LOGIC_O01_V150;

input group "Simulated route state"
input int  InpManagedPositions=0;
input bool InpCycleNone=true;
input bool InpExecutionTransitionPending=false;

CMultiAlphaRouteController151 controller;

SMA_ModuleSelection150 MakeSelection(const ENUM_MA_STRUCTURE_MODE_V150 structure,
                                     const ENUM_MA_LOGIC_ID_V150 full_module,
                                     const ENUM_MA_LOGIC_ID_V150 entry_module,
                                     const ENUM_MA_LOGIC_ID_V150 manage_module,
                                     const ENUM_MA_LOGIC_ID_V150 exit_module)
  {
   SMA_ModuleSelection150 s;
   s.structure=structure;
   s.full_module=full_module;
   s.entry_module=entry_module;
   s.manage_module=manage_module;
   s.exit_module=exit_module;
   return s;
  }

string RouteText(const SMA_ModuleSelection150 &s)
  {
   return "structure="+MA150StructureName(s.structure)+
          " full="+MA150LogicName(s.full_module)+
          " entry="+MA150LogicName(s.entry_module)+
          " manage="+MA150LogicName(s.manage_module)+
          " exit="+MA150LogicName(s.exit_module);
  }

int OnInit()
  {
   SMA_ModuleSelection150 initial=MakeSelection(InpInitialStructure,InpInitialFull,InpInitialEntry,InpInitialManage,InpInitialExit);
   string reason="";
   if(!MA150ValidateO01Gate(initial,reason))
     {
      Print("[MA_ROUTE151_INIT_REJECT] reason=",reason," ",RouteText(initial)," NO_ORDERS=1");
      return INIT_PARAMETERS_INCORRECT;
     }

   controller.SetInitial(initial);

   SMA_ModuleSelection150 requested=MakeSelection(InpRequestedStructure,InpRequestedFull,InpRequestedEntry,InpRequestedManage,InpRequestedExit);
   SMA_RouteState150 state;
   state.managed_positions=InpManagedPositions;
   state.cycle_none=InpCycleNone;
   state.execution_transition_pending=InpExecutionTransitionPending;

   bool ok=controller.Request(requested,state,reason);
   SMA_ModuleSelection150 active=controller.Active();

   Print("[MA_ROUTE151_REQUEST] requested={",RouteText(requested),"} state_positions=",state.managed_positions,
         " cycle_none=",(int)state.cycle_none," transition_pending=",(int)state.execution_transition_pending,
         " result=",(ok?"ACCEPT":"REJECT")," reason=",reason,
         " active={",RouteText(active),"} NO_ORDERS=1");

   // Rejection is an expected safety outcome, not an EA initialization error.
   // This lets the tester log prove that the active route was preserved.
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   // Intentionally empty: this gate tests route-change policy only.
  }
