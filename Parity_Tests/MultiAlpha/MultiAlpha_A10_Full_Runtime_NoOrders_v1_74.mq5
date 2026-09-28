//+------------------------------------------------------------------+
//| MultiAlpha_A10_Full_Runtime_NoOrders_v1_74.mq5                  |
//| Staging host: route FULL=A10 through common FULL dispatcher.      |
//| NO BROKER ORDERS. Does not alter the frozen O01 runtime host.     |
//+------------------------------------------------------------------+
#property strict
#property version "1.74"

#include "..\\..\\Include\\Common\\MultiAlpha_Full_Dispatcher_v1_74.mqh"

CMultiAlphaFullDispatcher174 g_full_dispatcher;
SMA_ModuleSelection150 g_route;

string ModeName(const int m)
  {
   if(m==0)return "Breakout";
   if(m==1)return "Re-entry";
   if(m==2)return "Midline";
   if(m==3)return "Squeeze";
   return "Unknown";
  }

void A10Defaults(SA10FullConfig100 &c)
  {
   c.max_positions=4;c.skip_opposite=true;c.entry_ttl_seconds=120;
   c.mode[0].enabled=true;c.mode[0].brick=17;c.mode[0].bb_period=20;c.mode[0].deviation=1.0;c.mode[0].squeeze_width=1.0;c.mode[0].entry_run=2;c.mode[0].tp=24;c.mode[0].sl=42;c.mode[0].max_hold=1230;c.mode[0].cooldown=5;c.mode[0].max_spread=.35;
   c.mode[1].enabled=true;c.mode[1].brick=30;c.mode[1].bb_period=31;c.mode[1].deviation=1.2;c.mode[1].squeeze_width=1.0;c.mode[1].entry_run=1;c.mode[1].tp=28;c.mode[1].sl=48.5;c.mode[1].max_hold=2580;c.mode[1].cooldown=3;c.mode[1].max_spread=.35;
   c.mode[2].enabled=true;c.mode[2].brick=30;c.mode[2].bb_period=5;c.mode[2].deviation=3.0;c.mode[2].squeeze_width=1.0;c.mode[2].entry_run=1;c.mode[2].tp=10;c.mode[2].sl=34.5;c.mode[2].max_hold=2220;c.mode[2].cooldown=3;c.mode[2].max_spread=.35;
   c.mode[3].enabled=true;c.mode[3].brick=14;c.mode[3].bb_period=18;c.mode[3].deviation=2.4;c.mode[3].squeeze_width=34.5;c.mode[3].entry_run=1;c.mode[3].tp=26;c.mode[3].sl=31;c.mode[3].max_hold=2050;c.mode[3].cooldown=1;c.mode[3].max_spread=.35;
  }

int OnInit()
  {
   g_route.structure=MA_STRUCTURE_FULL_V150;
   g_route.full_module=MA_LOGIC_A10_V150;
   g_route.entry_module=MA_LOGIC_NONE_V150;
   g_route.manage_module=MA_LOGIC_NONE_V150;
   g_route.exit_module=MA_LOGIC_NONE_V150;

   SA10FullConfig100 cfg={};
   A10Defaults(cfg);
   const double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick_size<=0.0 || !g_full_dispatcher.InitA10(cfg,tick_size))
      return INIT_FAILED;

   Print("[MA_FULL174_START] STRUCTURE=FULL FULL=A10 DISPATCHER=1.74",
         " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || tick.bid<=0.0 || tick.ask<tick.bid)return;

   SA10FullEvent100 e={};
   if(!g_full_dispatcher.OnTick(g_route,tick,e) || !e.valid)return;

   Print(e.is_entry?"[MA_FULL174_ENTRY]":"[MA_FULL174_EXIT]",
         " module=A10 mode=",ModeName(e.mode),
         " dir=",(e.direction>0?"BUY":"SELL"),
         " reason=",e.reason,
         " price=",DoubleToString(e.price,_Digits),
         " ticket=",e.ticket,
         " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  }

void OnDeinit(const int reason)
  {
   Print("[MA_FULL174_SUMMARY] module=A10 ticks=",g_full_dispatcher.A10Ticks(),
         " entries=",g_full_dispatcher.A10Entries(),
         " exits=",g_full_dispatcher.A10Exits(),
         " open=",g_full_dispatcher.A10OpenCount(),
         " breakout_entries=",g_full_dispatcher.A10ModeEntries(0),
         " breakout_exits=",g_full_dispatcher.A10ModeExits(0),
         " reentry_entries=",g_full_dispatcher.A10ModeEntries(1),
         " reentry_exits=",g_full_dispatcher.A10ModeExits(1),
         " midline_entries=",g_full_dispatcher.A10ModeEntries(2),
         " midline_exits=",g_full_dispatcher.A10ModeExits(2),
         " squeeze_entries=",g_full_dispatcher.A10ModeEntries(3),
         " squeeze_exits=",g_full_dispatcher.A10ModeExits(3),
         " reason=",reason,
         " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  }
