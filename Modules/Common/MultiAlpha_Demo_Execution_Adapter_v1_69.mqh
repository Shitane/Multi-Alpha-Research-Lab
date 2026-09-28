//+------------------------------------------------------------------+
//| MultiAlpha_Demo_Execution_Adapter_v1_69.mqh                     |
//| Checked broker boundary for Multi Alpha DEMO execution.          |
//| DEMO + HEDGING + Symbol/Magic ownership are mandatory.           |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_DEMO_EXECUTION_ADAPTER_V1_69_MQH
#define MULTIALPHA_DEMO_EXECUTION_ADAPTER_V1_69_MQH
#include <Trade/Trade.mqh>

class CMultiAlphaDemoExecutionAdapter169
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
  // Synchronous market execution is accepted only after a terminal DONE/DONE_PARTIAL result.
  // PLACED is not treated as a completed position transition for this safety gate.
  return r==TRADE_RETCODE_DONE||r==TRADE_RETCODE_DONE_PARTIAL;
 }
 bool ConfirmOwnedPosition(const ulong ticket,const ENUM_POSITION_TYPE side,string &reason) const{
  if(ticket==0){reason="broker reported success but no owned position ticket was found";return false;}
  if(!PositionSelectByTicket(ticket)){reason="new position ticket is not selectable";return false;}
  if(PositionGetString(POSITION_SYMBOL)!=m_symbol||PositionGetInteger(POSITION_MAGIC)!=m_magic){reason="new position ownership mismatch";return false;}
  if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side){reason="new position side mismatch";return false;}
  return true;
 }
 double OwnedSideLots(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0.0;double v=0.0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)==side)v+=PositionGetDouble(POSITION_VOLUME);}
  return v;
 }
 ulong NewestOwnedTicket(const ENUM_POSITION_TYPE side) const{
  if(!m_initialized)return 0;long newest=-1;ulong ticket=0;
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;
   long tm=PositionGetInteger(POSITION_TIME_MSC);if(tm>=newest){newest=tm;ticket=t;}}
  return ticket;
 }
 void LogResult(const string action,const bool api_ok,const ulong position_ticket) const{
  Print("[MA_EXEC169_RESULT] instance=",m_instance_id," action=",action,
        " api_ok=",(int)api_ok," retcode=",m_trade.ResultRetcode(),
        " desc=",m_trade.ResultRetcodeDescription()," order=",m_trade.ResultOrder(),
        " deal=",m_trade.ResultDeal()," position_ticket=",position_ticket,
        " symbol=",m_symbol," magic=",m_magic," owned_positions=",ManagedPositions());
 }
 void LogLifecycle(const string phase,const string action,const ENUM_POSITION_TYPE side,
                   const double requested_lot,const ulong position_ticket) const{
  Print("[MA_EXEC169_LIFECYCLE] phase=",phase,
        " instance=",m_instance_id," symbol=",m_symbol," magic=",m_magic,
        " action=",action," side=",EnumToString(side),
        " requested_lot=",DoubleToString(requested_lot,2),
        " order=",m_trade.ResultOrder()," deal=",m_trade.ResultDeal(),
        " position_ticket=",position_ticket,
        " retcode=",m_trade.ResultRetcode()," desc=",m_trade.ResultRetcodeDescription(),
        " owned_positions=",ManagedPositions(),
        " transition_pending=",(int)m_transition_pending);
 }
 void LogOwnedPosition(const string phase,const ulong ticket) const{
  if(ticket==0||!PositionSelectByTicket(ticket)){Print("[MA_EXEC169_OWNERSHIP] phase=",phase," instance=",m_instance_id," ticket=",ticket," selected=0 symbol=",m_symbol," magic=",m_magic);return;}
  Print("[MA_EXEC169_OWNERSHIP] phase=",phase," instance=",m_instance_id," ticket=",ticket,
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
 CMultiAlphaDemoExecutionAdapter169(){
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
  Print("[MA_EXEC169_INIT] instance=",m_instance_id," symbol=",m_symbol," magic=",m_magic,
        " account=DEMO margin=HEDGING BROKER_ACTIONS_ARMED=1");
  return true;
 }
 bool Initialized() const{return m_initialized;}
 bool TransitionPending() const{return m_transition_pending;}

 // Read-only broker-state audit. This does not place/modify/close orders.
 // Ownership contract is Symbol + Magic; instance_id is diagnostic identity.
 bool AuditOwnedState(string &reason) const{
  reason="";
  if(!m_initialized){reason="adapter not initialized";return false;}
  int owned=0,buy_count=0,sell_count=0;
  double buy_lots=0.0,sell_lots=0.0;
  for(int i=PositionsTotal()-1;i>=0;i--){
   ulong t=PositionGetTicket(i);
   if(t==0)continue;
   if(!PositionSelectByTicket(t)){reason="position ticket became unselectable during audit";return false;}
   if(PositionGetString(POSITION_SYMBOL)!=m_symbol||PositionGetInteger(POSITION_MAGIC)!=m_magic)continue;
   owned++;
   double vol=PositionGetDouble(POSITION_VOLUME);
   if(vol<=0.0){reason="owned position has non-positive volume";return false;}
   ENUM_POSITION_TYPE side=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   if(side==POSITION_TYPE_BUY){buy_count++;buy_lots+=vol;}
   else if(side==POSITION_TYPE_SELL){sell_count++;sell_lots+=vol;}
   else {reason="owned position has unsupported position type";return false;}
  }
  if(owned!=buy_count+sell_count){reason="owned position count mismatch";return false;}
  Print("[MA_EXEC169_STATE_AUDIT] instance=",m_instance_id," symbol=",m_symbol," magic=",m_magic,
        " owned=",owned," buy_count=",buy_count," sell_count=",sell_count,
        " buy_lots=",DoubleToString(buy_lots,2)," sell_lots=",DoubleToString(sell_lots,2),
        " transition_pending=",(int)m_transition_pending," result=PASS");
  return true;
 }
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
  int before_count=ManagedPositionsSide(side);double before_lots=OwnedSideLots(side);
  m_transition_pending=true;
  string cmt="MA"+IntegerToString(m_instance_id)+" "+tag;
  Print("[MA_EXEC169_LIFECYCLE] phase=REQUEST instance=",m_instance_id," symbol=",m_symbol," magic=",m_magic,
        " action=OPEN side=",EnumToString(side)," requested_lot=",DoubleToString(lot,2),
        " order=0 deal=0 position_ticket=0 retcode=0 owned_positions=",ManagedPositions(),
        " transition_pending=",(int)m_transition_pending);
  bool api_ok=(side==POSITION_TYPE_BUY?m_trade.Buy(lot,m_symbol,0,0,0,cmt):m_trade.Sell(lot,m_symbol,0,0,0,cmt));
  bool ok=api_ok&&TradeResultOK();
  int after_count=ManagedPositionsSide(side);double after_lots=OwnedSideLots(side);
  ulong position_ticket=(ok?NewestOwnedTicket(side):0);
  if(ok&&after_count<=before_count){ok=false;reason="owned position count did not increase after open";}
  if(ok&&after_lots<=before_lots+1e-9){ok=false;reason="owned side lots did not increase after open";}
  if(ok)ok=ConfirmOwnedPosition(position_ticket,side,reason);
  Print("[MA_EXEC169_OPEN_DELTA] instance=",m_instance_id," side=",EnumToString(side),
        " before_count=",before_count," after_count=",after_count,
        " before_lots=",DoubleToString(before_lots,2)," after_lots=",DoubleToString(after_lots,2),
        " requested_lot=",DoubleToString(lot,2)," result=",(ok?"PASS":"REJECT"));
  LogResult(side==POSITION_TYPE_BUY?"BUY":"SELL",api_ok,position_ticket);
  LogLifecycle(ok?"CONFIRMED":"REJECTED","OPEN",side,lot,position_ticket);
  if(ok)LogOwnedPosition("AFTER_OPEN_CONFIRMED",position_ticket);
  if(!ok&&reason=="")reason=m_trade.ResultRetcodeDescription();
  m_transition_pending=false;return ok;
 }
 bool CloseSide(const ENUM_POSITION_TYPE side,string &reason){
  if(!Ready(reason))return false;ulong tickets[];ArrayResize(tickets,0);
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;
   if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side)continue;int n=ArraySize(tickets);ArrayResize(tickets,n+1);tickets[n]=t;}
  m_transition_pending=true;bool all_ok=true;
  for(int j=0;j<ArraySize(tickets);j++){double close_lot=0.0;if(PositionSelectByTicket(tickets[j]))close_lot=PositionGetDouble(POSITION_VOLUME);LogOwnedPosition("BEFORE_CLOSE_SIDE",tickets[j]);LogLifecycle("REQUEST","CLOSE_SIDE",side,close_lot,tickets[j]);bool api_ok=m_trade.PositionClose(tickets[j]);bool ok=api_ok&&TradeResultOK();if(ok&&PositionSelectByTicket(tickets[j])){ok=false;reason="position still present after synchronous close";}LogResult("CLOSE_SIDE",api_ok,tickets[j]);LogLifecycle(ok?"CONFIRMED":"REJECTED","CLOSE_SIDE",side,close_lot,tickets[j]);if(!ok){all_ok=false;if(reason=="")reason=m_trade.ResultRetcodeDescription();}}
  m_transition_pending=false;return all_ok;
 }
 bool CloseAll(string &reason){
  if(!Ready(reason))return false;ulong tickets[];ArrayResize(tickets,0);
  for(int i=PositionsTotal()-1;i>=0;i--){ulong t=PositionGetTicket(i);if(!OwnedSelectedPosition(t))continue;int n=ArraySize(tickets);ArrayResize(tickets,n+1);tickets[n]=t;}
  m_transition_pending=true;bool all_ok=true;
  for(int j=0;j<ArraySize(tickets);j++){ENUM_POSITION_TYPE close_side=POSITION_TYPE_BUY;double close_lot=0.0;if(PositionSelectByTicket(tickets[j])){close_side=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);close_lot=PositionGetDouble(POSITION_VOLUME);}LogOwnedPosition("BEFORE_CLOSE_ALL",tickets[j]);LogLifecycle("REQUEST","CLOSE_ALL",close_side,close_lot,tickets[j]);bool api_ok=m_trade.PositionClose(tickets[j]);bool ok=api_ok&&TradeResultOK();if(ok&&PositionSelectByTicket(tickets[j])){ok=false;reason="position still present after synchronous close";}LogResult("CLOSE_ALL",api_ok,tickets[j]);LogLifecycle(ok?"CONFIRMED":"REJECTED","CLOSE_ALL",close_side,close_lot,tickets[j]);if(!ok){all_ok=false;if(reason=="")reason=m_trade.ResultRetcodeDescription();}}
  m_transition_pending=false;return all_ok;
 }
};
#endif
