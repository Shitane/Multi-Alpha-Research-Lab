//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Runtime_Adapter_v1_20.mqh                         |
//| Runtime settings -> frozen Core v1.00 Entry/Exit configs.        |
//| Decision/config transport only. NO ORDERS.                       |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_RUNTIME_ADAPTER_V1_20_MQH
#define O01_GSG_RSI30_RUNTIME_ADAPTER_V1_20_MQH
#include "O01_Runtime_Settings_v1_10.mqh"
#include "O01_GSG_RSI30_Core_Interface_v1_00.mqh"
#define O01_RUNTIME_ADAPTER_VERSION "1.20"
class CO01RuntimeAdapter120{
public:
 void EntryConfig(const SO01RuntimeSettings110 &s,SO01EntryConfig &c) const{
  c.new_cycles=s.new_cycles;c.trade_buy=s.trade_buy;c.trade_sell=s.trade_sell;c.rsi_lower=s.rsi_lower;c.rsi_upper=s.rsi_upper;
 }
 void ExitConfig(const SO01RuntimeSettings110 &s,const int count,SO01ExitConfig &c) const{
  c.trailing=true;c.tp_points=(count<=1?110:100);c.sl_points=s.virtual_sl_points;
  c.trail_start=(count<=1?s.single_trail_start:s.basket_trail_start);
  c.trail_lock=(count<=1?s.single_trail_lock:s.basket_trail_lock);
  c.trail_distance=(count<=1?s.single_trail_distance:s.basket_trail_distance);
  c.trail_step=(count<=1?s.single_trail_step:s.basket_trail_step);
 }
 bool Validate(const SO01RuntimeSettings110 &s) const{
  return s.rsi_period>0&&s.rsi_lower>=0&&s.rsi_upper<=100&&s.rsi_lower<s.rsi_upper&&s.initial_lot>0&&
         s.lot_multiplier>=1&&s.max_lot>=s.initial_lot&&s.max_orders>0&&s.fixed_distance_points>0&&
         s.dynamic_start_order>0&&s.dynamic_start_points>0&&s.distance_multiplier>=1&&
         s.warning_dd>=0&&s.pause_grid_dd>=s.warning_dd&&s.emergency_close_dd>=s.pause_grid_dd;
 }
};
#endif
