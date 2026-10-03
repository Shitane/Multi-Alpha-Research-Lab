//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Manage_Action_Evaluator_v1_00.mqh      |
//| Generic persisted MANAGE definition -> grid-add decision.        |
//| Decision only. NO ORDERS / VIRTUAL NOT FILL.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_SAVED_MANAGE_ACTION_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_SAVED_MANAGE_ACTION_EVALUATOR_V1_00_MQH
#include "MultiAlpha_Builder_Saved_Definition_Route_v1_00.mqh"
#include "..\\O01\\O01_GSG_RSI30_Manage_Module_v1_40.mqh"
#define MA_BUILDER_SAVED_MANAGE_ACTION_EVALUATOR_VERSION "1.00"

class CMultiAlphaBuilderSavedManageActionEvaluator100
{
private:
 CMultiAlphaBuilderInterpreter101 m_i;
 double Num(const string p,const string key,const double defv)
 {
  return StringToDouble(m_i.Param(p,key,DoubleToString(defv,8)));
 }
 int IntNum(const string p,const string key,const int defv)
 {
  return (int)StringToInteger(m_i.Param(p,key,IntegerToString(defv)));
 }
 bool BoolNum(const string p,const string key,const bool defv)
 {
  return (StringToInteger(m_i.Param(p,key,(defv?"1":"0")))!=0);
 }
public:
 bool Evaluate(const SMA_BuilderSavedDefinition100 &d,const bool is_buy,
               const SO01ManageContext &x,SO01ManageDecision &out,string &trace,string &reason)
 {
  out.action=O01_MANAGE_NONE;out.requested_lot=0.0;
  out.required_distance_points=0.0;out.next_grid_number=x.position_count+1;
  trace="";
  if(!d.loaded){reason="DEFINITION NOT LOADED";return false;}

  SO01ManageConfig c={};
  bool have_max=false,have_fixed=false,have_dynamic=false,have_lot=false,have_action=false;
  for(int i=0;i<24;i++)
  {
   string part=d.part[i],p=d.param[i];
   if(part==""||part=="EMPTY"||part=="AND"||part=="OR")continue;
   if(part=="POSITION_COUNT")continue;
   if(part=="MAX_ORDERS"){c.max_orders=IntNum(p,"VALUE",5);have_max=true;continue;}
   if(part=="TRAIL_PAUSE"){c.pause_grid_while_trailing=BoolNum(p,"ENABLED",true);continue;}
   if(part=="TIME"){c.allow_grid_outside_time=BoolNum(p,"ALLOW_OUTSIDE",false);continue;}
   if(part=="NEWS"||part=="SPREAD")continue;
   if(part=="ONE/BAR"){c.one_order_per_bar=BoolNum(p,"ENABLED",true);continue;}
   if(part=="FIXED_DIST"){c.fixed_distance_points=IntNum(p,"POINTS",100);have_fixed=true;continue;}
   if(part=="DYNAMIC_DIST")
   {
    c.dynamic_start_order=IntNum(p,"START_ORDER",3);
    c.dynamic_start_points=IntNum(p,"START_POINTS",150);
    c.distance_multiplier=Num(p,"MULT",1.5);have_dynamic=true;continue;
   }
   if(part=="LOT_MULT"){c.lot_multiplier=Num(p,"MULT",2.0);have_lot=true;continue;}
   if(part=="MAX_LOT"){c.max_lot=Num(p,"VALUE",0.50);continue;}
   if(part=="MAX_TOTAL"){c.max_total_lots_per_side=Num(p,"VALUE",1.0);continue;}
   if(part=="ADD BUY/SELL"||part=="ADD GRID"){have_action=true;continue;}
   reason="UNSUPPORTED MANAGE PART: "+part;return false;
  }
  if(!have_max||!have_fixed||!have_dynamic||!have_lot||!have_action)
  {reason="MANAGE REQUIRED PARTS MISSING";return false;}

  if(x.position_count<=0 || x.position_count>=c.max_orders){reason="VALID";return true;}
  if(c.pause_grid_while_trailing && x.trailing_active){reason="VALID";return true;}
  if(!c.allow_grid_outside_time && !x.time_allowed){reason="VALID";return true;}
  if(x.news_grid_blocked || !x.spread_ok){reason="VALID";return true;}
  if(c.one_order_per_bar && x.same_bar_as_last_order){reason="VALID";return true;}
  if(x.point<=0.0){reason="VALID";return true;}

  if(out.next_grid_number<c.dynamic_start_order)out.required_distance_points=(double)c.fixed_distance_points;
  else out.required_distance_points=(double)c.dynamic_start_points*MathPow(c.distance_multiplier,out.next_grid_number-c.dynamic_start_order);
  bool dist=(is_buy ? x.market_price<=x.last_price-out.required_distance_points*x.point
                    : x.market_price>=x.last_price+out.required_distance_points*x.point);
  if(!dist){reason="VALID";return true;}
  double lot=x.last_lot*c.lot_multiplier;
  if(c.max_lot>0.0)lot=MathMin(lot,c.max_lot);
  if(c.max_total_lots_per_side>0.0 && x.current_total_lots+lot>c.max_total_lots_per_side+1e-9){reason="VALID";return true;}
  out.action=O01_MANAGE_ADD_GRID;out.requested_lot=lot;
  trace="ADD GRID side="+(is_buy?"BUY":"SELL")+" lot="+DoubleToString(lot,2)+" dist="+DoubleToString(out.required_distance_points,1);
  reason="VALID";return true;
 }
};
#endif
