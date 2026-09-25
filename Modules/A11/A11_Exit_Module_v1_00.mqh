// A11 Exit Module v1.00 - exit decisions only, research-only, NO ORDERS.
#ifndef A11_EXIT_MODULE_V1_00_MQH
#define A11_EXIT_MODULE_V1_00_MQH

enum ENUM_A11_EXIT_REASON
{
 A11_EXIT_NONE=0,
 A11_EXIT_OPPOSITE=1,
 A11_EXIT_FAST_MA=2
};

class CA11Exit
{
public:
 ENUM_A11_EXIT_REASON OnSignal(const bool open,const ENUM_POSITION_TYPE current_type,const int signal) const
 {
  if(!open || signal==-1) return A11_EXIT_NONE;
  ENUM_POSITION_TYPE want=(signal==ORDER_TYPE_BUY?POSITION_TYPE_BUY:POSITION_TYPE_SELL);
  return(current_type!=want?A11_EXIT_OPPOSITE:A11_EXIT_NONE);
 }
 ENUM_A11_EXIT_REASON OnNoSignal(const bool use_fast_exit,const bool open,const ENUM_POSITION_TYPE current_type,
                                 const double closed_price,const double fast_closed) const
 {
  if(!use_fast_exit || !open) return A11_EXIT_NONE;
  if(current_type==POSITION_TYPE_BUY && closed_price<=fast_closed) return A11_EXIT_FAST_MA;
  if(current_type==POSITION_TYPE_SELL && closed_price>=fast_closed) return A11_EXIT_FAST_MA;
  return A11_EXIT_NONE;
 }
 string ReasonText(const ENUM_A11_EXIT_REASON reason) const
 {
  if(reason==A11_EXIT_OPPOSITE) return "OPPOSITE";
  if(reason==A11_EXIT_FAST_MA) return "FAST_MA";
  return "NONE";
 }
};
#endif
