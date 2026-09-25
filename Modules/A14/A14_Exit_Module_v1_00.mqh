//+------------------------------------------------------------------+
//| A14 Exit Module v1.00                                           |
//| Virtual TP/SL/TIME lifecycle. NO ORDERS.                        |
//+------------------------------------------------------------------+
#ifndef __A14_EXIT_MODULE_V1_00_MQH__
#define __A14_EXIT_MODULE_V1_00_MQH__
class CA14ExitModule
{
 private: double m_tp_bricks,m_sl_bricks,m_brick; int m_hold_minutes;
 public:
 void Init(const double tp_bricks,const double sl_bricks,const int hold_minutes,const double brick){
  m_tp_bricks=tp_bricks;m_sl_bricks=sl_bricks;m_hold_minutes=hold_minutes;m_brick=brick;
 }
 string Check(const MqlTick &t,const bool open,const int dir,const double open_price,const datetime open_time)const{
  if(!open)return "";
  const double ex=(dir>0?t.bid:t.ask),move=dir*(ex-open_price);
  if(move>=m_tp_bricks*m_brick)return "TP";
  if(move<=-m_sl_bricks*m_brick)return "SL";
  if(m_hold_minutes>0&&open_time>0&&(long)(t.time-open_time)>=(long)m_hold_minutes*60)return "TIME";
  return "";
 }
};
#endif
