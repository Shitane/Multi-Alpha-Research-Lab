//+------------------------------------------------------------------+
//| A10_Full_Module_Parity_NoOrders_v1_00.mq5                        |
//| Independent FULL/A10 parity harness. NO BROKER ORDERS.           |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\Include\\A10\\A10_Full_Module_v1_00.mqh"

CA10FullModule100 g_full;

void SetMode(SA10FullConfig100 &cfg,const int idx,bool en,double brick,int period,double dev,
             double squeeze,int run,double tp,double sl,int hold,int cd,double spread)
  {cfg.mode[idx].enabled=en;cfg.mode[idx].brick=brick;cfg.mode[idx].bb_period=period;cfg.mode[idx].deviation=dev;cfg.mode[idx].squeeze_width=squeeze;
   cfg.mode[idx].entry_run=run;cfg.mode[idx].tp=tp;cfg.mode[idx].sl=sl;cfg.mode[idx].max_hold=hold;cfg.mode[idx].cooldown=cd;cfg.mode[idx].max_spread=spread;}

string ModeName(int m){if(m==0)return"Breakout";if(m==1)return"Re-entry";if(m==2)return"Midline";return"Squeeze";}

int OnInit()
  {
   SA10FullConfig100 c={};c.max_positions=4;c.skip_opposite=true;c.entry_ttl_seconds=120;
   SetMode(c,0,true,17,20,1.0,1.0,2,24,42,1230,5,.35);
   SetMode(c,1,true,30,31,1.2,1.0,1,28,48.5,2580,3,.35);
   SetMode(c,2,true,30,5,3.0,1.0,1,10,34.5,2220,3,.35);
   SetMode(c,3,true,14,18,2.4,34.5,1,26,31,2050,1,.35);
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
