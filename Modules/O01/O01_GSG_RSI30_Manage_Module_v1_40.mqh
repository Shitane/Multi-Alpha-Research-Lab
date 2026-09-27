//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Manage_Module_v1_40.mqh                           |
//| O01 split MANAGE decision extraction. NO ORDERS.                 |
//| Grid/add-position decision only; Exit remains separate.           |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_MANAGE_MODULE_V1_40_MQH
#define O01_GSG_RSI30_MANAGE_MODULE_V1_40_MQH

enum ENUM_O01_MANAGE_DECISION
  {
   O01_MANAGE_NONE=0,
   O01_MANAGE_ADD_GRID=1
  };

struct SO01ManageConfig
  {
   bool allow_grid_outside_time;
   bool one_order_per_bar;
   bool pause_grid_while_trailing;
   int  max_orders;
   double max_total_lots_per_side;
   double max_lot;
   double lot_multiplier;
   int fixed_distance_points;
   int dynamic_start_order;
   int dynamic_start_points;
   double distance_multiplier;
  };

struct SO01ManageContext
  {
   bool time_allowed;
   bool news_grid_blocked;
   bool spread_ok;
   bool trailing_active;
   bool same_bar_as_last_order;
   int position_count;
   double current_total_lots;
   double last_price;
   double last_lot;
   double market_price;
   double point;
  };

struct SO01ManageDecision
  {
   ENUM_O01_MANAGE_DECISION action;
   double requested_lot;
   double required_distance_points;
   int next_grid_number;
  };

class CO01ManageModule140
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

      if(x.position_count<=0 || x.position_count>=c.max_orders)
         return d;
      if(c.pause_grid_while_trailing && x.trailing_active)
         return d;
      if(!c.allow_grid_outside_time && !x.time_allowed)
         return d;
      if(x.news_grid_blocked || !x.spread_ok)
         return d;
      if(c.one_order_per_bar && x.same_bar_as_last_order)
         return d;
      if(x.point<=0.0)
         return d;

      d.required_distance_points=DistancePoints(c,d.next_grid_number);
      bool distance_met=(is_buy
                         ? x.market_price<=x.last_price-d.required_distance_points*x.point
                         : x.market_price>=x.last_price+d.required_distance_points*x.point);
      if(!distance_met)
         return d;

      double lot=x.last_lot*c.lot_multiplier;
      if(c.max_lot>0.0)
         lot=MathMin(lot,c.max_lot);
      if(c.max_total_lots_per_side>0.0 &&
         x.current_total_lots+lot>c.max_total_lots_per_side+1e-9)
         return d;

      d.action=O01_MANAGE_ADD_GRID;
      d.requested_lot=lot;
      return d;
     }
  };

#endif
