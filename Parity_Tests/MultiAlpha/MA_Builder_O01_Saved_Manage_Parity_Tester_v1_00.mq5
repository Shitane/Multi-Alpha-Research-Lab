//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Manage_Parity_Tester_v1_00.mq5             |
//| O01 reference vs persisted SAVE24 generic MANAGE evaluator.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Manage_Module_v1_40.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Manage_Action_Evaluator_v1_00.mqh"
input string InpManageName="O01_MANAGE_GENERIC_V1";
input int InpMaxSamples=200000;
CO01ManageModule140 g_ref; CMultiAlphaBuilderSavedManageActionEvaluator100 g_builder;
SMA_BuilderSavedDefinition100 g_m; int g_n=0,g_match=0,g_add_buy=0,g_add_sell=0;bool g_done=false;
bool Same(const SO01ManageDecision &a,const SO01ManageDecision &b){return a.action==b.action&&MathAbs(a.requested_lot-b.requested_lot)<1e-9&&MathAbs(a.required_distance_points-b.required_distance_points)<1e-9&&a.next_grid_number==b.next_grid_number;}
int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 string fn="MultiAlpha_Builder_MANAGE_"+InpManageName+".csv";int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');
 if(h==INVALID_HANDLE){Print("RESULT: FAIL - NOT FOUND: ",fn);return INIT_FAILED;}
 string sig=FileReadString(h),ver=FileReadString(h);int role=(int)FileReadNumber(h),count=(int)FileReadNumber(h);
 if(sig!="MA_BUILDER_ROLE"||role!=1||count!=24){FileClose(h);Print("RESULT: FAIL - INVALID MANAGE FILE");return INIT_FAILED;}
 g_m.role=1;g_m.name=InpManageName;g_m.loaded=true;g_m.valid=true;g_m.reason="READY";g_m.expression="";
 for(int i=0;i<24;i++){g_m.part[i]="EMPTY";g_m.param[i]="";}
 for(int i=0;i<24&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string p=FileReadString(h),a=FileReadString(h);if(no>=1&&no<=24){g_m.part[no-1]=p;g_m.param[no-1]=a;}}FileClose(h);
 Print("O01 REFERENCE vs SAVED GENERIC BUILDER MANAGE / TESTER v1.00");Print("SOURCE=",fn);
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void Eval(const bool is_buy,const SO01ManageConfig &c,const SO01ManageContext &x)
{
 SO01ManageDecision a=g_ref.Evaluate(is_buy,c,x),b;string tr,why;
 if(!g_builder.Evaluate(g_m,is_buy,x,b,tr,why)){Print("RESULT: FAIL - ",why);g_done=true;return;}
 g_n++;if(Same(a,b))g_match++;else Print("[SAVED_MANAGE_MISMATCH] n=",g_n," side=",(is_buy?"BUY":"SELL")," ref=",a.action," saved=",b.action," lot_ref=",a.requested_lot," lot_saved=",b.requested_lot," dist_ref=",a.required_distance_points," dist_saved=",b.required_distance_points," trace=",tr);
 if(a.action==O01_MANAGE_ADD_GRID){if(is_buy)g_add_buy++;else g_add_sell++;}
}
void OnTick()
{
 if(g_done)return;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;double point=SymbolInfoDouble(_Symbol,SYMBOL_POINT);if(point<=0)return;
 SO01ManageConfig c={};c.allow_grid_outside_time=false;c.one_order_per_bar=true;c.pause_grid_while_trailing=true;c.max_orders=5;c.max_total_lots_per_side=1.0;c.max_lot=0.50;c.lot_multiplier=2.0;c.fixed_distance_points=100;c.dynamic_start_order=3;c.dynamic_start_points=150;c.distance_multiplier=1.5;
 int pc=1+(g_n%4);double dist=(pc+1<c.dynamic_start_order?c.fixed_distance_points:c.dynamic_start_points*MathPow(c.distance_multiplier,(pc+1)-c.dynamic_start_order));
 SO01ManageContext xb={};xb.time_allowed=true;xb.news_grid_blocked=false;xb.spread_ok=true;xb.trailing_active=false;xb.same_bar_as_last_order=false;xb.position_count=pc;xb.current_total_lots=0.01*pc;xb.last_lot=0.01;xb.market_price=t.bid;xb.point=point;xb.last_price=t.bid+(dist+10.0)*point;Eval(true,c,xb);if(g_done)return;
 SO01ManageContext xs=xb;xs.market_price=t.ask;xs.last_price=t.ask-(dist+10.0)*point;Eval(false,c,xs);
 if((g_add_buy>0&&g_add_sell>0&&g_n>=200)||g_n>=InpMaxSamples){g_done=true;Print("TOTAL SAVED MANAGE PARITY ",g_match,"/",g_n," ADD_BUY=",g_add_buy," ADD_SELL=",g_add_sell);bool ok=(g_match==g_n&&g_add_buy>0&&g_add_sell>0);Print(ok?"RESULT: PASS - O01 reference MANAGE == persisted SAVE24 generic Builder MANAGE":"RESULT: INCOMPLETE/FAIL - inspect counters");Print("SCOPE: persisted SAVE24 definition + generic MANAGE evaluator + deterministic virtual position state + real tester ticks");Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");}
}
