//+------------------------------------------------------------------+
//| A10_Entry_Settings_v1_00.mqh                                    |
//| Entry-only settings extracted from A10 original v1.30.           |
//| NO broker orders. TP/SL/hold/cooldown intentionally excluded.    |
//+------------------------------------------------------------------+
#ifndef A10_ENTRY_SETTINGS_V1_00_MQH
#define A10_ENTRY_SETTINGS_V1_00_MQH

struct SA10EntryModeSettings100
  {
   bool enabled;
   double brick_size;
   int bb_period;
   double deviation;
   int entry_run;
   double squeeze_max_width;
  };

struct SA10EntrySettings100
  {
   bool skip_opposite_signals;
   SA10EntryModeSettings100 breakout;
   SA10EntryModeSettings100 reentry;
   SA10EntryModeSettings100 midline;
   SA10EntryModeSettings100 squeeze;
  };

void A10EntryDefaults100(SA10EntrySettings100 &s)
  {
   s.skip_opposite_signals=true;
   s.breakout.enabled=true;s.breakout.brick_size=17.0;s.breakout.bb_period=20;s.breakout.deviation=1.0;s.breakout.entry_run=2;s.breakout.squeeze_max_width=1.0;
   s.reentry.enabled=true;s.reentry.brick_size=30.0;s.reentry.bb_period=31;s.reentry.deviation=1.2;s.reentry.entry_run=1;s.reentry.squeeze_max_width=1.0;
   s.midline.enabled=true;s.midline.brick_size=30.0;s.midline.bb_period=5;s.midline.deviation=3.0;s.midline.entry_run=1;s.midline.squeeze_max_width=1.0;
   s.squeeze.enabled=true;s.squeeze.brick_size=14.0;s.squeeze.bb_period=18;s.squeeze.deviation=2.4;s.squeeze.entry_run=1;s.squeeze.squeeze_max_width=34.5;
  }

bool A10ValidateMode100(const SA10EntryModeSettings100 &m,const bool squeeze_mode=false)
  {
   if(!m.enabled)return true;
   if(!MathIsValidNumber(m.brick_size)||m.brick_size<=0.0)return false;
   if(m.bb_period<2||m.bb_period>500)return false;
   if(!MathIsValidNumber(m.deviation)||m.deviation<=0.0||m.deviation>10.0)return false;
   if(m.entry_run<1||m.entry_run>50)return false;
   if(squeeze_mode&&(!MathIsValidNumber(m.squeeze_max_width)||m.squeeze_max_width<=0.0||m.squeeze_max_width>1000.0))return false;
   return true;
  }

bool A10ValidateEntrySettings100(const SA10EntrySettings100 &s)
  {
   if(!s.breakout.enabled&&!s.reentry.enabled&&!s.midline.enabled&&!s.squeeze.enabled)return false;
   return A10ValidateMode100(s.breakout)&&A10ValidateMode100(s.reentry)&&A10ValidateMode100(s.midline)&&A10ValidateMode100(s.squeeze,true);
  }
#endif
