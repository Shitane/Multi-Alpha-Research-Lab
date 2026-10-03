//+------------------------------------------------------------------+
//| MA_Builder_O01_Manage_Parity_Tester_v1_00.mq5                   |
//| O01 MANAGE reference vs generic-part composition on tester ticks.|
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Manage_Module_v1_40.mqh"

input int InpMaxSamples=200000;

CO01ManageModule140 g_ref;
int g_n=0,g_match=0,g_add_buy=0,g_add_sell=0;
bool g_done=false;

SO01ManageDecision GenericManage(const bool is_buy,const SO01ManageConfig &c,const SO01ManageContext &x)
{
 SO01ManageDecision d;d.action=O01_MANAGE_NONE;d.requested_lot=0.0;
 d.required_distance_points=0.0;d.next_grid_number=x.position_count+1;

 // Generic parts: POSITION_COUNT + MAX_ORDERS
 if(x.position_count<=0 || x.position_count>=c.max_orders)return d;
 // TRAIL_PAUSE
 if(c.pause_grid_while_trailing && x.trailing_active)return d;
 // TIME
 if(!c.allow_grid_outside_time && !x.time_allowed)return d;
 // NEWS + SPREAD
 if(x.news_grid_blocked || !x.spread_ok)return d;
 // ONE/BAR
 if(c.one_order_per_bar && x.same_bar_as_last_order)return d;
 if(x.point<=0.0)return d;
 // FIXED_DIST / DYNAMIC_DIST
 if(d.next_grid_number<c.dynamic_start_order)d.required_distance_points=(double)c.fixed_distance_points;
 else d.required_distance_points=(double)c.dynamic_start_points*MathPow(c.distance_multiplier,d.next_grid_number-c.dynamic_start_order);
 bool dist=is_buy ? x.market_price<=x.last_price-d.required_distance_points*x.point
                  : x.market_price>=x.last_price+d.required_distance_points*x.point;
 if(!dist)return d;
 // LOT_MULT + MAX_LOT + MAX_TOTAL
 double lot=x.last_lot*c.lot_multiplier;
 if(c.max_lot>0.0)lot=MathMin(lot,c.max_lot);
 if(c.max_total_lots_per_side>0.0 && x.current_total_lots+lot>c.max_total_lots_per_side+1e-9)return d;
 d.action=O01_MANAGE_ADD_GRID;d.requested_lot=lot;return d;
}
bool Same(const SO01ManageDecision &a,const SO01ManageDecision &b)
{
 return a.action==b.action && MathAbs(a.requested_lot-b.requested_lot)<1e-9 &&
        MathAbs(a.required_distance_points-b.required_distance_points)<1e-9 &&
        a.next_grid_number==b.next_grid_number;
}
void Eval(const bool is_buy,const SO01ManageConfig &c,const SO01ManageContext &x)
{
 SO01ManageDecision a=g_ref.Evaluate(is_buy,c,x),b=GenericManage(is_buy,c,x);
 g_n++;if(Same(a,b))g_match++;
 else Print("[MANAGE_PARITY_FAIL] n=",g_n," side=",(is_buy?"BUY":"SELL")," ref=",a.action," builder=",b.action,
            " lot_ref=",a.requested_lot," lot_builder=",b.requested_lot,
            " dist_ref=",a.required_distance_points," dist_builder=",b.required_distance_points);
 if(a.action==O01_MANAGE_ADD_GRID){if(is_buy)g_add_buy++;else g_add_sell++;}
}
int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 Print("O01 MANAGE REFERENCE vs GENERIC BUILDER PARTS / TESTER v1.00");
 Print("PARTS: POSITION_COUNT MAX_ORDERS TRAIL_PAUSE TIME NEWS SPREAD ONE/BAR FIXED_DIST DYNAMIC_DIST LOT_MULT MAX_LOT MAX_TOTAL");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick()
{
 if(g_done)return;
 MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;
 double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);if(point<=0)return;

 SO01ManageConfig c={};
 c.allow_grid_outside_time=false;c.one_order_per_bar=true;c.pause_grid_while_trailing=true;
 c.max_orders=5;c.max_total_lots_per_side=1.0;c.max_lot=0.50;c.lot_multiplier=2.0;
 c.fixed_distance_points=100;c.dynamic_start_order=3;c.dynamic_start_points=150;c.distance_multiplier=1.5;

 // Deterministic virtual position contexts driven by the same historical market tick.
 // BUY context deliberately places last_price above market; SELL mirrors below market.
 int pc=1+(g_n%4);
 double dist=(pc+1<c.dynamic_start_order?c.fixed_distance_points:
             c.dynamic_start_points*MathPow(c.distance_multiplier,(pc+1)-c.dynamic_start_order));
 SO01ManageContext xb={};xb.time_allowed=true;xb.news_grid_blocked=false;xb.spread_ok=true;
 xb.trailing_active=false;xb.same_bar_as_last_order=false;xb.position_count=pc;
 xb.current_total_lots=0.01*pc;xb.last_lot=0.01;xb.market_price=t.bid;xb.point=point;
 xb.last_price=t.bid+(dist+10.0)*point;
 Eval(true,c,xb);

 SO01ManageContext xs=xb;xs.market_price=t.ask;xs.last_price=t.ask-(dist+10.0)*point;
 Eval(false,c,xs);

 if((g_add_buy>0 && g_add_sell>0 && g_n>=200) || g_n>=InpMaxSamples)
 {
  g_done=true;
  Print("TOTAL MANAGE PARITY ",g_match,"/",g_n," ADD_BUY=",g_add_buy," ADD_SELL=",g_add_sell);
  if(g_match==g_n && g_add_buy>0 && g_add_sell>0)
   Print("RESULT: PASS - O01 reference MANAGE == generic Builder-part MANAGE with BUY/SELL grid adds observed");
  else if(g_match==g_n)Print("RESULT: INCOMPLETE - parity matched but both grid-add directions were not observed");
  else Print("RESULT: FAIL - O01 reference MANAGE != generic Builder-part MANAGE");
  Print("SCOPE: deterministic virtual position state + real Strategy Tester market ticks");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 }
}
