//+------------------------------------------------------------------+
//|             GDS Renko Bollinger 4-Mode Demo EA                  |
//|        Educational multi-engine Renko Bollinger example         |
//+------------------------------------------------------------------+
#property copyright "Golden Delta"
#property link      "https://goldendeltaea.com/"
#property version   "1.00"
#property strict
#property description "A10 separated Entry+Exit parity candidate."
#property description "Four independent Renko+Bollinger modes."
#property description "Virtual positions only. No broker orders."
#property description "For baseline parity research."

// -------------------------------------------------------------------
// Common execution settings
// -------------------------------------------------------------------
input group "Common execution"
input double InpLots                  = 0.01;       // Requested fixed lot
input ulong  InpMagic                 = 26091150;   // Base magic; four mode magics are Base+1...Base+4
input int    InpMaxPositions          = 4;          // Maximum simultaneous GDS positions (1..4)
input bool   InpSkipOppositeSignals   = true;       // Safety filter: skip new same-tick entries when modes disagree

// -------------------------------------------------------------------
// Mode 1: Breakout - real-tick verified profile
// -------------------------------------------------------------------
input group "1. Breakout"
input bool   InpBreakoutEnabled       = true;       // Enable Breakout mode
input double InpBreakoutBrickSize     = 17.0;       // Renko brick size
input int    InpBreakoutBBPeriod      = 20;         // Bollinger period
input double InpBreakoutDeviation     = 1.0;        // Bollinger deviation
input int    InpBreakoutEntryRun      = 2;          // Minimum same-direction Renko run
input double InpBreakoutTP            = 24.0;       // Virtual TP, bricks
input double InpBreakoutSL            = 42.0;       // Virtual SL, bricks
input int    InpBreakoutMaxHold       = 1230;       // Maximum hold, minutes
input int    InpBreakoutCooldown      = 5;          // Cooldown after exit, completed mode bricks
input double InpBreakoutMaxSpread     = 0.35;       // Max spread / mode brick size

// -------------------------------------------------------------------
// Mode 2: Re-entry / Mean Reversion - real-tick verified profile
// -------------------------------------------------------------------
input group "2. Re-entry / Mean Reversion"
input bool   InpReentryEnabled        = true;       // Enable Re-entry mode
input double InpReentryBrickSize      = 30.0;       // Renko brick size
input int    InpReentryBBPeriod       = 31;         // Bollinger period
input double InpReentryDeviation      = 1.2;        // Bollinger deviation
input int    InpReentryEntryRun       = 1;          // Minimum same-direction Renko run
input double InpReentryTP             = 28.0;       // Virtual TP, bricks
input double InpReentrySL             = 48.5;       // Virtual SL, bricks
input int    InpReentryMaxHold        = 2580;       // Maximum hold, minutes
input int    InpReentryCooldown       = 3;          // Cooldown after exit, completed mode bricks
input double InpReentryMaxSpread      = 0.35;       // Max spread / mode brick size

// -------------------------------------------------------------------
// Mode 3: Midline Cross - real-tick verified profile
// -------------------------------------------------------------------
input group "3. Midline Cross"
input bool   InpMidlineEnabled        = true;       // Enable Midline Cross mode
input double InpMidlineBrickSize      = 30.0;       // Renko brick size
input int    InpMidlineBBPeriod       = 5;          // Bollinger period
input double InpMidlineDeviation      = 3.0;        // Bollinger deviation
input int    InpMidlineEntryRun       = 1;          // Minimum same-direction Renko run
input double InpMidlineTP             = 10.0;       // Virtual TP, bricks
input double InpMidlineSL             = 34.5;       // Virtual SL, bricks
input int    InpMidlineMaxHold        = 2220;       // Maximum hold, minutes
input int    InpMidlineCooldown       = 3;          // Cooldown after exit, completed mode bricks
input double InpMidlineMaxSpread      = 0.35;       // Max spread / mode brick size

// -------------------------------------------------------------------
// Mode 4: Squeeze Breakout - real-tick verified profile
// -------------------------------------------------------------------
input group "4. Squeeze Breakout"
input bool   InpSqueezeEnabled        = true;       // Enable Squeeze Breakout mode
input double InpSqueezeBrickSize      = 14.0;       // Renko brick size
input int    InpSqueezeBBPeriod       = 18;         // Bollinger period
input double InpSqueezeDeviation      = 2.4;        // Bollinger deviation
input double InpSqueezeMaxWidth       = 34.5;       // Maximum full band width, in bricks
input int    InpSqueezeEntryRun       = 1;          // Minimum same-direction Renko run
input double InpSqueezeTP             = 26.0;       // Virtual TP, bricks
input double InpSqueezeSL             = 31.0;       // Virtual SL, bricks
input int    InpSqueezeMaxHold        = 2050;       // Maximum hold, minutes
input int    InpSqueezeCooldown       = 1;          // Cooldown after exit, completed mode bricks
input double InpSqueezeMaxSpread      = 0.35;       // Max spread / mode brick size

#include "..\\..\\Include\\A10_Entry_Module_v1_00.mqh"
#include "..\\..\\Include\\A10_Exit_Module_v1_00.mqh"

CA10EntryModule g_breakout;
CA10EntryModule g_reentry;
CA10EntryModule g_midline;
CA10EntryModule g_squeeze;

CA10ExitModule g_exit_breakout;
CA10ExitModule g_exit_reentry;
CA10ExitModule g_exit_midline;
CA10ExitModule g_exit_squeeze;

//+------------------------------------------------------------------+
ulong ModeMagic(const int mode)
  {
   return InpMagic+(ulong)(mode+1);
  }

//+------------------------------------------------------------------+
bool IsOurMagic(const ulong magic,int &mode)
  {
   for(int i=0;i<4;i++)
     {
      if(magic==ModeMagic(i))
        {
         mode=i;
         return true;
        }
     }
   mode=-1;
   return false;
  }

//+------------------------------------------------------------------+
string ModeName(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return "Breakout";
   if(mode==A10_ENTRY_REENTRY) return "Re-entry";
   if(mode==A10_ENTRY_MIDLINE) return "Midline";
   if(mode==A10_ENTRY_SQUEEZE) return "Squeeze";
   return "Unknown";
  }

//+------------------------------------------------------------------+
bool ModeEnabled(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return g_breakout.Enabled();
   if(mode==A10_ENTRY_REENTRY) return g_reentry.Enabled();
   if(mode==A10_ENTRY_MIDLINE) return g_midline.Enabled();
   if(mode==A10_ENTRY_SQUEEZE) return g_squeeze.Enabled();
   return false;
  }

//+------------------------------------------------------------------+
double ModeBrick(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return g_breakout.Brick();
   if(mode==A10_ENTRY_REENTRY) return g_reentry.Brick();
   if(mode==A10_ENTRY_MIDLINE) return g_midline.Brick();
   if(mode==A10_ENTRY_SQUEEZE) return g_squeeze.Brick();
   return 0.0;
  }

//+------------------------------------------------------------------+
CA10ExitModule *ModeExit(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return GetPointer(g_exit_breakout);
   if(mode==A10_ENTRY_REENTRY) return GetPointer(g_exit_reentry);
   if(mode==A10_ENTRY_MIDLINE) return GetPointer(g_exit_midline);
   if(mode==A10_ENTRY_SQUEEZE) return GetPointer(g_exit_squeeze);
   return NULL;
  }

//+------------------------------------------------------------------+
int ModeCooldownLeft(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return g_breakout.Cooldown();
   if(mode==A10_ENTRY_REENTRY) return g_reentry.Cooldown();
   if(mode==A10_ENTRY_MIDLINE) return g_midline.Cooldown();
   if(mode==A10_ENTRY_SQUEEZE) return g_squeeze.Cooldown();
   return 0;
  }

//+------------------------------------------------------------------+
void StartModeCooldown(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) g_breakout.StartCooldown();
   else if(mode==A10_ENTRY_REENTRY) g_reentry.StartCooldown();
   else if(mode==A10_ENTRY_MIDLINE) g_midline.StartCooldown();
   else if(mode==A10_ENTRY_SQUEEZE) g_squeeze.StartCooldown();
  }

//+------------------------------------------------------------------+
bool ModeSpreadIsAcceptable(const int mode,const MqlTick &tick)
  {
   double max_fraction=0.0;
   if(mode==A10_ENTRY_BREAKOUT) max_fraction=g_breakout.Spread();
   else if(mode==A10_ENTRY_REENTRY) max_fraction=g_reentry.Spread();
   else if(mode==A10_ENTRY_MIDLINE) max_fraction=g_midline.Spread();
   else if(mode==A10_ENTRY_SQUEEZE) max_fraction=g_squeeze.Spread();
   else return false;

   const double brick=ModeBrick(mode);
   if(brick<=0.0 || max_fraction<=0.0) return false;
   return ((tick.ask-tick.bid)<=brick*max_fraction);
  }

//+------------------------------------------------------------------+
double NormalizeVolume(const double requested)
  {
   double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);

   if(!MathIsValidNumber(requested) || requested<=0.0) return 0.0;
   if(!MathIsValidNumber(vmin) || !MathIsValidNumber(vmax) ||
      !MathIsValidNumber(step) || vmin<=0.0 || vmax<vmin) return 0.0;
   if(step<=0.0) step=vmin;
   if(step<=0.0) return 0.0;

   double volume=MathRound(requested/step)*step;
   volume=MathMax(vmin,MathMin(vmax,volume));
   volume=NormalizeDouble(volume,8);
   if(volume<vmin-1.0e-10 || volume>vmax+1.0e-10) return 0.0;
   return volume;
  }

//+------------------------------------------------------------------+
bool GetFillingMode(ENUM_ORDER_TYPE_FILLING &filling)
  {
   const long flags=SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);
   const ENUM_SYMBOL_TRADE_EXECUTION execution=(ENUM_SYMBOL_TRADE_EXECUTION)
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE);

   filling=ORDER_FILLING_FOK;
   if(execution==SYMBOL_TRADE_EXECUTION_INSTANT ||
      execution==SYMBOL_TRADE_EXECUTION_REQUEST) return true;
   if((flags & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) return true;
   if((flags & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)
     {
      filling=ORDER_FILLING_IOC;
      return true;
     }
   if(execution==SYMBOL_TRADE_EXECUTION_MARKET) return false;
   filling=ORDER_FILLING_RETURN;
   return true;
  }

//+------------------------------------------------------------------+
bool IsHedgingAccount(void)
  {
   return ((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }

//+------------------------------------------------------------------+
int EffectiveMaxPositions(void)
  {
   if(!IsHedgingAccount()) return 1;
   return MathMax(1,MathMin(4,InpMaxPositions));
  }

//+------------------------------------------------------------------+
// A10 NO_ORDERS virtual lifecycle state. Never represents a broker fill.
bool     g_v_open[4]={false,false,false,false};
int      g_v_dir[4]={0,0,0,0};
double   g_v_price[4]={0.0,0.0,0.0,0.0};
datetime g_v_time[4]={0,0,0,0};
ulong    g_v_ticket[4]={0,0,0,0};
ulong    g_v_next_ticket=1;
long     g_v_entries=0;
long     g_v_exits=0;
long     g_v_ticks=0;
long     g_v_entries_mode[4]={0,0,0,0};
long     g_v_exits_mode[4]={0,0,0,0};

//+------------------------------------------------------------------+
bool PositionExists(const ulong ticket)
  {
   if(ticket==0) return false;
   for(int mode=0;mode<4;mode++) if(g_v_open[mode] && g_v_ticket[mode]==ticket) return true;
   return false;
  }

//+------------------------------------------------------------------+
bool FindModePosition(const int wanted_mode,ulong &ticket,long &type,double &volume,
                      double &open_price,datetime &open_time,ulong &position_magic)
  {
   ticket=0; type=-1; volume=0.0; open_price=0.0; open_time=0; position_magic=0;
   if(wanted_mode<0 || wanted_mode>3 || !g_v_open[wanted_mode]) return false;
   ticket=g_v_ticket[wanted_mode];
   type=(g_v_dir[wanted_mode]>0 ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   volume=InpLots;
   open_price=g_v_price[wanted_mode];
   open_time=g_v_time[wanted_mode];
   position_magic=ModeMagic(wanted_mode);
   return true;
  }

//+------------------------------------------------------------------+
bool ModeHasPosition(const int mode)
  {
   return (mode>=0 && mode<4 && g_v_open[mode]);
  }

//+------------------------------------------------------------------+
int CountOurPositions(void)
  {
   int count=0;
   for(int mode=0;mode<4;mode++) if(g_v_open[mode]) count++;
   return count;
  }

//+------------------------------------------------------------------+
bool ExternalPositionOnSymbol(void)
  {
   return false; // NO_ORDERS harness intentionally ignores broker positions.
  }

//+------------------------------------------------------------------+
bool ValidTick(const MqlTick &tick)
  {
   return MathIsValidNumber(tick.bid) && MathIsValidNumber(tick.ask) &&
          tick.bid>0.0 && tick.ask>=tick.bid && tick.time>0;
  }

//+------------------------------------------------------------------+
int SecondsOfDay(const datetime value)
  {
   MqlDateTime part={};
   if(!TimeToStruct(value,part)) return -1;
   return part.hour*3600+part.min*60+part.sec;
  }

//+------------------------------------------------------------------+
datetime TradingSessionEnd(const datetime now)
  {
   MqlDateTime current={};
   if(now<=0 || !TimeToStruct(now,current)) return 0;
   const int seconds=current.hour*3600+current.min*60+current.sec;
   const datetime midnight=now-seconds;

   for(int offset=0;offset<=1;offset++)
     {
      const ENUM_DAY_OF_WEEK day=(ENUM_DAY_OF_WEEK)
         ((current.day_of_week-offset+7)%7);
      for(uint session=0;session<24;session++)
        {
         datetime from=0,to=0;
         if(!SymbolInfoSessionTrade(_Symbol,day,session,from,to)) break;
         const int start_seconds=SecondsOfDay(from);
         const int end_seconds=SecondsOfDay(to);
         if(start_seconds<0 || end_seconds<0) continue;

         const datetime start=midnight-offset*86400+start_seconds;
         datetime end=midnight-offset*86400+end_seconds;
         if(end<=start) end+=86400;
         if(now>=start && now<end) return end;
        }
     }
   return 0;
  }

//+------------------------------------------------------------------+
bool TradingSessionIsOpen(const datetime when=0)
  {
   return TradingSessionEnd(when>0 ? when : TimeCurrent())>0;
  }

//+------------------------------------------------------------------+
bool HasActiveOrder(const bool only_ours)
  {
   return false; // NO_ORDERS: no broker orders are ever created.
  }

bool     g_exit_pending[4];
string   g_exit_reason[4];
ulong    g_exit_ticket[4];
int      g_pending_entry_dir[4];
datetime g_pending_entry_time[4];
bool     g_request_this_tick=false;
datetime g_retry_after=0;
datetime g_request_session_end=0;
int      g_request_failures=0;
ulong    g_wait_order=0;
bool     g_execution_uncertain=false;
bool     g_uncertain_exit=false;
int      g_uncertain_mode=-1;
ulong    g_uncertain_ticket=0;
const int GDS_MAX_REQUEST_FAILURES=3;
const int GDS_ENTRY_QUEUE_TTL=120;

//+------------------------------------------------------------------+
bool AnyPendingExit(void)
  {
   for(int mode=0;mode<4;mode++) if(g_exit_pending[mode]) return true;
   return false;
  }

//+------------------------------------------------------------------+
int PendingEntryCount(void)
  {
   int count=0;
   for(int mode=0;mode<4;mode++) if(g_pending_entry_dir[mode]!=0) count++;
   return count;
  }

//+------------------------------------------------------------------+
void ClearPendingEntry(const int mode)
  {
   if(mode<0 || mode>3) return;
   g_pending_entry_dir[mode]=0;
   g_pending_entry_time[mode]=0;
  }

//+------------------------------------------------------------------+
void MarkExitCompleted(const int mode)
  {
   if(mode<0 || mode>3) return;
   StartModeCooldown(mode);
   g_exit_pending[mode]=false;
   g_exit_reason[mode]="";
   g_exit_ticket[mode]=0;
  }

//+------------------------------------------------------------------+
bool ResolveExecution(void)
  {
   return true; // Virtual lifecycle is synchronous in this baseline harness.
  }

//+------------------------------------------------------------------+
bool RequestWindowIsOpen(void)
  {
   if(g_request_this_tick || !ResolveExecution()) return false;
   if(!TerminalInfoInteger(TERMINAL_CONNECTED) ||
      !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ||
      !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return false;

   const datetime now=TimeCurrent();
   const datetime end=TradingSessionEnd(now);
   if(end<=0) return false;

   if(g_request_session_end!=end)
     {
      g_request_session_end=end;
      g_request_failures=0;
      g_retry_after=0;
     }
   return now>=g_retry_after;
  }

//+------------------------------------------------------------------+
void RegisterFailure(const uint retcode,const string details)
  {
   g_request_failures++;
   const datetime now=TimeCurrent();
   const datetime end=TradingSessionEnd(now);

   if(retcode==TRADE_RETCODE_MARKET_CLOSED ||
      g_request_failures>=GDS_MAX_REQUEST_FAILURES)
      g_retry_after=(end>now ? end : now+300);
   else
      g_retry_after=now+(g_request_failures==1 ? 5 : 30);

   Print("GDS Renko Bollinger 4-Mode: request deferred. Retcode ",retcode,
         ", ",details,", next attempt no earlier than ",
         TimeToString(g_retry_after,TIME_DATE|TIME_SECONDS));
  }

//+------------------------------------------------------------------+
bool SubmitDeal(MqlTradeRequest &request,const bool is_exit,const int owner_mode,const ulong position_ticket=0)
  {
   Print("[A10_NOORDERS_GUARD] SubmitDeal blocked. NO_ORDERS=1");
   return false;
  }

//+------------------------------------------------------------------+
bool TradeModeAllowsEntry(const int direction)
  {
   const ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(mode==SYMBOL_TRADE_MODE_DISABLED || mode==SYMBOL_TRADE_MODE_CLOSEONLY) return false;
   if(mode==SYMBOL_TRADE_MODE_LONGONLY && direction<0) return false;
   if(mode==SYMBOL_TRADE_MODE_SHORTONLY && direction>0) return false;
   return true;
  }

//+------------------------------------------------------------------+
bool TradeModeAllowsClose(void)
  {
   const ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   return (mode!=SYMBOL_TRADE_MODE_DISABLED);
  }

//+------------------------------------------------------------------+
void RequestExit(const string reason,const int owner_mode,const ulong ticket)
  {
   if(owner_mode<0 || owner_mode>3 || ticket==0) return;
   if(!g_exit_pending[owner_mode])
     {
      g_exit_reason[owner_mode]=reason;
      g_exit_ticket[owner_mode]=ticket;
     }
   g_exit_pending[owner_mode]=true;
   ClearPendingEntry(owner_mode);
  }

//+------------------------------------------------------------------+
bool SendMarket(const int direction,const int owner_mode)
  {
   if(direction!=1 && direction!=-1) return false;
   if(owner_mode<0 || owner_mode>3 || !ModeEnabled(owner_mode)) return false;
   if(AnyPendingExit() || ModeHasPosition(owner_mode)) return false;
   if(CountOurPositions()>=EffectiveMaxPositions()) return false;
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !ValidTick(tick)) return false;
   if(!ModeSpreadIsAcceptable(owner_mode,tick)) return false;
   g_v_open[owner_mode]=true;
   g_v_dir[owner_mode]=direction;
   g_v_price[owner_mode]=(direction>0 ? tick.ask : tick.bid);
   g_v_time[owner_mode]=TimeCurrent();
   g_v_ticket[owner_mode]=g_v_next_ticket++;
   g_v_entries++; g_v_entries_mode[owner_mode]++;
   Print("[A10_NOORDERS_ENTRY] mode=",ModeName(owner_mode)," dir=",(direction>0?"BUY":"SELL"),
         " price=",DoubleToString(g_v_price[owner_mode],_Digits)," ticket=",g_v_ticket[owner_mode],
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return true;
  }

//+------------------------------------------------------------------+
bool ClosePositionByTicket(const int owner_mode,const ulong ticket,const string reason)
  {
   if(owner_mode<0 || owner_mode>3 || !g_v_open[owner_mode] || g_v_ticket[owner_mode]!=ticket)
     { MarkExitCompleted(owner_mode); return true; }
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !ValidTick(tick)) return false;
   const double px=(g_v_dir[owner_mode]>0 ? tick.bid : tick.ask);
   Print("[A10_NOORDERS_EXIT] mode=",ModeName(owner_mode)," reason=",reason,
         " price=",DoubleToString(px,_Digits)," ticket=",ticket,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   g_v_open[owner_mode]=false; g_v_dir[owner_mode]=0; g_v_price[owner_mode]=0.0;
   g_v_time[owner_mode]=0; g_v_ticket[owner_mode]=0;
   g_v_exits++; g_v_exits_mode[owner_mode]++;
   MarkExitCompleted(owner_mode);
   return true;
  }

//+------------------------------------------------------------------+
void TryPendingExit(void)
  {
   for(int mode=0;mode<4;mode++)
     {
      if(!g_exit_pending[mode]) continue;
      const ulong ticket=g_exit_ticket[mode];
      if(ticket==0 || !PositionExists(ticket)) { MarkExitCompleted(mode); continue; }
      ClosePositionByTicket(mode,ticket,g_exit_reason[mode]);
      return;
     }
  }

//+------------------------------------------------------------------+
void CheckPriceExits(const MqlTick &tick)
  {
   for(int owner=0;owner<4;owner++)
     {
      if(!g_v_open[owner] || g_exit_pending[owner]) continue;
      CA10ExitModule *ex=ModeExit(owner); if(ex==NULL) continue;
      SA10ExitDecision d={};
      ex.CheckPrice(g_v_dir[owner],g_v_price[owner],g_v_time[owner],
                    tick.bid,tick.ask,TimeCurrent(),ModeBrick(owner),d);
      if(d.exit) RequestExit(ex.ReasonText(d.reason),owner,g_v_ticket[owner]);
     }
  }

//+------------------------------------------------------------------+
void ProcessOwnerSignalExit(const int owner,const SA10EntryResult &result)
  {
   if(result.completed<=0 || owner<0 || owner>3 || g_exit_pending[owner] || !g_v_open[owner]) return;
   CA10ExitModule *ex=ModeExit(owner); if(ex==NULL) return;
   SA10ExitDecision d={};
   ex.CheckSignal(owner,g_v_dir[owner],result.completed,result.raw_signal,result.bb_ready,
                  result.final_close,result.bb_mid,d);
   if(d.exit) RequestExit(ex.ReasonText(d.reason),owner,g_v_ticket[owner]);
  }

//+------------------------------------------------------------------+
void QueueNewSignals(const int &signals[],const MqlTick &tick)
  {
   bool candidate[4]={false,false,false,false};
   bool long_signal=false;
   bool short_signal=false;

   for(int mode=0;mode<4;mode++)
     {
      if(!ModeEnabled(mode) || ModeCooldownLeft(mode)>0 || signals[mode]==0) continue;
      if(ModeHasPosition(mode) || g_pending_entry_dir[mode]!=0 || g_exit_pending[mode]) continue;
      if(!ModeSpreadIsAcceptable(mode,tick)) continue;
      candidate[mode]=true;
      if(signals[mode]>0) long_signal=true;
      if(signals[mode]<0) short_signal=true;
     }

   if(InpSkipOppositeSignals && long_signal && short_signal)
     {
      Print("GDS Renko Bollinger: opposite mode signals on the same tick; new entries skipped by input setting.");
      return;
     }

   int free_slots=EffectiveMaxPositions()-CountOurPositions()-PendingEntryCount();
   if(free_slots<=0) return;

   // Deterministic queue priority: Breakout -> Re-entry -> Midline -> Squeeze.
   for(int mode=0;mode<4 && free_slots>0;mode++)
     {
      if(!candidate[mode]) continue;
      g_pending_entry_dir[mode]=signals[mode];
      g_pending_entry_time[mode]=TimeCurrent();
      free_slots--;
     }
  }

//+------------------------------------------------------------------+
void TryPendingEntry(const MqlTick &tick)
  {
   if(AnyPendingExit() || HasActiveOrder(false) || ExternalPositionOnSymbol()) return;
   if(CountOurPositions()>=EffectiveMaxPositions()) return;

   const datetime now=TimeCurrent();
   for(int mode=0;mode<4;mode++)
     {
      const int direction=g_pending_entry_dir[mode];
      if(direction==0) continue;

      if(g_pending_entry_time[mode]>0 && now-g_pending_entry_time[mode]>GDS_ENTRY_QUEUE_TTL)
        {
         ClearPendingEntry(mode);
         continue;
        }
      if(!ModeEnabled(mode) || ModeCooldownLeft(mode)>0 || ModeHasPosition(mode))
        {
         ClearPendingEntry(mode);
         continue;
        }
      if(!ModeSpreadIsAcceptable(mode,tick)) continue;
      if(!TradeModeAllowsEntry(direction)) continue;

      if(SendMarket(direction,mode)) ClearPendingEntry(mode);
      return; // One trade request per tick; remaining queued modes are handled on following ticks.
     }
  }

//+------------------------------------------------------------------+
void UpdateAllModesAndTrade(const double price,const MqlTick &tick)
  {
   SA10EntryResult r0={};
   SA10EntryResult r1={};
   SA10EntryResult r2={};
   SA10EntryResult r3={};

   g_breakout.PushPrice(price,r0);
   g_reentry.PushPrice(price,r1);
   g_midline.PushPrice(price,r2);
   g_squeeze.PushPrice(price,r3);

   ProcessOwnerSignalExit(A10_ENTRY_BREAKOUT,r0);
   ProcessOwnerSignalExit(A10_ENTRY_REENTRY,r1);
   ProcessOwnerSignalExit(A10_ENTRY_MIDLINE,r2);
   ProcessOwnerSignalExit(A10_ENTRY_SQUEEZE,r3);

   if(AnyPendingExit()) return;

   int signals[4]={r0.signal,r1.signal,r2.signal,r3.signal};
   QueueNewSignals(signals,tick);
   TryPendingEntry(tick);
  }

//+------------------------------------------------------------------+
int OnInit(void)
  {
   if(!MathIsValidNumber(InpLots) || InpLots<=0.0 || InpMagic==0 ||
      InpMaxPositions<1 || InpMaxPositions>4)
     {
      Print("GDS Renko Bollinger 4-Mode: invalid common inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!InpBreakoutEnabled && !InpReentryEnabled && !InpMidlineEnabled && !InpSqueezeEnabled)
     {
      Print("GDS Renko Bollinger 4-Mode: enable at least one strategy mode.");
      return INIT_PARAMETERS_INCORRECT;
     }

   const double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(!MathIsValidNumber(tick_size) || tick_size<=0.0)
     {
      Print("GDS Bollinger: symbol tick size unavailable.");
      return INIT_FAILED;
     }

   const double effective_volume=NormalizeVolume(InpLots);
   if(effective_volume<=0.0)
     {
      Print("GDS Bollinger: symbol volume settings unavailable or invalid.");
      return INIT_FAILED;
     }

   if(!g_breakout.Configure(InpBreakoutEnabled,A10_ENTRY_BREAKOUT,tick_size,InpBreakoutBrickSize,InpBreakoutBBPeriod,InpBreakoutDeviation,1.0,InpBreakoutEntryRun,InpBreakoutCooldown,InpBreakoutMaxSpread) ||
      !g_reentry.Configure(InpReentryEnabled,A10_ENTRY_REENTRY,tick_size,InpReentryBrickSize,InpReentryBBPeriod,InpReentryDeviation,1.0,InpReentryEntryRun,InpReentryCooldown,InpReentryMaxSpread) ||
      !g_midline.Configure(InpMidlineEnabled,A10_ENTRY_MIDLINE,tick_size,InpMidlineBrickSize,InpMidlineBBPeriod,InpMidlineDeviation,1.0,InpMidlineEntryRun,InpMidlineCooldown,InpMidlineMaxSpread) ||
      !g_squeeze.Configure(InpSqueezeEnabled,A10_ENTRY_SQUEEZE,tick_size,InpSqueezeBrickSize,InpSqueezeBBPeriod,InpSqueezeDeviation,InpSqueezeMaxWidth,InpSqueezeEntryRun,InpSqueezeCooldown,InpSqueezeMaxSpread))
     {
      Print("GDS Renko Bollinger 4-Mode: invalid enabled-mode inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!g_exit_breakout.Configure(InpBreakoutTP,InpBreakoutSL,InpBreakoutMaxHold) ||
      !g_exit_reentry.Configure(InpReentryTP,InpReentrySL,InpReentryMaxHold) ||
      !g_exit_midline.Configure(InpMidlineTP,InpMidlineSL,InpMidlineMaxHold) ||
      !g_exit_squeeze.Configure(InpSqueezeTP,InpSqueezeSL,InpSqueezeMaxHold))
     {
      Print("A10 separated exit module: invalid inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   for(int mode=0;mode<4;mode++)
     {
      g_exit_pending[mode]=false;
      g_exit_reason[mode]="";
      g_exit_ticket[mode]=0;
      g_pending_entry_dir[mode]=0;
      g_pending_entry_time[mode]=0;
     }
   g_request_this_tick=false;
   g_retry_after=0;
   g_request_session_end=0;
   g_request_failures=0;
   g_wait_order=0;
   g_execution_uncertain=false;
   g_uncertain_exit=false;
   g_uncertain_mode=-1;
   g_uncertain_ticket=0;

   for(int vm=0;vm<4;vm++)
     { g_v_open[vm]=false; g_v_dir[vm]=0; g_v_price[vm]=0.0; g_v_time[vm]=0; g_v_ticket[vm]=0; g_v_entries_mode[vm]=0; g_v_exits_mode[vm]=0; }
   g_v_next_ticket=1; g_v_entries=0; g_v_exits=0; g_v_ticks=0;
   Print("[A10_SPLIT_PARITY_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   Print("A10 Core NoOrders v1.00 started. EffectiveLots=",DoubleToString(effective_volume,2),
         ", MaxPositions=",EffectiveMaxPositions(),
         ", SkipOppositeSameTick=",(InpSkipOppositeSignals ? "ON" : "OFF"),
         ", Account=",(IsHedgingAccount() ? "HEDGING" : "NETTING"),
         ", Breakout=",(InpBreakoutEnabled ? "ON" : "OFF"),
         ", Re-entry=",(InpReentryEnabled ? "ON" : "OFF"),
         ", Midline=",(InpMidlineEnabled ? "ON" : "OFF"),
         ", Squeeze=",(InpSqueezeEnabled ? "ON" : "OFF"));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Print("[A10_SPLIT_PARITY_SUMMARY] ticks=",g_v_ticks," entries=",g_v_entries," exits=",g_v_exits,
         " open=",CountOurPositions(),
         " breakout_entries=",g_v_entries_mode[0]," breakout_exits=",g_v_exits_mode[0],
         " reentry_entries=",g_v_entries_mode[1]," reentry_exits=",g_v_exits_mode[1],
         " midline_entries=",g_v_entries_mode[2]," midline_exits=",g_v_exits_mode[2],
         " squeeze_entries=",g_v_entries_mode[3]," squeeze_exits=",g_v_exits_mode[3],
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  }

//+------------------------------------------------------------------+
void OnTick(void)
  {
   g_v_ticks++;
   g_request_this_tick=false;
   ResolveExecution();

   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !ValidTick(tick)) return;

   // Exits always have priority over new entries.
   TryPendingExit();
   CheckPriceExits(tick);
   TryPendingExit();

   // Every enabled mode receives the same BID tick, but builds its own Renko stream.
   UpdateAllModesAndTrade(tick.bid,tick);

   // Completed-brick mode logic may request an exit now.
   TryPendingExit();
   if(!AnyPendingExit()) TryPendingEntry(tick);
  }
//+------------------------------------------------------------------+
