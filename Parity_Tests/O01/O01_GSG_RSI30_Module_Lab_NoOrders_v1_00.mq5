//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Module_Lab_NoOrders_v1_00.mq5                     |
//| Split-module laboratory host. NO ORDERS.                         |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\..\Include\O01\O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "..\..\Include\O01\O01_GSG_RSI30_Exit_Module_v1_00.mqh"
#include "..\..\Include\O01\O01_Settings_Panel_v1_00.mqh"

input double InpRSILower=30.0;
input double InpRSIUpper=70.0;
input double InpInitialLot=0.01;
input double InpLotMultiplier=1.50;
input double InpMaxLot=5.00;
input int InpWarningDD=8;
input int InpPauseGridDD=12;
input int InpEmergencyCloseDD=15;

SO01RuntimeSettings cfg;
CO01SettingsPanel panel;
CO01EntryModule entry_module;
CO01ExitModule exit_module;

void Defaults()
  {
   ZeroMemory(cfg);
   cfg.new_cycles=true; cfg.trade_buy=true; cfg.trade_sell=true;
   cfg.rsi_period=8; cfg.rsi_lower=InpRSILower; cfg.rsi_upper=InpRSIUpper;
   cfg.initial_lot=InpInitialLot; cfg.lot_multiplier=InpLotMultiplier; cfg.max_lot=InpMaxLot;
   cfg.max_buy_orders=10; cfg.max_sell_orders=10;
   cfg.single_tp_points=110; cfg.basket_tp_points=100; cfg.virtual_sl_points=1500;
   cfg.single_trail_start=110; cfg.single_trail_lock=60; cfg.single_trail_distance=50; cfg.single_trail_step=10;
   cfg.basket_trail_start=100; cfg.basket_trail_lock=50; cfg.basket_trail_distance=50; cfg.basket_trail_step=10;
   cfg.fixed_distance_points=200; cfg.dynamic_start_order=3; cfg.dynamic_start_points=300; cfg.distance_multiplier=1.20;
   cfg.warning_dd=InpWarningDD; cfg.pause_grid_dd=InpPauseGridDD; cfg.emergency_close_dd=InpEmergencyCloseDD;
   cfg.time_mode=0; cfg.start_hour=7; cfg.start_minute=0; cfg.end_hour=11; cfg.end_minute=0; cfg.use_news_filter=true;
  }

int OnInit()
  {
   Defaults(); panel.Create(cfg);
   Print("[O01_MODULE_LAB_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1 RSI=",cfg.rsi_lower,"/",cfg.rsi_upper);
   return INIT_SUCCEEDED;
  }
void OnDeinit(const int reason) { panel.Delete(); }
void OnTick() { /* v1.00 scaffold: decisions are wired in the next parity step; intentionally no orders. */ }
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   int r=panel.Event(id,sparam,cfg);
   if(r!=0) Print("[O01_SETTINGS] event=",r," RSI=",cfg.rsi_lower,"/",cfg.rsi_upper," lot=",cfg.initial_lot,
                  " DD=",cfg.warning_dd,"/",cfg.pause_grid_dd,"/",cfg.emergency_close_dd," NO_ORDERS=1");
  }
