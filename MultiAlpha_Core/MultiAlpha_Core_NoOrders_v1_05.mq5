//+------------------------------------------------------------------+
//| MultiAlpha_Core_NoOrders_v1_05.mq5                              |
//| Unified A10/A11/A12/A13/A15/A16 host using MultiAlpha interface.     |
//| Research only. NO ORDERS. Select Alpha with InpAlpha.            |
//+------------------------------------------------------------------+
#property strict

#include "..\\..\\Include\\MultiAlpha_Interface_v1_00.mqh"
#include "..\\..\\Include\\A10_Entry_Module_v1_00.mqh"
#include "..\\..\\Include\\A10_Exit_Module_v1_00.mqh"
#include "..\\..\\Include\\A11_MA_Cross_Module_v1_00.mqh"
#include "..\\..\\Include\\A12_Entry_Module.mqh"
#include "..\\..\\Include\\A13_Dual_MA_Module_v1_00.mqh"
#include "..\\..\\Include\\A15_Entry_Module_v1_00.mqh"
#include "..\\..\\Include\\A15_Exit_Decision_Module_v1_00.mqh"
#include "..\\..\\Include\\Alpha_Template_v1_00.mqh"

input ENUM_MULTI_ALPHA_ID InpAlpha=ALPHA_A15;

// A10 parameters (verified original defaults)
input group "Common execution"
input double InpA10Lots                  = 0.01;       // Requested fixed lot
input ulong  InpA10Magic                 = 26091150;   // Base magic; four mode magics are Base+1...Base+4
input int    InpA10MaxPositions          = 4;          // Maximum simultaneous GDS positions (1..4)
input bool   InpA10SkipOppositeSignals   = true;       // Safety filter: skip new same-tick entries when modes disagree

// -------------------------------------------------------------------
// Mode 1: Breakout - real-tick verified profile
// -------------------------------------------------------------------
input group "1. Breakout"
input bool   InpA10BreakoutEnabled       = true;       // Enable Breakout mode
input double InpA10BreakoutBrickSize     = 17.0;       // Renko brick size
input int    InpA10BreakoutBBPeriod      = 20;         // Bollinger period
input double InpA10BreakoutDeviation     = 1.0;        // Bollinger deviation
input int    InpA10BreakoutEntryRun      = 2;          // Minimum same-direction Renko run
input double InpA10BreakoutTP            = 24.0;       // Virtual TP, bricks
input double InpA10BreakoutSL            = 42.0;       // Virtual SL, bricks
input int    InpA10BreakoutMaxHold       = 1230;       // Maximum hold, minutes
input int    InpA10BreakoutCooldown      = 5;          // Cooldown after exit, completed mode bricks
input double InpA10BreakoutMaxSpread     = 0.35;       // Max spread / mode brick size

// -------------------------------------------------------------------
// Mode 2: Re-entry / Mean Reversion - real-tick verified profile
// -------------------------------------------------------------------
input group "2. Re-entry / Mean Reversion"
input bool   InpA10ReentryEnabled        = true;       // Enable Re-entry mode
input double InpA10ReentryBrickSize      = 30.0;       // Renko brick size
input int    InpA10ReentryBBPeriod       = 31;         // Bollinger period
input double InpA10ReentryDeviation      = 1.2;        // Bollinger deviation
input int    InpA10ReentryEntryRun       = 1;          // Minimum same-direction Renko run
input double InpA10ReentryTP             = 28.0;       // Virtual TP, bricks
input double InpA10ReentrySL             = 48.5;       // Virtual SL, bricks
input int    InpA10ReentryMaxHold        = 2580;       // Maximum hold, minutes
input int    InpA10ReentryCooldown       = 3;          // Cooldown after exit, completed mode bricks
input double InpA10ReentryMaxSpread      = 0.35;       // Max spread / mode brick size

// -------------------------------------------------------------------
// Mode 3: Midline Cross - real-tick verified profile
// -------------------------------------------------------------------
input group "3. Midline Cross"
input bool   InpA10MidlineEnabled        = true;       // Enable Midline Cross mode
input double InpA10MidlineBrickSize      = 30.0;       // Renko brick size
input int    InpA10MidlineBBPeriod       = 5;          // Bollinger period
input double InpA10MidlineDeviation      = 3.0;        // Bollinger deviation
input int    InpA10MidlineEntryRun       = 1;          // Minimum same-direction Renko run
input double InpA10MidlineTP             = 10.0;       // Virtual TP, bricks
input double InpA10MidlineSL             = 34.5;       // Virtual SL, bricks
input int    InpA10MidlineMaxHold        = 2220;       // Maximum hold, minutes
input int    InpA10MidlineCooldown       = 3;          // Cooldown after exit, completed mode bricks
input double InpA10MidlineMaxSpread      = 0.35;       // Max spread / mode brick size

// -------------------------------------------------------------------
// Mode 4: Squeeze Breakout - real-tick verified profile
// -------------------------------------------------------------------
input group "4. Squeeze Breakout"
input bool   InpA10SqueezeEnabled        = true;       // Enable Squeeze Breakout mode
input double InpA10SqueezeBrickSize      = 14.0;       // Renko brick size
input int    InpA10SqueezeBBPeriod       = 18;         // Bollinger period
input double InpA10SqueezeDeviation      = 2.4;        // Bollinger deviation
input double InpA10SqueezeMaxWidth       = 34.5;       // Maximum full band width, in bricks
input int    InpA10SqueezeEntryRun       = 1;          // Minimum same-direction Renko run
input double InpA10SqueezeTP             = 26.0;       // Virtual TP, bricks
input double InpA10SqueezeSL             = 31.0;       // Virtual SL, bricks
input int    InpA10SqueezeMaxHold        = 2050;       // Maximum hold, minutes
input int    InpA10SqueezeCooldown       = 1;          // Cooldown after exit, completed mode bricks
input double InpA10SqueezeMaxSpread      = 0.35;       // Max spread / mode brick size

// A11 parameters (verified original defaults)
input group "A11 MA Cross"
input ENUM_MA_METHOD InpA11MAMethod=MODE_EMA;
input int InpA11FastPeriod=100;
input int InpA11SlowPeriod=200;
input bool InpA11UseMAFilter=false;
input ENUM_MA_METHOD InpA11FilterMethod=MODE_SMA;
input ENUM_TIMEFRAMES InpA11FilterTimeframe=PERIOD_D1;
input int InpA11FilterPeriod=100;
input double InpA11TakeProfit=0.0;
input double InpA11StopLoss=0.0;
input bool InpA11UseFastMAExit=false;
input double InpA11MaxLotSize=0.1;
input double InpA11MinEquity=100.0;
input int InpA11MagicNumber=889;

// A12 parameters
input double InpA12BrickSize=16.0;
input int    InpA12ADXPeriod=14;
input double InpA12ADXThreshold=8.5;
input double InpA12MinDISeparation=2.5;
input int    InpA12EntryRunBricks=3;
input double InpA12TakeProfitBricks=9.5;
input double InpA12StopLossBricks=42.0;
input int    InpA12MaxHoldMinutes=1060;

// A13 parameters (verified original defaults)
input group "A13 Renko Dual MA"
input double InpA13BrickSize=6.0;
input int InpA13FastMAPeriod=9;
input int InpA13SlowMAPeriod=152;
input double InpA13MinMASeparationBricks=4.15;
input int InpA13EntryRunBricks=2;
input double InpA13TakeProfitBricks=55.0;
input double InpA13StopLossBricks=32.0;
input int InpA13MaxHoldMinutes=1440;
input int InpA13CooldownBricks=16;
input double InpA13MaxSpreadFraction=0.35;

// A15 parameters
input double InpA15BrickSize=14.0;
input double InpA15TakeProfitBricks=8.0;
input double InpA15StopLossBricks=8.2;
input int    InpA15MaxHoldMinutes=4935;
input int    InpA15DonchianPeriod=25;
input double InpA15BreakoutBufferBricks=0.20;
input int    InpA15EntryRunBricks=1;

// Common host gates
input int    InpCooldownBricks=6;
input double InpMaxSpreadFraction=0.35;

SMultiAlphaPosition g_position;
int  g_cooldown=0;
bool g_failed=false;
long g_ticks=0,g_bricks=0,g_raw=0,g_entries=0,g_exits=0,g_blocks=0,g_spread_blocks=0;

// A10 state / lifecycle (four independent virtual mode positions)

CA10EntryModule a10_breakout;
CA10EntryModule a10_reentry;
CA10EntryModule a10_midline;
CA10EntryModule a10_squeeze;

CA10ExitModule a10_exit_breakout;
CA10ExitModule a10_exit_reentry;
CA10ExitModule a10_exit_midline;
CA10ExitModule a10_exit_squeeze;

//+------------------------------------------------------------------+
ulong A10_ModeMagic(const int mode)
  {
   return InpA10Magic+(ulong)(mode+1);
  }

//+------------------------------------------------------------------+
bool A10_IsOurMagic(const ulong magic,int &mode)
  {
   for(int i=0;i<4;i++)
     {
      if(magic==A10_ModeMagic(i))
        {
         mode=i;
         return true;
        }
     }
   mode=-1;
   return false;
  }

//+------------------------------------------------------------------+
string A10_ModeName(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return "Breakout";
   if(mode==A10_ENTRY_REENTRY) return "Re-entry";
   if(mode==A10_ENTRY_MIDLINE) return "Midline";
   if(mode==A10_ENTRY_SQUEEZE) return "Squeeze";
   return "Unknown";
  }

//+------------------------------------------------------------------+
bool A10_ModeEnabled(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return a10_breakout.Enabled();
   if(mode==A10_ENTRY_REENTRY) return a10_reentry.Enabled();
   if(mode==A10_ENTRY_MIDLINE) return a10_midline.Enabled();
   if(mode==A10_ENTRY_SQUEEZE) return a10_squeeze.Enabled();
   return false;
  }

//+------------------------------------------------------------------+
double A10_ModeBrick(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return a10_breakout.Brick();
   if(mode==A10_ENTRY_REENTRY) return a10_reentry.Brick();
   if(mode==A10_ENTRY_MIDLINE) return a10_midline.Brick();
   if(mode==A10_ENTRY_SQUEEZE) return a10_squeeze.Brick();
   return 0.0;
  }

//+------------------------------------------------------------------+
CA10ExitModule *A10_ModeExit(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return GetPointer(a10_exit_breakout);
   if(mode==A10_ENTRY_REENTRY) return GetPointer(a10_exit_reentry);
   if(mode==A10_ENTRY_MIDLINE) return GetPointer(a10_exit_midline);
   if(mode==A10_ENTRY_SQUEEZE) return GetPointer(a10_exit_squeeze);
   return NULL;
  }

//+------------------------------------------------------------------+
int A10_ModeCooldownLeft(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) return a10_breakout.Cooldown();
   if(mode==A10_ENTRY_REENTRY) return a10_reentry.Cooldown();
   if(mode==A10_ENTRY_MIDLINE) return a10_midline.Cooldown();
   if(mode==A10_ENTRY_SQUEEZE) return a10_squeeze.Cooldown();
   return 0;
  }

//+------------------------------------------------------------------+
void A10_StartModeCooldown(const int mode)
  {
   if(mode==A10_ENTRY_BREAKOUT) a10_breakout.StartCooldown();
   else if(mode==A10_ENTRY_REENTRY) a10_reentry.StartCooldown();
   else if(mode==A10_ENTRY_MIDLINE) a10_midline.StartCooldown();
   else if(mode==A10_ENTRY_SQUEEZE) a10_squeeze.StartCooldown();
  }

//+------------------------------------------------------------------+
bool A10_ModeSpreadIsAcceptable(const int mode,const MqlTick &tick)
  {
   double max_fraction=0.0;
   if(mode==A10_ENTRY_BREAKOUT) max_fraction=a10_breakout.Spread();
   else if(mode==A10_ENTRY_REENTRY) max_fraction=a10_reentry.Spread();
   else if(mode==A10_ENTRY_MIDLINE) max_fraction=a10_midline.Spread();
   else if(mode==A10_ENTRY_SQUEEZE) max_fraction=a10_squeeze.Spread();
   else return false;

   const double brick=A10_ModeBrick(mode);
   if(brick<=0.0 || max_fraction<=0.0) return false;
   return ((tick.ask-tick.bid)<=brick*max_fraction);
  }

//+------------------------------------------------------------------+
double A10_NormalizeVolume(const double requested)
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
bool A10_GetFillingMode(ENUM_ORDER_TYPE_FILLING &filling)
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
bool A10_IsHedgingAccount(void)
  {
   return ((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING);
  }

//+------------------------------------------------------------------+
int A10_EffectiveMaxPositions(void)
  {
   if(!A10_IsHedgingAccount()) return 1;
   return MathMax(1,MathMin(4,InpA10MaxPositions));
  }

//+------------------------------------------------------------------+
// A10 NO_ORDERS virtual lifecycle state. Never represents a broker fill.
bool     a10_v_open[4]={false,false,false,false};
int      a10_v_dir[4]={0,0,0,0};
double   a10_v_price[4]={0.0,0.0,0.0,0.0};
datetime a10_v_time[4]={0,0,0,0};
ulong    a10_v_ticket[4]={0,0,0,0};
ulong    a10_v_next_ticket=1;
long     a10_v_entries=0;
long     a10_v_exits=0;
long     a10_v_ticks=0;
long     a10_v_entries_mode[4]={0,0,0,0};
long     a10_v_exits_mode[4]={0,0,0,0};

//+------------------------------------------------------------------+
bool A10_PositionExists(const ulong ticket)
  {
   if(ticket==0) return false;
   for(int mode=0;mode<4;mode++) if(a10_v_open[mode] && a10_v_ticket[mode]==ticket) return true;
   return false;
  }

//+------------------------------------------------------------------+
bool A10_FindModePosition(const int wanted_mode,ulong &ticket,long &type,double &volume,
                      double &open_price,datetime &open_time,ulong &position_magic)
  {
   ticket=0; type=-1; volume=0.0; open_price=0.0; open_time=0; position_magic=0;
   if(wanted_mode<0 || wanted_mode>3 || !a10_v_open[wanted_mode]) return false;
   ticket=a10_v_ticket[wanted_mode];
   type=(a10_v_dir[wanted_mode]>0 ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
   volume=InpA10Lots;
   open_price=a10_v_price[wanted_mode];
   open_time=a10_v_time[wanted_mode];
   position_magic=A10_ModeMagic(wanted_mode);
   return true;
  }

//+------------------------------------------------------------------+
bool A10_ModeHasPosition(const int mode)
  {
   return (mode>=0 && mode<4 && a10_v_open[mode]);
  }

//+------------------------------------------------------------------+
int A10_CountOurPositions(void)
  {
   int count=0;
   for(int mode=0;mode<4;mode++) if(a10_v_open[mode]) count++;
   return count;
  }

//+------------------------------------------------------------------+
bool A10_ExternalPositionOnSymbol(void)
  {
   return false; // NO_ORDERS harness intentionally ignores broker positions.
  }

//+------------------------------------------------------------------+
bool A10_ValidTick(const MqlTick &tick)
  {
   return MathIsValidNumber(tick.bid) && MathIsValidNumber(tick.ask) &&
          tick.bid>0.0 && tick.ask>=tick.bid && tick.time>0;
  }

//+------------------------------------------------------------------+
int A10_SecondsOfDay(const datetime value)
  {
   MqlDateTime part={};
   if(!TimeToStruct(value,part)) return -1;
   return part.hour*3600+part.min*60+part.sec;
  }

//+------------------------------------------------------------------+
datetime A10_TradingSessionEnd(const datetime now)
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
         const int start_seconds=A10_SecondsOfDay(from);
         const int end_seconds=A10_SecondsOfDay(to);
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
bool A10_TradingSessionIsOpen(const datetime when=0)
  {
   return A10_TradingSessionEnd(when>0 ? when : TimeCurrent())>0;
  }

//+------------------------------------------------------------------+
bool A10_HasActiveOrder(const bool only_ours)
  {
   return false; // NO_ORDERS: no broker orders are ever created.
  }

bool     a10_exit_pending[4];
string   a10_exit_reason[4];
ulong    a10_exit_ticket[4];
int      a10_pending_entry_dir[4];
datetime a10_pending_entry_time[4];
bool     a10_request_this_tick=false;
datetime a10_retry_after=0;
datetime a10_request_session_end=0;
int      a10_request_failures=0;
ulong    a10_wait_order=0;
bool     a10_execution_uncertain=false;
bool     a10_uncertain_exit=false;
int      a10_uncertain_mode=-1;
ulong    a10_uncertain_ticket=0;
const int A10_MAX_REQUEST_FAILURES=3;
const int A10_ENTRY_QUEUE_TTL=120;

//+------------------------------------------------------------------+
bool A10_AnyPendingExit(void)
  {
   for(int mode=0;mode<4;mode++) if(a10_exit_pending[mode]) return true;
   return false;
  }

//+------------------------------------------------------------------+
int A10_PendingEntryCount(void)
  {
   int count=0;
   for(int mode=0;mode<4;mode++) if(a10_pending_entry_dir[mode]!=0) count++;
   return count;
  }

//+------------------------------------------------------------------+
void A10_ClearPendingEntry(const int mode)
  {
   if(mode<0 || mode>3) return;
   a10_pending_entry_dir[mode]=0;
   a10_pending_entry_time[mode]=0;
  }

//+------------------------------------------------------------------+
void A10_MarkExitCompleted(const int mode)
  {
   if(mode<0 || mode>3) return;
   A10_StartModeCooldown(mode);
   a10_exit_pending[mode]=false;
   a10_exit_reason[mode]="";
   a10_exit_ticket[mode]=0;
  }

//+------------------------------------------------------------------+
bool A10_ResolveExecution(void)
  {
   return true; // Virtual lifecycle is synchronous in this baseline harness.
  }

//+------------------------------------------------------------------+
bool A10_RequestWindowIsOpen(void)
  {
   if(a10_request_this_tick || !A10_ResolveExecution()) return false;
   if(!TerminalInfoInteger(TERMINAL_CONNECTED) ||
      !TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ||
      !MQLInfoInteger(MQL_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_ALLOWED) ||
      !AccountInfoInteger(ACCOUNT_TRADE_EXPERT)) return false;

   const datetime now=TimeCurrent();
   const datetime end=A10_TradingSessionEnd(now);
   if(end<=0) return false;

   if(a10_request_session_end!=end)
     {
      a10_request_session_end=end;
      a10_request_failures=0;
      a10_retry_after=0;
     }
   return now>=a10_retry_after;
  }

//+------------------------------------------------------------------+
void A10_RegisterFailure(const uint retcode,const string details)
  {
   a10_request_failures++;
   const datetime now=TimeCurrent();
   const datetime end=A10_TradingSessionEnd(now);

   if(retcode==TRADE_RETCODE_MARKET_CLOSED ||
      a10_request_failures>=A10_MAX_REQUEST_FAILURES)
      a10_retry_after=(end>now ? end : now+300);
   else
      a10_retry_after=now+(a10_request_failures==1 ? 5 : 30);

   Print("GDS Renko Bollinger 4-Mode: request deferred. Retcode ",retcode,
         ", ",details,", next attempt no earlier than ",
         TimeToString(a10_retry_after,TIME_DATE|TIME_SECONDS));
  }

//+------------------------------------------------------------------+
bool A10_SubmitDeal(MqlTradeRequest &request,const bool is_exit,const int owner_mode,const ulong position_ticket=0)
  {
   Print("[A10_NOORDERS_GUARD] A10_SubmitDeal blocked. NO_ORDERS=1");
   return false;
  }

//+------------------------------------------------------------------+
bool A10_TradeModeAllowsEntry(const int direction)
  {
   const ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   if(mode==SYMBOL_TRADE_MODE_DISABLED || mode==SYMBOL_TRADE_MODE_CLOSEONLY) return false;
   if(mode==SYMBOL_TRADE_MODE_LONGONLY && direction<0) return false;
   if(mode==SYMBOL_TRADE_MODE_SHORTONLY && direction>0) return false;
   return true;
  }

//+------------------------------------------------------------------+
bool A10_TradeModeAllowsClose(void)
  {
   const ENUM_SYMBOL_TRADE_MODE mode=(ENUM_SYMBOL_TRADE_MODE)
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE);
   return (mode!=SYMBOL_TRADE_MODE_DISABLED);
  }

//+------------------------------------------------------------------+
void A10_RequestExit(const string reason,const int owner_mode,const ulong ticket)
  {
   if(owner_mode<0 || owner_mode>3 || ticket==0) return;
   if(!a10_exit_pending[owner_mode])
     {
      a10_exit_reason[owner_mode]=reason;
      a10_exit_ticket[owner_mode]=ticket;
     }
   a10_exit_pending[owner_mode]=true;
   A10_ClearPendingEntry(owner_mode);
  }

//+------------------------------------------------------------------+
bool A10_SendMarket(const int direction,const int owner_mode)
  {
   if(direction!=1 && direction!=-1) return false;
   if(owner_mode<0 || owner_mode>3 || !A10_ModeEnabled(owner_mode)) return false;
   if(A10_AnyPendingExit() || A10_ModeHasPosition(owner_mode)) return false;
   if(A10_CountOurPositions()>=A10_EffectiveMaxPositions()) return false;
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !A10_ValidTick(tick)) return false;
   if(!A10_ModeSpreadIsAcceptable(owner_mode,tick)) return false;
   a10_v_open[owner_mode]=true;
   a10_v_dir[owner_mode]=direction;
   a10_v_price[owner_mode]=(direction>0 ? tick.ask : tick.bid);
   a10_v_time[owner_mode]=TimeCurrent();
   a10_v_ticket[owner_mode]=a10_v_next_ticket++;
   a10_v_entries++; a10_v_entries_mode[owner_mode]++;
   Print("[A10_NOORDERS_ENTRY] mode=",A10_ModeName(owner_mode)," dir=",(direction>0?"BUY":"SELL"),
         " price=",DoubleToString(a10_v_price[owner_mode],_Digits)," ticket=",a10_v_ticket[owner_mode],
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return true;
  }

//+------------------------------------------------------------------+
bool A10_ClosePositionByTicket(const int owner_mode,const ulong ticket,const string reason)
  {
   if(owner_mode<0 || owner_mode>3 || !a10_v_open[owner_mode] || a10_v_ticket[owner_mode]!=ticket)
     { A10_MarkExitCompleted(owner_mode); return true; }
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !A10_ValidTick(tick)) return false;
   const double px=(a10_v_dir[owner_mode]>0 ? tick.bid : tick.ask);
   Print("[A10_NOORDERS_EXIT] mode=",A10_ModeName(owner_mode)," reason=",reason,
         " price=",DoubleToString(px,_Digits)," ticket=",ticket,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   a10_v_open[owner_mode]=false; a10_v_dir[owner_mode]=0; a10_v_price[owner_mode]=0.0;
   a10_v_time[owner_mode]=0; a10_v_ticket[owner_mode]=0;
   a10_v_exits++; a10_v_exits_mode[owner_mode]++;
   A10_MarkExitCompleted(owner_mode);
   return true;
  }

//+------------------------------------------------------------------+
void A10_TryPendingExit(void)
  {
   for(int mode=0;mode<4;mode++)
     {
      if(!a10_exit_pending[mode]) continue;
      const ulong ticket=a10_exit_ticket[mode];
      if(ticket==0 || !A10_PositionExists(ticket)) { A10_MarkExitCompleted(mode); continue; }
      A10_ClosePositionByTicket(mode,ticket,a10_exit_reason[mode]);
      return;
     }
  }

//+------------------------------------------------------------------+
void A10_CheckPriceExits(const MqlTick &tick)
  {
   for(int owner=0;owner<4;owner++)
     {
      if(!a10_v_open[owner] || a10_exit_pending[owner]) continue;
      CA10ExitModule *ex=A10_ModeExit(owner);
      if(ex==NULL) continue;
      SA10ExitDecision d={};
      ex.CheckPrice(a10_v_dir[owner],a10_v_price[owner],a10_v_time[owner],
                    tick.bid,tick.ask,TimeCurrent(),A10_ModeBrick(owner),d);
      if(d.exit) A10_RequestExit(ex.ReasonText(d.reason),owner,a10_v_ticket[owner]);
     }
  }

//+------------------------------------------------------------------+
void A10_ProcessOwnerSignalExit(const int owner,const SA10EntryResult &result)
  {
   if(result.completed<=0 || owner<0 || owner>3 || a10_exit_pending[owner] || !a10_v_open[owner]) return;
   CA10ExitModule *ex=A10_ModeExit(owner);
   if(ex==NULL) return;
   SA10ExitDecision d={};
   ex.CheckSignal(owner,a10_v_dir[owner],result.completed,result.raw_signal,result.bb_ready,
                  result.final_close,result.bb_mid,d);
   if(d.exit) A10_RequestExit(ex.ReasonText(d.reason),owner,a10_v_ticket[owner]);
  }

//+------------------------------------------------------------------+
void A10_QueueNewSignals(const int &signals[],const MqlTick &tick)
  {
   bool candidate[4]={false,false,false,false};
   bool long_signal=false;
   bool short_signal=false;

   for(int mode=0;mode<4;mode++)
     {
      if(!A10_ModeEnabled(mode) || A10_ModeCooldownLeft(mode)>0 || signals[mode]==0) continue;
      if(A10_ModeHasPosition(mode) || a10_pending_entry_dir[mode]!=0 || a10_exit_pending[mode]) continue;
      if(!A10_ModeSpreadIsAcceptable(mode,tick)) continue;
      candidate[mode]=true;
      if(signals[mode]>0) long_signal=true;
      if(signals[mode]<0) short_signal=true;
     }

   if(InpA10SkipOppositeSignals && long_signal && short_signal)
     {
      Print("GDS Renko Bollinger: opposite mode signals on the same tick; new entries skipped by input setting.");
      return;
     }

   int free_slots=A10_EffectiveMaxPositions()-A10_CountOurPositions()-A10_PendingEntryCount();
   if(free_slots<=0) return;

   // Deterministic queue priority: Breakout -> Re-entry -> Midline -> Squeeze.
   for(int mode=0;mode<4 && free_slots>0;mode++)
     {
      if(!candidate[mode]) continue;
      a10_pending_entry_dir[mode]=signals[mode];
      a10_pending_entry_time[mode]=TimeCurrent();
      free_slots--;
     }
  }

//+------------------------------------------------------------------+
void A10_TryPendingEntry(const MqlTick &tick)
  {
   if(A10_AnyPendingExit() || A10_HasActiveOrder(false) || A10_ExternalPositionOnSymbol()) return;
   if(A10_CountOurPositions()>=A10_EffectiveMaxPositions()) return;

   const datetime now=TimeCurrent();
   for(int mode=0;mode<4;mode++)
     {
      const int direction=a10_pending_entry_dir[mode];
      if(direction==0) continue;

      if(a10_pending_entry_time[mode]>0 && now-a10_pending_entry_time[mode]>A10_ENTRY_QUEUE_TTL)
        {
         A10_ClearPendingEntry(mode);
         continue;
        }
      if(!A10_ModeEnabled(mode) || A10_ModeCooldownLeft(mode)>0 || A10_ModeHasPosition(mode))
        {
         A10_ClearPendingEntry(mode);
         continue;
        }
      if(!A10_ModeSpreadIsAcceptable(mode,tick)) continue;
      if(!A10_TradeModeAllowsEntry(direction)) continue;

      if(A10_SendMarket(direction,mode)) A10_ClearPendingEntry(mode);
      return; // One trade request per tick; remaining queued modes are handled on following ticks.
     }
  }

//+------------------------------------------------------------------+
void A10_UpdateAllModesAndTrade(const double price,const MqlTick &tick)
  {
   SA10EntryResult r0={};
   SA10EntryResult r1={};
   SA10EntryResult r2={};
   SA10EntryResult r3={};

   a10_breakout.PushPrice(price,r0);
   a10_reentry.PushPrice(price,r1);
   a10_midline.PushPrice(price,r2);
   a10_squeeze.PushPrice(price,r3);

   A10_ProcessOwnerSignalExit(A10_ENTRY_BREAKOUT,r0);
   A10_ProcessOwnerSignalExit(A10_ENTRY_REENTRY,r1);
   A10_ProcessOwnerSignalExit(A10_ENTRY_MIDLINE,r2);
   A10_ProcessOwnerSignalExit(A10_ENTRY_SQUEEZE,r3);

   if(A10_AnyPendingExit()) return;

   int signals[4]={r0.signal,r1.signal,r2.signal,r3.signal};
   A10_QueueNewSignals(signals,tick);
   A10_TryPendingEntry(tick);
  }

//+------------------------------------------------------------------+
int InitA10()
  {
   if(!MathIsValidNumber(InpA10Lots) || InpA10Lots<=0.0 || InpA10Magic==0 ||
      InpA10MaxPositions<1 || InpA10MaxPositions>4)
     {
      Print("GDS Renko Bollinger 4-Mode: invalid common inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!InpA10BreakoutEnabled && !InpA10ReentryEnabled && !InpA10MidlineEnabled && !InpA10SqueezeEnabled)
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

   const double effective_volume=A10_NormalizeVolume(InpA10Lots);
   if(effective_volume<=0.0)
     {
      Print("GDS Bollinger: symbol volume settings unavailable or invalid.");
      return INIT_FAILED;
     }

   if(!a10_breakout.Configure(InpA10BreakoutEnabled,A10_ENTRY_BREAKOUT,tick_size,InpA10BreakoutBrickSize,InpA10BreakoutBBPeriod,InpA10BreakoutDeviation,1.0,InpA10BreakoutEntryRun,InpA10BreakoutCooldown,InpA10BreakoutMaxSpread) ||
      !a10_reentry.Configure(InpA10ReentryEnabled,A10_ENTRY_REENTRY,tick_size,InpA10ReentryBrickSize,InpA10ReentryBBPeriod,InpA10ReentryDeviation,1.0,InpA10ReentryEntryRun,InpA10ReentryCooldown,InpA10ReentryMaxSpread) ||
      !a10_midline.Configure(InpA10MidlineEnabled,A10_ENTRY_MIDLINE,tick_size,InpA10MidlineBrickSize,InpA10MidlineBBPeriod,InpA10MidlineDeviation,1.0,InpA10MidlineEntryRun,InpA10MidlineCooldown,InpA10MidlineMaxSpread) ||
      !a10_squeeze.Configure(InpA10SqueezeEnabled,A10_ENTRY_SQUEEZE,tick_size,InpA10SqueezeBrickSize,InpA10SqueezeBBPeriod,InpA10SqueezeDeviation,InpA10SqueezeMaxWidth,InpA10SqueezeEntryRun,InpA10SqueezeCooldown,InpA10SqueezeMaxSpread))
     {
      Print("GDS Renko Bollinger 4-Mode: invalid enabled-mode inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!a10_exit_breakout.Configure(InpA10BreakoutTP,InpA10BreakoutSL,InpA10BreakoutMaxHold) ||
      !a10_exit_reentry.Configure(InpA10ReentryTP,InpA10ReentrySL,InpA10ReentryMaxHold) ||
      !a10_exit_midline.Configure(InpA10MidlineTP,InpA10MidlineSL,InpA10MidlineMaxHold) ||
      !a10_exit_squeeze.Configure(InpA10SqueezeTP,InpA10SqueezeSL,InpA10SqueezeMaxHold))
     {
      Print("A10 separated exit module: invalid inputs.");
      return INIT_PARAMETERS_INCORRECT;
     }

   for(int mode=0;mode<4;mode++)
     {
      a10_exit_pending[mode]=false;
      a10_exit_reason[mode]="";
      a10_exit_ticket[mode]=0;
      a10_pending_entry_dir[mode]=0;
      a10_pending_entry_time[mode]=0;
     }
   a10_request_this_tick=false;
   a10_retry_after=0;
   a10_request_session_end=0;
   a10_request_failures=0;
   a10_wait_order=0;
   a10_execution_uncertain=false;
   a10_uncertain_exit=false;
   a10_uncertain_mode=-1;
   a10_uncertain_ticket=0;

   for(int vm=0;vm<4;vm++)
     { a10_v_open[vm]=false; a10_v_dir[vm]=0; a10_v_price[vm]=0.0; a10_v_time[vm]=0; a10_v_ticket[vm]=0; a10_v_entries_mode[vm]=0; a10_v_exits_mode[vm]=0; }
   a10_v_next_ticket=1; a10_v_entries=0; a10_v_exits=0; a10_v_ticks=0;
   Print("[A10_NOORDERS_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   Print("A10 Core NoOrders v1.00 started. EffectiveLots=",DoubleToString(effective_volume,2),
         ", MaxPositions=",A10_EffectiveMaxPositions(),
         ", SkipOppositeSameTick=",(InpA10SkipOppositeSignals ? "ON" : "OFF"),
         ", Account=",(A10_IsHedgingAccount() ? "HEDGING" : "NETTING"),
         ", Breakout=",(InpA10BreakoutEnabled ? "ON" : "OFF"),
         ", Re-entry=",(InpA10ReentryEnabled ? "ON" : "OFF"),
         ", Midline=",(InpA10MidlineEnabled ? "ON" : "OFF"),
         ", Squeeze=",(InpA10SqueezeEnabled ? "ON" : "OFF"));
   return INIT_SUCCEEDED;
  }

//+------------------------------------------------------------------+


// A11 state
CA11MACross g_a11;
long g_a11_newbars=0;

// A12 state
CRenkoBuilder g_a12_renko;
CRenkoADX     g_a12_adx;
double g_a12_tick_size=0.0,g_a12_effective_brick=0.0;

// A13 state
CA13DualMA g_a13;

// A15 state
CA15RenkoBuilder g_a15_renko;
CA15EntryModule  g_a15_entry;

// A16 template state (empty Alpha; emits no decisions)
CAlphaTemplate g_a16_template;

void ClearPosition()
  {
   g_position.is_open=false; g_position.direction=0; g_position.entry_price=0.0;
   g_position.entry_time=0; g_position.volume=0.0;
  }

void ApplyDecision(const SMultiAlphaDecision &d)
  {
   if(d.action==ALPHA_ACTION_ENTRY)
     {
      g_position.is_open=true; g_position.direction=d.direction;
      g_position.entry_price=d.decision_price; g_position.entry_time=d.time;
      g_position.volume=0.01; g_entries++;
      PrintFormat("[MULTI_ALPHA_CORE_ENTRY] alpha=%d no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         (int)d.alpha_id,g_entries,TimeToString(d.time,TIME_DATE|TIME_SECONDS),
         d.time_msc,d.direction,d.decision_price,d.reason);
     }
   else if(d.action==ALPHA_ACTION_EXIT)
     {
      g_exits++;
      PrintFormat("[MULTI_ALPHA_CORE_EXIT] alpha=%d no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         (int)d.alpha_id,g_exits,TimeToString(d.time,TIME_DATE|TIME_SECONDS),
         d.time_msc,d.direction,d.decision_price,d.reason);
      ClearPosition(); g_cooldown=InpCooldownBricks;
     }
  }

void EmitExit(const SMultiAlphaMarket &m,const string reason,SMultiAlphaDecision &d)
  {
   MultiAlphaDecisionClear(d,InpAlpha);
   d.action=ALPHA_ACTION_EXIT; d.direction=g_position.direction; d.reason=reason;
   d.decision_price=(g_position.direction>0 ? m.bid : m.ask);
   d.time=m.time; d.time_msc=m.time_msc;
  }

string A12TickExit(const SMultiAlphaMarket &m)
  {
   if(!g_position.is_open) return "";
   const double px=(g_position.direction>0 ? m.bid : m.ask);
   const double move=g_position.direction*(px-g_position.entry_price);
   if(move>=InpA12TakeProfitBricks*g_a12_effective_brick) return "TP";
   if(move<=-InpA12StopLossBricks*g_a12_effective_brick) return "SL";
   if(InpA12MaxHoldMinutes>0 &&
      (long)(m.time-g_position.entry_time)>=(long)InpA12MaxHoldMinutes*60) return "TIME";
   return "";
  }

SA15ExitSnapshot A15Snapshot()
  {
   SA15ExitSnapshot s; s.is_open=g_position.is_open; s.direction=g_position.direction;
   s.entry_price=g_position.entry_price; s.entry_time=g_position.entry_time; return s;
  }
SA15ExitSettings A15Settings()
  {
   SA15ExitSettings s; s.brick_size=InpA15BrickSize;
   s.take_profit_bricks=InpA15TakeProfitBricks; s.stop_loss_bricks=InpA15StopLossBricks;
   s.max_hold_minutes=InpA15MaxHoldMinutes; return s;
  }

int InitA11()
  {
   if(InpA11FastPeriod>=InpA11SlowPeriod || InpA11FastPeriod<1 || InpA11SlowPeriod<1)
      return INIT_PARAMETERS_INCORRECT;
   if(InpA11TakeProfit<0.0 || InpA11StopLoss<0.0 ||
      InpA11MaxLotSize<0.01 || InpA11MinEquity<10.0)
      return INIT_PARAMETERS_INCORRECT;
   g_a11_newbars=0;
   if(!g_a11.Init(InpA11FastPeriod,InpA11SlowPeriod,InpA11MAMethod,
                  InpA11UseMAFilter,InpA11FilterMethod,
                  InpA11FilterTimeframe,InpA11FilterPeriod))
      return INIT_FAILED;
   return INIT_SUCCEEDED;
  }

int InitA12()
  {
   if(InpA12BrickSize<=0.0 || InpA12ADXPeriod<2 || InpA12ADXPeriod>100 ||
      InpA12ADXThreshold<0.0 || InpA12MinDISeparation<0.0 ||
      InpA12EntryRunBricks<1 || InpA12TakeProfitBricks<=0.0 ||
      InpA12StopLossBricks<=0.0 || InpA12MaxHoldMinutes<0) return INIT_PARAMETERS_INCORRECT;
   g_a12_tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(g_a12_tick_size<=0.0) return INIT_FAILED;
   const long units=(long)MathMax(1.0,MathRound(InpA12BrickSize/g_a12_tick_size));
   g_a12_effective_brick=(double)units*g_a12_tick_size;
   g_a12_renko.Init(g_a12_tick_size,units); g_a12_adx.Init(InpA12ADXPeriod);
   return INIT_SUCCEEDED;
  }

int InitA13()
  {
   if(InpA13TakeProfitBricks<=0.0 || InpA13StopLossBricks<=0.0 ||
      InpA13MaxHoldMinutes<0 || InpA13CooldownBricks<0 ||
      InpA13MaxSpreadFraction<=0.0) return INIT_PARAMETERS_INCORRECT;
   const double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(!g_a13.Init(tick_size,InpA13BrickSize,InpA13FastMAPeriod,InpA13SlowMAPeriod,
                  InpA13MinMASeparationBricks,InpA13EntryRunBricks)) return INIT_PARAMETERS_INCORRECT;
   return INIT_SUCCEEDED;
  }

int InitA15()
  {
   if(InpA15BrickSize<=0.0 || InpA15TakeProfitBricks<=0.0 ||
      InpA15StopLossBricks<=0.0 || InpA15MaxHoldMinutes<0 ||
      InpA15DonchianPeriod<2 || InpA15DonchianPeriod>512 ||
      InpA15BreakoutBufferBricks<0.0 || InpA15EntryRunBricks<1)
      return INIT_PARAMETERS_INCORRECT;
   g_a15_renko.Init(InpA15BrickSize);
   g_a15_entry.Init(InpA15BrickSize,InpA15DonchianPeriod,
                   InpA15BreakoutBufferBricks,InpA15EntryRunBricks);
   return INIT_SUCCEEDED;
  }

int OnInit()
  {
   if(InpAlpha!=ALPHA_A10 && InpAlpha!=ALPHA_A11 && InpAlpha!=ALPHA_A12 && InpAlpha!=ALPHA_A13 && InpAlpha!=ALPHA_A15 && InpAlpha!=ALPHA_A16_TEMPLATE) return INIT_PARAMETERS_INCORRECT;
   if(InpCooldownBricks<0 || InpMaxSpreadFraction<0.0) return INIT_PARAMETERS_INCORRECT;
   ClearPosition(); g_cooldown=0; g_failed=false;
   g_ticks=0; g_bricks=0; g_raw=0; g_entries=0; g_exits=0; g_blocks=0; g_spread_blocks=0;
   int rc=INIT_SUCCEEDED;
   if(InpAlpha==ALPHA_A10) rc=InitA10();
   else if(InpAlpha==ALPHA_A11) rc=InitA11();
   else if(InpAlpha==ALPHA_A12) rc=InitA12();
   else if(InpAlpha==ALPHA_A13) rc=InitA13();
   else if(InpAlpha==ALPHA_A15) rc=InitA15();
   else g_a16_template.Init();
   if(rc!=INIT_SUCCEEDED) return rc;
   PrintFormat("[MULTI_ALPHA_CORE_START] selected_alpha=%d cooldown=%d spread_fraction=%.4f NO_ORDERS=1",
      (int)InpAlpha,InpCooldownBricks,InpMaxSpreadFraction);
   return INIT_SUCCEEDED;
  }

void TickA10(const MqlTick &tick_in)
  {
   a10_request_this_tick=false;
   A10_ResolveExecution();

   MqlTick tick=tick_in;
   if(!A10_ValidTick(tick)) return;

   // Exits always have priority over new entries.
   A10_TryPendingExit();
   A10_CheckPriceExits(tick);
   A10_TryPendingExit();

   // Every enabled mode receives the same BID tick, but builds its own Renko stream.
   A10_UpdateAllModesAndTrade(tick.bid,tick);

   // Completed-brick mode logic may request an exit now.
   A10_TryPendingExit();
   if(!A10_AnyPendingExit()) A10_TryPendingEntry(tick);
  }


void TickA11(const SMultiAlphaMarket &m)
  {
   if(!g_a11.Prepare()) return;
   if(AccountInfoDouble(ACCOUNT_EQUITY)<InpA11MinEquity) return;
   if(!g_a11.IsNewBar()) return;
   g_a11_newbars++;

   const int signal=g_a11.Signal();
   if(signal==-1)
     {
      if(InpA11UseFastMAExit && g_position.is_open)
        {
         const double close=iClose(_Symbol,PERIOD_CURRENT,1);
         if((g_position.direction>0 && close<=g_a11.FastClosed()) ||
            (g_position.direction<0 && close>=g_a11.FastClosed()))
           {
            SMultiAlphaDecision d; MultiAlphaDecisionClear(d,ALPHA_A11);
            d.action=ALPHA_ACTION_EXIT; d.direction=g_position.direction; d.reason="FAST_MA";
            d.decision_price=(g_position.direction>0 ? m.bid : m.ask);
            d.time=m.time; d.time_msc=m.time_msc;
            g_exits++;
            PrintFormat("[MULTI_ALPHA_CORE_EXIT] alpha=11 no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
               g_exits,TimeToString(d.time,TIME_DATE|TIME_SECONDS),d.time_msc,d.direction,d.decision_price,d.reason);
            ClearPosition();
           }
        }
      return;
     }

   g_raw++;
   const int direction=(signal==ORDER_TYPE_BUY ? 1 : -1);
   const bool same=(g_position.is_open && g_position.direction==direction);

   if(g_position.is_open && !same)
     {
      const int old_direction=g_position.direction;
      const double close_price=(old_direction>0 ? m.bid : m.ask);
      g_exits++;
      PrintFormat("[MULTI_ALPHA_CORE_EXIT] alpha=11 no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=OPPOSITE NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         g_exits,TimeToString(m.time,TIME_DATE|TIME_SECONDS),m.time_msc,old_direction,close_price);
      ClearPosition();
     }

   if(!same)
     {
      const double entry_price=(direction>0 ? m.ask : m.bid);
      g_position.is_open=true; g_position.direction=direction;
      g_position.entry_price=entry_price; g_position.entry_time=m.time; g_position.volume=0.01;
      g_entries++;
      PrintFormat("[MULTI_ALPHA_CORE_ENTRY] alpha=11 no=%I64d time=%s time_msc=%I64d dir=%d price=%.8f reason=A11_MA_CROSS NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         g_entries,TimeToString(m.time,TIME_DATE|TIME_SECONDS),m.time_msc,direction,entry_price);
     }
  }

void TickA12(const SMultiAlphaMarket &m)
  {
   bool closed=false; SMultiAlphaDecision d; MultiAlphaDecisionClear(d,ALPHA_A12);
   if(g_position.is_open)
     {
      const string r=A12TickExit(m);
      if(r!="") { EmitExit(m,r,d); ApplyDecision(d); closed=true; }
     }

   SRenkoBrick bricks[];
   const int n=g_a12_renko.PushPrice(m.bid,bricks);
   if(n<0) { g_failed=true; Print("[MULTI_ALPHA_CORE_ERROR] alpha=12 renko_builder_stopped NO_ORDERS=1"); return; }
   if(n==0) return;

   int final_signal=0,final_raw=0;
   for(int i=0;i<n;i++)
     {
      int raw=0;
      final_signal=A12_ProcessCompletedBrick(g_a12_adx,bricks[i],
         InpA12ADXThreshold,InpA12MinDISeparation,InpA12EntryRunBricks,raw);
      final_raw=raw; g_bricks++;
     }

   if(g_cooldown>0)
     {
      const int before=g_cooldown; g_cooldown-=n; if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[MULTI_ALPHA_CORE_COOLDOWN] alpha=12 time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         m.time_msc,before,n,g_cooldown);
     }

   if(g_position.is_open)
     {
      if(final_raw!=0 && final_raw==-g_position.direction)
        { EmitExit(m,"DI_FLIP",d); ApplyDecision(d); }
      return;
     }

   if(final_signal==0) return;
   g_raw++;
   if(closed || g_cooldown>0)
     {
      g_blocks++;
      PrintFormat("[MULTI_ALPHA_CORE_BLOCK] alpha=12 time_msc=%I64d signal=%d gate=%s cooldown=%d NO_ORDERS=1",
         m.time_msc,final_signal,(closed?"CLOSED_THIS_TICK":"COOLDOWN"),g_cooldown);
      return;
     }

   const double spread=m.ask-m.bid,limit=InpMaxSpreadFraction*g_a12_effective_brick;
   if(spread>limit) { g_blocks++; g_spread_blocks++; return; }

   MultiAlphaDecisionClear(d,ALPHA_A12); d.action=ALPHA_ACTION_ENTRY;
   d.direction=final_signal; d.reason="A12 ADX RENKO";
   d.decision_price=(final_signal>0?m.ask:m.bid); d.time=m.time; d.time_msc=m.time_msc;
   ApplyDecision(d);
  }

void TickA13(const SMultiAlphaMarket &m)
  {
   bool closed=false;
   SMultiAlphaDecision d; MultiAlphaDecisionClear(d,ALPHA_A13);

   if(g_position.is_open)
     {
      const double executable=(g_position.direction>0 ? m.bid : m.ask);
      const double move=g_position.direction*(executable-g_position.entry_price);
      const double brick=g_a13.EffectiveBrick();
      string r="";
      if(move>=InpA13TakeProfitBricks*brick) r="TP";
      else if(move<=-InpA13StopLossBricks*brick) r="SL";
      else if(InpA13MaxHoldMinutes>0 &&
              (long)(m.time-g_position.entry_time)>=(long)InpA13MaxHoldMinutes*60) r="TIME";
      if(r!="")
        {
         EmitExit(m,r,d); ApplyDecision(d);
         g_cooldown=InpA13CooldownBricks; closed=true;
        }
     }

   int n=0,alignment=0;
   const int final_signal=g_a13.PushBid(m.bid,n,alignment);
   if(g_a13.Failed())
     {
      g_failed=true;
      Print("[MULTI_ALPHA_CORE_ERROR] alpha=13 renko_builder_stopped NO_ORDERS=1");
      return;
     }
   if(n==0) return;
   g_bricks+=n;

   if(g_cooldown>0)
     {
      g_cooldown-=n;
      if(g_cooldown<0) g_cooldown=0;
     }

   if(g_position.is_open)
     {
      if(alignment!=0 && alignment==-g_position.direction)
        {
         EmitExit(m,"MA_FLIP",d); ApplyDecision(d);
         g_cooldown=InpA13CooldownBricks;
        }
      return;
     }

   if(final_signal==0) return;
   if(closed || g_cooldown>0)
     {
      g_blocks++;
      return;
     }
   g_raw++;
   const double spread=m.ask-m.bid;
   const double limit=InpA13MaxSpreadFraction*g_a13.EffectiveBrick();
   if(spread>limit) { g_blocks++; g_spread_blocks++; return; }

   MultiAlphaDecisionClear(d,ALPHA_A13);
   d.action=ALPHA_ACTION_ENTRY; d.direction=final_signal; d.reason="A13 DUAL MA";
   d.decision_price=(final_signal>0 ? m.ask : m.bid); d.time=m.time; d.time_msc=m.time_msc;
   ApplyDecision(d);
  }

void TickA15(const SMultiAlphaMarket &m,const MqlTick &tick)
  {
   bool closed=false; SMultiAlphaDecision d; MultiAlphaDecisionClear(d,ALPHA_A15);
   if(g_position.is_open)
     {
      const string r=A15ExitPriceTimeDecision(A15Snapshot(),A15Settings(),tick,TimeCurrent());
      if(r!="") { EmitExit(m,r,d); ApplyDecision(d); closed=true; }
     }

   SA15Brick bricks[];
   const int n=g_a15_renko.PushPrice(m.bid,bricks);
   int final_signal=0;
   for(int i=0;i<n;i++) { final_signal=g_a15_entry.ProcessCompletedBrick(bricks[i]); g_bricks++; }
   if(n>0 && final_signal!=0) g_raw++;

   if(g_position.is_open && n>0)
     {
      const string r=A15ExitOppositeDecision(A15Snapshot(),final_signal);
      if(r!="") { EmitExit(m,r,d); ApplyDecision(d); closed=true; }
     }

   if(n>0 && g_cooldown>0)
     {
      const int before=g_cooldown; g_cooldown-=n; if(g_cooldown<0) g_cooldown=0;
      PrintFormat("[MULTI_ALPHA_CORE_COOLDOWN] alpha=15 time_msc=%I64d before=%d bricks=%d after=%d NO_ORDERS=1",
         m.time_msc,before,n,g_cooldown);
     }

   if(n==0 || g_position.is_open || closed || g_cooldown>0 || final_signal==0) return;
   const double spread=m.ask-m.bid,limit=InpMaxSpreadFraction*InpA15BrickSize;
   if(spread>limit) { g_blocks++; g_spread_blocks++; return; }

   MultiAlphaDecisionClear(d,ALPHA_A15); d.action=ALPHA_ACTION_ENTRY;
   d.direction=final_signal; d.reason="A15 DONCHIAN BREAKOUT";
   d.decision_price=(final_signal>0?m.ask:m.bid); d.time=m.time; d.time_msc=m.time_msc;
   ApplyDecision(d);
  }

void TickA16Template(const SMultiAlphaMarket &m)
  {
   SMultiAlphaDecision d;
   MultiAlphaDecisionClear(d,ALPHA_A16_TEMPLATE);
   if(g_a16_template.Evaluate(m,g_position,d))
      ApplyDecision(d);
  }

void OnTick()
  {
   if(g_failed) return;
   MqlTick tick={}; if(!SymbolInfoTick(_Symbol,tick)) return;
   SMultiAlphaMarket m; m.time=tick.time; m.time_msc=tick.time_msc; m.bid=tick.bid; m.ask=tick.ask;
   if(!MultiAlphaMarketValid(m)) return;
   g_ticks++;
   if(InpAlpha==ALPHA_A10) TickA10(tick);
   else if(InpAlpha==ALPHA_A11) TickA11(m);
   else if(InpAlpha==ALPHA_A12) TickA12(m);
   else if(InpAlpha==ALPHA_A13) TickA13(m);
   else if(InpAlpha==ALPHA_A15) TickA15(m,tick);
   else TickA16Template(m);
  }

void OnDeinit(const int reason)
  {
   if(InpAlpha==ALPHA_A11) g_a11.Release();
   if(InpAlpha==ALPHA_A10)
      PrintFormat("[MULTI_ALPHA_A10_SUMMARY] ticks=%I64d entries=%I64d exits=%I64d open=%d breakout_entries=%I64d breakout_exits=%I64d reentry_entries=%I64d reentry_exits=%I64d midline_entries=%I64d midline_exits=%I64d squeeze_entries=%I64d squeeze_exits=%I64d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         g_ticks,a10_v_entries,a10_v_exits,A10_CountOurPositions(),a10_v_entries_mode[0],a10_v_exits_mode[0],a10_v_entries_mode[1],a10_v_exits_mode[1],a10_v_entries_mode[2],a10_v_exits_mode[2],a10_v_entries_mode[3],a10_v_exits_mode[3]);
   long summary_entries=g_entries;
   long summary_exits=g_exits;
   int summary_open=(int)g_position.is_open;
   if(InpAlpha==ALPHA_A10)
     {
      summary_entries=a10_v_entries;
      summary_exits=a10_v_exits;
      summary_open=A10_CountOurPositions();
     }
   PrintFormat("[MULTI_ALPHA_CORE_SUMMARY] selected_alpha=%d ticks=%I64d bricks=%I64d raw=%I64d entries=%I64d exits=%I64d blocks=%I64d spread_blocks=%I64d open=%d cooldown=%d failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      (int)InpAlpha,g_ticks,g_bricks,g_raw,summary_entries,summary_exits,g_blocks,g_spread_blocks,
      summary_open,g_cooldown,(int)g_failed,reason);
  }
