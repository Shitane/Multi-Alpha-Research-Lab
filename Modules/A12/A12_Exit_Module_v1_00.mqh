// A12 Exit Module - research-only, NO ORDERS.
// Separates A12 exit decisions from the host while preserving the verified
// executable-price, TP/SL/TIME priority, and completed-Renko DI_FLIP semantics.
#ifndef A12_EXIT_MODULE_V1_00_MQH
#define A12_EXIT_MODULE_V1_00_MQH

enum ENUM_A12_EXIT_REASON
  {
   A12_EXIT_NONE=0,
   A12_EXIT_TP,
   A12_EXIT_SL,
   A12_EXIT_TIME,
   A12_EXIT_DI_FLIP
  };

class CA12ExitModule
  {
private:
   double m_brick;
   double m_tp_bricks;
   double m_sl_bricks;
   int    m_max_hold_minutes;

public:
   bool Configure(const double effective_brick,
                  const double take_profit_bricks,
                  const double stop_loss_bricks,
                  const int max_hold_minutes)
     {
      if(effective_brick<=0.0 || take_profit_bricks<=0.0 ||
         stop_loss_bricks<=0.0 || max_hold_minutes<0) return false;
      m_brick=effective_brick;
      m_tp_bricks=take_profit_bricks;
      m_sl_bricks=stop_loss_bricks;
      m_max_hold_minutes=max_hold_minutes;
      return true;
     }

   ENUM_A12_EXIT_REASON TickDecision(const bool is_open,
                                     const int direction,
                                     const double entry_price,
                                     const datetime entry_time,
                                     const double bid,
                                     const double ask,
                                     const datetime now) const
     {
      if(!is_open || (direction!=1 && direction!=-1)) return A12_EXIT_NONE;
      const double px=(direction>0 ? bid : ask);
      const double move=direction*(px-entry_price);
      if(move>=m_tp_bricks*m_brick) return A12_EXIT_TP;
      if(move<=-m_sl_bricks*m_brick) return A12_EXIT_SL;
      if(m_max_hold_minutes>0 &&
         (long)(now-entry_time)>=(long)m_max_hold_minutes*60) return A12_EXIT_TIME;
      return A12_EXIT_NONE;
     }

   ENUM_A12_EXIT_REASON CompletedRenkoDecision(const bool is_open,
                                               const int direction,
                                               const int final_raw_direction) const
     {
      if(!is_open || (direction!=1 && direction!=-1)) return A12_EXIT_NONE;
      if(final_raw_direction!=0 && final_raw_direction==-direction)
         return A12_EXIT_DI_FLIP;
      return A12_EXIT_NONE;
     }

   string ReasonText(const ENUM_A12_EXIT_REASON reason) const
     {
      if(reason==A12_EXIT_TP) return "TP";
      if(reason==A12_EXIT_SL) return "SL";
      if(reason==A12_EXIT_TIME) return "TIME";
      if(reason==A12_EXIT_DI_FLIP) return "DI_FLIP";
      return "";
     }
  };

#endif // A12_EXIT_MODULE_V1_00_MQH
