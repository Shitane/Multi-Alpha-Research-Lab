//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Exit_Module_v1_00.mqh                             |
//| Decision/state extraction for O01 virtual exits. NO ORDERS.      |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_EXIT_MODULE_V1_00_MQH
#define O01_GSG_RSI30_EXIT_MODULE_V1_00_MQH

enum ENUM_O01_EXIT_DECISION
  { O01_EXIT_NONE=0,O01_EXIT_VIRTUAL_SL,O01_EXIT_FIXED_TP,O01_EXIT_SINGLE_TRAILING,O01_EXIT_BASKET_TRAILING };

struct SO01TrailState { bool active; double peak_pts,stop_pts; int position_count; };
struct SO01ExitConfig
  {
   bool trailing;
   int tp_points,sl_points,trail_start,trail_lock,trail_distance,trail_step;
  };

class CO01ExitModule
  {
public:
   ENUM_O01_EXIT_DECISION Evaluate(const bool is_buy,const int count,const double move_pts,
                                   const SO01ExitConfig &c,SO01TrailState &t) const
     {
      if(count<=0) { t.active=false; t.peak_pts=0; t.stop_pts=0; t.position_count=0; return O01_EXIT_NONE; }
      if(c.sl_points>0 && move_pts<=-(double)c.sl_points) return O01_EXIT_VIRTUAL_SL;
      if(!c.trailing)
        return (c.tp_points>0 && move_pts>=(double)c.tp_points ? O01_EXIT_FIXED_TP : O01_EXIT_NONE);

      if(t.active && t.position_count!=count)
        { t.active=false; t.peak_pts=0; t.stop_pts=0; }
      if(!t.active)
        {
         if(c.trail_start<=0 || move_pts<(double)c.trail_start) { t.position_count=count; return O01_EXIT_NONE; }
         t.active=true; t.peak_pts=move_pts;
         t.stop_pts=MathMax((double)c.trail_lock,t.peak_pts-(double)c.trail_distance);
         t.position_count=count;
        }
      else if(move_pts>t.peak_pts && (c.trail_step<=0 || move_pts-t.peak_pts>=(double)c.trail_step))
        {
         t.peak_pts=move_pts;
         t.stop_pts=MathMax(t.stop_pts,MathMax((double)c.trail_lock,t.peak_pts-(double)c.trail_distance));
        }
      if(t.active && move_pts<=t.stop_pts)
         return (count==1 ? O01_EXIT_SINGLE_TRAILING : O01_EXIT_BASKET_TRAILING);
      return O01_EXIT_NONE;
     }
  };

#endif
