//+------------------------------------------------------------------+
//| MultiAlpha_Runtime_Panel_LeftBuilderMigration_NoOrders_v2_69.mq5                      |
//| Multi Alpha integration gate: O01 plus verified FULL=A10 route.   |
//| NO_ORDERS only. v1.73 remains the verified O01 DEMO host.         |
//| A10 FULL uses the same verified v1.74 dispatcher/module path.     |
//+------------------------------------------------------------------+
#property strict
#property version "2.69"

#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Runtime_Adapter_v1_20.mqh"
#include "..\\..\\..\\Include\\O01\\O01_Settings_Panel_v1_64.mqh"
#include "..\\..\\..\\Include\\O01\\MultiAlpha_Foundation_v1_40.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Route_Selector_Panel_v1_85.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_A10_Split_Runtime_v1_85.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Full_Dispatcher_v1_74.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Entry_Dispatcher_v1_72.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Demo_Execution_Adapter_v1_73.mqh"
#include "..\\..\\..\\Include\\A10\\A10_Entry_Settings_Panel_v1_03.mqh"
#include "..\\..\\..\\Include\\A10\\A10_Full_Settings_Panel_v1_02.mqh"
#include "..\\..\\..\\Include\\A10\\A10_Split_Detail_Panel_v1_00.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Left_Context_v1_84.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Left_Workspace_Tabs_v2_03.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Right_Workspace_Tabs_v1_03.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Builder_Workspace_Shell_v1_01.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Workspace_O01_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_FreeSlot_Panel_v1_23.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Parts_Picker_v1_13.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Interpreter_v1_01.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Instance_Composer_v1_01.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Slot_Workspace_Store_v1_01.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Readout_Panel_v1_04.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Common_Filter_v1_10.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Filter_Panel_v1_11.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Slot_Filter_Preset_v1_20.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Filter_Preset_Panel_v1_26.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Preset_Action_Panel_v2_14.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Slot_State_v1_95.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Slot_Panel_v2_15.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Left_Slot_Badge_v1_99.mqh"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Left_Header_Spacing_v1_99.mqh"

enum O01_TIME_MODE { O01_AUTO_GMT=0,O01_SERVER_TIME=1,O01_CUSTOM_GMT=2 };

input ENUM_MA_EXECUTION_MODE InpExecutionMode=MA_EXECUTION_NO_ORDERS;

input group "Multi Alpha Instance Identity"
input int  InpInstanceId=1;
input long InpMagic=46102031;

input group "Multi Alpha Route"
input ENUM_MA_STRUCTURE_MODE_V150 InpStructure=MA_STRUCTURE_FULL_V150;
input ENUM_MA_LOGIC_ID_V150 InpFullModule=MA_LOGIC_A10_V150;
input ENUM_MA_LOGIC_ID_V150 InpEntryModule=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpManageModule=MA_LOGIC_O01_V150;
input ENUM_MA_LOGIC_ID_V150 InpExitModule=MA_LOGIC_O01_V150;

// O01 startup defaults. Expert Properties -> panel -> runtime.
// These inputs are read only after initialization; panel APPLY/LOAD changes runtime, not these input values.
input group "O01 Entry / Filter"
input bool   InpNewCycles=true;
input bool   InpTradeBuy=true;
input bool   InpTradeSell=true;
input int    InpRSIPeriod=8;
input double InpRSILower=30.0;
input double InpRSIUpper=70.0;
input int    InpATR1Period=15;
input int    InpATR2Period=15;
input ENUM_TIMEFRAMES InpATR2Timeframe=PERIOD_CURRENT;
input double InpATR1MinPoints=0.0;
input double InpATR1MaxPoints=10000.0;
input double InpATR2MinPoints=0.0;
input double InpATR2MaxPoints=10000.0;

input group "O01 Manage / Grid / Lot"
input double InpInitialLot=0.01;
input double InpLotMultiplier=1.50;
input double InpMaxLot=5.00;
input double InpMaxTotalLotsPerSide=1.20;
input int    InpMaxOrders=10;
input int    InpFixedDistancePoints=200;
input int    InpDynamicStartOrder=3;
input int    InpDynamicStartPoints=300;
input double InpDistanceMultiplier=1.20;
input bool   InpAllowGridOutsideTime=true;
input bool   InpOneOrderPerBar=true;
input bool   InpPauseGridWhileTrailing=true;

input group "O01 Exit / Trailing"
input int InpVirtualSLPoints=1500;
input int InpSingleTrailStart=110;
input int InpSingleTrailLock=60;
input int InpSingleTrailDistance=50;
input int InpSingleTrailStep=10;
input int InpBasketTrailStart=100;
input int InpBasketTrailLock=50;
input int InpBasketTrailDistance=50;
input int InpBasketTrailStep=10;

input group "O01 Safety / DD"
input int InpWarningDD=8;
input int InpPauseGridDD=12;
input int InpEmergencyCloseDD=15;

input group "O01 Time / News"
input O01_TIME_MODE InpTimeMode=O01_AUTO_GMT;
input int InpStartHour=7;
input int InpStartMinute=0;
input int InpEndHour=11;
input int InpEndMinute=0;
input bool InpUseNewsFilter=true;
input bool InpNewsManageOnly=true;

SO01RuntimeSettings110 runtime_cfg;
CO01SettingsPanel164 panel;
CO01RuntimeAdapter120 adapter;
CO01CoreInterface core;
SMA140StrategyIdentity strategy;
SMA140PanelTheme panel_theme;
CMultiAlphaRouteController185 route_controller;
CMultiAlphaRouteSelectorPanel185 route_panel;
bool route_panel_created231=false;
CMultiAlphaEntryDispatcher172 entry_dispatcher;
CMultiAlphaFullDispatcher174 full_dispatcher;
CMultiAlphaA10SplitRuntime185 a10_split_runtime;
CMultiAlphaDemoExecutionAdapter173 execution_adapter;
SA10EntrySettings100 a10_entry_cfg;
CA10EntrySettingsPanel100 a10_panel;
SA10FullConfig100 a10_full_cfg;
CA10FullSettingsPanel102 a10_full_panel;
CA10SplitDetailPanel100 a10_split_detail_panel;
CMultiAlphaLeftContext184 left_context;
CMultiAlphaLeftWorkspaceTabs203 left_tabs;
CMultiAlphaRightWorkspaceTabs103 right_tabs;
CMultiAlphaBuilderWorkspaceShell101 builder_workspace;
CMultiAlphaBuilderWorkspaceO01100 o01_builder_workspace;
CMultiAlphaBuilderFreeSlotPanel123 free_slot_builder;
CMultiAlphaBuilderPartsPicker113 builder_parts_picker;
CMultiAlphaBuilderInterpreter101 builder_interpreter;
CMultiAlphaBuilderReadoutPanel104 builder_readout;
CMultiAlphaBuilderInstanceComposer101 builder_instance_composer;
CMultiAlphaBuilderSlotWorkspaceStore101 builder_slot_workspace;
CMultiAlphaFilterStore110 filter_store;
CMultiAlphaFilterPanel111 filter_panel;
CMultiAlphaSlotFilterPreset120 filter_preset;
CMultiAlphaFilterPresetPanel126 filter_preset_panel;
CMultiAlphaPresetActionPanel214 preset_action_panel;
CMultiAlphaSlotState195 slot_state;
CMultiAlphaSlotPanel215 slot_panel;
CMultiAlphaLeftSlotBadge199 left_slot_badge;
CMultiAlphaLeftHeaderSpacing199 left_header_spacing;
bool left_builder_parts269=false;

struct VPos{double price,lot;datetime time,bar;};
VPos buy[],sell[];
SO01TrailState bt,st;
int rh=INVALID_HANDLE,a1h=INVALID_HANDLE,a2h=INVALID_HANDLE;
datetime lastBuyBar=0,lastSellBar=0;
ulong ticks=0,entries=0,grids=0,closes=0,singleTrail=0,basketTrail=0,vsl=0,timeBlocks=0,newsBlocks=0,spreadBlocks=0,filterBlocks=0;


void CleanupLegacyWorkspaceObjects220()
{
 // Remove orphan UI objects left by earlier panel generations.
 // Current v2.20 objects are recreated immediately after this cleanup.
 string prefixes[]={"MAPRESET212_","MAPRESET213_","MAPRESET214_","MAFPRESET123_","MAFPRESET124_","MAFPRESET125_","MAFPRESET126_","MARIGHT100_","MARIGHT101_","MALEFT202_","MALEFTSLOT198_"};
 for(int i=0;i<ArraySize(prefixes);i++) ObjectsDeleteAll(0,prefixes[i]);
 // Retired O01 preset controls shared the O01CFG160 prefix, so remove them by exact name.
 string retired[]={"L_H_PRESETSEC","L_PRESETLAB","PRESET","L_SAVEDLAB","L_SAVEDVAL","NEXT","SAVE","LOAD","DELETE","RESET"};
 for(int j=0;j<ArraySize(retired);j++) ObjectDelete(0,"O01CFG160_"+retired[j]);
 ChartRedraw();
}
void SetPrefixVisible221(const string prefix,const bool on)
{
 int total=ObjectsTotal(0,0,-1);
 for(int i=total-1;i>=0;i--)
 {
  string n=ObjectName(0,i,0,-1);
  if(StringFind(n,prefix)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));
 }
}
void BuilderReadout243(){string pp[],pv[],why;free_slot_builder.Export(pp,pv);bool ok=builder_interpreter.Validate(pp,pv,why);string expr=builder_interpreter.Expression(pp,pv);builder_readout.Show(ok,why,expr);Print("[MA_BUILDER243_READ] valid=",(int)ok," reason=",why," expression=",expr," NO_ORDERS=1");}
void AssignBuilderRoleToSelectedSlot264()
{
 string pp[],pv[],why;free_slot_builder.Export(pp,pv);
 int target=slot_state.Selected(),role=free_slot_builder.Role();
 string defname=free_slot_builder.DefinitionName(role);
 bool ok=builder_instance_composer.AssignRole(target,role,defname,pp,pv,why);
 if(ok) builder_instance_composer.SetIdentity(target,strategy.symbol,strategy.magic+(target-1));
 Print("[MA_BUILDER264_ROLE_EMBED] slot=",target," role=",(role==0?"ENTRY":role==1?"MANAGE":"EXIT"),
       " definition=",defname," ok=",(int)ok," reason=",why,
       " summary=",builder_instance_composer.Summary(target)," NO_ORDERS=1");
}
void EmbedAllBuilderRolesToSelectedSlot264()
{
 int target=slot_state.Selected(); bool all_ok=true; string all_reason="";
 for(int role=0;role<3;role++)
 {
  string pp[],pv[],why;free_slot_builder.ExportRole(role,pp,pv);
  string defname=free_slot_builder.DefinitionName(role);
  bool ok=builder_instance_composer.AssignRole(target,role,defname,pp,pv,why);
  Print("[MA_BUILDER264_ROLE_EMBED] slot=",target," role=",(role==0?"ENTRY":role==1?"MANAGE":"EXIT"),
        " definition=",defname," ok=",(int)ok," reason=",why," NO_ORDERS=1");
  if(!ok){all_ok=false;if(all_reason!="")all_reason+=" | ";all_reason+=(role==0?"ENTRY":role==1?"MANAGE":"EXIT")+": "+why;}
 }
 builder_instance_composer.SetIdentity(target,strategy.symbol,strategy.magic+(target-1));
 string ready_reason="";bool ready=builder_instance_composer.Ready(target,ready_reason);
 Print("[MA_BUILDER264_SLOT_EMBED] slot=",target," all_roles=",(int)all_ok," ready=",(int)ready,
       " reason=",(all_ok?ready_reason:all_reason)," summary=",builder_instance_composer.Summary(target)," NO_ORDERS=1");
}
void RefreshRightWorkspace221()
{
 bool slot=right_tabs.SlotVisible();
 slot_panel.SetVisible(slot);
 if(!slot)
 {
  SetPrefixVisible221("MA_ROUTE175_",false);
 }
 if(slot)
 {
  // v2.31: ROUTE uses a Canvas background. Hiding old chart objects and
  // merely restoring TIMEFRAMES can leave that canvas black after a
  // workspace round-trip. Recreate ROUTE from the selected-slot state,
  // matching the known-good startup lifecycle.
  SMA_ModuleSelection150 d=slot_state.CurrentRoute();
  if(route_panel_created231) route_panel.Delete();
  route_panel.Create(&route_controller,d,640,146,panel_theme.opacity);
  route_panel_created231=true;
  route_panel.SetDraft(d);
  bool reg=(d.structure==MA_STRUCTURE_FULL_V150
            ? route_panel.DraftFullRegistered()
            : (route_panel.DraftEntryRegistered() &&
               route_panel.DraftManageRegistered() &&
               route_panel.DraftExitRegistered()));
  panel.SetRouteDraftContext(MA150StructureName(d.structure),
                             MA150LogicName(d.full_module),
                             MA150LogicName(d.entry_module),
                             MA150LogicName(d.manage_module),
                             MA150LogicName(d.exit_module),reg);
 }
 // v2.69: right workspace owns SLOT only. Builder and EA PARTS live inside left LOGIC.
 builder_readout.Hide();free_slot_builder.Hide();builder_parts_picker.Hide();o01_builder_workspace.Hide();builder_workspace.HideAll();
 ObjectSetInteger(0,"MARIGHT103_TAB_LOGIC",OBJPROP_TIMEFRAMES,0);
 ObjectSetInteger(0,"MARIGHT103_TAB_PARTS",OBJPROP_TIMEFRAMES,0);
 ChartRedraw();
}

void RefreshLeftBuilder269()
{
 bool logic=left_tabs.LogicVisible();
 if(logic)
 {
  // LOGIC is now the Builder workspace. Retire the legacy O01/A10 settings surface from this view.
  SetPrefixVisible221("O01CFG160_",false);
  a10_full_panel.Hide();
  a10_panel.ShowModeButton(false);
  ObjectDelete(0,"O01CFG160_A10_FULL_MODE_NEXT");
  ObjectDelete(0,"O01CFG160_A10_MODE_NEXT");
  if(left_builder_parts269)
  {
   builder_readout.Hide();free_slot_builder.Hide();
   builder_parts_picker.SetRole(free_slot_builder.Role());
   builder_parts_picker.SetSlot(free_slot_builder.Selected(),free_slot_builder.SelectedPart(),free_slot_builder.SelectedParams());
   builder_parts_picker.Show();
  }
  else
  {
   builder_parts_picker.Hide();
   free_slot_builder.Show();
   BuilderReadout243();
  }
 }
 else
 {
  builder_readout.Hide();free_slot_builder.Hide();builder_parts_picker.Hide();
 }
 ChartRedraw();
}

void A10FullDefaults175(SA10FullConfig100 &c)
{
 c.max_positions=4;c.skip_opposite=true;c.entry_ttl_seconds=120;
 c.mode[0].enabled=true;c.mode[0].brick=17;c.mode[0].bb_period=20;c.mode[0].deviation=1.0;c.mode[0].squeeze_width=1.0;c.mode[0].entry_run=2;c.mode[0].tp=24;c.mode[0].sl=42;c.mode[0].max_hold=1230;c.mode[0].cooldown=5;c.mode[0].max_spread=.35;
 c.mode[1].enabled=true;c.mode[1].brick=30;c.mode[1].bb_period=31;c.mode[1].deviation=1.2;c.mode[1].squeeze_width=1.0;c.mode[1].entry_run=1;c.mode[1].tp=28;c.mode[1].sl=48.5;c.mode[1].max_hold=2580;c.mode[1].cooldown=3;c.mode[1].max_spread=.35;
 c.mode[2].enabled=true;c.mode[2].brick=30;c.mode[2].bb_period=5;c.mode[2].deviation=3.0;c.mode[2].squeeze_width=1.0;c.mode[2].entry_run=1;c.mode[2].tp=10;c.mode[2].sl=34.5;c.mode[2].max_hold=2220;c.mode[2].cooldown=3;c.mode[2].max_spread=.35;
 c.mode[3].enabled=true;c.mode[3].brick=14;c.mode[3].bb_period=18;c.mode[3].deviation=2.4;c.mode[3].squeeze_width=34.5;c.mode[3].entry_run=1;c.mode[3].tp=26;c.mode[3].sl=31;c.mode[3].max_hold=2050;c.mode[3].cooldown=1;c.mode[3].max_spread=.35;
}
string A10FullModeName175(const int m){if(m==0)return "Breakout";if(m==1)return "Re-entry";if(m==2)return "Midline";if(m==3)return "Squeeze";return "Unknown";}

void Defaults(){
 runtime_cfg.new_cycles=InpNewCycles;runtime_cfg.trade_buy=InpTradeBuy;runtime_cfg.trade_sell=InpTradeSell;runtime_cfg.allow_grid_outside_time=InpAllowGridOutsideTime;runtime_cfg.one_order_per_bar=InpOneOrderPerBar;runtime_cfg.pause_grid_while_trailing=InpPauseGridWhileTrailing;
 runtime_cfg.rsi_period=InpRSIPeriod;runtime_cfg.rsi_lower=InpRSILower;runtime_cfg.rsi_upper=InpRSIUpper;runtime_cfg.atr1_period=InpATR1Period;runtime_cfg.atr2_period=InpATR2Period;runtime_cfg.atr2_timeframe=(int)InpATR2Timeframe;runtime_cfg.atr1_min_points=InpATR1MinPoints;runtime_cfg.atr1_max_points=InpATR1MaxPoints;runtime_cfg.atr2_min_points=InpATR2MinPoints;runtime_cfg.atr2_max_points=InpATR2MaxPoints;
 runtime_cfg.initial_lot=InpInitialLot;runtime_cfg.lot_multiplier=InpLotMultiplier;runtime_cfg.max_lot=InpMaxLot;runtime_cfg.max_total_lots_per_side=InpMaxTotalLotsPerSide;runtime_cfg.max_orders=InpMaxOrders;runtime_cfg.fixed_distance_points=InpFixedDistancePoints;runtime_cfg.dynamic_start_order=InpDynamicStartOrder;runtime_cfg.dynamic_start_points=InpDynamicStartPoints;runtime_cfg.distance_multiplier=InpDistanceMultiplier;
 runtime_cfg.virtual_sl_points=InpVirtualSLPoints;runtime_cfg.single_trail_start=InpSingleTrailStart;runtime_cfg.single_trail_lock=InpSingleTrailLock;runtime_cfg.single_trail_distance=InpSingleTrailDistance;runtime_cfg.single_trail_step=InpSingleTrailStep;runtime_cfg.basket_trail_start=InpBasketTrailStart;runtime_cfg.basket_trail_lock=InpBasketTrailLock;runtime_cfg.basket_trail_distance=InpBasketTrailDistance;runtime_cfg.basket_trail_step=InpBasketTrailStep;
 runtime_cfg.warning_dd=InpWarningDD;runtime_cfg.pause_grid_dd=InpPauseGridDD;runtime_cfg.emergency_close_dd=InpEmergencyCloseDD;runtime_cfg.time_mode=(int)InpTimeMode;runtime_cfg.start_hour=InpStartHour;runtime_cfg.start_minute=InpStartMinute;runtime_cfg.end_hour=InpEndHour;runtime_cfg.end_minute=InpEndMinute;runtime_cfg.use_news_filter=InpUseNewsFilter;runtime_cfg.news_manage_only=InpNewsManageOnly;
}
double B(int h){double x[1];return CopyBuffer(h,0,0,1,x)==1?x[0]:EMPTY_VALUE;}
int C(VPos &p[]){return ArraySize(p);}
double Lots(VPos &p[]){double s=0;for(int i=0;i<C(p);i++)s+=p[i].lot;return s;}
double Avg(VPos &p[]){double pv=0,v=0;for(int i=0;i<C(p);i++){pv+=p[i].price*p[i].lot;v+=p[i].lot;}return v>0?pv/v:0;}
double LastPrice(VPos &p[]){return C(p)?p[C(p)-1].price:0;}
double LastLot(VPos &p[]){return C(p)?p[C(p)-1].lot:runtime_cfg.initial_lot;}
double NormLot(double x){double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX),step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);if(step<=0)step=.01;x=MathMax(mn,MathMin(mx,MathMin(runtime_cfg.max_lot,x)));return NormalizeDouble(MathRound(x/step)*step,2);}
double Dist(int n){if(n<runtime_cfg.dynamic_start_order)return runtime_cfg.fixed_distance_points;return runtime_cfg.dynamic_start_points*MathPow(runtime_cfg.distance_multiplier,n-runtime_cfg.dynamic_start_order);}
int NM(int m){while(m<0)m+=1440;while(m>=1440)m-=1440;return m;}
bool Win(int m,int s,int e){return s==e||(s<e?(m>=s&&m<e):(m>=s||m<e));}
bool TimeOK(){MqlDateTime d;TimeToStruct(TimeTradeServer(),d);if(d.day_of_week<1||d.day_of_week>5)return false;int m=d.hour*60+d.min,s=runtime_cfg.start_hour*60+runtime_cfg.start_minute,e=runtime_cfg.end_hour*60+runtime_cfg.end_minute;if(runtime_cfg.time_mode==O01_AUTO_GMT||runtime_cfg.time_mode==O01_CUSTOM_GMT){s=NM(s+180);e=NM(e+180);}return Win(m,s,e);}
bool SpreadOK(){return true;}
bool NewsNewBlocked(){return false;}
bool NewsGridBlocked(){return false;}
bool DemoExecution(){return InpExecutionMode==MA_EXECUTION_DEMO;}
int LiveCount(const bool isBuy){return execution_adapter.ManagedPositionsSide(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL);}
double LiveLots(const bool isBuy){return execution_adapter.ManagedLotsSide(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL);}
double LiveAvg(const bool isBuy){return execution_adapter.WeightedAveragePrice(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL);}
double LiveLastPrice(const bool isBuy){return execution_adapter.NewestPositionPrice(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL);}
double LiveLastLot(const bool isBuy){return execution_adapter.NewestPositionLot(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL);}
bool ExecOpen(const bool isBuy,const double lot,const string tag){
 string reason="";bool ok=execution_adapter.OpenMarket(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL,lot,tag,reason);
 if(!ok)Print("[MA_RUNTIME185_OPEN_REJECT] side=",(isBuy?"BUY":"SELL")," tag=",tag," reason=",reason);
 return ok;
}
bool ExecCloseSide(const bool isBuy,const string why){
 string reason="";bool ok=execution_adapter.CloseSide(isBuy?POSITION_TYPE_BUY:POSITION_TYPE_SELL,reason);
 if(!ok)Print("[MA_RUNTIME185_CLOSE_REJECT] side=",(isBuy?"BUY":"SELL")," why=",why," reason=",reason);
 return ok;
}
void Add(VPos &p[],double px,double lot){int n=C(p);ArrayResize(p,n+1);p[n].price=px;p[n].lot=lot;p[n].time=TimeCurrent();p[n].bar=iTime(_Symbol,_Period,0);}
void Clear(VPos &p[]){ArrayResize(p,0);}
string EN(ENUM_O01_EXIT_DECISION d){if(d==O01_EXIT_VIRTUAL_SL)return "VIRTUAL_SL";if(d==O01_EXIT_SINGLE_TRAILING)return "SINGLE_TRAILING";if(d==O01_EXIT_BASKET_TRAILING)return "BASKET_TRAILING";if(d==O01_EXIT_FIXED_TP)return "FIXED_TP";return "NONE";}
void LO(string side,string tag,double px,double lot,int n){Print("[O01_RUNTIME140_OPEN] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," instance=",strategy.instance_id," magic=",strategy.magic," symbol=",strategy.symbol," side=",side," tag=",tag," count=",n," lot=",DoubleToString(lot,2)," px=",DoubleToString(px,_Digits)," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));}
void LX(string side,ENUM_O01_EXIT_DECISION d,int n,double avg,double px,double mv){Print("[O01_RUNTIME140_EXIT] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," instance=",strategy.instance_id," magic=",strategy.magic," symbol=",strategy.symbol," side=",side," reason=",EN(d)," count=",n," avg=",DoubleToString(avg,_Digits)," px=",DoubleToString(px,_Digits)," move_pts=",DoubleToString(mv,1)," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));}

bool RebuildIndicatorHandles()
{
 int nr=iRSI(_Symbol,_Period,runtime_cfg.rsi_period,PRICE_CLOSE);
 int na1=iATR(_Symbol,_Period,runtime_cfg.atr1_period);
 int na2=iATR(_Symbol,(ENUM_TIMEFRAMES)runtime_cfg.atr2_timeframe,runtime_cfg.atr2_period);
 if(nr==INVALID_HANDLE||na1==INVALID_HANDLE||na2==INVALID_HANDLE)
 {
  if(nr!=INVALID_HANDLE)IndicatorRelease(nr);if(na1!=INVALID_HANDLE)IndicatorRelease(na1);if(na2!=INVALID_HANDLE)IndicatorRelease(na2);
  Print("[O01_RUNTIME140_HANDLES] rebuild failed");
  return false;
 }
 if(rh!=INVALID_HANDLE)IndicatorRelease(rh);if(a1h!=INVALID_HANDLE)IndicatorRelease(a1h);if(a2h!=INVALID_HANDLE)IndicatorRelease(a2h);
 rh=nr;a1h=na1;a2h=na2;
 Print("[O01_RUNTIME140_HANDLES] rebuilt RSI=",runtime_cfg.rsi_period," ATR1=",runtime_cfg.atr1_period," ATR2=",runtime_cfg.atr2_period," TF2=",runtime_cfg.atr2_timeframe);
 return true;
}

void Manage(bool isBuy,VPos &p[],SO01TrailState &ts,MqlTick &t){
 bool live=DemoExecution();
 int n=(live?LiveCount(isBuy):C(p));if(n<=0){core.ResetTrail(ts);return;}
 double avg=(live?LiveAvg(isBuy):Avg(p)),px=isBuy?t.bid:t.ask,mv=isBuy?(px-avg)/_Point:(avg-px)/_Point;
 SO01ExitConfig xc;adapter.ExitConfig(runtime_cfg,n,xc);ENUM_O01_EXIT_DECISION d=core.EvaluateExit(isBuy,n,mv,xc,ts);
 if(d!=O01_EXIT_NONE){
  LX(isBuy?"BUY":"SELL",d,n,avg,px,mv);
  bool closed=(!live||ExecCloseSide(isBuy,EN(d)));
  if(closed){closes++;if(d==O01_EXIT_SINGLE_TRAILING)singleTrail++;if(d==O01_EXIT_BASKET_TRAILING)basketTrail++;if(d==O01_EXIT_VIRTUAL_SL)vsl++;if(!live)Clear(p);core.ResetTrail(ts);}
  return;
 }
 if(n>=runtime_cfg.max_orders||(runtime_cfg.pause_grid_while_trailing&&ts.active))return;
 if(!runtime_cfg.allow_grid_outside_time&&!TimeOK())return;if(NewsGridBlocked()||!SpreadOK())return;
 datetime bar=iTime(_Symbol,_Period,0);if(runtime_cfg.one_order_per_bar&&(isBuy?lastBuyBar:lastSellBar)==bar)return;
 double lp=(live?LiveLastPrice(isBuy):LastPrice(p)),ds=Dist(n+1);if(lp<=0)return;
 bool met=isBuy?t.ask<=lp-ds*_Point:t.bid>=lp+ds*_Point;if(!met)return;
 double lastLot=(live?LiveLastLot(isBuy):LastLot(p));double lot=NormLot(lastLot*runtime_cfg.lot_multiplier);
 double totalLots=(live?LiveLots(isBuy):Lots(p));if(runtime_cfg.max_total_lots_per_side>0&&totalLots+lot>runtime_cfg.max_total_lots_per_side+1e-9)return;
 double op=isBuy?t.ask:t.bid;
 bool opened=(!live||ExecOpen(isBuy,lot,"GRID #"+IntegerToString(n+1)));
 if(opened){if(!live)Add(p,op,lot);if(isBuy)lastBuyBar=bar;else lastSellBar=bar;grids++;LO(isBuy?"BUY":"SELL","GRID #"+IntegerToString(n+1),op,lot,n+1);}
}

SMA_ModuleSelection150 StartupRoute(){
 SMA_ModuleSelection150 s;s.structure=InpStructure;s.full_module=InpFullModule;s.entry_module=InpEntryModule;s.manage_module=InpManageModule;s.exit_module=InpExitModule;return s;
}
SMA_RouteState150 LiveRouteState(){
 SMA_RouteState150 s;
 // While broker actions remain unarmed, virtual positions preserve the parity
 // cycle gate. Any real positions already owned by this Symbol+Magic are also
 // counted so a route cannot be changed across an ownership boundary.
 int real_positions=(execution_adapter.Initialized()?execution_adapter.ManagedPositions():0);
 s.managed_positions=C(buy)+C(sell)+real_positions;
 s.cycle_none=(s.managed_positions==0);
 s.execution_transition_pending=execution_adapter.TransitionPending();
 return s;
}

int OnInit(){
 ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
 if(InpExecutionMode!=MA_EXECUTION_NO_ORDERS){Print("[MA_RUNTIME185_EXEC_REJECT] A10 FULL integration gate is NO_ORDERS only; use v1.73 for verified O01 DEMO.");return INIT_PARAMETERS_INCORRECT;}
 Defaults();MA140_DefaultIdentity(strategy,_Symbol);MA140_DefaultTheme(panel_theme);
 if(InpInstanceId<=0 || InpMagic<=0){Print("[MA_RUNTIME161_IDENTITY] invalid instance_id=",InpInstanceId," magic=",InpMagic);return INIT_PARAMETERS_INCORRECT;}
 strategy.instance_id=InpInstanceId;strategy.magic=InpMagic;
 SMA_ModuleSelection150 initial_route=StartupRoute();string route_reason="";
 if(!MA185ValidateRoute(initial_route,route_reason)){Print("[O01_RUNTIME153_ROUTE_INIT_REJECT] reason=",route_reason," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));return INIT_PARAMETERS_INCORRECT;}
 route_controller.SetInitial(initial_route);
 // v1.62 validates the future broker boundary on DEMO/HEDGING accounts,
 // but intentionally keeps broker actions unarmed.
 if(InpExecutionMode==MA_EXECUTION_DEMO)
 {
  string exec_reason="";
  if(!execution_adapter.Init(strategy.instance_id,strategy.symbol,strategy.magic,exec_reason))
  {
   Print("[MA_RUNTIME185_EXEC_INIT_REJECT] reason=",exec_reason," BROKER_ACTIONS_ARMED=0");
   return INIT_PARAMETERS_INCORRECT;
  }
  Print("[MA_RUNTIME185_EXEC_GATE] DEMO identity validated; broker actions armed. BROKER_ACTIONS_ARMED=1");
 }
 if(InpExecutionMode==MA_EXECUTION_DEMO)
 {
  string state_reason="";
  if(!execution_adapter.AuditOwnedState(state_reason))
  {
   Print("[MA_RUNTIME185_STATE_AUDIT_REJECT] phase=INIT reason=",state_reason);
   return INIT_PARAMETERS_INCORRECT;
  }
 }
 if(!adapter.Validate(runtime_cfg))return INIT_PARAMETERS_INCORRECT;
 A10EntryDefaults100(a10_entry_cfg);
 double a10_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
 if(!entry_dispatcher.InitA10(a10_entry_cfg,a10_tick_size)){Print("[MA_RUNTIME185_A10_ENTRY_INIT] failed");return INIT_FAILED;}
 A10FullDefaults175(a10_full_cfg);
 if(a10_tick_size<=0.0 || !full_dispatcher.InitA10(a10_full_cfg,a10_tick_size)){Print("[MA_RUNTIME185_A10_FULL_INIT] failed");return INIT_FAILED;}
 if(!a10_split_runtime.Init(a10_entry_cfg,a10_full_cfg,a10_tick_size)){Print("[MA_RUNTIME185_A10_SPLIT_INIT] failed");return INIT_FAILED;}
 if(!RebuildIndicatorHandles())return INIT_FAILED;
 CleanupLegacyWorkspaceObjects220();
 panel.SetInitialConfig(runtime_cfg); // exact Expert Properties startup snapshot for REFRESH
 slot_state.Init(strategy.symbol,initial_route);filter_store.Init();filter_preset.Init();builder_instance_composer.Reset();builder_instance_composer.SetIdentity(1,strategy.symbol,strategy.magic);
 // v2.65 migration gate: populate #01 with an O01-like recipe made only from generic Builder parts.
 // This is reference data, not a hard-coded O01 runtime module. NO_ORDERS remains mandatory.
 free_slot_builder.LoadGenericO01ReferenceSeed();
 // v2.67: persist the generic O01 Builder recipe into SLOT #01 workspace itself.
 // This makes the 50-slot ownership explicit: #01 restores O01 after visiting an empty #02..#50.
 SaveBuilderWorkspaceToSlot266(slot_state.Selected());
 EmbedAllBuilderRolesToSelectedSlot264();
 Print("[MA_BUILDER267_SLOT01_O01_PERSIST] target=#",slot_state.Selected()," revision=",builder_slot_workspace.Revision(slot_state.Selected())," ",builder_instance_composer.Summary(slot_state.Selected())," NO_ORDERS=1");
 panel.Create(runtime_cfg,strategy,panel_theme);left_tabs.Create();right_tabs.Create();right_tabs.Select(0);builder_workspace.Create();filter_panel.Create();filter_preset_panel.Create();preset_action_panel.Create();left_slot_badge.Create(slot_state.Selected());slot_panel.Create(&slot_state,640,58,panel_theme.opacity);RefreshRightWorkspace221();
 bool initial_registered=(initial_route.structure==MA_STRUCTURE_FULL_V150?MA185IsRegistered(initial_route.full_module,MA_CAP_FULL_V185):(MA185IsRegistered(initial_route.entry_module,MA_CAP_ENTRY_V185)&&MA185IsRegistered(initial_route.manage_module,MA_CAP_MANAGE_V185)&&MA185IsRegistered(initial_route.exit_module,MA_CAP_EXIT_V185)));
 panel.SetRouteDraftContext(MA150StructureName(initial_route.structure),MA150LogicName(initial_route.full_module),MA150LogicName(initial_route.entry_module),MA150LogicName(initial_route.manage_module),MA150LogicName(initial_route.exit_module),initial_registered);
 route_panel.Create(&route_controller,initial_route,640,146,panel_theme.opacity);
 route_panel_created231=true;
 if(initial_route.structure==MA_STRUCTURE_FULL_V150 && initial_route.full_module==MA_LOGIC_A10_V150){left_context.A10Full();a10_full_panel.Display(a10_full_cfg);}
 else if(initial_route.structure==MA_STRUCTURE_SPLIT_V150){
  left_context.Split(MA150LogicName(initial_route.entry_module),MA150LogicName(initial_route.manage_module),MA150LogicName(initial_route.exit_module));
  a10_full_panel.Hide();
  if(initial_route.entry_module==MA_LOGIC_A10_V150)a10_panel.Display(a10_entry_cfg);else a10_panel.RestoreO01Labels();
  if(initial_route.manage_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayManage(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreManageO01(runtime_cfg);
  if(initial_route.exit_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayExit(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreExitO01(runtime_cfg);
 }
 left_header_spacing.Apply();RefreshCommonFilter202();PrintFilterRegression202();
 // v2.29 startup UI sync: route_panel must already exist before the same
 // SLOT re-entry refresh used by workspace switching is executed.
 // v2.28 called RefreshRightWorkspace221() before route_panel.Create(),
 // leaving the initial SLOT/ROUTE view stale until the user changed tabs.
 RefreshRightWorkspace221();
 Print("[MA_RUNTIME185_START] CORE=1.00 ADAPTER=1.20 PANEL_ROUTE=1.81 FOUNDATION=1.40 REGISTRY=1.75 FULL_DISPATCHER=1.74 A10_FULL_PANEL=1.01 LEFT_CONTEXT=1.80 ENTRY_DISPATCHER=1.72 EXEC_ADAPTER=1.73 LOG_POLICY=1.71 GATE_DEFAULT=FULL_A10 instance=",strategy.instance_id," magic=",strategy.magic," symbol=",strategy.symbol," entry=",strategy.entry_module," manage=",strategy.manage_module," exit=",strategy.exit_module," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));
 RefreshLeftBuilder269();
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){
 preset_action_panel.Delete();
 filter_preset_panel.Delete();
 filter_panel.Delete();
 builder_readout.Delete();
 builder_parts_picker.Delete();
 free_slot_builder.Delete();
 o01_builder_workspace.Delete();
 builder_workspace.Delete();
 right_tabs.Delete();
 slot_panel.Delete();
 left_slot_badge.Delete();
 left_tabs.Delete();
 SMA_ModuleSelection150 final_route=route_controller.Active();
 if(final_route.structure==MA_STRUCTURE_FULL_V150 && final_route.full_module==MA_LOGIC_A10_V150)
  Print("[MA_RUNTIME201_A10_FULL_SUMMARY] ticks=",full_dispatcher.A10Ticks(),
        " entries=",full_dispatcher.A10Entries()," exits=",full_dispatcher.A10Exits(),
        " open=",full_dispatcher.A10OpenCount(),
        " breakout_entries=",full_dispatcher.A10ModeEntries(0)," breakout_exits=",full_dispatcher.A10ModeExits(0),
        " reentry_entries=",full_dispatcher.A10ModeEntries(1)," reentry_exits=",full_dispatcher.A10ModeExits(1),
        " midline_entries=",full_dispatcher.A10ModeEntries(2)," midline_exits=",full_dispatcher.A10ModeExits(2),
        " squeeze_entries=",full_dispatcher.A10ModeEntries(3)," squeeze_exits=",full_dispatcher.A10ModeExits(3),
        " reason=",reason," NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 route_panel.Delete();panel.Delete();if(rh!=INVALID_HANDLE)IndicatorRelease(rh);if(a1h!=INVALID_HANDLE)IndicatorRelease(a1h);if(a2h!=INVALID_HANDLE)IndicatorRelease(a2h);
 Print("[O01_RUNTIME140_SUMMARY] instance=",strategy.instance_id," magic=",strategy.magic," symbol=",strategy.symbol," ticks=",ticks," entries=",entries," grids=",grids," closes=",closes," single_trail=",singleTrail," basket_trail=",basketTrail," virtual_sl=",vsl," buy_open=",(DemoExecution()?LiveCount(true):C(buy))," sell_open=",(DemoExecution()?LiveCount(false):C(sell))," time_blocks=",timeBlocks," news_blocks=",newsBlocks," spread_blocks=",spreadBlocks," filter_blocks=",filterBlocks," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));
}
void OnTick(){
 if(DemoExecution())
 {
  static datetime last_audit_second=0;
  static datetime last_audit_log=0;
  datetime now=TimeCurrent();
  if(now!=last_audit_second)
  {
   // Safety audit still runs once per second. Successful PASS logging is reduced to every 5 minutes.
   // Failures remain immediate; broker lifecycle logs remain unchanged.
   bool log_pass=(last_audit_log==0 || now-last_audit_log>=300);
   string state_reason="";
   if(!execution_adapter.AuditOwnedState(state_reason,log_pass))
   {
    Print("[MA_RUNTIME185_STATE_AUDIT_REJECT] phase=TICK reason=",state_reason," broker_actions_skipped=1");
    return;
   }
   if(log_pass)last_audit_log=now;
   last_audit_second=now;
  }
 }
 static ulong diag_ticks=0; diag_ticks++;
 if(diag_ticks==1 || diag_ticks%100000==0) Print("[O01_TICK_DIAG] ticks=",diag_ticks," time=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
 int pr=panel.PollButtons(runtime_cfg);
 if(pr!=0){
  Print("[O01_RUNTIME140_PANEL_POLL] result=",pr," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0));
  if(pr>0) RebuildIndicatorHandles();
 }
 ticks++;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;
 SMA_ModuleSelection150 active_route_now=route_controller.Active();
 if(active_route_now.structure==MA_STRUCTURE_FULL_V150 && active_route_now.full_module==MA_LOGIC_A10_V150)
 {
  SA10FullEvent100 fe={};
  if(full_dispatcher.OnTick(active_route_now,t,fe) && fe.valid)
   Print(fe.is_entry?"[MA_RUNTIME185_A10_FULL_ENTRY]":"[MA_RUNTIME185_A10_FULL_EXIT]",
         " mode=",A10FullModeName175(fe.mode)," dir=",(fe.direction>0?"BUY":"SELL"),
         " reason=",fe.reason," price=",DoubleToString(fe.price,_Digits)," ticket=",fe.ticket,
         " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return;
 }
 if(active_route_now.structure==MA_STRUCTURE_SPLIT_V150 &&
    active_route_now.entry_module==MA_LOGIC_A10_V150 &&
    active_route_now.manage_module==MA_LOGIC_A10_V150 &&
    active_route_now.exit_module==MA_LOGIC_A10_V150)
 {
  SA10SplitEvent185 se={};
  if(a10_split_runtime.OnTick(t,se) && se.valid)
   Print(se.is_entry?"[MA_RUNTIME185_A10_SPLIT_ENTRY]":"[MA_RUNTIME185_A10_SPLIT_EXIT]",
         " mode=",A10FullModeName175(se.mode)," dir=",(se.direction>0?"BUY":"SELL"),
         " reason=",se.reason," price=",DoubleToString(se.price,_Digits)," ticket=",se.ticket,
         " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return;
 }
 Manage(true,buy,bt,t);Manage(false,sell,st,t);
 double r=B(rh),a1=B(a1h),a2=B(a2h);if(r==EMPTY_VALUE||a1==EMPTY_VALUE||a2==EMPTY_VALUE)return;
 if(!TimeOK()){if(r<runtime_cfg.rsi_lower||r>runtime_cfg.rsi_upper)timeBlocks++;return;}if(NewsNewBlocked()){newsBlocks++;return;}if(!SpreadOK()){spreadBlocks++;return;}
 double p1=a1/_Point,p2=a2/_Point;if(!(p1>=runtime_cfg.atr1_min_points&&p1<=runtime_cfg.atr1_max_points&&p2>=runtime_cfg.atr2_min_points&&p2<=runtime_cfg.atr2_max_points)){filterBlocks++;return;}
 SO01EntryConfig ec;adapter.EntryConfig(runtime_cfg,ec);SO01EntryContext x;x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=(DemoExecution()?LiveCount(true):C(buy));x.sell_count=(DemoExecution()?LiveCount(false):C(sell));x.rsi=r;SMA_ModuleSelection150 active_route=route_controller.Active();ENUM_O01_ENTRY_SIGNAL sig=entry_dispatcher.Evaluate(active_route,core,ec,x,t.bid);datetime bar=iTime(_Symbol,_Period,0);
 if(sig==O01_ENTRY_BUY&&(!runtime_cfg.one_order_per_bar||lastBuyBar!=bar)){double l=NormLot(runtime_cfg.initial_lot);bool opened=(!DemoExecution()||ExecOpen(true,l,"INITIAL"));if(opened){if(!DemoExecution())Add(buy,t.ask,l);lastBuyBar=bar;entries++;LO("BUY","INITIAL",t.ask,l,(DemoExecution()?LiveCount(true):C(buy)));}}
 if(sig==O01_ENTRY_SELL&&(!runtime_cfg.one_order_per_bar||lastSellBar!=bar)){double l=NormLot(runtime_cfg.initial_lot);bool opened=(!DemoExecution()||ExecOpen(false,l,"INITIAL"));if(opened){if(!DemoExecution())Add(sell,t.bid,l);lastSellBar=bar;entries++;LO("SELL","INITIAL",t.bid,l,(DemoExecution()?LiveCount(false):C(sell)));}}
}
bool CommonFilterAllOff202(const SMA_CommonFilterConfig110 &c)
{
 return (!c.trading_time&&!c.news&&!c.fomc&&!c.nfp&&!c.cpi&&!c.month_end&&!c.month_start&&!c.quarter_end&&!c.year_end&&!c.rollover&&!c.friday&&!c.spread&&!c.volatility);
}
void PrintFilterRegression202()
{
 SMA_CommonFilterConfig110 c=filter_store.Get(1);
 Print("[MA_FILTER202_OFF_GATE] slot=1 all_off=",(CommonFilterAllOff202(c)?1:0),
       " runtime_connected=0 expected_behavior=IDENTICAL_TO_V2_01_BASELINE NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
}
void RefreshCommonFilter202()
{
 if(left_tabs.FilterVisible())
 {
  SMA_CommonFilterConfig110 fc=filter_store.Get(slot_state.Selected());
  filter_panel.Show(slot_state.Selected(),fc);filter_preset_panel.Hide();preset_action_panel.Hide();return;
 }
 filter_panel.Hide();filter_preset_panel.Hide();
 if(left_tabs.PresetVisible())preset_action_panel.Show(slot_state.Selected());else preset_action_panel.Hide();
}

bool SaveFilterPreset205(const string name,string &reason)
{
 for(int i=1;i<=MA_FILTER_SLOT_COUNT_V110;i++){SMA_CommonFilterConfig110 c=filter_store.Get(i);if(!filter_preset.Set(i,c,reason))return false;}
 return filter_preset.SaveNamed(name,reason);
}
bool LoadFilterPreset205(const string name,string &reason)
{
 if(!filter_preset.LoadNamed(name,reason))return false;
 for(int i=1;i<=MA_FILTER_SLOT_COUNT_V110;i++)filter_store.Set(i,filter_preset.Get(i));
 return true;
}

void PrintSelectedFilter210(const string phase)
{
 int slot=slot_state.Selected();
 SMA_CommonFilterConfig110 c=filter_store.Get(slot);
 Print("[MA_FILTER210_SLOT_VIEW] phase=",phase,
       " slot=",slot,
       " time=",(int)c.trading_time,
       " start=",StringFormat("%02d:%02d",c.start_hour,c.start_minute),
       " end=",StringFormat("%02d:%02d",c.end_hour,c.end_minute),
       " news=",(int)c.news,
       " fomc=",(int)c.fomc,
       " spread=",(int)c.spread,
       " max_spread=",DoubleToString(c.max_spread_points,1),
       " volatility=",(int)c.volatility,
       " atr_min=",DoubleToString(c.min_atr_points,1),
       " atr_max=",DoubleToString(c.max_atr_points,1),
       " runtime_connected=0 NO_ORDERS=1");
}

void SaveBuilderWorkspaceToSlot266(const int target)
{
 int rr=0;
 int ii=0;
 rr=0;
 while(rr<3)
 {
  builder_slot_workspace.BeginRole(target,rr,free_slot_builder.DefinitionName(rr));
  ii=0;
  while(ii<24)
  {
   builder_slot_workspace.SetItem(target,rr,ii,free_slot_builder.PartAt(rr,ii),free_slot_builder.ParamsAt(rr,ii));
   ii++;
  }
  rr++;
 }
 builder_slot_workspace.Commit(target);
 Print("[MA_BUILDER266_WORKSPACE_SAVE] slot=",target," revision=",builder_slot_workspace.Revision(target)," NO_ORDERS=1");
}
void LoadBuilderWorkspaceFromSlot266(const int target)
{
 int rr=0;
 int ii=0;
 string dn="";
 if(!builder_slot_workspace.Initialized(target))
 {
  rr=0;
  while(rr<3)
  {
   if(rr==0) dn="BUILDER_ENTRY_SLOT"+IntegerToString(target);
   else if(rr==1) dn="BUILDER_MANAGE_SLOT"+IntegerToString(target);
   else dn="BUILDER_EXIT_SLOT"+IntegerToString(target);
   free_slot_builder.BeginRoleImport(rr,dn);
   ii=0;
   while(ii<24)
   {
    free_slot_builder.SetRoleItem(rr,ii,"EMPTY","");
    ii++;
   }
   rr++;
  }
  SaveBuilderWorkspaceToSlot266(target);
 }
 else
 {
  rr=0;
  while(rr<3)
  {
   free_slot_builder.BeginRoleImport(rr,builder_slot_workspace.RoleNameAt(target,rr));
   ii=0;
   while(ii<24)
   {
    free_slot_builder.SetRoleItem(rr,ii,builder_slot_workspace.PartAt(target,rr,ii),builder_slot_workspace.ParamsAt(target,rr,ii));
    ii++;
   }
   rr++;
  }
 }
 Print("[MA_BUILDER266_WORKSPACE_LOAD] slot=",target," revision=",builder_slot_workspace.Revision(target)," NO_ORDERS=1");
}

void SyncSelectedSlotDraft195()
{
 SMA_ModuleSelection150 d=slot_state.CurrentRoute();
 route_panel.SetDraft(d);
 bool reg=(d.structure==MA_STRUCTURE_FULL_V150?route_panel.DraftFullRegistered():(route_panel.DraftEntryRegistered()&&route_panel.DraftManageRegistered()&&route_panel.DraftExitRegistered()));
 panel.SetRouteDraftContext(MA150StructureName(d.structure),MA150LogicName(d.full_module),MA150LogicName(d.entry_module),MA150LogicName(d.manage_module),MA150LogicName(d.exit_module),reg);
 if(!reg){a10_full_panel.Hide();left_context.Unregistered(MA150LogicName(d.full_module));}
 else if(d.structure==MA_STRUCTURE_FULL_V150 && d.full_module==MA_LOGIC_A10_V150){left_context.A10Full();a10_full_panel.Display(a10_full_cfg);}
 else if(d.structure==MA_STRUCTURE_SPLIT_V150)
 {
  left_context.Split(MA150LogicName(d.entry_module),MA150LogicName(d.manage_module),MA150LogicName(d.exit_module));a10_full_panel.Hide();
  if(d.entry_module==MA_LOGIC_A10_V150)a10_panel.Display(a10_entry_cfg);else a10_panel.RestoreO01Labels();
  if(d.manage_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayManage(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreManageO01(runtime_cfg);
  if(d.exit_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayExit(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreExitO01(runtime_cfg);
 }
 else {left_context.Restore();a10_full_panel.Hide();a10_panel.RestoreO01Labels();}
 left_tabs.Refresh();RefreshCommonFilter202();PrintSelectedFilter210("SLOT_SWITCH");
 Print("[MA_SLOT195_LOAD] slot=",slot_state.Selected()," route=",route_panel.DraftSummary()," runtime_changed=0");
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){
 int fb=(left_tabs.LogicVisible()&&!left_builder_parts269?free_slot_builder.OnChartEvent(id,lparam,dparam,sparam):0);
 if(fb==2){builder_parts_picker.SetRole(free_slot_builder.Role());builder_parts_picker.SetSlot(free_slot_builder.Selected(),free_slot_builder.SelectedPart(),free_slot_builder.SelectedParams());left_builder_parts269=true;RefreshLeftBuilder269();return;}
 if(fb==5){BuilderReadout243();return;}
 // v2.68: SAVE/LOAD commits the visible Builder board back to the selected SLOT workspace.
 if(fb==3){SaveBuilderWorkspaceToSlot266(slot_state.Selected());AssignBuilderRoleToSelectedSlot264();BuilderReadout243();return;}
 if(fb==4){SaveBuilderWorkspaceToSlot266(slot_state.Selected());EmbedAllBuilderRolesToSelectedSlot264();BuilderReadout243();return;}
 if(fb==1)return;
 int bp=(left_tabs.LogicVisible()&&left_builder_parts269?builder_parts_picker.OnChartEvent(id,sparam):0);
 // v2.68: EA PARTS APPLY/DELETE is SLOT-local and auto-committed immediately.
 // This prevents an edit in SLOT #01 from leaking into #02 and prevents loss on SLOT switching.
 if(bp==2){if(free_slot_builder.PutSelected(builder_parts_picker.Chosen(),builder_parts_picker.Parameters())){SaveBuilderWorkspaceToSlot266(slot_state.Selected());AssignBuilderRoleToSelectedSlot264();left_builder_parts269=false;RefreshLeftBuilder269();}return;}
 if(bp==3){left_builder_parts269=false;RefreshLeftBuilder269();return;}
 if(bp==4){if(free_slot_builder.DeleteSelected()){SaveBuilderWorkspaceToSlot266(slot_state.Selected());AssignBuilderRoleToSelectedSlot264();}left_builder_parts269=false;RefreshLeftBuilder269();return;}
 if(bp==1)return;
 int rw=right_tabs.Event(id,sparam);
 if(rw!=0){right_tabs.Select(0);RefreshRightWorkspace221();return;}
 if(!right_tabs.SlotVisible()){
  // Builder workspaces are UI-only in v2.21. Existing SLOT/route/runtime behavior is untouched.
  return;
 }
 int sr=slot_panel.Event(id,sparam,lparam,dparam);
 if(sr!=0)
 {
  left_slot_badge.Set(slot_state.Selected());
  if(sr==1){LoadBuilderWorkspaceFromSlot266(slot_state.Selected());SyncSelectedSlotDraft195();left_builder_parts269=false;RefreshLeftBuilder269();}
  return;
 }
 if(left_tabs.Event(id,sparam)!=0){if(!left_tabs.LogicVisible()){a10_full_panel.Hide();a10_panel.ShowModeButton(false);ObjectDelete(0,"O01CFG160_A10_FULL_MODE_NEXT");ObjectDelete(0,"O01CFG160_A10_MODE_NEXT");}else{SMA_ModuleSelection150 dv=route_panel.Draft();if(dv.structure==MA_STRUCTURE_FULL_V150&&dv.full_module==MA_LOGIC_A10_V150)a10_full_panel.Display(a10_full_cfg);else if(dv.structure==MA_STRUCTURE_SPLIT_V150&&dv.entry_module==MA_LOGIC_A10_V150)a10_panel.Display(a10_entry_cfg);}RefreshCommonFilter202();left_builder_parts269=false;RefreshLeftBuilder269();return;}
 int fpr=filter_preset_panel.Event(id,sparam);
 if(fpr!=0)
 {
  string preset_reason="";string preset_name=filter_preset_panel.Name();bool ok=false;
  if(fpr==1)ok=SaveFilterPreset205(preset_name,preset_reason);else ok=LoadFilterPreset205(preset_name,preset_reason);
  if(ok){filter_preset_panel.Status(fpr==1?"SAVED 50 SLOTS":"LOADED 50 SLOTS",true);if(fpr==2)RefreshCommonFilter202();Print("[MA_FILTER_PRESET205_",fpr==1?"SAVE":"LOAD","] name=",preset_name," slots=50 runtime_connected=0");}
  else {filter_preset_panel.Status("ERROR: "+preset_reason,false);Print("[MA_FILTER_PRESET205_FAIL] action=",(fpr==1?"SAVE":"LOAD")," name=",preset_name," reason=",preset_reason);}
  return;
 }
 int par=preset_action_panel.Event(id,sparam);
 if(par!=0)
 {
  string n=(par==6||par==7)?preset_action_panel.FilterName():(par==4||par==5)?preset_action_panel.AllName():preset_action_panel.SlotName(),why="";bool ok=false;
  if(par==6)ok=SaveFilterPreset205(n,why);
  else if(par==7)ok=LoadFilterPreset205(n,why);
  else {preset_action_panel.Status("UI READY - STORAGE WIRING NEXT",false);Print("[MA_PRESET212_UI] action=",par," slot=",slot_state.Selected()," NO_ORDERS=1 broker_actions_changed=0");return;}
  if(ok){preset_action_panel.Status(par==6?"FILTER SAVED (50)":"FILTER LOADED (50)",true);if(par==7)RefreshCommonFilter202();Print("[MA_PRESET212_FILTER] action=",(par==6?"SAVE":"LOAD")," name=",n," slots=50 NO_ORDERS=1");}
  else {preset_action_panel.Status("ERROR: "+why,false);Print("[MA_PRESET212_FILTER_FAIL] action=",par," name=",n," reason=",why);}
  return;
 }
 SMA_CommonFilterConfig110 fc_evt=filter_store.Get(slot_state.Selected());
 if(filter_panel.Event(id,sparam,fc_evt)!=0){filter_store.Set(slot_state.Selected(),fc_evt);RefreshCommonFilter202();Print("[MA_FILTER202_EDIT] slot=",slot_state.Selected()," runtime_connected=0");return;}
 string route_reason="";SMA_RouteState150 route_state=LiveRouteState();
 int rr=route_panel.Event(id,sparam,route_state,route_reason,lparam,dparam);
 if(rr==1 || rr==2){
   if(rr==1)slot_state.SetCurrentRoute(route_panel.Draft());
   SMA_ModuleSelection150 d=route_panel.Draft();
   bool draft_registered=(d.structure==MA_STRUCTURE_FULL_V150?route_panel.DraftFullRegistered():(route_panel.DraftEntryRegistered()&&route_panel.DraftManageRegistered()&&route_panel.DraftExitRegistered()));panel.SetRouteDraftContext(MA150StructureName(d.structure),MA150LogicName(d.full_module),MA150LogicName(d.entry_module),MA150LogicName(d.manage_module),MA150LogicName(d.exit_module),draft_registered);
   if(!draft_registered){a10_full_panel.Hide();left_context.Unregistered(MA150LogicName(d.full_module));}
   else if(d.structure==MA_STRUCTURE_FULL_V150 && d.full_module==MA_LOGIC_A10_V150){left_context.A10Full();a10_full_panel.Display(a10_full_cfg);}
   else if(d.structure==MA_STRUCTURE_SPLIT_V150){
     left_context.Split(MA150LogicName(d.entry_module),MA150LogicName(d.manage_module),MA150LogicName(d.exit_module));a10_full_panel.Hide();
     if(d.entry_module==MA_LOGIC_A10_V150)a10_panel.Display(a10_entry_cfg);else a10_panel.RestoreO01Labels();
     if(d.manage_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayManage(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreManageO01(runtime_cfg);
     if(d.exit_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayExit(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreExitO01(runtime_cfg);
   }
   else {left_context.Restore();a10_full_panel.Hide();a10_panel.RestoreO01Labels();}
   bool route_registered=(d.structure==MA_STRUCTURE_FULL_V150?route_panel.DraftFullRegistered():(route_panel.DraftEntryRegistered()&&route_panel.DraftManageRegistered()&&route_panel.DraftExitRegistered()));
   string sync=(route_registered?"REGISTERED ROUTE - DETAIL PANEL CONTEXT":"NOT REGISTERED - O01 SETTINGS PRESERVED");
   left_header_spacing.Apply();
   left_tabs.Refresh();
   Print("[O01_RUNTIME156_DRAFT_SYNC] draft=",route_panel.DraftSummary()," left_panel=",sync," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));
 }
 if(rr==-3){SMA_ModuleSelection150 d=route_panel.Draft();bool draft_registered=(d.structure==MA_STRUCTURE_FULL_V150?route_panel.DraftFullRegistered():(route_panel.DraftEntryRegistered()&&route_panel.DraftManageRegistered()&&route_panel.DraftExitRegistered()));panel.SetRouteDraftContext(MA150StructureName(d.structure),MA150LogicName(d.full_module),MA150LogicName(d.entry_module),MA150LogicName(d.manage_module),MA150LogicName(d.exit_module),draft_registered);
   if(!draft_registered){a10_full_panel.Hide();left_context.Unregistered(MA150LogicName(d.full_module));}
   else if(d.structure==MA_STRUCTURE_FULL_V150 && d.full_module==MA_LOGIC_A10_V150){left_context.A10Full();a10_full_panel.Display(a10_full_cfg);}
   else if(d.structure==MA_STRUCTURE_SPLIT_V150){
     left_context.Split(MA150LogicName(d.entry_module),MA150LogicName(d.manage_module),MA150LogicName(d.exit_module));a10_full_panel.Hide();
     if(d.entry_module==MA_LOGIC_A10_V150)a10_panel.Display(a10_entry_cfg);else a10_panel.RestoreO01Labels();
     if(d.manage_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayManage(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreManageO01(runtime_cfg);
     if(d.exit_module==MA_LOGIC_A10_V150)a10_split_detail_panel.DisplayExit(true,a10_full_cfg,0);else a10_split_detail_panel.RestoreExitO01(runtime_cfg);
   }
   else {left_context.Restore();a10_full_panel.Hide();a10_panel.RestoreO01Labels();}}
 if(rr==3)slot_state.SetCurrentRoute(route_panel.Draft());
 if(rr!=0){SMA_ModuleSelection150 ar=route_controller.Active();Print("[O01_RUNTIME153_ROUTE_PANEL] event=",rr," reason=",route_reason," active_structure=",MA150StructureName(ar.structure)," full=",MA150LogicName(ar.full_module)," entry=",MA150LogicName(ar.entry_module)," manage=",MA150LogicName(ar.manage_module)," exit=",MA150LogicName(ar.exit_module)," positions=",route_state.managed_positions," cycle_none=",(int)route_state.cycle_none," transition_pending=",(int)route_state.execution_transition_pending," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0)," VIRTUAL_NOT_FILL=",(DemoExecution()?0:1));return;}
 // v1.71: suppress unhandled/background chart-event noise. Actionable route/panel events above remain logged.
 SMA_ModuleSelection150 draft_now=route_panel.Draft();
 if(draft_now.structure==MA_STRUCTURE_FULL_V150 && draft_now.full_module==MA_LOGIC_A10_V150){
  if(a10_full_panel.HandleClick(sparam,a10_full_cfg))return;
  if(id==CHARTEVENT_OBJECT_CLICK && sparam=="O01CFG160_APPLY"){
   if(a10_full_panel.Pull(a10_full_cfg)){double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);if(full_dispatcher.InitA10(a10_full_cfg,ts))Print("[MA_RUNTIME185_A10_FULL_PANEL] APPLY valid=1 reinitialized=1");else Print("[MA_RUNTIME185_A10_FULL_PANEL] APPLY init_failed=1");}
   else Print("[MA_RUNTIME185_A10_FULL_PANEL] APPLY valid=0");
   return;
  }
 }
 if(draft_now.structure==MA_STRUCTURE_SPLIT_V150 && draft_now.entry_module==MA_LOGIC_A10_V150){
  if(a10_panel.HandleClick(sparam,a10_entry_cfg))return;
  if(id==CHARTEVENT_OBJECT_CLICK && sparam=="O01CFG160_APPLY"){
   if(a10_panel.Pull(a10_entry_cfg)){double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);if(entry_dispatcher.InitA10(a10_entry_cfg,ts)&&a10_split_runtime.Init(a10_entry_cfg,a10_full_cfg,ts))Print("[MA_RUNTIME185_A10_PANEL] APPLY valid=1 split_reinitialized=1");else Print("[MA_RUNTIME185_A10_PANEL] APPLY init_failed=1");}
   else Print("[MA_RUNTIME161_A10_PANEL] APPLY valid=0");
   return;
  }
 }
 SO01RuntimeSettings110 before=runtime_cfg;
 int r=panel.Event(id,sparam,runtime_cfg);
 if(r!=0)
 {
  bool ok=adapter.Validate(runtime_cfg);
  if(!ok){runtime_cfg=before;Print("[O01_RUNTIME140_PANEL] result=",r," valid=0 rolled_back=1");return;}
  bool handleChanged=(before.rsi_period!=runtime_cfg.rsi_period||before.atr1_period!=runtime_cfg.atr1_period||before.atr2_period!=runtime_cfg.atr2_period||before.atr2_timeframe!=runtime_cfg.atr2_timeframe);
  if(handleChanged&&!RebuildIndicatorHandles()){runtime_cfg=before;RebuildIndicatorHandles();Print("[O01_RUNTIME140_PANEL] result=",r," valid=1 handles=FAIL rolled_back=1");return;}
  Print("[O01_RUNTIME140_PANEL] result=",r," valid=1 handles_rebuilt=",(int)handleChanged," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," BROKER_ACTIONS_ARMED=",(DemoExecution()?1:0));
 }
}
