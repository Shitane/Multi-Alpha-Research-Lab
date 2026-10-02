//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Manage_Evaluator_v1_00.mqh               |
//| LB-01 Builder evaluator for verified O01 MANAGE/grid decisions.  |
//| Decision only. NO ORDERS / VIRTUAL NOT FILL.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_MANAGE_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_MANAGE_EVALUATOR_V1_00_MQH

#include "..\\O01\\O01_GSG_RSI30_Manage_Module_v1_40.mqh"

#define MA_BUILDER_O01_MANAGE_EVALUATOR_VERSION "1.00"

class CMultiAlphaBuilderO01ManageEvaluator100
{
private:
 double DistancePoints(const SO01ManageConfig &c,const int next_order_number) const
 {
  if(next_order_number<c.dynamic_start_order)
     return (double)c.fixed_distance_points;
  return (double)c.dynamic_start_points*
         MathPow(c.distance_multiplier,next_order_number-c.dynamic_start_order);
 }

public:
 SO01ManageDecision Evaluate(const bool is_buy,
                             const SO01ManageConfig &c,
                             const SO01ManageContext &x) const
 {
  SO01ManageDecision d;
  d.action=O01_MANAGE_NONE;
  d.requested_lot=0.0;
  d.required_distance_points=0.0;
  d.next_grid_number=x.position_count+1;

  if(x.position_count<=0 || x.position_count>=c.max_orders) return d;
  if(c.pause_grid_while_trailing && x.trailing_active) return d;
  if(!c.allow_grid_outside_time && !x.time_allowed) return d;
  if(x.news_grid_blocked || !x.spread_ok) return d;
  if(c.one_order_per_bar && x.same_bar_as_last_order) return d;
  if(x.point<=0.0) return d;

  d.required_distance_points=DistancePoints(c,d.next_grid_number);
  bool distance_met=(is_buy
                     ? x.market_price<=x.last_price-d.required_distance_points*x.point
                     : x.market_price>=x.last_price+d.required_distance_points*x.point);
  if(!distance_met) return d;

  double lot=x.last_lot*c.lot_multiplier;
  if(c.max_lot>0.0) lot=MathMin(lot,c.max_lot);
  if(c.max_total_lots_per_side>0.0 &&
     x.current_total_lots+lot>c.max_total_lots_per_side+1e-9)
     return d;

  d.action=O01_MANAGE_ADD_GRID;
  d.requested_lot=lot;
  return d;
 }

 bool ParityCheck(const bool is_buy,
                  const SO01ManageConfig &c,
                  const SO01ManageContext &x,
                  SO01ManageDecision &reference_decision,
                  SO01ManageDecision &builder_decision) const
 {
  CO01ManageModule140 reference;
  reference_decision=reference.Evaluate(is_buy,c,x);
  builder_decision=Evaluate(is_buy,c,x);
  return (reference_decision.action==builder_decision.action &&
          MathAbs(reference_decision.requested_lot-builder_decision.requested_lot)<1e-9 &&
          MathAbs(reference_decision.required_distance_points-builder_decision.required_distance_points)<1e-9 &&
          reference_decision.next_grid_number==builder_decision.next_grid_number);
 }
};

#endif