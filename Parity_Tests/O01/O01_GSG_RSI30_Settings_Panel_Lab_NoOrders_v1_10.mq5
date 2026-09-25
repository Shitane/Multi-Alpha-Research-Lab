//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Settings_Panel_Lab_NoOrders_v1_10.mq5            |
//| Panel/settings transport compile + chart-event lab. NO ORDERS.   |
//+------------------------------------------------------------------+
#property strict
#property version "1.10"
#include "..\..\Include\O01\O01_Settings_Panel_v1_10.mqh"
SO01RuntimeSettings110 cfg;CO01SettingsPanel110 panel;
void Defaults(){
 cfg.new_cycles=true;cfg.trade_buy=true;cfg.trade_sell=true;cfg.allow_grid_outside_time=true;cfg.one_order_per_bar=true;cfg.pause_grid_while_trailing=true;
 cfg.rsi_period=8;cfg.rsi_lower=30;cfg.rsi_upper=70;cfg.atr1_period=15;cfg.atr2_period=15;cfg.atr2_timeframe=PERIOD_CURRENT;cfg.atr1_min_points=0;cfg.atr1_max_points=10000;cfg.atr2_min_points=0;cfg.atr2_max_points=10000;
 cfg.initial_lot=.01;cfg.lot_multiplier=1.5;cfg.max_lot=5;cfg.max_total_lots_per_side=1.2;cfg.max_orders=10;cfg.fixed_distance_points=200;cfg.dynamic_start_order=3;cfg.dynamic_start_points=300;cfg.distance_multiplier=1.2;
 cfg.virtual_sl_points=1500;cfg.single_trail_start=110;cfg.single_trail_lock=60;cfg.single_trail_distance=50;cfg.single_trail_step=10;cfg.basket_trail_start=100;cfg.basket_trail_lock=50;cfg.basket_trail_distance=50;cfg.basket_trail_step=10;
 cfg.warning_dd=8;cfg.pause_grid_dd=12;cfg.emergency_close_dd=15;cfg.time_mode=0;cfg.start_hour=7;cfg.start_minute=0;cfg.end_hour=11;cfg.end_minute=0;cfg.use_news_filter=true;cfg.news_manage_only=true;
}
int OnInit(){Defaults();panel.Create(cfg);Print("[O01_PANEL110_START] NO_ORDERS=1 settings_file=O01_GSG_RSI30_Settings_v1_10.csv DD=",cfg.warning_dd,"/",cfg.pause_grid_dd,"/",cfg.emergency_close_dd);return INIT_SUCCEEDED;}
void OnDeinit(const int reason){panel.Delete();}
void OnTick(){}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){int r=panel.Event(id,sparam,cfg);if(r!=0)Print("[O01_PANEL110_EVENT] result=",r," RSI=",DoubleToString(cfg.rsi_lower,1),"/",DoubleToString(cfg.rsi_upper,1)," lot=",DoubleToString(cfg.initial_lot,2)," grid=",cfg.fixed_distance_points," DD=",cfg.warning_dd,"/",cfg.pause_grid_dd,"/",cfg.emergency_close_dd," time=",StringFormat("%02d:%02d-%02d:%02d",cfg.start_hour,cfg.start_minute,cfg.end_hour,cfg.end_minute)," NO_ORDERS=1");}
