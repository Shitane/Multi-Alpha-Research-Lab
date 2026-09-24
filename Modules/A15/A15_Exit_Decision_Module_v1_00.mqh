#ifndef A15_EXIT_DECISION_MODULE_V1_00_MQH
#define A15_EXIT_DECISION_MODULE_V1_00_MQH
// Research-only decision module extracted from original A15 v1.11.
// No trade calls, position selection, Renko generation or state mutation.
// The caller MUST supply broker-confirmed entry price/time for live parity.
struct SA15ExitSnapshot
  {
   bool is_open;
   int direction; // +1 BUY, -1 SELL
   double entry_price;
   datetime entry_time;
  };
struct SA15ExitSettings
  {
   double brick_size;
   double take_profit_bricks;
   double stop_loss_bricks;
   int max_hold_minutes;
  };
// Priority is original CheckPriceExit(): TP -> SL -> TIME.
// now_time must be TimeCurrent() at the original decision point.
string A15ExitPriceTimeDecision(const SA15ExitSnapshot &position,
                                const SA15ExitSettings &settings,
                                const MqlTick &tick,
                                const datetime now_time)
  {
   if(!position.is_open || (position.direction!=1 && position.direction!=-1)) return "";
   const double executable=(position.direction>0 ? tick.bid : tick.ask);
   if(executable<=0.0) return "";
   const double move=position.direction*(executable-position.entry_price);
   if(move>=settings.take_profit_bricks*settings.brick_size) return "TP";
   if(move<=-settings.stop_loss_bricks*settings.brick_size) return "SL";
   if(settings.max_hold_minutes>0 && position.entry_time>0)
     {
      const long held_seconds=(long)(now_time-position.entry_time);
      if(held_seconds>=(long)settings.max_hold_minutes*60) return "TIME";
     }
   return "";
  }
// Called ONLY after the caller has processed all bricks of the tick and
// retained the newest completed brick's Donchian signal (original A15 rule).
// The caller is responsible for original scheduling: pending price exit first,
// then Renko update, and for preserving an already-pending exit reason.
string A15ExitOppositeDecision(const SA15ExitSnapshot &position,
                               const int newest_completed_signal)
  {
   if(position.is_open && (position.direction==1 || position.direction==-1) &&
      newest_completed_signal!=0 && newest_completed_signal!=position.direction)
      return "OPPOSITE DONCHIAN BREAKOUT";
   return "";
  }
#endif
