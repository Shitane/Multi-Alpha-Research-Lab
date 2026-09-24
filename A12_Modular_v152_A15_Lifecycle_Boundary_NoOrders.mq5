// A12/A15 original price-exit decision parity audit; READ-ONLY; no trading.
// Put A12_Entry_Module.mqh in the same MQL5\Experts directory as this EA.
#property strict
#property version "1.52"
#property description "Research-only A15 virtual/actual lifecycle boundary audit; never places orders."
#include "..\..\Include\A12_Entry_Module.mqh"
#include "..\..\Include\A15_Exit_Decision_Module_v1_00.mqh"
input double InpBrickSize=16.0;
input int InpADXPeriod=14;
input double InpADXThreshold=8.5;
input double InpMinDISeparation=2.5;
input int InpEntryRunBricks=3;
input double InpTakeProfitBricks=9.5;
input double InpStopLossBricks=42.0;
input int InpMaxHoldMinutes=1060;
input int InpCooldownBricks=6;
input double InpMaxSpreadFraction=0.35;
// Modules are independent. Defaults reproduce v1.10 virtual decisions.
enum ENUM_A12_ENTRY_MODULE { ENTRY_A12_VERIFIED=0, ENTRY_DISABLED=1, ENTRY_A15_REFERENCE_SEEDED=2, ENTRY_A15_AUTONOMOUS=3 };
enum ENUM_A12_EXIT_MODULE  { EXIT_A12_VERIFIED=0, EXIT_DISABLED=1, EXIT_TIME_WITH_SL=2, EXIT_A15_PRICE_TIME_PROTOTYPE=3, EXIT_A15_FULL_PROTOTYPE=4 };
// Experimental alternative: time-based exit with original emergency stop-loss.
input int InpAlternativeHoldMinutes=180;
// A15 ORIGINAL v1.11 defaults; independent Renko/Donchian for full prototype.
input double InpA15BrickSize=14.0;
input double InpA15TakeProfitBricks=8.0;
input double InpA15StopLossBricks=8.2;
input int InpA15MaxHoldMinutes=4935;
input int InpA15DonchianPeriod=25;
input double InpA15BreakoutBufferBricks=0.20;
input int InpA15EntryRunBricks=1;
input ENUM_A12_ENTRY_MODULE InpEntryModule=ENTRY_A15_AUTONOMOUS;
input ENUM_A12_EXIT_MODULE InpExitModule=EXIT_A15_FULL_PROTOTYPE;
// Independent A15 Renko: copied from original v1.11; no A12 brick substitution.
struct SA15Brick
  {
   double open;
   double close;
   int    direction; // +1 up, -1 down
   int    run;       // consecutive bricks in current direction
  };

//+------------------------------------------------------------------+
//| Classic fixed-size Renko builder, two-brick reversal             |
//+------------------------------------------------------------------+
class CA15RenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;
   int    m_run;

   void AddBrick(SA15Brick &out[],const double open_price,
                 const double close_price,const int direction)
     {
      if(direction==m_last_dir)
         m_run++;
      else
        {
         m_last_dir=direction;
         m_run=1;
        }

      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].open=NormalizeDouble(open_price,_Digits);
      out[n].close=NormalizeDouble(close_price,_Digits);
      out[n].direction=direction;
      out[n].run=m_run;
     }

public:
   void Init(const double brick_size)
     {
      m_size=brick_size;
      m_has_anchor=false;
      m_anchor=0.0;
      m_last_close=0.0;
      m_last_dir=0;
      m_run=0;
     }

   int PushPrice(const double price,SA15Brick &out[])
     {
      ArrayResize(out,0);
      if(m_size<=0.0 || price<=0.0)
         return 0;

      if(!m_has_anchor)
        {
         m_anchor=price;
         m_has_anchor=true;
         return 0;
        }

      int added=0;

      // First direction: one full brick from the starting anchor.
      if(m_last_dir==0)
        {
         while(price>=m_anchor+m_size)
           {
            const double brick_open=m_anchor;
            m_anchor+=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,+1);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            const double brick_open=m_anchor;
            m_anchor-=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,-1);
            added++;
           }
         return added;
        }

      bool changed=true;
      while(changed)
        {
         changed=false;

         if(m_last_dir>0)
           {
            if(price>=m_last_close+m_size)
              {
               const double brick_open=m_last_close;
               m_last_close+=m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               const double brick_open=m_last_close-m_size;
               m_last_close-=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               const double brick_open=m_last_close;
               m_last_close-=m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               const double brick_open=m_last_close+m_size;
               m_last_close+=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };


// A15 Donchian state is updated on every valid BID tick, independently of A12.
const int A15_MAX_HISTORY=512;
CA15RenkoBuilder g_a15_renko;
SA15Brick g_a15_history[];
long g_a15_brick_no=0;
void A15PushHistory(const SA15Brick &brick)
  {
   int n=ArraySize(g_a15_history);
   if(n>=A15_MAX_HISTORY)
     {
      for(int i=1;i<n;i++) g_a15_history[i-1]=g_a15_history[i];
      n--;
      ArrayResize(g_a15_history,n);
     }
   ArrayResize(g_a15_history,n+1);
   g_a15_history[n]=brick;
  }
bool A15GetDonchian(const int lookback,double &upper,double &lower)
  {
   const int n=ArraySize(g_a15_history);
   if(lookback<1 || n<lookback) return false;
   upper=-1.0e100; lower=1.0e100;
   const int first=n-lookback;
   for(int i=first;i<n;i++)
     {
      const double high=MathMax(g_a15_history[i].open,g_a15_history[i].close);
      const double low=MathMin(g_a15_history[i].open,g_a15_history[i].close);
      if(high>upper) upper=high;
      if(low<lower) lower=low;
     }
   return true;
  }
int A15ProcessCompletedBrick(const SA15Brick &brick)
  {
   double upper=0.0,lower=0.0;
   int signal=0;
   if(A15GetDonchian(InpA15DonchianPeriod,upper,lower))
     {
      const double buffer=InpA15BreakoutBufferBricks*InpA15BrickSize;
      if(brick.direction>0 && brick.run>=InpA15EntryRunBricks && brick.close>upper+buffer)
         signal=+1;
      else if(brick.direction<0 && brick.run>=InpA15EntryRunBricks && brick.close<lower-buffer)
         signal=-1;
     }
   A15PushHistory(brick); // Original v1.11 appends AFTER channel test.
   return signal;
  }

CRenkoBuilder g_a12_renko;
CRenkoADX g_a12_adx;
long g_a12_brick_no=0;
long g_a12_signal_no=0;
bool g_a12_failed=false;
bool g_v_position=false;
int g_v_direction=0;
double g_v_entry_price=0.0;
datetime g_v_entry_time=0;
int g_v_cooldown=0;
// Shared read-only position snapshot: exit modules consume this interface,
// not the entry module's private state. Snapshot is rebuilt at each decision.
struct SResearchPosition
  {
   bool is_open;
   int direction;
   double entry_price;
   datetime entry_time;
  };
SResearchPosition PositionSnapshot()
  {
   SResearchPosition position;
   position.is_open=g_v_position;
   position.direction=g_v_direction;
   position.entry_price=g_v_entry_price;
   position.entry_time=g_v_entry_time;
   return position;
  }

long g_v_entries=0,g_v_exits=0,g_v_blocks=0;
// Autonomous mode never uses reference times/prices to open or close a position.
int g_auto_entry_compare_index=0,g_auto_exit_compare_index=0;
int g_auto_entry_match=0,g_auto_entry_diff=0,g_auto_exit_match=0,g_auto_exit_diff=0;

// Original A15 v1.11 tester deal log: fixed reference entries and exits.
// These are historical observations, NOT a reproduced entry strategy or broker fills.
int g_ref_entry_index=0,g_ref_exit_index=0;
int g_ref_entry_seen=0,g_ref_entry_missed=0,g_ref_exit_matched=0,g_ref_exit_diff=0;
datetime RefEntryTime(const int i)
  {
   if(i==0) return D'2026.08.20 18:02:27';
   if(i==1) return D'2026.08.25 03:00:24';
   if(i==2) return D'2026.08.27 13:02:52';
   return 0;
  }
double RefEntryPrice(const int i)
  {
   if(i==0) return 4530.76;
   if(i==1) return 4684.66;
   if(i==2) return 4571.77;
   return 0.0;
  }
int RefEntryDirection(const int i) { return (i==2 ? -1 : 1); }
datetime RefExitTime(const int i)
  {
   if(i==0) return D'2026.08.24 04:17:28';
   if(i==1) return D'2026.08.26 18:15:43';
   if(i==2) return D'2026.08.28 21:17:18';
   return 0;
  }
double RefExitPrice(const int i)
  {
   if(i==0) return 4622.05;
   if(i==1) return 4585.67;
   if(i==2) return 4457.81;
   return 0.0;
  }
string RefExitReason(const int i)
  {
   if(i==0) return "TIME";
   if(i==1) return "OPPOSITE DONCHIAN BREAKOUT";
   if(i==2) return "TP";
   return "";
  }
// Entry-second tick audit: quote equality is a candidate, not proof of an order/fill tick.
long g_entry_trace_seen[3]={0,0,0};
long g_entry_trace_equal[3]={0,0,0};
long g_a15_raw_entry_signals=0;
long g_a15_ref_second_signal_matches=0;
long g_a15_ref_second_direction_matches=0;
long g_a15_ref_second_quote_matches=0;
// Reference time_msc values were observed in the separate v1.47 tester order audit.
// They are NOT independently derived by this no-orders EA.
long g_a15_ref_msc_matches=0;
long g_a15_ref_msc_quote_matches=0;
long g_a15_ref_msc_spread_pass=0;
long g_a15_ref_msc_spread_fail=0;
long RefEntryOrderTickMsc(const int i)
  {
   if(i==0) return 1787248947333;
   if(i==1) return 1787626824126;
   if(i==2) return 1787835772547;
   return 0;
  }

void TraceReferenceEntrySecond(const MqlTick &tick)
  {
   for(int i=0;i<3;i++)
     {
      if(tick.time!=RefEntryTime(i)) continue;
      g_entry_trace_seen[i]++;
      const double quote=(RefEntryDirection(i)>0 ? tick.ask : tick.bid);
      const double reference=RefEntryPrice(i);
      const double tolerance=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
      const bool equal=(MathAbs(quote-reference)<=tolerance);
      if(equal) g_entry_trace_equal[i]++;
      // Bound the log size, but always show a price-equal candidate.
      if(g_entry_trace_seen[i]<=300 || equal)
         PrintFormat("[A15_ENTRY_SECOND_TICK] index=%d seq=%I64d time=%s time_msc=%I64d bid=%.8f ask=%.8f reference=%.8f side_quote=%.8f equal=%d flags=%u NO_ORDERS=1 CANDIDATE_NOT_FILL=1",
            i+1,g_entry_trace_seen[i],TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,
            tick.bid,tick.ask,reference,quote,(int)equal,tick.flags);
      return;
     }
  }
void RefSeedEntry(const MqlTick &tick)
  {
   if(g_ref_entry_index>=3 || tick.time<RefEntryTime(g_ref_entry_index)) return;
   const int i=g_ref_entry_index;
   g_ref_entry_index++;
   if(tick.time!=RefEntryTime(i) || g_v_position)
     {
      g_ref_entry_missed++;
      PrintFormat("[A15_REF_ENTRY_MISSED] index=%d expected=%s observed=%s already_open=%d NO_ORDERS=1",
         i+1,TimeToString(RefEntryTime(i),TIME_DATE|TIME_SECONDS),TimeToString(tick.time,TIME_DATE|TIME_SECONDS),(int)g_v_position);
      return;
     }
   const int direction=RefEntryDirection(i);
   const double quote=(direction>0 ? tick.ask : tick.bid);
   const double reference=RefEntryPrice(i);
   const double tolerance=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
   if(MathAbs(quote-reference)>tolerance)
     {
      // The reference is the ORIGINAL filled price. The first tick observed in
      // that second need not be the original order-fill tick; log but DO NOT veto.
      PrintFormat("[A15_REF_ENTRY_QUOTE_DIFF] index=%d time=%s reference=%.8f quote=%.8f difference=%.8f bid=%.8f ask=%.8f SEED_WITH_REFERENCE=1 NO_ORDERS=1",
         i+1,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),reference,quote,quote-reference,tick.bid,tick.ask);
     }
   g_v_position=true; g_v_direction=direction;
   g_v_entry_price=reference; g_v_entry_time=RefEntryTime(i);
   g_v_entries++; g_ref_entry_seen++;
   PrintFormat("[A15_REF_ENTRY_SEEDED] index=%d time=%s time_msc=%I64d direction=%d reference=%.8f quote=%.8f bid=%.8f ask=%.8f VIRTUAL_NOT_FILL=1 NO_ORDERS=1",
      i+1,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,direction,reference,quote,tick.bid,tick.ask);
  }

// Diagnostic only: never call OrderCheck or OrderSend.
datetime g_probe_exit_time=0;
datetime g_probe_last_second=0;
bool g_probe_first_open_logged=false;
bool g_probe_session_open_logged=false;
datetime g_probe_first_session_open_time=0;
int g_probe_exit_direction=0;
datetime g_probe_first_open_time=0;
int ProbeSecondsOfDay(const datetime value)
  {
   MqlDateTime part={};
   if(!TimeToStruct(value,part)) return -1;
   return part.hour*3600+part.min*60+part.sec;
  }
datetime ProbeTradingSessionEnd(const datetime now)
  {
   MqlDateTime current={};
   if(now<=0 || !TimeToStruct(now,current)) return 0;
   const int seconds=current.hour*3600+current.min*60+current.sec;
   const datetime midnight=now-seconds;
   for(int offset=0;offset<=1;offset++)
     {
      const ENUM_DAY_OF_WEEK day=(ENUM_DAY_OF_WEEK)((current.day_of_week-offset+7)%7);
      for(uint session=0;session<24;session++)
        {
         datetime from=0,to=0;
         if(!SymbolInfoSessionTrade(_Symbol,day,session,from,to)) break;
         const int start_seconds=ProbeSecondsOfDay(from);
         const int end_seconds=ProbeSecondsOfDay(to);
         if(start_seconds<0 || end_seconds<0) continue;
         const datetime start=midnight-offset*86400+start_seconds;
         datetime end=midnight-offset*86400+end_seconds;
         if(end<=start) end+=86400;
         if(now>=start && now<end) return end;
        }
     }
   return 0;
  }
void ProbeExitEnvironment(const MqlTick &tick)
  {
   if(g_probe_exit_time<=0 || tick.time<g_probe_exit_time ||
      (long)(tick.time-g_probe_exit_time)>120 || tick.time==g_probe_last_second) return;
   g_probe_last_second=tick.time;
   const datetime session_end=ProbeTradingSessionEnd(tick.time);
   // First observable tradable environment after the first virtual exit.
   // This is NOT an order fill and does not prove that OrderCheck/OrderSend would succeed.
   const bool env_allowed=(session_end>0 &&
      SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE)==SYMBOL_TRADE_MODE_FULL &&
      TerminalInfoInteger(TERMINAL_CONNECTED)!=0 &&
      TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)!=0 &&
      MQLInfoInteger(MQL_TRADE_ALLOWED)!=0 &&
      AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)!=0 &&
      AccountInfoInteger(ACCOUNT_TRADE_EXPERT)!=0);
   // Session-only observation: independent of other trading permission flags.
   // A hypothetical exit quote is NOT an actual fill or a broker-validated order.
   if(session_end>0 && !g_probe_session_open_logged)
     {
      g_probe_session_open_logged=true;
      g_probe_first_session_open_time=tick.time;
      PrintFormat("[A12_EXIT_SESSION_FIRST_OPEN] decision=%s first_observed=%s wait_seconds=%d direction=%d hypothetical_exit_quote=%.8f bid=%.8f ask=%.8f SESSION_ONLY_NOT_FILL=1 NO_ORDERS=1",
         TimeToString(g_probe_exit_time,TIME_DATE|TIME_SECONDS),
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
         (int)(tick.time-g_probe_exit_time),g_probe_exit_direction,
         (g_probe_exit_direction>0 ? tick.bid : tick.ask),tick.bid,tick.ask);
     }
   if(env_allowed && !g_probe_first_open_logged)
     {
      g_probe_first_open_logged=true;
      g_probe_first_open_time=tick.time;
      PrintFormat("[A12_EXIT_ENV_FIRST_ALLOWED] decision=%s first_observed=%s wait_seconds=%d bid=%.8f ask=%.8f ENV_ONLY_NOT_FILL=1 NO_ORDERS=1",
         TimeToString(g_probe_exit_time,TIME_DATE|TIME_SECONDS),
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
         (int)(tick.time-g_probe_exit_time),tick.bid,tick.ask);
     }
   PrintFormat("[A12_EXIT_ENV_PROBE] time=%s seconds_after_decision=%d session_open=%d session_end=%s trade_mode=%d connected=%d terminal_trade=%d mql_trade=%d account_trade=%d account_expert=%d bid=%.8f ask=%.8f NO_ORDERS=1 OBSERVATION_ONLY=1",
      TimeToString(tick.time,TIME_DATE|TIME_SECONDS),(int)(tick.time-g_probe_exit_time),
      (int)(session_end>0),TimeToString(session_end,TIME_DATE|TIME_SECONDS),
      (int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE),
      (int)TerminalInfoInteger(TERMINAL_CONNECTED),
      (int)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED),
      (int)MQLInfoInteger(MQL_TRADE_ALLOWED),
      (int)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED),
      (int)AccountInfoInteger(ACCOUNT_TRADE_EXPERT),tick.bid,tick.ask);
  }
// Research-only lifecycle markers: no OrderCheck, OrderSend or trade transactions.
void AuditVirtualStage(const string stage,const MqlTick &tick,const string reason)
  {
   PrintFormat("[A15_LIFECYCLE_NOORDERS] stage=%s time=%s time_msc=%I64d reason=%s virtual_position=%d direction=%d entry_time=%s entry_price=%.8f bid=%.8f ask=%.8f cooldown=%d ORDER_REQUEST=NOT_SENT ORDER_RESULT=NOT_AVAILABLE DEAL=NOT_OBSERVED NO_ORDERS=1",
      stage,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,reason,
      (int)g_v_position,g_v_direction,TimeToString(g_v_entry_time,TIME_DATE|TIME_SECONDS),
      g_v_entry_price,tick.bid,tick.ask,g_v_cooldown);
  }
// Observation-only comparison boundary. This EA never observes broker order/fill
// lifecycle; those fields must remain explicitly UNKNOWN, not simulated.
void AuditLifecycleBoundary(const string stage,const MqlTick &tick,const string reason)
  {
   PrintFormat("[A15_V152_BOUNDARY] stage=%s time=%s time_msc=%I64d reason=%s virtual_position=%d virtual_direction=%d virtual_entry_time=%s virtual_entry_price=%.8f virtual_cooldown=%d broker_order=NOT_OBSERVED broker_fill=NOT_OBSERVED broker_position_absent=NOT_VERIFIED broker_cooldown_start=UNKNOWN NO_ORDERS=1",
      stage,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,reason,
      (int)g_v_position,g_v_direction,TimeToString(g_v_entry_time,TIME_DATE|TIME_SECONDS),
      g_v_entry_price,g_v_cooldown);
  }
void VirtualExit(const string why,const MqlTick &tick)
  {
   if(!g_v_position) return;
   AuditVirtualStage("EXIT_DECISION_BEFORE_VIRTUAL_CLOSE",tick,why);
   AuditLifecycleBoundary("EXIT_DECISION_ONLY",tick,why);
   if(InpExitModule==EXIT_A15_FULL_PROTOTYPE)
     {
      const double executable=(g_v_direction>0 ? tick.bid : tick.ask);
      const double move=g_v_direction*(executable-g_v_entry_price);
      const long held=(long)(tick.time-g_v_entry_time);
      PrintFormat("[A15_EXIT_AUDIT] time=%s time_msc=%I64d reason=%s dir=%d entry_time=%s entry=%.8f bid=%.8f ask=%.8f executable=%.8f move=%.8f tp_threshold=%.8f sl_threshold=%.8f held_seconds=%I64d time_threshold_seconds=%I64d VIRTUAL_NOT_FILL=1 NO_ORDERS=1",
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,why,g_v_direction,
         TimeToString(g_v_entry_time,TIME_DATE|TIME_SECONDS),g_v_entry_price,tick.bid,tick.ask,
         executable,move,InpA15TakeProfitBricks*InpA15BrickSize,
         -InpA15StopLossBricks*InpA15BrickSize,held,(long)InpA15MaxHoldMinutes*60);
     }
   PrintFormat("[A12_VIRTUAL_EXIT] time=%s reason=%s direction=%d entry=%.8f exit=%.8f VIRTUAL_NOT_FILL=1",
      TimeToString(tick.time,TIME_DATE|TIME_SECONDS),why,g_v_direction,g_v_entry_price,
      (g_v_direction>0 ? tick.bid : tick.ask));
   // Start the 120-second environment observation at the first virtual exit only.
   if(g_probe_exit_time==0)
     {
      g_probe_exit_time=tick.time;
      g_probe_exit_direction=g_v_direction;
      g_probe_last_second=0;
      PrintFormat("[A12_EXIT_DECISION_ANCHOR] time=%s reason=%s decision_price=%.8f VIRTUAL_NOT_FILL=1 NO_ORDERS=1",
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),why,
         (g_v_direction>0 ? tick.bid : tick.ask));
     }
   const int closed_direction=g_v_direction;
   g_v_position=false;
   g_v_direction=0;
   g_v_cooldown=InpCooldownBricks;
   g_v_exits++;
   AuditVirtualStage("VIRTUAL_EXIT_AND_COOLDOWN_NOT_BROKER_CONFIRMED",tick,why);
   AuditLifecycleBoundary("VIRTUAL_POSITION_CLEARED_COOLDOWN_SET",tick,why);
   if(InpEntryModule==ENTRY_A15_AUTONOMOUS)
     {
      const int i=g_auto_exit_compare_index++;
      const double actual=(closed_direction>0 ? tick.bid : tick.ask);
      const double tol=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
      const bool match=(i<3 && tick.time==RefExitTime(i) && why==RefExitReason(i) && MathAbs(actual-RefExitPrice(i))<=tol);
      if(match) g_auto_exit_match++; else g_auto_exit_diff++;
      PrintFormat("[A15_AUTO_EXIT_COMPARE] index=%d match=%d time=%s time_msc=%I64d reason=%s price=%.8f expected_time=%s expected_reason=%s expected_price=%.8f NO_ORDERS=1 REFERENCE_COMPARISON_ONLY=1",
         i+1,(int)match,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,why,actual,
         (i<3 ? TimeToString(RefExitTime(i),TIME_DATE|TIME_SECONDS) : "NONE"),
         (i<3 ? RefExitReason(i) : "NONE"),(i<3 ? RefExitPrice(i) : 0.0));
     }
   if(InpEntryModule==ENTRY_A15_REFERENCE_SEEDED)
     {
      const int i=g_ref_exit_index;
      if(i<3)
        {
         // Reference direction determines the executable quote.
         const double observed=(why=="" ? 0.0 : (RefEntryDirection(i)>0 ? tick.bid : tick.ask));
         const double tolerance=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
         const bool match=(tick.time==RefExitTime(i) && why==RefExitReason(i) && MathAbs(observed-RefExitPrice(i))<=tolerance);
         if(match) g_ref_exit_matched++; else g_ref_exit_diff++;
         PrintFormat("[A15_REF_EXIT_COMPARE] index=%d match=%d expected_time=%s observed_time=%s observed_time_msc=%I64d expected_reason=%s observed_reason=%s expected_price=%.8f observed_quote=%.8f bid=%.8f ask=%.8f VIRTUAL_NOT_FILL=1 NO_ORDERS=1",
            i+1,(int)match,TimeToString(RefExitTime(i),TIME_DATE|TIME_SECONDS),TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,
            RefExitReason(i),why,RefExitPrice(i),observed,tick.bid,tick.ask);
         g_ref_exit_index++;
        }
     }
  }
bool VirtualSpreadOK(const MqlTick &tick,const double effective_brick)
  {
   return tick.ask-tick.bid<=InpMaxSpreadFraction*effective_brick;
  }
// Independent reference: original A15 v1.11 CheckPriceExit decision order.
// Original FindOurPosition() is replaced ONLY with the same A12 virtual snapshot;
// no original order execution or broker fills are simulated.
string OriginalA15PriceReason(const MqlTick &tick,const SResearchPosition &position)
  {
   if(!position.is_open) return "";
   const int direction=position.direction;
   const double executable=(direction>0 ? tick.bid : tick.ask);
   if(executable<=0.0) return "";
   const double move=direction*(executable-position.entry_price);
   const double tp=InpA15TakeProfitBricks*InpA15BrickSize;
   const double sl=InpA15StopLossBricks*InpA15BrickSize;
   if(move>=tp) return "TP";
   if(move<=-sl) return "SL";
   if(InpA15MaxHoldMinutes>0 && position.entry_time>0)
     {
      const long held_seconds=(long)(TimeCurrent()-position.entry_time);
      if(held_seconds>=(long)InpA15MaxHoldMinutes*60) return "TIME";
     }
   return "";
  }
// v1.51: read-only shadow decision audit; no orders and no changes to the original path.
long g_shadow_price_checks=0;
long g_shadow_price_mismatches=0;
long g_shadow_opposite_checks=0;
long g_shadow_opposite_mismatches=0;
long g_shadow_price_triggers=0;
long g_shadow_opposite_triggers=0;
SA15ExitSnapshot ShadowA15Snapshot(const SResearchPosition &position)
  {
   SA15ExitSnapshot snapshot;
   snapshot.is_open=position.is_open;
   snapshot.direction=position.direction;
   snapshot.entry_price=position.entry_price;
   snapshot.entry_time=position.entry_time;
   return snapshot;
  }
SA15ExitSettings ShadowA15Settings()
  {
   SA15ExitSettings settings;
   settings.brick_size=InpA15BrickSize;
   settings.take_profit_bricks=InpA15TakeProfitBricks;
   settings.stop_loss_bricks=InpA15StopLossBricks;
   settings.max_hold_minutes=InpA15MaxHoldMinutes;
   return settings;
  }
long g_a15_parity_ticks=0;
long g_a15_parity_mismatches=0;
long g_a15_parity_opposite_checks=0;
long g_a15_parity_opposite_mismatches=0;
// Exit module boundary: new exit rules belong here, not in the entry module.
string A12ExitTickReason(const MqlTick &tick,const double effective_brick,const SResearchPosition &position)
  {
   if(InpExitModule==EXIT_DISABLED || !position.is_open) return "";
   const double executable=(position.direction>0 ? tick.bid : tick.ask);
   if(InpExitModule==EXIT_A15_PRICE_TIME_PROTOTYPE || InpExitModule==EXIT_A15_FULL_PROTOTYPE)
     {
      // A15 price exits for both A15 modules: own brick size and hold limit.
      // Opposite Donchian exit is checked separately after the A15 Renko update.
      const double a15_move=position.direction*(executable-position.entry_price);
      if(a15_move>=InpA15TakeProfitBricks*InpA15BrickSize) return "TP";
      if(a15_move<=-InpA15StopLossBricks*InpA15BrickSize) return "SL";
      if(InpA15MaxHoldMinutes>0 && position.entry_time>0 &&
         (long)(tick.time-position.entry_time)>=(long)InpA15MaxHoldMinutes*60) return "TIME";
      return "";
     }
   const double move=position.direction*(executable-position.entry_price);
   if(InpExitModule==EXIT_A12_VERIFIED && move>=InpTakeProfitBricks*effective_brick) return "TP";
   if(move<=-InpStopLossBricks*effective_brick) return "SL";
   if(InpExitModule==EXIT_TIME_WITH_SL)
     {
      if((long)(tick.time-position.entry_time)>=(long)InpAlternativeHoldMinutes*60) return "ALT_TIME";
      return "";
     }
   if(InpMaxHoldMinutes>0 && (long)(tick.time-position.entry_time)>=(long)InpMaxHoldMinutes*60) return "TIME";
   return "";
  }
string A12ExitBrickReason(const int raw_direction,const SResearchPosition &position)
  {
   if(InpExitModule!=EXIT_A12_VERIFIED || !position.is_open) return "";
   if(raw_direction!=0 && raw_direction==-position.direction) return "DI_FLIP";
   return "";
  }
// Entry module boundary: preserve the original final-brick signal.
int A12EntryDecision(const int final_signal)
  {
   if(InpEntryModule==ENTRY_DISABLED) return 0;
   return final_signal;
  }
int OnInit()
  {
   if(!MathIsValidNumber(InpBrickSize) || InpBrickSize<=0.0 ||
      InpADXPeriod<2 || InpADXPeriod>100 ||
      !MathIsValidNumber(InpADXThreshold) || InpADXThreshold<0.0 || InpADXThreshold>100.0 ||
      !MathIsValidNumber(InpMinDISeparation) || InpMinDISeparation<0.0 || InpMinDISeparation>100.0 ||
      InpEntryRunBricks<1 || InpEntryRunBricks>50 ||
      InpTakeProfitBricks<=0.0 || InpStopLossBricks<=0.0 ||
      InpMaxHoldMinutes<0 || InpAlternativeHoldMinutes<1 || InpCooldownBricks<0 ||
      InpMaxSpreadFraction<0.0 ||
      !MathIsValidNumber(InpA15BrickSize) || InpA15BrickSize<=0.0 ||
      !MathIsValidNumber(InpA15TakeProfitBricks) || InpA15TakeProfitBricks<=0.0 ||
      !MathIsValidNumber(InpA15StopLossBricks) || InpA15StopLossBricks<=0.0 ||
      InpA15MaxHoldMinutes<0 || InpA15DonchianPeriod<2 || InpA15DonchianPeriod>A15_MAX_HISTORY ||
      !MathIsValidNumber(InpA15BreakoutBufferBricks) || InpA15BreakoutBufferBricks<0.0 ||
      InpA15EntryRunBricks<1) return INIT_PARAMETERS_INCORRECT;
   const double tick_size=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(!MathIsValidNumber(tick_size) || tick_size<=0.0) return INIT_FAILED;
   const double raw_units=InpBrickSize/tick_size;
   if(!MathIsValidNumber(raw_units) || raw_units<0.5 || raw_units>1e9) return INIT_FAILED;
   const long units=(long)MathMax(1.0,MathRound(raw_units));
   g_a12_renko.Init(tick_size,units);
   g_a12_adx.Init(InpADXPeriod);
   g_a15_renko.Init(InpA15BrickSize);
   ArrayResize(g_a15_history,0); g_a15_brick_no=0;
   g_a12_brick_no=0;
   g_a12_signal_no=0;
   g_a12_failed=false;
   g_v_position=false; g_v_direction=0; g_v_entry_price=0.0;
   g_v_entry_time=0; g_v_cooldown=0;
   g_v_entries=0; g_v_exits=0; g_v_blocks=0;
   g_auto_entry_compare_index=0; g_auto_exit_compare_index=0;
   g_auto_entry_match=0; g_auto_entry_diff=0; g_auto_exit_match=0; g_auto_exit_diff=0;
   g_ref_entry_index=0; g_ref_exit_index=0; g_ref_entry_seen=0; g_ref_entry_missed=0; g_ref_exit_matched=0; g_ref_exit_diff=0;
   g_probe_exit_time=0; g_probe_last_second=0;
   g_probe_first_open_logged=false; g_probe_first_open_time=0;
   g_probe_session_open_logged=false; g_probe_first_session_open_time=0;
   g_probe_exit_direction=0;
   PrintFormat("[A12_MODULE_SELECTION] entry=%d exit=%d NO_ORDERS=1",(int)InpEntryModule,(int)InpExitModule);
   Print("[MODULAR_POSITION_INTERFACE] version=1 shared_snapshot=1 entry=A12 exit=A12_or_alternative NO_ORDERS=1");
   if(InpExitModule==EXIT_A15_PRICE_TIME_PROTOTYPE)
      PrintFormat("[A15_PARTIAL_EXIT] TP=%.4f SL=%.4f hold=%d brick=%.4f OPPOSITE_DONCHIAN_NOT_IMPLEMENTED=1 NO_ORDERS=1",
         InpA15TakeProfitBricks,InpA15StopLossBricks,InpA15MaxHoldMinutes,InpA15BrickSize);
   if(InpExitModule==EXIT_A15_FULL_PROTOTYPE)
      PrintFormat("[A15_FULL_EXIT] brick=%.4f donchian=%d buffer=%.4f run=%d TP=%.4f SL=%.4f hold=%d NO_ORDERS=1",
         InpA15BrickSize,InpA15DonchianPeriod,InpA15BreakoutBufferBricks,InpA15EntryRunBricks,
         InpA15TakeProfitBricks,InpA15StopLossBricks,InpA15MaxHoldMinutes);
   if(InpExitModule==EXIT_TIME_WITH_SL)
      PrintFormat("[A12_ALTERNATIVE_EXIT] hold_minutes=%d stop_loss_bricks=%.4f NO_ORDERS=1",InpAlternativeHoldMinutes,InpStopLossBricks);
   PrintFormat("[A12_ENTRY_OBSERVER_START] symbol=%s effective_brick=%.8f period=%d threshold=%.4f min_di=%.4f run=%d NO_ORDERS=1",
               _Symbol,(double)units*tick_size,InpADXPeriod,InpADXThreshold,InpMinDISeparation,InpEntryRunBricks);
   return INIT_SUCCEEDED;
  }
void OnTick()
  {
   if(g_a12_failed) return;
   MqlTick tick={};
   if(!SymbolInfoTick(_Symbol,tick) || !MathIsValidNumber(tick.bid) ||
      !MathIsValidNumber(tick.ask) || tick.bid<=0.0 || tick.ask<tick.bid || tick.time<=0) return;
   bool closed_this_tick=false;
   if(InpEntryModule==ENTRY_A15_REFERENCE_SEEDED) TraceReferenceEntrySecond(tick);
   if(InpEntryModule==ENTRY_A15_REFERENCE_SEEDED) RefSeedEntry(tick);
   const double effective_brick=(double)MathMax(1.0,MathRound(InpBrickSize/SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)))*SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   if(g_v_position)
     {
      const SResearchPosition position=PositionSnapshot();
      const string reason=A12ExitTickReason(tick,effective_brick,position);
      if(InpExitModule==EXIT_A15_FULL_PROTOTYPE)
        {
         const string original_reason=OriginalA15PriceReason(tick,position);
         g_a15_parity_ticks++;
         if(original_reason!=reason)
           {
            g_a15_parity_mismatches++;
            PrintFormat("[A15_PARITY_FIRST_OR_NEXT_DIFF] time=%s time_msc=%I64d original=%s modular=%s dir=%d entry=%.8f bid=%.8f ask=%.8f NO_ORDERS=1",
               TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,original_reason,reason,
               position.direction,position.entry_price,tick.bid,tick.ask);
           }
        }
      if(InpExitModule==EXIT_A15_FULL_PROTOTYPE)
        {
         const SA15ExitSnapshot shadow_position=ShadowA15Snapshot(position);
         const SA15ExitSettings shadow_settings=ShadowA15Settings();
         const string shadow_reason=A15ExitPriceTimeDecision(shadow_position,shadow_settings,tick,TimeCurrent());
         g_shadow_price_checks++;
         if(shadow_reason!="") g_shadow_price_triggers++;
         if(shadow_reason!=reason)
           {
            g_shadow_price_mismatches++;
            PrintFormat("[A15_SHADOW_PRICE_DIFF] time_msc=%I64d baseline=%s shadow=%s dir=%d entry=%.8f entry_time=%s bid=%.8f ask=%.8f NO_ORDERS=1",tick.time_msc,reason,shadow_reason,position.direction,position.entry_price,TimeToString(position.entry_time,TIME_DATE|TIME_SECONDS),tick.bid,tick.ask);
           }
        }
      if(reason!="") { VirtualExit(reason,tick); closed_this_tick=true; }
     }
   // Observe every valid tick, including ticks that create no Renko brick.
   ProbeExitEnvironment(tick);
   // A15 original sequence: price exit first, then update independent BID Renko;
   // retain only the newest completed brick signal on this tick.
   SA15Brick a15_bricks[];
   const int a15_n=g_a15_renko.PushPrice(tick.bid,a15_bricks);
   int a15_final_signal=0;
   for(int ai=0;ai<a15_n;ai++)
     {
      a15_final_signal=A15ProcessCompletedBrick(a15_bricks[ai]);
      g_a15_brick_no++;
      if(InpExitModule==EXIT_A15_FULL_PROTOTYPE)
         PrintFormat("[A15_EXIT_BRICK] no=%I64d time=%s open=%.8f close=%.8f direction=%d run=%d signal=%d",
            g_a15_brick_no,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
            a15_bricks[ai].open,a15_bricks[ai].close,a15_bricks[ai].direction,
            a15_bricks[ai].run,a15_final_signal);
     }
   // v1.46: audit the exact tick on which the original A15 Renko/Donchian
   // machinery produces a raw non-zero entry signal. This is observation only;
   // no OrderCheck/OrderSend and no claim that a signal equals an actual fill.
   if(a15_n>0 && a15_final_signal!=0)
     {
      g_a15_raw_entry_signals++;
      int ref_index=-1;
      for(int ri=0;ri<3;ri++)
         if(tick.time==RefEntryTime(ri)) { ref_index=ri; break; }
      const bool ref_second=(ref_index>=0);
      const bool ref_dir=(ref_second && a15_final_signal==RefEntryDirection(ref_index));
      const double side_quote=(a15_final_signal>0 ? tick.ask : tick.bid);
      const double ref_price=(ref_second ? RefEntryPrice(ref_index) : 0.0);
      const double tolerance=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
      const bool ref_quote=(ref_second && MathAbs(side_quote-ref_price)<=tolerance);
      if(ref_second) g_a15_ref_second_signal_matches++;
      if(ref_dir) g_a15_ref_second_direction_matches++;
      if(ref_quote) g_a15_ref_second_quote_matches++;
      // Compare the raw signal's tick against the previously recorded
      // original-copy order tick. Spread is a quote-only precheck, NOT OrderCheck.
      if(ref_second && tick.time_msc==RefEntryOrderTickMsc(ref_index))
        {
         g_a15_ref_msc_matches++;
         if(ref_dir && ref_quote) g_a15_ref_msc_quote_matches++;
         const double spread=tick.ask-tick.bid;
         const bool spread_ok=(spread<=InpA15BrickSize*InpMaxSpreadFraction);
         if(spread_ok) g_a15_ref_msc_spread_pass++;
         else g_a15_ref_msc_spread_fail++;
         PrintFormat("[A15_REFERENCE_ORDER_TICK_COMPARE] index=%d time_msc=%I64d signal=%d ref_direction=%d direction_match=%d quote=%.8f ref_price=%.8f price_match=%d spread=%.8f spread_limit=%.8f spread_precheck=%d NO_ORDERS=1 REFERENCE_TIME_FROM_V147=1 NOT_ORDER_REPLAY=1",
            ref_index+1,tick.time_msc,a15_final_signal,RefEntryDirection(ref_index),(int)ref_dir,
            side_quote,ref_price,(int)ref_quote,spread,InpA15BrickSize*InpMaxSpreadFraction,(int)spread_ok);
        }

      PrintFormat("[A15_RAW_ENTRY_SIGNAL] no=%I64d time=%s time_msc=%I64d signal=%d bricks_on_tick=%d bid=%.8f ask=%.8f side_quote=%.8f ref_index=%d ref_second=%d ref_direction_match=%d ref_price=%.8f ref_quote_match=%d NO_ORDERS=1 RAW_SIGNAL_NOT_FILL=1",
         g_a15_raw_entry_signals,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,
         a15_final_signal,a15_n,tick.bid,tick.ask,side_quote,ref_index+1,(int)ref_second,
         (int)ref_dir,ref_price,(int)ref_quote);
     }

   if(InpExitModule==EXIT_A15_FULL_PROTOTYPE && g_v_position && a15_n>0)
     {
      // Original UpdateRenkoAndTrade: only the newest completed brick signal.
      const bool original_opposite=(a15_final_signal!=0 && a15_final_signal!=g_v_direction);
      const bool modular_opposite=(a15_final_signal!=0 && a15_final_signal!=g_v_direction);
      g_a15_parity_opposite_checks++;
      if(original_opposite!=modular_opposite) g_a15_parity_opposite_mismatches++;
      const SResearchPosition shadow_position_source=PositionSnapshot();
      const SA15ExitSnapshot shadow_position=ShadowA15Snapshot(shadow_position_source);
      const string shadow_reason=A15ExitOppositeDecision(shadow_position,a15_final_signal);
      const bool shadow_opposite=(shadow_reason!="");
      g_shadow_opposite_checks++;
      if(shadow_opposite) g_shadow_opposite_triggers++;
      if(original_opposite!=shadow_opposite)
        {
         g_shadow_opposite_mismatches++;
         PrintFormat("[A15_SHADOW_OPPOSITE_DIFF] time_msc=%I64d baseline=%d shadow=%d reason=%s signal=%d dir=%d bid=%.8f ask=%.8f NO_ORDERS=1",tick.time_msc,(int)original_opposite,(int)shadow_opposite,shadow_reason,a15_final_signal,g_v_direction,tick.bid,tick.ask);
        }
     }
   if(InpExitModule==EXIT_A15_FULL_PROTOTYPE && g_v_position &&
      a15_final_signal!=0 && a15_final_signal!=g_v_direction)
     {
      PrintFormat("[A15_OPPOSITE_SIGNAL] time=%s direction=%d position_direction=%d",
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),a15_final_signal,g_v_direction);
      VirtualExit("OPPOSITE DONCHIAN BREAKOUT",tick);
      closed_this_tick=true;
     }
   if(InpEntryModule==ENTRY_A15_AUTONOMOUS)
     {
      // Match original UpdateRenkoAndTrade order: decrement cooldown on EVERY
      // completed-brick tick, then check position/closed-this-tick/spread/signal.
      if(a15_n>0 && g_v_cooldown>0)
        {
         const int audit_cooldown_before=g_v_cooldown;
         g_v_cooldown-=a15_n;
         if(g_v_cooldown<0) g_v_cooldown=0;
         PrintFormat("[A15_LIFECYCLE_COOLDOWN] time_msc=%I64d before=%d bricks=%d after=%d VIRTUAL_ONLY=1 NO_ORDERS=1",tick.time_msc,audit_cooldown_before,a15_n,g_v_cooldown);
         AuditLifecycleBoundary("VIRTUAL_COOLDOWN_DECREMENT",tick,"BRICKS");
        }
      if(a15_n>0 && !g_v_position && !closed_this_tick &&
         g_v_cooldown==0 && a15_final_signal!=0)
        {
         const double spread=tick.ask-tick.bid;
         const double limit=InpMaxSpreadFraction*InpA15BrickSize;
         if(spread<=limit)
           {
            const int dir=a15_final_signal;
            const double price=(dir>0 ? tick.ask : tick.bid);
            g_v_position=true; g_v_direction=dir;
            g_v_entry_price=price; g_v_entry_time=tick.time; g_v_entries++;
            AuditVirtualStage("VIRTUAL_ENTRY_NOT_BROKER_CONFIRMED",tick,"ENTRY");
            AuditLifecycleBoundary("VIRTUAL_ENTRY_ONLY",tick,"ENTRY");
            const int i=g_auto_entry_compare_index++;
            const double tol=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*0.5+1e-8;
            const bool match=(i<3 && tick.time_msc==RefEntryOrderTickMsc(i) &&
                              dir==RefEntryDirection(i) && MathAbs(price-RefEntryPrice(i))<=tol);
            if(match) g_auto_entry_match++; else g_auto_entry_diff++;
            PrintFormat("[A15_AUTO_ENTRY_COMPARE] index=%d match=%d time=%s time_msc=%I64d dir=%d price=%.8f bid=%.8f ask=%.8f spread=%.8f expected_msc=%I64d expected_dir=%d expected_price=%.8f NO_ORDERS=1 REFERENCE_COMPARISON_ONLY=1",
               i+1,(int)match,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,dir,price,tick.bid,tick.ask,spread,
               (i<3 ? RefEntryOrderTickMsc(i) : (long)0),(i<3 ? RefEntryDirection(i) : 0),(i<3 ? RefEntryPrice(i) : 0.0));
           }
         else
           {
            g_v_blocks++;
            PrintFormat("[A15_AUTO_SPREAD_BLOCK] time=%s time_msc=%I64d spread=%.8f limit=%.8f NO_ORDERS=1",
               TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,spread,limit);
           }
        }
      return; // A15 autonomous path never uses A12 entry or reference seeding.
     }
   if(InpEntryModule==ENTRY_A15_REFERENCE_SEEDED) return; // reference-only mode
   SRenkoBrick bricks[];
   const int n=g_a12_renko.PushPrice(tick.bid,bricks);
   if(n<0)
     {
      g_a12_failed=true;
      Print("[A12_ENTRY_OBSERVER_ERROR] renko builder stopped");
      return;
     }
   if(n==0) return;
   int final_signal=0;
   int final_raw_direction=0;
   for(int i=0;i<n;i++)
     {
      int raw_direction=0;
      final_signal=A12_ProcessCompletedBrick(g_a12_adx,bricks[i],
                   InpADXThreshold,InpMinDISeparation,InpEntryRunBricks,raw_direction);
      final_raw_direction=raw_direction;
      g_a12_brick_no++;
      PrintFormat("[A12_ENTRY_BRICK] no=%I64d time=%s open=%.8f close=%.8f direction=%d run=%d raw=%d signal=%d",
                  g_a12_brick_no,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
                  bricks[i].open,bricks[i].close,bricks[i].direction,bricks[i].run,raw_direction,final_signal);
     }
   if(g_v_cooldown>0)
     {
      const int before=g_v_cooldown;
      g_v_cooldown-=n;
      if(g_v_cooldown<0) g_v_cooldown=0;
      PrintFormat("[A12_VIRTUAL_COOLDOWN_STEP] time=%s before=%d bricks=%d after=%d",
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),before,n,g_v_cooldown);
     }
   if(g_v_position)
     {
      const SResearchPosition position=PositionSnapshot();
      const string brick_exit=A12ExitBrickReason(final_raw_direction,position);
      if(brick_exit!="") VirtualExit(brick_exit,tick);
      return;
     }
   // Original A12 uses ONLY the final brick's signal for each tick.
   const int selected_signal=A12EntryDecision(final_signal);
   if(selected_signal!=0)
     {
      g_a12_signal_no++;
      PrintFormat("[A12_ENTRY_RAW_CANDIDATE] no=%I64d time=%s direction=%d raw=%d bricks_this_tick=%d brick_no=%I64d",
                  g_a12_signal_no,TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
                  selected_signal,final_raw_direction,n,g_a12_brick_no);
      string gate="ENTRY_CANDIDATE";
      if(closed_this_tick) gate="CLOSED_THIS_TICK";
      else if(g_v_cooldown>0) gate="COOLDOWN";
      PrintFormat("[A12_VIRTUAL_SIGNAL_GATE] time=%s signal=%d gate=%s cooldown=%d VIRTUAL_NOT_FILL=1",
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),selected_signal,gate,g_v_cooldown);
      if(gate!="ENTRY_CANDIDATE") { g_v_blocks++; return; }
      if(!VirtualSpreadOK(tick,effective_brick))
        {
         PrintFormat("[A12_VIRTUAL_ENTRY_BLOCK] time=%s reason=SPREAD",TimeToString(tick.time,TIME_DATE|TIME_SECONDS));
         g_v_blocks++;
         return;
        }
      g_v_position=true;
      g_v_direction=selected_signal;
      g_v_entry_price=(selected_signal>0 ? tick.ask : tick.bid);
      g_v_entry_time=tick.time;
      g_v_entries++;
      if(InpExitModule==EXIT_A15_FULL_PROTOTYPE)
         PrintFormat("[A15_EXIT_AUDIT_ENTRY] time=%s time_msc=%I64d dir=%d entry=%.8f bid=%.8f ask=%.8f tp_threshold=%.8f sl_threshold=%.8f hold_seconds=%I64d VIRTUAL_NOT_FILL=1 NO_ORDERS=1",
            TimeToString(tick.time,TIME_DATE|TIME_SECONDS),tick.time_msc,g_v_direction,g_v_entry_price,
            tick.bid,tick.ask,InpA15TakeProfitBricks*InpA15BrickSize,
            InpA15StopLossBricks*InpA15BrickSize,(long)InpA15MaxHoldMinutes*60);
      PrintFormat("[A12_VIRTUAL_ENTRY_REQUEST] time=%s dir=%d price=%.8f cooldown=%d VIRTUAL_NOT_FILL=1",
         TimeToString(tick.time,TIME_DATE|TIME_SECONDS),selected_signal,g_v_entry_price,g_v_cooldown);
     }
  }
void OnDeinit(const int reason)
  {
   if(InpEntryModule==ENTRY_A15_AUTONOMOUS)
      PrintFormat("[A15_AUTO_LIFECYCLE_SUMMARY] entries=%I64d exits=%I64d open=%d entry_match=%d entry_diff=%d exit_match=%d exit_diff=%d reference_entries=3 reference_exits=3 NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
         g_v_entries,g_v_exits,(int)g_v_position,g_auto_entry_match,g_auto_entry_diff,g_auto_exit_match,g_auto_exit_diff);
   for(int i=0;i<3;i++)
      PrintFormat("[A15_ENTRY_SECOND_SUMMARY] index=%d ticks=%I64d quote_equal_candidates=%I64d NO_ORDERS=1 NOT_PROOF_OF_FILL=1",
         i+1,g_entry_trace_seen[i],g_entry_trace_equal[i]);
   PrintFormat("[A15_REFERENCE_ORDER_TICK_SUMMARY] reference_count=3 signal_same_msc=%I64d same_msc_direction_and_price=%I64d spread_pass=%I64d spread_fail=%I64d NO_ORDERS=1 REFERENCE_TIME_FROM_V147=1 NOT_ORDER_REPLAY=1",
      g_a15_ref_msc_matches,g_a15_ref_msc_quote_matches,g_a15_ref_msc_spread_pass,g_a15_ref_msc_spread_fail);
   PrintFormat("[A15_ENTRY_SIGNAL_SUMMARY] raw_signals=%I64d ref_second_matches=%I64d ref_direction_matches=%I64d ref_quote_matches=%I64d NO_ORDERS=1 RAW_SIGNAL_NOT_FILL=1",
      g_a15_raw_entry_signals,g_a15_ref_second_signal_matches,g_a15_ref_second_direction_matches,g_a15_ref_second_quote_matches);
   if(InpEntryModule==ENTRY_A15_REFERENCE_SEEDED)
      PrintFormat("[A15_REF_AUDIT_SUMMARY] seeded=%d missed=%d exit_matched=%d exit_different=%d exit_unobserved=%d open=%d NO_ORDERS=1 ORIGINAL_FILLS_NOT_REPRODUCED=1",
         g_ref_entry_seen,g_ref_entry_missed,g_ref_exit_matched,g_ref_exit_diff,3-g_ref_exit_index,(int)g_v_position);
   PrintFormat("[A15_SHADOW_SUMMARY] price_checks=%I64d price_triggers=%I64d price_mismatches=%I64d opposite_checks=%I64d opposite_triggers=%I64d opposite_mismatches=%I64d entries=%I64d exits=%I64d open=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_shadow_price_checks,g_shadow_price_triggers,g_shadow_price_mismatches,g_shadow_opposite_checks,g_shadow_opposite_triggers,g_shadow_opposite_mismatches,g_v_entries,g_v_exits,(int)g_v_position);
   PrintFormat("[A15_PARITY_SUMMARY] price_ticks=%I64d price_mismatches=%I64d opposite_checks=%I64d opposite_mismatches=%I64d NO_ORDERS=1 ORIGINAL_EXECUTION_NOT_REPRODUCED=1",
      g_a15_parity_ticks,g_a15_parity_mismatches,g_a15_parity_opposite_checks,g_a15_parity_opposite_mismatches);
   PrintFormat("[A12_EXIT_SESSION_SUMMARY] decision=%s first_session_open=%s wait_seconds=%d observed=%d SESSION_ONLY_NOT_FILL=1 NO_ORDERS=1",
      TimeToString(g_probe_exit_time,TIME_DATE|TIME_SECONDS),
      TimeToString(g_probe_first_session_open_time,TIME_DATE|TIME_SECONDS),
      (g_probe_exit_time>0 && g_probe_first_session_open_time>0 ? (int)(g_probe_first_session_open_time-g_probe_exit_time) : -1),
      (int)g_probe_session_open_logged);
   PrintFormat("[A12_EXIT_ENV_SUMMARY] decision=%s first_allowed=%s wait_seconds=%d observed=%d ENV_ONLY_NOT_FILL=1 NO_ORDERS=1",
      TimeToString(g_probe_exit_time,TIME_DATE|TIME_SECONDS),
      TimeToString(g_probe_first_open_time,TIME_DATE|TIME_SECONDS),
      (g_probe_exit_time>0 && g_probe_first_open_time>0 ? (int)(g_probe_first_open_time-g_probe_exit_time) : -1),
      (int)g_probe_first_open_logged);
   PrintFormat("[A12_ENTRY_OBSERVER_RESULT] bricks=%I64d raw_candidates=%I64d reason=%d NO_ORDERS=1",
               g_a12_brick_no,g_a12_signal_no,reason);
   PrintFormat("[A12_VIRTUAL_RESULT] entries=%I64d exits=%I64d blocks=%I64d open=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
      g_v_entries,g_v_exits,g_v_blocks,(int)g_v_position);
  }
