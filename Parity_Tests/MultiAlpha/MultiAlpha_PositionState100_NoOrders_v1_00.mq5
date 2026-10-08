#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Position_State_Adapter_v1_00.mqh"
// A14-5: read-only live position snapshot. No orders, no simulated fills.
int failures=0,checks=0;
void Check(const string label,const bool ok)
{
 checks++;
 Print("[MA_POSITION100_CASE] ",label," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
int OnInit()
{
 SMA_MEState100 state;state.buyCount=99;state.sellCount=99;
 string reason="";
 Check("EMPTY_SYMBOL_REJECT",!MAPositionState100("",12345,state,reason)&&reason=="EMPTY_SYMBOL"&&state.buyCount==0&&state.sellCount==0);
 Check("NEGATIVE_MAGIC_REJECT",!MAPositionState100(_Symbol,-1,state,reason)&&reason=="NEGATIVE_MAGIC"&&state.buyCount==0&&state.sellCount==0);
 long magic=987654321;
 bool read=MAPositionState100(_Symbol,magic,state,reason);
 Check("READ_SUCCESS",read&&reason=="READ_ONLY_SNAPSHOT");
 Check("NONNEGATIVE_COUNTS",read&&state.buyCount>=0&&state.sellCount>=0);
 int buy=0,sell=0;
 bool scan=true;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){scan=false;break;}
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
  if(type==POSITION_TYPE_BUY)buy++;
  else if(type==POSITION_TYPE_SELL)sell++;
  else scan=false;
 }
 Check("EXACT_SYMBOL_MAGIC_COUNT",read&&scan&&state.buyCount==buy&&state.sellCount==sell);
 Check("REPEAT_READ_STABLE",MAPositionState100(_Symbol,magic,state,reason)&&state.buyCount==buy&&state.sellCount==sell);
 string impossible="__MA_NO_MATCH_SYMBOL__";
 Check("OTHER_SYMBOL_EXCLUDED",MAPositionState100(impossible,magic,state,reason)&&state.buyCount==0&&state.sellCount==0);
 Print("[MA_POSITION100_INFO] symbol=",_Symbol," magic=",magic," matching_buy=",buy," matching_sell=",sell," account_positions=",PositionsTotal());
 if(failures==0)Print("[MA_POSITION100_PASS] cases=",checks," real_position_read=1 ownership_symbol_magic=1 no_matching_positions_allowed=1 trade_execution=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_POSITION100_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
