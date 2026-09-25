//+------------------------------------------------------------------+
//| O01_Runtime_Settings_v1_10.mqh                                  |
//| Expanded runtime settings + versioned FILE_COMMON save/load.      |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#ifndef O01_RUNTIME_SETTINGS_V1_10_MQH
#define O01_RUNTIME_SETTINGS_V1_10_MQH
struct SO01RuntimeSettings110
{
 bool new_cycles,trade_buy,trade_sell,allow_grid_outside_time,one_order_per_bar,pause_grid_while_trailing;
 int rsi_period; double rsi_lower,rsi_upper;
 int atr1_period,atr2_period,atr2_timeframe; double atr1_min_points,atr1_max_points,atr2_min_points,atr2_max_points;
 double initial_lot,lot_multiplier,max_lot,max_total_lots_per_side; int max_orders;
 int fixed_distance_points,dynamic_start_order,dynamic_start_points; double distance_multiplier;
 int virtual_sl_points,single_trail_start,single_trail_lock,single_trail_distance,single_trail_step;
 int basket_trail_start,basket_trail_lock,basket_trail_distance,basket_trail_step;
 int warning_dd,pause_grid_dd,emergency_close_dd;
 int time_mode,start_hour,start_minute,end_hour,end_minute; bool use_news_filter,news_manage_only;
};
class CO01SettingsStore110
{
 string f;
 void W(int h,string k,string v){FileWrite(h,k,v);}
public:
 void SetFile(string x){f=x;}
 bool Save(const SO01RuntimeSettings110 &s){
  int h=FileOpen(f,FILE_WRITE|FILE_CSV|FILE_COMMON,'='); if(h==INVALID_HANDLE)return false;
  W(h,"version","1.10");
  W(h,"new_cycles",(string)(int)s.new_cycles);W(h,"trade_buy",(string)(int)s.trade_buy);W(h,"trade_sell",(string)(int)s.trade_sell);
  W(h,"allow_grid_outside_time",(string)(int)s.allow_grid_outside_time);W(h,"one_order_per_bar",(string)(int)s.one_order_per_bar);W(h,"pause_grid_while_trailing",(string)(int)s.pause_grid_while_trailing);
  W(h,"rsi_period",(string)s.rsi_period);W(h,"rsi_lower",DoubleToString(s.rsi_lower,8));W(h,"rsi_upper",DoubleToString(s.rsi_upper,8));
  W(h,"atr1_period",(string)s.atr1_period);W(h,"atr2_period",(string)s.atr2_period);W(h,"atr2_timeframe",(string)s.atr2_timeframe);
  W(h,"atr1_min_points",DoubleToString(s.atr1_min_points,8));W(h,"atr1_max_points",DoubleToString(s.atr1_max_points,8));W(h,"atr2_min_points",DoubleToString(s.atr2_min_points,8));W(h,"atr2_max_points",DoubleToString(s.atr2_max_points,8));
  W(h,"initial_lot",DoubleToString(s.initial_lot,8));W(h,"lot_multiplier",DoubleToString(s.lot_multiplier,8));W(h,"max_lot",DoubleToString(s.max_lot,8));W(h,"max_total_lots_per_side",DoubleToString(s.max_total_lots_per_side,8));W(h,"max_orders",(string)s.max_orders);
  W(h,"fixed_distance_points",(string)s.fixed_distance_points);W(h,"dynamic_start_order",(string)s.dynamic_start_order);W(h,"dynamic_start_points",(string)s.dynamic_start_points);W(h,"distance_multiplier",DoubleToString(s.distance_multiplier,8));
  W(h,"virtual_sl_points",(string)s.virtual_sl_points);W(h,"single_trail_start",(string)s.single_trail_start);W(h,"single_trail_lock",(string)s.single_trail_lock);W(h,"single_trail_distance",(string)s.single_trail_distance);W(h,"single_trail_step",(string)s.single_trail_step);
  W(h,"basket_trail_start",(string)s.basket_trail_start);W(h,"basket_trail_lock",(string)s.basket_trail_lock);W(h,"basket_trail_distance",(string)s.basket_trail_distance);W(h,"basket_trail_step",(string)s.basket_trail_step);
  W(h,"warning_dd",(string)s.warning_dd);W(h,"pause_grid_dd",(string)s.pause_grid_dd);W(h,"emergency_close_dd",(string)s.emergency_close_dd);
  W(h,"time_mode",(string)s.time_mode);W(h,"start_hour",(string)s.start_hour);W(h,"start_minute",(string)s.start_minute);W(h,"end_hour",(string)s.end_hour);W(h,"end_minute",(string)s.end_minute);
  W(h,"use_news_filter",(string)(int)s.use_news_filter);W(h,"news_manage_only",(string)(int)s.news_manage_only);FileClose(h);return true;
 }
 bool Load(SO01RuntimeSettings110 &s){
  int h=FileOpen(f,FILE_READ|FILE_CSV|FILE_COMMON,'=');if(h==INVALID_HANDLE)return false;
  while(!FileIsEnding(h)){string k=FileReadString(h);if(FileIsEnding(h)&&k=="")break;string v=FileReadString(h);
   if(k=="new_cycles")s.new_cycles=StringToInteger(v)!=0;else if(k=="trade_buy")s.trade_buy=StringToInteger(v)!=0;else if(k=="trade_sell")s.trade_sell=StringToInteger(v)!=0;
   else if(k=="allow_grid_outside_time")s.allow_grid_outside_time=StringToInteger(v)!=0;else if(k=="one_order_per_bar")s.one_order_per_bar=StringToInteger(v)!=0;else if(k=="pause_grid_while_trailing")s.pause_grid_while_trailing=StringToInteger(v)!=0;
   else if(k=="rsi_period")s.rsi_period=(int)StringToInteger(v);else if(k=="rsi_lower")s.rsi_lower=StringToDouble(v);else if(k=="rsi_upper")s.rsi_upper=StringToDouble(v);
   else if(k=="atr1_period")s.atr1_period=(int)StringToInteger(v);else if(k=="atr2_period")s.atr2_period=(int)StringToInteger(v);else if(k=="atr2_timeframe")s.atr2_timeframe=(int)StringToInteger(v);
   else if(k=="atr1_min_points")s.atr1_min_points=StringToDouble(v);else if(k=="atr1_max_points")s.atr1_max_points=StringToDouble(v);else if(k=="atr2_min_points")s.atr2_min_points=StringToDouble(v);else if(k=="atr2_max_points")s.atr2_max_points=StringToDouble(v);
   else if(k=="initial_lot")s.initial_lot=StringToDouble(v);else if(k=="lot_multiplier")s.lot_multiplier=StringToDouble(v);else if(k=="max_lot")s.max_lot=StringToDouble(v);else if(k=="max_total_lots_per_side")s.max_total_lots_per_side=StringToDouble(v);else if(k=="max_orders")s.max_orders=(int)StringToInteger(v);
   else if(k=="fixed_distance_points")s.fixed_distance_points=(int)StringToInteger(v);else if(k=="dynamic_start_order")s.dynamic_start_order=(int)StringToInteger(v);else if(k=="dynamic_start_points")s.dynamic_start_points=(int)StringToInteger(v);else if(k=="distance_multiplier")s.distance_multiplier=StringToDouble(v);
   else if(k=="virtual_sl_points")s.virtual_sl_points=(int)StringToInteger(v);else if(k=="single_trail_start")s.single_trail_start=(int)StringToInteger(v);else if(k=="single_trail_lock")s.single_trail_lock=(int)StringToInteger(v);else if(k=="single_trail_distance")s.single_trail_distance=(int)StringToInteger(v);else if(k=="single_trail_step")s.single_trail_step=(int)StringToInteger(v);
   else if(k=="basket_trail_start")s.basket_trail_start=(int)StringToInteger(v);else if(k=="basket_trail_lock")s.basket_trail_lock=(int)StringToInteger(v);else if(k=="basket_trail_distance")s.basket_trail_distance=(int)StringToInteger(v);else if(k=="basket_trail_step")s.basket_trail_step=(int)StringToInteger(v);
   else if(k=="warning_dd")s.warning_dd=(int)StringToInteger(v);else if(k=="pause_grid_dd")s.pause_grid_dd=(int)StringToInteger(v);else if(k=="emergency_close_dd")s.emergency_close_dd=(int)StringToInteger(v);
   else if(k=="time_mode")s.time_mode=(int)StringToInteger(v);else if(k=="start_hour")s.start_hour=(int)StringToInteger(v);else if(k=="start_minute")s.start_minute=(int)StringToInteger(v);else if(k=="end_hour")s.end_hour=(int)StringToInteger(v);else if(k=="end_minute")s.end_minute=(int)StringToInteger(v);
   else if(k=="use_news_filter")s.use_news_filter=StringToInteger(v)!=0;else if(k=="news_manage_only")s.news_manage_only=StringToInteger(v)!=0;
  } FileClose(h);return true;
 }
};
#endif
