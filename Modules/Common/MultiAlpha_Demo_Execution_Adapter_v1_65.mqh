//+------------------------------------------------------------------+
//| MultiAlpha_Demo_Execution_Adapter_v1_65.mqh                     |
//| Checked broker boundary for Multi Alpha DEMO execution.          |
//| DEMO + HEDGING + Symbol/Magic ownership are mandatory.           |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_DEMO_EXECUTION_ADAPTER_V1_65_MQH
#define MULTIALPHA_DEMO_EXECUTION_ADAPTER_V1_65_MQH
#include <Trade/Trade.mqh>

class CMultiAlphaDemoExecutionAdapter165
{
private:
 CTrade m_trade;
 string m_symbol;
 long m_magic;
 int m_instance_id;
 bool m_initialized;
 bool m_transition_pending;

 bool OwnedSelectedPosition(const ulong ticket) const{
  if(ticket==0||!PositionSelectByTicket(ticket))return false;
  return PositionGetString(POSITION_SYMBOL)==m_symbol&&PositionGetInteger(POSITION_MAGIC)==m_magic;
 }
 bool TradeResultOK() const{
  uint r=m_trade.ResultRetcode();
  return r==TRADE_RETCODE_DONE||r==TRADE_RETCODE_DONE_PARTIAL||r==TRADE_RETCODE_PLACED;
 }
 ulong NewestOwnedTicket(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0;long newest=-1;ulong ticket=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;
   long tm=PositionGetInteger(POSITION_TIME_MSC);if(tm>=newest){newest=tm;ticket=t;}}
  return ticket;
 }
 void LogResult(const string action,const bool api_ok,const ulong position_ticket) const{
  Print("[MA_EXEC165_RESULT] instance=",m_instance_id," action=",action,
        " api_ok=",(int)api_ok," retcode=",m_trade.ResultRetcode(),
        " desc=",m_trade.ResultRetcodeDescription()," order=",m_trade.ResultOrder(),
        " deal=",m_trade.ResultDeal()," position_ticket=",position_ticket,
        " symbol=",m_symbol," magic=",m_magic," owned_positions=",ManagedPositions());
 }
 void LogOwnedPosition(const string phase,const ulong ticket) const{
  if(ticket==0||!PositionSelectByTicket(ticket)){Print("[MA_EXEC165_OWNERSHIP] phase=",phase," instance=",m_instance_id," ticket=",ticket," selected=0 symbol=",m_symbol," magic=",m_magic);return;}
  Print("[MA_EXEC165_OWNERSHIP] phase=",phase," instance=",m_instance_id," ticket=",ticket,
        " selected=1 owned=",(int)(PositionGetString(POSITION_SYMBOL)==m_symbol&&PositionGetInteger(POSITION_MAGIC)==m_magic),
        " pos_symbol=",PositionGetString(POSITION_SYMBOL)," pos_magic=",PositionGetInteger(POSITION_MAGIC),
        " type=",EnumToString((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)),
        " volume=",DoubleToString(PositionGetDouble(POSITION_VOLUME),2),
        " open=",DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),(int)SymbolInfoInteger(m_symbol,SYMBOL_DIGITS)),
        " expected_symbol=",m_symbol," expected_magic=",m_magic);
 }
 bool Ready(string &reason) const{
  reason="";
  if(!m_initialized){reason="adapter not initialized";return false;}
  if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO){reason="DEMO account required";return false;}
  if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING){reason="HEDGING account required";return false;}
  if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){reason="terminal trading disabled";return false;}
  if(!MQLInfoInteger(MQL_TRADE_ALLOWED)){reason="EA trading disabled";return false;}
  return true;
 }

public:
 CMultiAlphaDemoExecutionAdapter165(){
  m_symbol="";m_magic=0;m_instance_id=0;m_initialized=false;m_transition_pending=false;
 }
 bool Init(const int instance_id,const string symbol,const long magic,string &reason){
  reason="";m_initialized=false;m_transition_pending=false;
  if(instance_id<=0){reason="instance id must be positive";return false;}
  if(symbol==""){reason="symbol is empty";return false;}
  if(magic<=0){reason="magic must be positive";return false;}
  if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO){reason="DEMO account required";return false;}
  if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING){reason="HEDGING account required";return false;}
  m_instance_id=instance_id;m_symbol=symbol;m_magic=magic;
  m_trade.SetExpertMagicNumber(m_magic);
  if(!m_trade.SetTypeFillingBySymbol(m_symbol)){reason="unsupported symbol filling mode";return false;}
  m_trade.SetAsyncMode(false);m_initialized=true;
  Print("[MA_EXEC165_INIT] instance=",m_instance_id," symbol=",m_symbol," magic=",m_magic,
        " account=DEMO margin=HEDGING BROKER_ACTIONS_ARMED=1");
  return true;
 }
 bool Initialized() const{return m_initialized;}
 bool TransitionPending() const{return m_transition_pending;}
 string Symbol() const{return m_symbol;}
 long Magic() const{return m_magic;}

 int ManagedPositions() const{
  if(!m_initialized)return 0;int n=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(OwnedSelectedPosition(t))n++;}
  return n;
 }
 int ManagedPositionsSide(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0;int n=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==side)n++;}
  return n;
 }
 double ManagedLotsSide(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0.0;double v=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==side)v+=PositionGetDouble(POSITION_VOLUME);}
  return v;
 }
 double WeightedAveragePrice(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0.0;double pv=0,v=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;
   double lot=PositionGetDouble(POSITION_VOLUME);pv+=PositionGetDouble(POSITION_PRICE_OPEN)*lot;v+=lot;}
  return v>0?pv/v:0.0;
 }
 double NewestPositionPrice(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0.0;long newest=0;double px=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;
   long tm=PositionGetInteger(POSITION_TIME_MSC);if(tm>=newest){newest=tm;px=PositionGetDouble(POSITION_PRICE_OPEN);}}
  return px;
 }
 double NewestPositionLot(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0.0;long newest=0;double lot=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;
   long tm=PositionGetInteger(POSITION_TIME_MSC);if(tm>=newest){newest=tm;lot=PositionGetDouble(POSITION_VOLUME);}}
  return lot;
 }

 bool OpenMarket(const ENUM_POSITION_TYPE side,const double lot,const string tag,string &reason){
  if(!Ready(reason))return false;if(lot<=0){reason="lot must be positive";return false;}
  m_transition_pending=true;
  string cmt="MA"+IntegerToString(m_instance_id)+" "+tag;
  bool api_ok=(side==POSITION_TYPE_BUY?m_trade.Buy(lot,m_symbol,0,0,0,cmt):m_trade.Sell(lot,m_symbol,0,0,0,cmt));
  bool ok=api_ok&&TradeResultOK();
  ulong position_ticket=(ok?NewestOwnedTicket(side):0);
  LogResult(side==POSITION_TYPE_BUY?"BUY":"SELL",api_ok,position_ticket);
  if(ok)LogOwnedPosition("AFTER_OPEN",position_ticket);
  if(!ok)reason=m_trade.ResultRetcodeDescription();
  m_transition_pending=false;return ok;
 }
 bool CloseSide(const ENUM_POSITION_TYPE side,string &reason){
  if(!Ready(reason))return false;ulong tickets[];ArrayResize(tickets,0);
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;int n=ArraySize(tickets);ArrayResize(tickets,n+1);tickets[n]=t;}
  m_transition_pending=true;bool all_ok=true;
  for(int j=0;j<ArraySize(tickets);j++){LogOwnedPosition("BEFORE_CLOSE_SIDE",tickets[j]);bool api_ok=m_trade.PositionClose(tickets[j]);bool ok=api_ok&&TradeResultOK();LogResult("CLOSE_SIDE",api_ok,tickets[j]);if(!ok){all_ok=false;reason=m_trade.ResultRetcodeDescription();}}
  m_transition_pending=false;return all_ok;
 }
 bool CloseAll(string &reason){
  if(!Ready(reason))return false;ulong tickets[];ArrayResize(tickets,0);
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;int n=ArraySize(tickets);ArrayResize(tickets,n+1);tickets[n]=t;}
  m_transition_pending=true;bool all_ok=true;
  for(int j=0;j<ArraySize(tickets);j++){LogOwnedPosition("BEFORE_CLOSE_ALL",tickets[j]);bool api_ok=m_trade.PositionClose(tickets[j]);bool ok=api_ok&&TradeResultOK();LogResult("CLOSE_ALL",api_ok,tickets[j]);if(!ok){all_ok=false;reason=m_trade.ResultRetcodeDescription();}}
  m_transition_pending=false;return all_ok;
 }
};
#endif
