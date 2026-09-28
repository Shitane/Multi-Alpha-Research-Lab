//+------------------------------------------------------------------+
//| A10_Split_Manage_Parity_NoOrders_v1_01.mq5                       |
//| A10 ENTRY + MANAGE + EXIT split parity candidate.                |
//| Virtual lifecycle only. NO BROKER ORDERS.                        |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"

input group "Common execution"
input int    InpMaxPositions=4;
input bool   InpSkipOppositeSignals=true;

input group "1. Breakout"
input bool InpBreakoutEnabled=true;
input double InpBreakoutBrickSize=17.0;
input int InpBreakoutBBPeriod=20;
input double InpBreakoutDeviation=1.0;
input int InpBreakoutEntryRun=2;
input double InpBreakoutTP=24.0;
input double InpBreakoutSL=42.0;
input int InpBreakoutMaxHold=1230;
input int InpBreakoutCooldown=5;
input double InpBreakoutMaxSpread=0.35;

input group "2. Re-entry"
input bool InpReentryEnabled=true;
input double InpReentryBrickSize=30.0;
input int InpReentryBBPeriod=31;
input double InpReentryDeviation=1.2;
input int InpReentryEntryRun=1;
input double InpReentryTP=28.0;
input double InpReentrySL=48.5;
input int InpReentryMaxHold=2580;
input int InpReentryCooldown=3;
input double InpReentryMaxSpread=0.35;

input group "3. Midline"
input bool InpMidlineEnabled=true;
input double InpMidlineBrickSize=30.0;
input int InpMidlineBBPeriod=5;
input double InpMidlineDeviation=3.0;
input int InpMidlineEntryRun=1;
input double InpMidlineTP=10.0;
input double InpMidlineSL=34.5;
input int InpMidlineMaxHold=2220;
input int InpMidlineCooldown=3;
input double InpMidlineMaxSpread=0.35;

input group "4. Squeeze"
input bool InpSqueezeEnabled=true;
input double InpSqueezeBrickSize=14.0;
input int InpSqueezeBBPeriod=18;
input double InpSqueezeDeviation=2.4;
input double InpSqueezeMaxWidth=34.5;
input int InpSqueezeEntryRun=1;
input double InpSqueezeTP=26.0;
input double InpSqueezeSL=31.0;
input int InpSqueezeMaxHold=2050;
input int InpSqueezeCooldown=1;
input double InpSqueezeMaxSpread=0.35;

#include "..\\..\\Include\\A10\\A10_Entry_Module_v1_00.mqh"
#include "..\\..\\Include\\A10\\A10_Manage_Module_v1_00.mqh"
#include "..\\..\\Include\\A10\\A10_Exit_Module_v1_00.mqh"

CA10EntryModule g_entry[4];
CA10ExitModule g_exit[4];
CA10ManageModule100 g_manage;
ulong g_next_ticket=1;
long g_ticks=0,g_entries=0,g_exits=0;
long g_entries_mode[4]={0,0,0,0},g_exits_mode[4]={0,0,0,0};

string ModeName(const int m)
  {
   if(m==0)return "Breakout"; if(m==1)return "Re-entry";
   if(m==2)return "Midline"; if(m==3)return "Squeeze"; return "Unknown";
  }

bool ConfigureEntry(const int mode,const bool enabled,const double tick,const double brick,
                    const int period,const double dev,const double squeeze,const int run)
  {
   return g_entry[mode].Configure(enabled,(ENUM_A10_ENTRY_MODE)mode,tick,brick,period,dev,squeeze,run,0,1.0);
  }

bool ConfigureManageMode(const int mode,const bool enabled,const int cooldown,
                         const double spread)
  {
   return g_manage.ConfigureMode(mode,enabled,cooldown,spread,g_entry[mode].Brick());
  }

void CloseVirtual(const int mode,const string reason,const MqlTick &tick)
  {
   SA10ManagePosition100 p={}; if(!g_manage.PositionSnapshot(mode,p))return;
   const double px=(p.direction>0?tick.bid:tick.ask);
   Print("[A10_SPLIT101_EXIT] mode=",ModeName(mode)," reason=",reason,
         " price=",DoubleToString(px,_Digits)," ticket=",p.ticket,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   g_manage.MarkExitPending(mode);
   g_manage.SetTransitionPending(true);
   g_manage.ConfirmExit(mode);
   g_exits++;g_exits_mode[mode]++;
  }

void CheckPriceExits(const MqlTick &tick)
  {
   for(int mode=0;mode<4;mode++)
     {
      SA10ManagePosition100 p={}; if(!g_manage.PositionSnapshot(mode,p)||g_manage.ExitPending(mode))continue;
      SA10ExitDecision d={};
      g_exit[mode].CheckPrice(p.direction,p.open_price,p.open_time,tick.bid,tick.ask,
                              TimeCurrent(),g_entry[mode].Brick(),d);
      if(d.exit)CloseVirtual(mode,g_exit[mode].ReasonText(d.reason),tick);
     }
  }

void CheckSignalExit(const int mode,const SA10EntryResult &r,const MqlTick &tick)
  {
   SA10ManagePosition100 p={}; if(!g_manage.PositionSnapshot(mode,p)||g_manage.ExitPending(mode))return;
   SA10ExitDecision d={};
   g_exit[mode].CheckSignal(mode,p.direction,r.completed,r.raw_signal,r.bb_ready,
                            r.final_close,r.bb_mid,d);
   if(d.exit)CloseVirtual(mode,g_exit[mode].ReasonText(d.reason),tick);
  }

void ProcessPendingEntry(const MqlTick &tick)
  {
   SA10ManageEntryRequest100 q={};
   if(!g_manage.NextEntryRequest(tick,TimeCurrent(),q))return;
   const double px=(q.direction>0?tick.ask:tick.bid);
   const ulong ticket=g_next_ticket++;
   g_manage.ConfirmEntry(q.mode,q.direction,px,TimeCurrent(),ticket);
   g_entries++;g_entries_mode[q.mode]++;
   Print("[A10_SPLIT101_ENTRY] mode=",ModeName(q.mode)," dir=",(q.direction>0?"BUY":"SELL"),
         " price=",DoubleToString(px,_Digits)," ticket=",ticket,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }

int OnInit()
  {
   if(InpMaxPositions<1||InpMaxPositions>4)return INIT_PARAMETERS_INCORRECT;
   const double tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(tick<=0.0)return INIT_FAILED;
   if(!g_manage.Init(InpMaxPositions,InpSkipOppositeSignals,120))return INIT_FAILED;

   if(!ConfigureEntry(0,InpBreakoutEnabled,tick,InpBreakoutBrickSize,InpBreakoutBBPeriod,InpBreakoutDeviation,1.0,InpBreakoutEntryRun)||
      !ConfigureEntry(1,InpReentryEnabled,tick,InpReentryBrickSize,InpReentryBBPeriod,InpReentryDeviation,1.0,InpReentryEntryRun)||
      !ConfigureEntry(2,InpMidlineEnabled,tick,InpMidlineBrickSize,InpMidlineBBPeriod,InpMidlineDeviation,1.0,InpMidlineEntryRun)||
      !ConfigureEntry(3,InpSqueezeEnabled,tick,InpSqueezeBrickSize,InpSqueezeBBPeriod,InpSqueezeDeviation,InpSqueezeMaxWidth,InpSqueezeEntryRun))
      return INIT_PARAMETERS_INCORRECT;

   if(!ConfigureManageMode(0,InpBreakoutEnabled,InpBreakoutCooldown,InpBreakoutMaxSpread)||
      !ConfigureManageMode(1,InpReentryEnabled,InpReentryCooldown,InpReentryMaxSpread)||
      !ConfigureManageMode(2,InpMidlineEnabled,InpMidlineCooldown,InpMidlineMaxSpread)||
      !ConfigureManageMode(3,InpSqueezeEnabled,InpSqueezeCooldown,InpSqueezeMaxSpread))
      return INIT_PARAMETERS_INCORRECT;

   if(!g_exit[0].Configure(InpBreakoutTP,InpBreakoutSL,InpBreakoutMaxHold)||
      !g_exit[1].Configure(InpReentryTP,InpReentrySL,InpReentryMaxHold)||
      !g_exit[2].Configure(InpMidlineTP,InpMidlineSL,InpMidlineMaxHold)||
      !g_exit[3].Configure(InpSqueezeTP,InpSqueezeSL,InpSqueezeMaxHold))
      return INIT_PARAMETERS_INCORRECT;

   Print("[A10_SPLIT101_START] ENTRY=1 MANAGE=1 EXIT=1 TTL=120 NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick={};if(!SymbolInfoTick(_Symbol,tick)||tick.bid<=0||tick.ask<tick.bid)return;
   g_ticks++;

   // Original ordering: pending exit -> price exit -> pending exit.
   // Virtual lifecycle is synchronous, so price exits complete immediately.
   CheckPriceExits(tick);

   SA10EntryResult r[4];
   for(int mode=0;mode<4;mode++)
     {
      g_entry[mode].PushPrice(tick.bid,r[mode]);
      g_manage.OnCompletedBricks(mode,r[mode].completed);
     }

   // Owner signal exits have priority over new entries.
   for(int mode=0;mode<4;mode++)CheckSignalExit(mode,r[mode],tick);
   if(g_manage.AnyExitPending())return;

   int signals[4]={r[0].signal,r[1].signal,r[2].signal,r[3].signal};
   g_manage.QueueSignals(signals,tick,TimeCurrent());
   ProcessPendingEntry(tick);
  }

void OnDeinit(const int reason)
  {
   Print("[A10_SPLIT101_SUMMARY] ticks=",g_ticks," entries=",g_entries," exits=",g_exits,
         " open=",g_manage.OpenCount(),
         " breakout_entries=",g_entries_mode[0]," breakout_exits=",g_exits_mode[0],
         " reentry_entries=",g_entries_mode[1]," reentry_exits=",g_exits_mode[1],
         " midline_entries=",g_entries_mode[2]," midline_exits=",g_exits_mode[2],
         " squeeze_entries=",g_entries_mode[3]," squeeze_exits=",g_exits_mode[3],
         " pending_entries=",g_manage.PendingEntryCount(),
         " transition_pending=",(int)g_manage.TransitionPending(),
         " reason=",reason," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }
//+------------------------------------------------------------------+
