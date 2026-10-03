//+------------------------------------------------------------------+
//| MA_Builder_O01_Exit_Parity_Tester_v1_00.mq5                     |
//| O01 EXIT reference vs generic Builder-part composition.          |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Exit_Module_v1_00.mqh"

CO01ExitModule g_ref;
int g_n=0,g_match=0,g_vsl=0,g_tp=0,g_single=0,g_basket=0;
bool g_done=false;

ENUM_O01_EXIT_DECISION GenericExit(const int count,const double move_pts,const SO01ExitConfig &c,SO01TrailState &t)
{
 if(count<=0){t.active=false;t.peak_pts=0;t.stop_pts=0;t.position_count=0;return O01_EXIT_NONE;}
 // VIRTUAL_SL has first priority.
 if(c.sl_points>0 && move_pts<=-(double)c.sl_points)return O01_EXIT_VIRTUAL_SL;
 // FIXED_TP is used when trailing is disabled.
 if(!c.trailing)return(c.tp_points>0 && move_pts>=(double)c.tp_points?O01_EXIT_FIXED_TP:O01_EXIT_NONE);
 // SINGLE/BASKET TRAILING share state logic; action depends on POSITION_COUNT.
 if(t.active && t.position_count!=count){t.active=false;t.peak_pts=0;t.stop_pts=0;}
 if(!t.active){
  if(c.trail_start<=0 || move_pts<(double)c.trail_start){t.position_count=count;return O01_EXIT_NONE;}
  t.active=true;t.peak_pts=move_pts;t.stop_pts=MathMax((double)c.trail_lock,t.peak_pts-(double)c.trail_distance);t.position_count=count;
 } else if(move_pts>t.peak_pts && (c.trail_step<=0 || move_pts-t.peak_pts>=(double)c.trail_step)){
  t.peak_pts=move_pts;t.stop_pts=MathMax(t.stop_pts,MathMax((double)c.trail_lock,t.peak_pts-(double)c.trail_distance));
 }
 if(t.active && move_pts<=t.stop_pts)return(count==1?O01_EXIT_SINGLE_TRAILING:O01_EXIT_BASKET_TRAILING);
 return O01_EXIT_NONE;
}
bool StateSame(const SO01TrailState&a,const SO01TrailState&b){return a.active==b.active&&MathAbs(a.peak_pts-b.peak_pts)<1e-9&&MathAbs(a.stop_pts-b.stop_pts)<1e-9&&a.position_count==b.position_count;}
void Case(const string tag,const int count,const double move,const SO01ExitConfig &c,const SO01TrailState &initial)
{
 SO01TrailState a=initial,b=initial;
 ENUM_O01_EXIT_DECISION ra=g_ref.Evaluate(true,count,move,c,a),rb=GenericExit(count,move,c,b);
 g_n++;if(ra==rb&&StateSame(a,b))g_match++;else Print("[EXIT_PARITY_FAIL] ",tag," ref=",ra," builder=",rb);
 if(ra==O01_EXIT_VIRTUAL_SL)g_vsl++;if(ra==O01_EXIT_FIXED_TP)g_tp++;if(ra==O01_EXIT_SINGLE_TRAILING)g_single++;if(ra==O01_EXIT_BASKET_TRAILING)g_basket++;
}
int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 Print("O01 EXIT REFERENCE vs GENERIC BUILDER PARTS / TESTER v1.00");
 Print("PARTS: POSITION_COUNT MOVE_POINTS VIRTUAL_SL FIXED_TP SINGLE_TRAIL BASKET_TRAIL");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick()
{
 if(g_done)return;
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick))return; // prove tester market context is active
 SO01ExitConfig c={};c.tp_points=177;c.sl_points=300;c.trail_start=100;c.trail_lock=40;c.trail_distance=50;c.trail_step=10;

 SO01TrailState z={};
 c.trailing=false;Case("VSL",1,-301,c,z);Case("TP",1,178,c,z);Case("NONE",1,50,c,z);
 c.trailing=true;
 SO01TrailState s={};s.active=true;s.peak_pts=160;s.stop_pts=110;s.position_count=1;Case("SINGLE_TRAIL",1,100,c,s);
 SO01TrailState b={};b.active=true;b.peak_pts=160;b.stop_pts=110;b.position_count=3;Case("BASKET_TRAIL",3,100,c,b);
 SO01TrailState start={};Case("TRAIL_START",1,120,c,start);
 SO01TrailState empty={};Case("EMPTY",0,0,c,empty);

 if(g_n>=140)
 {
  g_done=true;
  Print("TOTAL EXIT PARITY ",g_match,"/",g_n," VSL=",g_vsl," TP=",g_tp," SINGLE=",g_single," BASKET=",g_basket);
  if(g_match==g_n&&g_vsl>0&&g_tp>0&&g_single>0&&g_basket>0)Print("RESULT: PASS - O01 reference EXIT == generic Builder-part EXIT with all exit families observed");
  else if(g_match==g_n)Print("RESULT: INCOMPLETE - parity matched but not all exit families observed");
  else Print("RESULT: FAIL - O01 reference EXIT != generic Builder-part EXIT");
  Print("SCOPE: deterministic virtual position/trailing state + active Strategy Tester market ticks");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 }
}
