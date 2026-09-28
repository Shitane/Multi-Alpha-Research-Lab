//+------------------------------------------------------------------+
//| A10_Full_Module_Parity_NoOrders_v1_00.mq5                        |
//| Independent FULL/A10 parity harness. NO BROKER ORDERS.           |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\Include\\A10\\A10_Full_Module_v1_00.mqh"

CA10FullModule100 g_full;

string ModeName(int m){if(m==0)return"Breakout";if(m==1)return"Re-entry";if(m==2)return"Midline";return"Squeeze";}

int OnInit()
  {
   SA10FullConfig100 c={};c.max_positions=4;c.skip_opposite=true;c.entry_ttl_seconds=120;
   c.mode[0].enabled=true;c.mode[0].brick=17;c.mode[0].bb_period=20;c.mode[0].deviation=1.0;c.mode[0].squeeze_width=1.0;c.mode[0].entry_run=2;c.mode[0].tp=24;c.mode[0].sl=42;c.mode[0].max_hold=1230;c.mode[0].cooldown=5;c.mode[0].max_spread=.35;
   c.mode[1].enabled=true;c.mode[1].brick=30;c.mode[1].bb_period=31;c.mode[1].deviation=1.2;c.mode[1].squeeze_width=1.0;c.mode[1].entry_run=1;c.mode[1].tp=28;c.mode[1].sl=48.5;c.mode[1].max_hold=2580;c.mode[1].cooldown=3;c.mode[1].max_spread=.35;
   c.mode[2].enabled=true;c.mode[2].brick=30;c.mode[2].bb_period=5;c.mode[2].deviation=3.0;c.mode[2].squeeze_width=1.0;c.mode[2].entry_run=1;c.mode[2].tp=10;c.mode[2].sl=34.5;c.mode[2].max_hold=2220;c.mode[2].cooldown=3;c.mode[2].max_spread=.35;
   c.mode[3].enabled=true;c.mode[3].brick=14;c.mode[3].bb_period=18;c.mode[3].deviation=2.4;c.mode[3].squeeze_width=34.5;c.mode[3].entry_run=1;c.mode[3].tp=26;c.mode[3].sl=31;c.mode[3].max_hold=2050;c.mode[3].cooldown=1;c.mode[3].max_spread=.35;
   double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(!g_full.Init(c,ts))return INIT_FAILED;
   Print("[A10_FULL100_START] FULL=A10 TTL=120 NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick t={};if(!SymbolInfoTick(_Symbol,t))return;
   SA10FullEvent100 e={};if(!g_full.OnTick(t,e)||!e.valid)return;
   Print(e.is_entry?"[A10_FULL100_ENTRY]":"[A10_FULL100_EXIT]",
         " mode=",ModeName(e.mode)," dir=",(e.direction>0?"BUY":"SELL"),
         " reason=",e.reason," price=",DoubleToString(e.price,_Digits),
         " ticket=",e.ticket," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }

void OnDeinit(const int reason)
  {
   Print("[A10_FULL100_SUMMARY] ticks=",g_full.Ticks()," entries=",g_full.Entries(),
         " exits=",g_full.Exits()," open=",g_full.OpenCount(),
         " breakout_entries=",g_full.ModeEntries(0)," breakout_exits=",g_full.ModeExits(0),
         " reentry_entries=",g_full.ModeEntries(1)," reentry_exits=",g_full.ModeExits(1),
         " midline_entries=",g_full.ModeEntries(2)," midline_exits=",g_full.ModeExits(2),
         " squeeze_entries=",g_full.ModeEntries(3)," squeeze_exits=",g_full.ModeExits(3),
         " reason=",reason," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }
