//+------------------------------------------------------------------+
//| MA_Builder_O01_Route_Parity_Tester_v1_00.mq5                    |
//| Stateful O01 reference vs Builder ENTRY->MANAGE->EXIT route.     |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Manage_Module_v1_40.mqh"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Exit_Module_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Entry_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Manage_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Exit_Evaluator_v1_00.mqh"

input int InpRSIPeriod=8;
input int InpMaxSamples=200000;

CO01EntryModule g_re;
CO01ManageModule140 g_rm;
CO01ExitModule g_rx;
CMultiAlphaBuilderO01EntryEvaluator100 g_be;
CMultiAlphaBuilderO01ManageEvaluator100 g_bm;
CMultiAlphaBuilderO01ExitEvaluator100 g_bx;
int g_rsi=INVALID_HANDLE,g_samples=0,g_entry_match=0,g_manage_match=0,g_exit_match=0;
int g_buy_entries=0,g_sell_entries=0,g_grid_buy=0,g_grid_sell=0,g_exits=0;
bool g_done=false;

bool ManageSame(const SO01ManageDecision&a,const SO01ManageDecision&b)
{return a.action==b.action&&MathAbs(a.requested_lot-b.requested_lot)<1e-9&&MathAbs(a.required_distance_points-b.required_distance_points)<1e-9&&a.next_grid_number==b.next_grid_number;}
bool TrailSame(const SO01TrailState&a,const SO01TrailState&b)
{return a.active==b.active&&MathAbs(a.peak_pts-b.peak_pts)<1e-9&&MathAbs(a.stop_pts-b.stop_pts)<1e-9&&a.position_count==b.position_count;}

int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);if(g_rsi==INVALID_HANDLE)return INIT_FAILED;
 Print("O01 STATEFUL ROUTE / REFERENCE vs BUILDER / TESTER v1.00");
 Print("FLOW: ENTRY -> virtual state -> MANAGE -> EXIT");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);}

void OnTick()
{
 if(g_done)return;
 double r[1];if(CopyBuffer(g_rsi,0,0,1,r)!=1)return;
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick))return;
 double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);if(point<=0)return;

 // ENTRY: real historical RSI/tick context.
 SO01EntryConfig ec={};ec.new_cycles=true;ec.trade_buy=true;ec.trade_sell=true;ec.rsi_lower=30;ec.rsi_upper=70;
 SO01EntryContext ex={};ex.emergency_lock=false;ex.time_allowed=true;ex.news_blocked=false;ex.spread_ok=true;ex.filters_ok=true;
 ex.buy_count=0;ex.sell_count=0;ex.rsi=r[0];
 ENUM_O01_ENTRY_SIGNAL er=g_re.Evaluate(ec,ex),eb=g_be.Evaluate(ec,ex);
 if(er==eb)g_entry_match++;else Print("[ROUTE_FAIL_ENTRY] sample=",g_samples," ref=",er," builder=",eb," rsi=",r[0]);
 if(er==O01_ENTRY_BUY)g_buy_entries++;if(er==O01_ENTRY_SELL)g_sell_entries++;

 // Route state: a signal creates a deterministic virtual position; otherwise
 // alternate a BUY/SELL virtual side so MANAGE/EXIT remain exercised.
 bool is_buy=(er==O01_ENTRY_BUY?true:(er==O01_ENTRY_SELL?false:((g_samples%2)==0)));
 int count=1+(g_samples%3);

 // MANAGE: same routed virtual position state for reference and Builder.
 SO01ManageConfig mc={};mc.allow_grid_outside_time=false;mc.one_order_per_bar=true;mc.pause_grid_while_trailing=true;
 mc.max_orders=5;mc.max_total_lots_per_side=1.0;mc.max_lot=0.50;mc.lot_multiplier=2.0;
 mc.fixed_distance_points=100;mc.dynamic_start_order=3;mc.dynamic_start_points=150;mc.distance_multiplier=1.5;
 SO01ManageContext mx={};mx.time_allowed=true;mx.news_grid_blocked=false;mx.spread_ok=true;mx.trailing_active=false;mx.same_bar_as_last_order=false;
 mx.position_count=count;mx.current_total_lots=0.01*count;mx.last_lot=0.01;mx.point=point;mx.market_price=(is_buy?tick.bid:tick.ask);
 int next=count+1;double dist=(next<mc.dynamic_start_order?mc.fixed_distance_points:mc.dynamic_start_points*MathPow(mc.distance_multiplier,next-mc.dynamic_start_order));
 mx.last_price=(is_buy?mx.market_price+(dist+10)*point:mx.market_price-(dist+10)*point);
 SO01ManageDecision mr=g_rm.Evaluate(is_buy,mc,mx),mb=g_bm.Evaluate(is_buy,mc,mx);
 if(ManageSame(mr,mb))g_manage_match++;else Print("[ROUTE_FAIL_MANAGE] sample=",g_samples," side=",(is_buy?"BUY":"SELL"));
 if(mr.action==O01_MANAGE_ADD_GRID){if(is_buy)g_grid_buy++;else g_grid_sell++;count++;}

 // EXIT: consume routed count. Cycle through exit families while preserving same state.
 SO01ExitConfig xc={};xc.tp_points=177;xc.sl_points=300;xc.trail_start=100;xc.trail_lock=40;xc.trail_distance=50;xc.trail_step=10;
 double move=0;SO01TrailState ri={},bi={};
 int mode=g_samples%4;
 if(mode==0){xc.trailing=true;move=-301;}
 if(mode==1){xc.trailing=false;move=178;}
 if(mode==2){xc.trailing=true;move=100;count=1;ri.active=true;ri.peak_pts=160;ri.stop_pts=110;ri.position_count=1;bi=ri;}
 if(mode==3){xc.trailing=true;move=100;count=MathMax(2,count);ri.active=true;ri.peak_pts=160;ri.stop_pts=110;ri.position_count=count;bi=ri;}
 ENUM_O01_EXIT_DECISION xr=g_rx.Evaluate(is_buy,count,move,xc,ri),xb=g_bx.Evaluate(is_buy,count,move,xc,bi);
 if(xr==xb&&TrailSame(ri,bi))g_exit_match++;else Print("[ROUTE_FAIL_EXIT] sample=",g_samples," ref=",xr," builder=",xb);
 if(xr!=O01_EXIT_NONE)g_exits++;

 g_samples++;
 if((g_buy_entries>0&&g_sell_entries>0&&g_grid_buy>0&&g_grid_sell>0&&g_exits>0&&g_samples>=1000)||g_samples>=InpMaxSamples)
 {
  g_done=true;
  Print("TOTAL ROUTE SAMPLES ",g_samples);
  Print("ENTRY PARITY ",g_entry_match,"/",g_samples," BUY=",g_buy_entries," SELL=",g_sell_entries);
  Print("MANAGE PARITY ",g_manage_match,"/",g_samples," ADD_BUY=",g_grid_buy," ADD_SELL=",g_grid_sell);
  Print("EXIT PARITY ",g_exit_match,"/",g_samples," EXITS=",g_exits);
  bool ok=(g_entry_match==g_samples&&g_manage_match==g_samples&&g_exit_match==g_samples&&g_buy_entries>0&&g_sell_entries>0&&g_grid_buy>0&&g_grid_sell>0&&g_exits>0);
  Print(ok?"RESULT: PASS - O01 reference route == Builder route across ENTRY->MANAGE->EXIT":"RESULT: INCOMPLETE/FAIL - inspect route counters");
  Print("SCOPE: real tester RSI/ticks + deterministic virtual routed position/trailing state");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 }
}
