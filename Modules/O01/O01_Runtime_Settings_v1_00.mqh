//+------------------------------------------------------------------+
//| O01_Runtime_Settings_v1_00.mqh                                  |
//| Runtime settings + save/load transport for O01 development.      |
//| Does not place orders.                                           |
//+------------------------------------------------------------------+
#ifndef O01_RUNTIME_SETTINGS_V1_00_MQH
#define O01_RUNTIME_SETTINGS_V1_00_MQH

struct SO01RuntimeSettings
  {
   bool new_cycles,trade_buy,trade_sell;
   double initial_lot,lot_multiplier,max_lot;
   int max_buy_orders,max_sell_orders;
   int rsi_period; double rsi_lower,rsi_upper;
   int single_tp_points,basket_tp_points,virtual_sl_points;
   int single_trail_start,single_trail_lock,single_trail_distance,single_trail_step;
   int basket_trail_start,basket_trail_lock,basket_trail_distance,basket_trail_step;
   int fixed_distance_points,dynamic_start_order,dynamic_start_points;
   double distance_multiplier;
   int warning_dd,pause_grid_dd,emergency_close_dd;
   int time_mode,start_hour,start_minute,end_hour,end_minute;
   bool use_news_filter;
  };

class CO01SettingsStore
  {
   string m_file;
public:
   void SetFile(const string name) { m_file=name; }
   bool Save(const SO01RuntimeSettings &s)
     {
      int h=FileOpen(m_file,FILE_WRITE|FILE_CSV|FILE_COMMON,'=');
      if(h==INVALID_HANDLE) return false;
      FileWrite(h,"version","1.00");
      FileWrite(h,"new_cycles",(int)s.new_cycles); FileWrite(h,"trade_buy",(int)s.trade_buy); FileWrite(h,"trade_sell",(int)s.trade_sell);
      FileWrite(h,"initial_lot",DoubleToString(s.initial_lot,8)); FileWrite(h,"lot_multiplier",DoubleToString(s.lot_multiplier,8)); FileWrite(h,"max_lot",DoubleToString(s.max_lot,8));
      FileWrite(h,"max_buy_orders",s.max_buy_orders); FileWrite(h,"max_sell_orders",s.max_sell_orders);
      FileWrite(h,"rsi_period",s.rsi_period); FileWrite(h,"rsi_lower",DoubleToString(s.rsi_lower,8)); FileWrite(h,"rsi_upper",DoubleToString(s.rsi_upper,8));
      FileWrite(h,"single_tp_points",s.single_tp_points); FileWrite(h,"basket_tp_points",s.basket_tp_points); FileWrite(h,"virtual_sl_points",s.virtual_sl_points);
      FileWrite(h,"single_trail_start",s.single_trail_start); FileWrite(h,"single_trail_lock",s.single_trail_lock); FileWrite(h,"single_trail_distance",s.single_trail_distance); FileWrite(h,"single_trail_step",s.single_trail_step);
      FileWrite(h,"basket_trail_start",s.basket_trail_start); FileWrite(h,"basket_trail_lock",s.basket_trail_lock); FileWrite(h,"basket_trail_distance",s.basket_trail_distance); FileWrite(h,"basket_trail_step",s.basket_trail_step);
      FileWrite(h,"fixed_distance_points",s.fixed_distance_points); FileWrite(h,"dynamic_start_order",s.dynamic_start_order); FileWrite(h,"dynamic_start_points",s.dynamic_start_points); FileWrite(h,"distance_multiplier",DoubleToString(s.distance_multiplier,8));
      FileWrite(h,"warning_dd",s.warning_dd); FileWrite(h,"pause_grid_dd",s.pause_grid_dd); FileWrite(h,"emergency_close_dd",s.emergency_close_dd);
      FileWrite(h,"time_mode",s.time_mode); FileWrite(h,"start_hour",s.start_hour); FileWrite(h,"start_minute",s.start_minute); FileWrite(h,"end_hour",s.end_hour); FileWrite(h,"end_minute",s.end_minute);
      FileWrite(h,"use_news_filter",(int)s.use_news_filter);
      FileClose(h); return true;
     }
   bool Load(SO01RuntimeSettings &s)
     {
      int h=FileOpen(m_file,FILE_READ|FILE_CSV|FILE_COMMON,'=');
      if(h==INVALID_HANDLE) return false;
      while(!FileIsEnding(h))
        {
         string k=FileReadString(h); if(FileIsEnding(h) && k=="") break; string v=FileReadString(h);
         if(k=="new_cycles")s.new_cycles=(StringToInteger(v)!=0); else if(k=="trade_buy")s.trade_buy=(StringToInteger(v)!=0); else if(k=="trade_sell")s.trade_sell=(StringToInteger(v)!=0);
         else if(k=="initial_lot")s.initial_lot=StringToDouble(v); else if(k=="lot_multiplier")s.lot_multiplier=StringToDouble(v); else if(k=="max_lot")s.max_lot=StringToDouble(v);
         else if(k=="max_buy_orders")s.max_buy_orders=(int)StringToInteger(v); else if(k=="max_sell_orders")s.max_sell_orders=(int)StringToInteger(v);
         else if(k=="rsi_period")s.rsi_period=(int)StringToInteger(v); else if(k=="rsi_lower")s.rsi_lower=StringToDouble(v); else if(k=="rsi_upper")s.rsi_upper=StringToDouble(v);
         else if(k=="single_tp_points")s.single_tp_points=(int)StringToInteger(v); else if(k=="basket_tp_points")s.basket_tp_points=(int)StringToInteger(v); else if(k=="virtual_sl_points")s.virtual_sl_points=(int)StringToInteger(v);
         else if(k=="single_trail_start")s.single_trail_start=(int)StringToInteger(v); else if(k=="single_trail_lock")s.single_trail_lock=(int)StringToInteger(v); else if(k=="single_trail_distance")s.single_trail_distance=(int)StringToInteger(v); else if(k=="single_trail_step")s.single_trail_step=(int)StringToInteger(v);
         else if(k=="basket_trail_start")s.basket_trail_start=(int)StringToInteger(v); else if(k=="basket_trail_lock")s.basket_trail_lock=(int)StringToInteger(v); else if(k=="basket_trail_distance")s.basket_trail_distance=(int)StringToInteger(v); else if(k=="basket_trail_step")s.basket_trail_step=(int)StringToInteger(v);
         else if(k=="fixed_distance_points")s.fixed_distance_points=(int)StringToInteger(v); else if(k=="dynamic_start_order")s.dynamic_start_order=(int)StringToInteger(v); else if(k=="dynamic_start_points")s.dynamic_start_points=(int)StringToInteger(v); else if(k=="distance_multiplier")s.distance_multiplier=StringToDouble(v);
         else if(k=="warning_dd")s.warning_dd=(int)StringToInteger(v); else if(k=="pause_grid_dd")s.pause_grid_dd=(int)StringToInteger(v); else if(k=="emergency_close_dd")s.emergency_close_dd=(int)StringToInteger(v);
         else if(k=="time_mode")s.time_mode=(int)StringToInteger(v); else if(k=="start_hour")s.start_hour=(int)StringToInteger(v); else if(k=="start_minute")s.start_minute=(int)StringToInteger(v); else if(k=="end_hour")s.end_hour=(int)StringToInteger(v); else if(k=="end_minute")s.end_minute=(int)StringToInteger(v);
         else if(k=="use_news_filter")s.use_news_filter=(StringToInteger(v)!=0);
        }
      FileClose(h); return true;
     }
  };
#endif
