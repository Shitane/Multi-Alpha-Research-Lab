//+------------------------------------------------------------------+
//| O01_Route_Selector_Panel_NoOrders_v1_52.mq5                     |
//| Gate-3B basic panel selector compile/runtime host. NO ORDERS.    |
//+------------------------------------------------------------------+
#property strict
#property version "1.52"
#include "..\\..\\Include\\Common\\MultiAlpha_Route_Selector_Panel_v1_52.mqh"

input group "Initial Route"
input ENUM_MA_STRUCTURE_MODE_V150 InpStructure=MA_STRUCTURE_SPLIT_V150;
input ENUM_MA_LOGIC_ID_V150 InpFullModule=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpEntryModule=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpManageModule=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpExitModule=MA_LOGIC_O01_V150;

input group "Gate-3A Simulated Runtime State"
input int InpManagedPositions=0;
input bool InpCycleNone=true;
input bool InpExecutionTransitionPending=false;

CMultiAlphaRouteController151 route_controller;
CMultiAlphaRouteSelectorPanel152 route_panel;

SMA_ModuleSelection150 Selection()
  {
   SMA_ModuleSelection150 s;
   s.structure=InpStructure;s.full_module=InpFullModule;s.entry_module=InpEntryModule;
   s.manage_module=InpManageModule;s.exit_module=InpExitModule;return s;
  }
SMA_RouteState150 RouteState()
  {
   SMA_RouteState150 s;s.managed_positions=InpManagedPositions;s.cycle_none=InpCycleNone;
   s.execution_transition_pending=InpExecutionTransitionPending;return s;
  }
string RouteText(const SMA_ModuleSelection150 &s)
  {
   return "structure="+MA150StructureName(s.structure)+" full="+MA150LogicName(s.full_module)+
          " entry="+MA150LogicName(s.entry_module)+" manage="+MA150LogicName(s.manage_module)+
          " exit="+MA150LogicName(s.exit_module);
  }

int OnInit()
  {
   SMA_ModuleSelection150 initial=Selection();string reason="";
   if(!MA150ValidateO01Gate(initial,reason))
     {Print("[MA_ROUTE152_INIT_REJECT] reason=",reason," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");return INIT_PARAMETERS_INCORRECT;}
   route_controller.SetInitial(initial);route_panel.Create(&route_controller,initial,20,20);
   Print("[MA_ROUTE152_START] active={",RouteText(initial),"} NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return INIT_SUCCEEDED;
  }
void OnDeinit(const int reason){route_panel.Delete();}
void OnTick(){}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   string reason="";SMA_RouteState150 state=RouteState();
   int r=route_panel.Event(id,sparam,state,reason);
   if(r==0)return;
   SMA_ModuleSelection150 active=route_controller.Active();
   Print("[MA_ROUTE152_PANEL] event=",r," reason=",reason," active={",RouteText(active),
         "} state_positions=",state.managed_positions," cycle_none=",(int)state.cycle_none,
         " transition_pending=",(int)state.execution_transition_pending,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }
