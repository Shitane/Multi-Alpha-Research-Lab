//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Runtime_Panel_Core_NoOrders_v1_20.mq5            |
//| Runtime panel -> frozen Core v1.00 decision adapter smoke lab.   |
//| NO ORDERS. VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.20"
#include "..\..\Include\O01\O01_GSG_RSI30_Runtime_Adapter_v1_20.mqh"
#include "..\..\Include\O01\O01_Settings_Panel_v1_20.mqh"
SO01RuntimeSettings110 cfg;CO01SettingsPanel120 panel;CO01RuntimeAdapter120 adapter;CO01CoreInterface core;
void Defaults(){
 cfg.new_cycles=true;cfg.trade_buy=true;cfg.trade_sell=true;cfg.allow_grid_outside_time=true;cfg.one_order_per_bar=true;cfg.pause_grid_while_trailing=true;
 cfg.rsi_period=8;cfg.rsi_lower=30;cfg.rsi_upper=70;cfg.atr1_period=15;cfg.atr2_period=15;cfg.atr2_timeframe=PERIOD_CURRENT;cfg.atr1_min_points=0;cfg.atr1_max_points=10000;cfg.atr2_min_points=0;cfg.atr2_max_points=10000;
 cfg.initial_lot=.01;cfg.lot_multiplier=1.5;cfg.max_lot=5;cfg.max_total_lots_per_side=1.2;cfg.max_orders=10;cfg.fixed_distance_points=200;cfg.dynamic_start_order=3;cfg.dynamic_start_points=300;cfg.distance_multiplier=1.2;
 cfg.virtual_sl_points=1500;cfg.single_trail_start=110;cfg.single_trail_lock=60;cfg.single_trail_distance=50;cfg.single_trail_step=10;cfg.basket_trail_start=100;cfg.basket_trail_lock=50;cfg.basket_trail_distance=50;cfg.basket_trail_step=10;
 cfg.warning_dd=8;cfg.pause_grid_dd=12;cfg.emergency_close_dd=15;cfg.time_mode=0;cfg.start_hour=7;cfg.start_minute=0;cfg.end_hour=11;cfg.end_minute=0;cfg.use_news_filter=true;cfg.news_manage_only=true;
}
void Probe(){
 SO01EntryConfig ec;adapter.EntryConfig(cfg,ec);SO01EntryContext x;x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=0;x.sell_count=0;x.rsi=cfg.rsi_lower-0.01;
 ENUM_O01_ENTRY_SIGNAL e=core.EvaluateEntry(ec,x);SO01ExitConfig xc;adapter.ExitConfig(cfg,1,xc);
 Print("[O01_RUNTIME120_PROBE] entry_probe=",(int)e," RSI=",DoubleToString(ec.rsi_lower,1),"/",DoubleToString(ec.rsi_upper,1)," lot=",DoubleToString(cfg.initial_lot,2)," grid=",cfg.fixed_distance_points," VSL=",xc.sl_points," trail=",xc.trail_start,"/",xc.trail_lock,"/",xc.trail_distance," DD=",cfg.warning_dd,"/",cfg.pause_grid_dd,"/",cfg.emergency_close_dd," time=",StringFormat("%02d:%02d-%02d:%02d",cfg.start_hour,cfg.start_minute,cfg.end_hour,cfg.end_minute)," CORE=1.00 ADAPTER=1.20 NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
}
int OnInit(){Defaults();if(!adapter.Validate(cfg))return INIT_PARAMETERS_INCORRECT;panel.Create(cfg);Print("[O01_RUNTIME120_START] CORE=1.00 ADAPTER=1.20 PANEL=1.20 NO_ORDERS=1 VIRTUAL_NOT_FILL=1");Probe();return INIT_SUCCEEDED;}
void OnDeinit(const int reason){panel.Delete();}
void OnTick(){}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){int r=panel.Event(id,sparam,cfg);if(r!=0){Print("[O01_RUNTIME120_PANEL] result=",r," valid=",(int)adapter.Validate(cfg)," NO_ORDERS=1");if(r>0&&adapter.Validate(cfg))Probe();}}
