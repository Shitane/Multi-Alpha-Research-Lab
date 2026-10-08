#ifndef MULTIALPHA_POSITION_STATE_ADAPTER_V1_00_MQH
#define MULTIALPHA_POSITION_STATE_ADAPTER_V1_00_MQH
#include "MultiAlpha_ME_State_Flags100_v1_00.mqh"
// Read-only MT5 position snapshot. Exact symbol + magic ownership.
// No CTrade, OrderSend, PositionClose or trade modifications.
bool MAPositionState100(const string symbol,const long magic,
 SMA_MEState100 &state,string &reason)
{
 state.buyCount=0;state.sellCount=0;
 if(symbol==""){reason="EMPTY_SYMBOL";return false;}
 if(magic<0){reason="NEGATIVE_MAGIC";return false;}
 int total=PositionsTotal();
 for(int i=0;i<total;i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){reason="POSITION_SELECT_FAILED";state.buyCount=0;state.sellCount=0;return false;}
  if(PositionGetString(POSITION_SYMBOL)!=symbol)continue;
  if(PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  ENUM_POSITION_TYPE side=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
  if(side==POSITION_TYPE_BUY)state.buyCount++;
  else if(side==POSITION_TYPE_SELL)state.sellCount++;
  else {reason="UNKNOWN_POSITION_TYPE";state.buyCount=0;state.sellCount=0;return false;}
 }
 reason="READ_ONLY_SNAPSHOT";return true;
}
#endif
