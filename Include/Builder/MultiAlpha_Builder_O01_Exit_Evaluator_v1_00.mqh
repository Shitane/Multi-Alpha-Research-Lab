//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Exit_Evaluator_v1_00.mqh                 |
//| LB-01 Builder evaluator for verified O01 EXIT decisions.         |
//| Decision/state only. NO ORDERS / VIRTUAL NOT FILL.               |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_EXIT_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_EXIT_EVALUATOR_V1_00_MQH

#include "..\\O01\\O01_GSG_RSI30_Exit_Module_v1_00.mqh"

#define MA_BUILDER_O01_EXIT_EVALUATOR_VERSION "1.00"

class CMultiAlphaBuilderO01ExitEvaluator100
{
public:
 ENUM_O01_EXIT_DECISION Evaluate(const bool is_buy,
                                 const int count,
                                 const double move_pts,
                                 const SO01ExitConfig &c,
                                 SO01TrailState &t) const
 {
  if(count<=0)
  {
   t.active=false; t.peak_pts=0; t.stop_pts=0; t.position_count=0;
   return O01_EXIT_NONE;
  }

  if(c.sl_points>0 && move_pts<=-(double)c.sl_points)
     return O01_EXIT_VIRTUAL_SL;

  if(!c.trailing)
     return (c.tp_points>0 && move_pts>=(double)c.tp_points
             ? O01_EXIT_FIXED_TP : O01_EXIT_NONE);

  if(t.active && t.position_count!=count)
  {
   t.active=false; t.peak_pts=0; t.stop_pts=0;
  }

  if(!t.active)
  {
   if(c.trail_start<=0 || move_pts<(double)c.trail_start)
   {
    t.position_count=count;
    return O01_EXIT_NONE;
   }
   t.active=true;
   t.peak_pts=move_pts;
   t.stop_pts=MathMax((double)c.trail_lock,
                      t.peak_pts-(double)c.trail_distance);
   t.position_count=count;
  }
  else if(move_pts>t.peak_pts &&
          (c.trail_step<=0 || move_pts-t.peak_pts>=(double)c.trail_step))
  {
   t.peak_pts=move_pts;
   t.stop_pts=MathMax(t.stop_pts,
                      MathMax((double)c.trail_lock,
                              t.peak_pts-(double)c.trail_distance));
  }

  if(t.active && move_pts<=t.stop_pts)
     return (count==1 ? O01_EXIT_SINGLE_TRAILING
                      : O01_EXIT_BASKET_TRAILING);

  return O01_EXIT_NONE;
 }

 bool ParityCheck(const bool is_buy,
                  const int count,
                  const double move_pts,
                  const SO01ExitConfig &c,
                  const SO01TrailState &initial_state,
                  ENUM_O01_EXIT_DECISION &reference_decision,
                  ENUM_O01_EXIT_DECISION &builder_decision,
                  SO01TrailState &reference_state,
                  SO01TrailState &builder_state) const
 {
  CO01ExitModule reference;
  reference_state=initial_state;
  builder_state=initial_state;
  reference_decision=reference.Evaluate(is_buy,count,move_pts,c,reference_state);
  builder_decision=Evaluate(is_buy,count,move_pts,c,builder_state);

  return (reference_decision==builder_decision &&
          reference_state.active==builder_state.active &&
          MathAbs(reference_state.peak_pts-builder_state.peak_pts)<1e-9 &&
          MathAbs(reference_state.stop_pts-builder_state.stop_pts)<1e-9 &&
          reference_state.position_count==builder_state.position_count);
 }
};

#endif
