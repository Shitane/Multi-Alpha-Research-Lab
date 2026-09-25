//+------------------------------------------------------------------+
//| A10_Exit_Module_v1_00.mqh                                       |
//| Split from verified A10 Bollinger lifecycle.                     |
//| Exit decision only. Research-only. NO ORDER OPERATIONS.           |
//+------------------------------------------------------------------+
#ifndef A10_EXIT_MODULE_V1_00_MQH
#define A10_EXIT_MODULE_V1_00_MQH

enum ENUM_A10_EXIT_REASON
{
 A10_EXIT_NONE=0,
 A10_EXIT_TP=1,
 A10_EXIT_SL=2,
 A10_EXIT_TIME=3,
 A10_EXIT_BB_MID=4,
 A10_EXIT_BB_OPPOSITE=5
};

struct SA10ExitDecision
{
 bool exit;
 ENUM_A10_EXIT_REASON reason;
};

class CA10ExitModule
{
 double m_tp_bricks,m_sl_bricks;
 int m_max_hold_minutes;
public:
 bool Configure(const double tp_bricks,const double sl_bricks,const int max_hold_minutes)
 {
  if(tp_bricks<=0.0||sl_bricks<=0.0||max_hold_minutes<0)return false;
  m_tp_bricks=tp_bricks;m_sl_bricks=sl_bricks;m_max_hold_minutes=max_hold_minutes;return true;
 }
 void Clear(SA10ExitDecision &d)const{d.exit=false;d.reason=A10_EXIT_NONE;}

 // Source-faithful price-exit priority: TP -> SL -> TIME.
 void CheckPrice(const int position_direction,const double open_price,const datetime open_time,
                 const double bid,const double ask,const datetime now,const double brick,
                 SA10ExitDecision &d)const
 {
  Clear(d);if((position_direction!=1&&position_direction!=-1)||open_price<=0||brick<=0)return;
  const double executable=(position_direction>0?bid:ask);if(executable<=0)return;
  const double move=position_direction*(executable-open_price);
  if(m_tp_bricks>0&&move>=m_tp_bricks*brick){d.exit=true;d.reason=A10_EXIT_TP;return;}
  if(m_sl_bricks>0&&move<=-m_sl_bricks*brick){d.exit=true;d.reason=A10_EXIT_SL;return;}
  if(m_max_hold_minutes>0&&open_time>0&&now>=open_time &&
     (long)(now-open_time)>=(long)m_max_hold_minutes*60)
  {d.exit=true;d.reason=A10_EXIT_TIME;return;}
 }

 // Completed-brick owner exit. Re-entry uses BB mid; other modes use opposite raw signal.
 void CheckSignal(const int mode,const int position_direction,const int completed,
                  const int raw_signal,const bool bb_ready,const double final_close,
                  const double bb_mid,SA10ExitDecision &d)const
 {
  Clear(d);if(completed<=0||(position_direction!=1&&position_direction!=-1))return;
  if(mode==1 && bb_ready)
  {
   if(position_direction>0&&final_close>=bb_mid){d.exit=true;d.reason=A10_EXIT_BB_MID;return;}
   if(position_direction<0&&final_close<=bb_mid){d.exit=true;d.reason=A10_EXIT_BB_MID;return;}
  }
  else if(raw_signal!=0&&raw_signal==-position_direction)
  {d.exit=true;d.reason=A10_EXIT_BB_OPPOSITE;return;}
 }
 string ReasonText(const ENUM_A10_EXIT_REASON r)const
 {
  if(r==A10_EXIT_TP)return "TP";if(r==A10_EXIT_SL)return "SL";if(r==A10_EXIT_TIME)return "TIME";
  if(r==A10_EXIT_BB_MID)return "BB_MID";if(r==A10_EXIT_BB_OPPOSITE)return "BB_OPPOSITE";return "";
 }
};
#endif
