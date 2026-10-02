//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Runtime_Tick_Gate_v1_00.mq5              |
//| Builder evaluators through runtime adapter. NO ORDERS.            |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Runtime_Tick_Adapter_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

void EntryDefaults(SO01EntryConfig &c,SO01EntryContext &x)
{
 c.trade_buy=true;c.trade_sell=true;c.new_cycles=true;c.rsi_lower=30;c.rsi_upper=70;
 x.rsi=20;x.buy_count=0;x.sell_count=0;x.emergency_lock=false;x.time_allowed=true;
 x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;
}
void ManageDefaults(SO01ManageConfig &c,SO01ManageContext &x)
{
 c.max_orders=5;c.fixed_distance_points=100;c.dynamic_start_order=99;c.dynamic_start_points=100;
 c.distance_multiplier=1.0;c.lot_multiplier=2.0;c.max_lot=0.0;c.max_total_lots_per_side=0.0;
 c.pause_grid_while_trailing=false;c.allow_grid_outside_time=true;c.one_order_per_bar=false;
 x.position_count=1;x.trailing_active=false;x.time_allowed=true;x.news_grid_blocked=false;x.spread_ok=true;
 x.same_bar_as_last_order=false;x.point=1.0;x.market_price=900;x.last_price=1000;x.last_lot=0.01;x.current_total_lots=0.01;
}
void ExitDefaults(SO01ExitConfig &c,SO01TrailState &t)
{
 c.sl_points=500;c.tp_points=100;c.trailing=false;c.trail_start=100;c.trail_distance=50;c.trail_lock=0;c.trail_step=10;
 t.active=false;t.peak_pts=0;t.stop_pts=0;t.position_count=0;
}

int OnInit()
{
 CMultiAlphaBuilderO01RuntimeTickAdapter100 a;
 SO01EntryConfig ec;SO01EntryContext ex;EntryDefaults(ec,ex);
 SO01ManageConfig mc;SO01ManageContext mx;ManageDefaults(mc,mx);
 SO01ExitConfig xc;SO01TrailState tf,ts;ExitDefaults(xc,tf);ts=tf;
 SMA_BuilderO01RuntimeDecision100 f={},s={},bad={};

 bool full=a.EvaluateFull("BUILDER_O01_FULL",ec,ex,true,mc,mx,true,1,120,xc,tf,f);
 bool split=a.EvaluateSplit("BUILDER_E01","BUILDER_M01","BUILDER_X01",ec,ex,true,mc,mx,true,1,120,xc,ts,s);
 bool same=full&&split&&
           f.entry_signal==s.entry_signal&&
           f.manage_decision.action==s.manage_decision.action&&
           MathAbs(f.manage_decision.requested_lot-s.manage_decision.requested_lot)<1e-9&&
           f.exit_decision==s.exit_decision&&
           tf.active==ts.active&&MathAbs(tf.peak_pts-ts.peak_pts)<1e-9&&MathAbs(tf.stop_pts-ts.stop_pts)<1e-9;
 bool expected=same&&f.entry_signal==O01_ENTRY_BUY&&
               f.manage_decision.action==O01_MANAGE_ADD_GRID&&
               f.exit_decision==O01_EXIT_FIXED_TP;
 SO01TrailState tb;ExitDefaults(xc,tb);
 bool reject=!a.EvaluateFull("BUILDER_UNKNOWN",ec,ex,true,mc,mx,true,1,120,xc,tb,bad)&&!bad.route_ready;

 int pass=(full?1:0)+(split?1:0)+(same?1:0)+(expected?1:0)+(reject?1:0);
 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 RUNTIME TICK ADAPTER GATE / NO ORDERS");
 Print("1 FULL ROUTE EVALUATION ",(full?"PASS":"FAIL")," reason=",f.route_reason);
 Print("2 SPLIT ROUTE EVALUATION ",(split?"PASS":"FAIL")," reason=",s.route_reason);
 Print("3 FULL == SPLIT DECISION/STATE ",(same?"PASS":"FAIL"));
 Print("4 EXPECTED ENTRY=BUY MANAGE=ADD_GRID EXIT=FIXED_TP ",(expected?"PASS":"FAIL"));
 Print("5 UNKNOWN ROUTE REJECT ",(reject?"PASS":"FAIL")," reason=",bad.route_reason);
 Print("TOTAL ",pass,"/5");
 Print(pass==5 ? "RESULT: PASS - O01 Builder runtime tick adapter (5/5)"
               : "RESULT: FAIL - O01 Builder runtime tick adapter");
 Print("NO ORDERS / VIRTUAL NOT FILL / NO BROKER API CALLS");
 Print("============================================================");
 return pass==5?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
