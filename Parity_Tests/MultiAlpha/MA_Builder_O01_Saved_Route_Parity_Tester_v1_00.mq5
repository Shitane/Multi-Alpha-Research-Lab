//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Route_Parity_Tester_v1_00.mq5              |
//| Persisted SAVE24 ENTRY -> MANAGE -> EXIT route parity gate.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Manage_Module_v1_40.mqh"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Exit_Module_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Entry_Action_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Manage_Action_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Exit_Action_Evaluator_v1_00.mqh"

input string InpEntryName="O01_ENTRY_GENERIC_V1";
input string InpManageName="O01_MANAGE_GENERIC_V1";
input string InpExitTrailOnName="O01_EXIT_GENERIC_V1";
input string InpExitTrailOffName="O01_EXIT_FIXEDTP_GENERIC_V1";
input int InpRSIPeriod=8;
input int InpMaxSamples=200000;

CO01EntryModule g_er; CO01ManageModule140 g_mr; CO01ExitModule g_xr;
CMultiAlphaBuilderSavedEntryActionEvaluator100 g_eb;
CMultiAlphaBuilderSavedManageActionEvaluator100 g_mb;
CMultiAlphaBuilderSavedExitActionEvaluator100 g_xb;
SMA_BuilderSavedDefinition100 g_e,g_m,g_xon,g_xoff;
int g_rsi=INVALID_HANDLE,g_n=0,g_entry_match=0,g_manage_match=0,g_exit_match=0;
int g_buy=0,g_sell=0,g_add_buy=0,g_add_sell=0,g_vsl=0,g_tp=0,g_single=0,g_basket=0;
bool g_done=false;

bool LoadDef(const int role,const string name,SMA_BuilderSavedDefinition100 &d)
{
 string prefix=(role==0?"ENTRY":(role==1?"MANAGE":"EXIT"));
 string fn="MultiAlpha_Builder_"+prefix+"_"+name+".csv";
 int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');
 if(h==INVALID_HANDLE){Print("RESULT: FAIL - NOT FOUND: ",fn);return false;}
 string sig=FileReadString(h),ver=FileReadString(h);int got_role=(int)FileReadNumber(h),count=(int)FileReadNumber(h);
 if(sig!="MA_BUILDER_ROLE"||got_role!=role||count!=24){FileClose(h);Print("RESULT: FAIL - INVALID ",prefix," FILE: ",fn);return false;}
 d.role=role;d.name=name;d.loaded=true;d.valid=true;d.reason="READY";d.expression="";
 for(int i=0;i<24;i++){d.part[i]="EMPTY";d.param[i]="";}
 for(int i=0;i<24&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string p=FileReadString(h),a=FileReadString(h);if(no>=1&&no<=24){d.part[no-1]=p;d.param[no-1]=a;}}
 FileClose(h);Print("LOADED: ",fn);return true;
}
bool SameManage(const SO01ManageDecision&a,const SO01ManageDecision&b){return a.action==b.action&&MathAbs(a.requested_lot-b.requested_lot)<1e-9&&MathAbs(a.required_distance_points-b.required_distance_points)<1e-9&&a.next_grid_number==b.next_grid_number;}
bool SameTrail(const SO01TrailState&a,const SO01TrailState&b){return a.active==b.active&&MathAbs(a.peak_pts-b.peak_pts)<1e-9&&MathAbs(a.stop_pts-b.stop_pts)<1e-9&&a.position_count==b.position_count;}

int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 if(!LoadDef(0,InpEntryName,g_e)||!LoadDef(1,InpManageName,g_m)||!LoadDef(2,InpExitTrailOnName,g_xon)||!LoadDef(2,InpExitTrailOffName,g_xoff))return INIT_FAILED;
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);if(g_rsi==INVALID_HANDLE){Print("RESULT: FAIL - RSI handle");return INIT_FAILED;}
 Print("O01 REFERENCE vs PERSISTED GENERIC BUILDER ROUTE / TESTER v1.00");
 Print("ROUTE=",InpEntryName," -> ",InpManageName," -> ",InpExitTrailOnName," / ",InpExitTrailOffName);
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);}

void OnTick()
{
 if(g_done)return;double rr[1];if(CopyBuffer(g_rsi,0,0,1,rr)!=1)return;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);if(point<=0)return;

 // ENTRY: real tester RSI/ticks, persisted ENTRY definition.
 SO01EntryConfig ec={};ec.new_cycles=true;ec.trade_buy=true;ec.trade_sell=true;ec.rsi_lower=30;ec.rsi_upper=70;
 SO01EntryContext ex={};ex.emergency_lock=false;ex.time_allowed=true;ex.news_blocked=false;ex.spread_ok=true;ex.filters_ok=true;ex.buy_count=0;ex.sell_count=0;ex.rsi=rr[0];
 ENUM_O01_ENTRY_SIGNAL er=g_er.Evaluate(ec,ex);
 SMA_BuilderSavedEntryContext100 ebx={};ebx.rsi=rr[0];ebx.buy_count=0;ebx.sell_count=0;ebx.cycle_new=true;ebx.emergency_unlocked=true;ebx.time_allowed=true;ebx.news_clear=true;ebx.spread_ok=true;ebx.filters_ok=true;
 ENUM_MA_BUILDER_ENTRY_ACTION100 eb;string tr,why;if(!g_eb.Evaluate(g_e,ebx,eb,tr,why)){Print("RESULT: FAIL ENTRY - ",why);g_done=true;return;}
 if((int)er==(int)eb)g_entry_match++;else Print("[ROUTE ENTRY MISMATCH] n=",g_n," ref=",(int)er," saved=",(int)eb," rsi=",rr[0]," ",tr);
 if(er==O01_ENTRY_BUY)g_buy++;if(er==O01_ENTRY_SELL)g_sell++;

 // MANAGE: deterministic virtual state anchored to current real tester price.
 SO01ManageConfig mc={};mc.allow_grid_outside_time=false;mc.one_order_per_bar=true;mc.pause_grid_while_trailing=true;mc.max_orders=5;mc.max_total_lots_per_side=1.0;mc.max_lot=0.50;mc.lot_multiplier=2.0;mc.fixed_distance_points=100;mc.dynamic_start_order=3;mc.dynamic_start_points=150;mc.distance_multiplier=1.5;
 bool side=((g_n&1)==0);int pc=1+(g_n%4);double dist=(pc+1<mc.dynamic_start_order?mc.fixed_distance_points:mc.dynamic_start_points*MathPow(mc.distance_multiplier,(pc+1)-mc.dynamic_start_order));
 SO01ManageContext mx={};mx.time_allowed=true;mx.news_grid_blocked=false;mx.spread_ok=true;mx.trailing_active=false;mx.same_bar_as_last_order=false;mx.position_count=pc;mx.current_total_lots=0.01*pc;mx.last_lot=0.01;mx.point=point;
 if(side){mx.market_price=t.bid;mx.last_price=t.bid+(dist+10.0)*point;}else{mx.market_price=t.ask;mx.last_price=t.ask-(dist+10.0)*point;}
 SO01ManageDecision mr=g_mr.Evaluate(side,mc,mx),mb;if(!g_mb.Evaluate(g_m,side,mx,mb,tr,why)){Print("RESULT: FAIL MANAGE - ",why);g_done=true;return;}
 if(SameManage(mr,mb))g_manage_match++;else Print("[ROUTE MANAGE MISMATCH] n=",g_n," side=",(side?"BUY":"SELL")," ref=",mr.action," saved=",mb.action," ",tr);
 if(mr.action==O01_MANAGE_ADD_GRID){if(side)g_add_buy++;else g_add_sell++;}

 // EXIT: cycle through persisted trail OFF/ON families while preserving state inside each sample.
 int phase=g_n%7;bool trail=(phase>=2);SMA_BuilderSavedDefinition100 xd=(trail?g_xon:g_xoff);
 double move=-1600;int xc=1;if(phase==1)move=120;if(phase==2)move=-1600;if(phase==3)move=100;if(phase==4)move=50;if(phase==5){move=100;xc=2;}if(phase==6){move=50;xc=2;}
 SO01ExitConfig xcfg={};xcfg.tp_points=110;xcfg.sl_points=1500;xcfg.trailing=trail;xcfg.trail_start=80;xcfg.trail_lock=20;xcfg.trail_distance=40;xcfg.trail_step=10;
 SO01TrailState rs={},bs={};
 // Prime trailing state for phases that must exercise a trailing close.
 if(phase==4){g_xr.Evaluate(true,1,100,xcfg,rs);ENUM_O01_EXIT_DECISION dummy;g_xb.Evaluate(xd,true,1,100,bs,dummy,tr,why);}
 if(phase==6){g_xr.Evaluate(true,2,100,xcfg,rs);ENUM_O01_EXIT_DECISION dummy;g_xb.Evaluate(xd,true,2,100,bs,dummy,tr,why);}
 ENUM_O01_EXIT_DECISION xr=g_xr.Evaluate(true,xc,move,xcfg,rs),xb;if(!g_xb.Evaluate(xd,true,xc,move,bs,xb,tr,why)){Print("RESULT: FAIL EXIT - ",why);g_done=true;return;}
 if(xr==xb&&SameTrail(rs,bs))g_exit_match++;else Print("[ROUTE EXIT MISMATCH] n=",g_n," phase=",phase," ref=",xr," saved=",xb," ",tr);
 if(xr==O01_EXIT_VIRTUAL_SL)g_vsl++;if(xr==O01_EXIT_FIXED_TP)g_tp++;if(xr==O01_EXIT_SINGLE_TRAILING)g_single++;if(xr==O01_EXIT_BASKET_TRAILING)g_basket++;

 g_n++;
 if((g_buy>0&&g_sell>0&&g_n>=1000)||g_n>=InpMaxSamples)
 {
  g_done=true;Print("TOTAL SAVED ROUTE SAMPLES ",g_n);
  Print("ENTRY PARITY ",g_entry_match,"/",g_n," BUY=",g_buy," SELL=",g_sell);
  Print("MANAGE PARITY ",g_manage_match,"/",g_n," ADD_BUY=",g_add_buy," ADD_SELL=",g_add_sell);
  Print("EXIT PARITY ",g_exit_match,"/",g_n," VSL=",g_vsl," TP=",g_tp," SINGLE=",g_single," BASKET=",g_basket);
  bool ok=(g_entry_match==g_n&&g_manage_match==g_n&&g_exit_match==g_n&&g_buy>0&&g_sell>0&&g_add_buy>0&&g_add_sell>0&&g_vsl>0&&g_tp>0&&g_single>0&&g_basket>0);
  Print(ok?"RESULT: PASS - O01 reference route == persisted SAVE24 generic Builder route":"RESULT: INCOMPLETE/FAIL - inspect route counters");
  Print("SCOPE: persisted ENTRY/MANAGE/EXIT SAVE24 definitions + generic evaluators + real tester RSI/ticks + deterministic virtual routed state");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 }
}
