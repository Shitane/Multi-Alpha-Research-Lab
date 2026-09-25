//+------------------------------------------------------------------+
//| A13 Exit Module v1.00                                           |
//| Virtual exit decisions extracted from verified A13.              |
//| SAFETY: NO_ORDERS. No broker execution functions.                |
//+------------------------------------------------------------------+
#ifndef __A13_EXIT_MODULE_V1_00_MQH__
#define __A13_EXIT_MODULE_V1_00_MQH__

enum EA13ExitDecision { A13_EXIT_NONE=0,A13_EXIT_TP,A13_EXIT_SL,A13_EXIT_TIME,A13_EXIT_MA_FLIP };

class CA13Exit
{
 private:
  double m_brick,m_tp_bricks,m_sl_bricks;
  int m_max_hold_minutes;
 public:
  CA13Exit(){m_brick=0;m_tp_bricks=0;m_sl_bricks=0;m_max_hold_minutes=0;}
  bool Configure(const double effective_brick,const double tp_bricks,const double sl_bricks,const int max_hold_minutes)
  {
   if(!MathIsValidNumber(effective_brick)||effective_brick<=0||
      !MathIsValidNumber(tp_bricks)||tp_bricks<=0||
      !MathIsValidNumber(sl_bricks)||sl_bricks<=0||max_hold_minutes<0)return false;
   m_brick=effective_brick;m_tp_bricks=tp_bricks;m_sl_bricks=sl_bricks;m_max_hold_minutes=max_hold_minutes;return true;
  }
  EA13ExitDecision TickDecision(const int direction,const double open_price,const datetime open_time,const MqlTick &tick)
  {
   if(direction!=1&&direction!=-1)return A13_EXIT_NONE;
   const double executable=(direction>0?tick.bid:tick.ask);
   if(!MathIsValidNumber(executable)||executable<=0)return A13_EXIT_NONE;
   const double move=direction*(executable-open_price);
   if(move>=m_tp_bricks*m_brick)return A13_EXIT_TP;
   if(move<=-m_sl_bricks*m_brick)return A13_EXIT_SL;
   if(m_max_hold_minutes>0&&open_time>0&&(long)(tick.time-open_time)>=(long)m_max_hold_minutes*60)return A13_EXIT_TIME;
   return A13_EXIT_NONE;
  }
  EA13ExitDecision CompletedRenkoDecision(const int position_direction,const int final_alignment)
  {
   if((position_direction==1||position_direction==-1)&&final_alignment!=0&&final_alignment==-position_direction)return A13_EXIT_MA_FLIP;
   return A13_EXIT_NONE;
  }
  string ReasonText(const EA13ExitDecision d)
  {
   if(d==A13_EXIT_TP)return "TP";if(d==A13_EXIT_SL)return "SL";if(d==A13_EXIT_TIME)return "TIME";if(d==A13_EXIT_MA_FLIP)return "MA_FLIP";return "";
  }
};
#endif
