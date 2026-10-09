#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-22: read-only owned ticket selection. No CTrade, no order APIs.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
void A22Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_TICKET_CASE] ",name," ",ok?"PASS":"FAIL");
}
bool A22Match(const string symbol,const long magic,const int side,
 const string candidateSymbol,const long candidateMagic,const int candidateSide)
{
 return symbol!=""&&magic>0&&(side==(int)POSITION_TYPE_BUY||side==(int)POSITION_TYPE_SELL)&&
        candidateSymbol==symbol&&candidateMagic==magic&&candidateSide==side;
}
int A22ReadTickets(const string symbol,const long magic,const int side,
 ulong &tickets[],double &lots[],bool &readOk)
{
 ArrayResize(tickets,0);ArrayResize(lots,0);readOk=true;
 if(symbol==""||magic<=0||(side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL))
 {readOk=false;return 0;}
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){readOk=false;return ArraySize(tickets);}
  if(!A22Match(symbol,magic,side,PositionGetString(POSITION_SYMBOL),
     PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE)))continue;
  double volume=PositionGetDouble(POSITION_VOLUME);
  if(volume<=0.0||!MathIsValidNumber(volume)){readOk=false;return ArraySize(tickets);}
  int n=ArraySize(tickets);ArrayResize(tickets,n+1);ArrayResize(lots,n+1);
  tickets[n]=ticket;lots[n]=volume;
 }
 return ArraySize(tickets);
}
bool A22UniqueNonzero(const ulong &tickets[])
{
 for(int i=0;i<ArraySize(tickets);i++)
 {
  if(tickets[i]==0)return false;
  for(int j=0;j<i;j++)if(tickets[i]==tickets[j])return false;
 }
 return true;
}
int OnInit()
{
 ulong sellTickets[],buyTickets[],otherTickets[];
 double sellLots[],buyLots[],otherLots[];
 bool sellRead=false,buyRead=false,otherRead=false;
 int sells=A22ReadTickets(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,sellTickets,sellLots,sellRead);
 int buys=A22ReadTickets(_Symbol,InpMagic,(int)POSITION_TYPE_BUY,buyTickets,buyLots,buyRead);
 A22Check("SYMBOL_MAGIC_SIDE_MATCH",A22Match(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic,(int)POSITION_TYPE_SELL));
 A22Check("OTHER_MAGIC_REJECT",!A22Match(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic+1,(int)POSITION_TYPE_SELL));
 A22Check("OTHER_SYMBOL_REJECT",!A22Match(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol+"_OTHER",InpMagic,(int)POSITION_TYPE_SELL));
 A22Check("OPPOSITE_SIDE_REJECT",!A22Match(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic,(int)POSITION_TYPE_BUY));
 A22Check("EMPTY_SYMBOL_REJECT",!A22Match("",InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic,(int)POSITION_TYPE_SELL));
 A22Check("ZERO_MAGIC_REJECT",!A22Match(_Symbol,0,(int)POSITION_TYPE_SELL,_Symbol,0,(int)POSITION_TYPE_SELL));
 A22Check("INVALID_SIDE_REJECT",!A22Match(_Symbol,InpMagic,-1,_Symbol,InpMagic,-1));
 A22Check("SELL_READ",sellRead);
 A22Check("BUY_READ",buyRead);
 A22Check("SELL_TICKETS_UNIQUE",A22UniqueNonzero(sellTickets));
 A22Check("BUY_TICKETS_UNIQUE",A22UniqueNonzero(buyTickets));
 A22Check("SIDE_SEPARATION",!(sells>0&&buys>0&&sellTickets[0]==buyTickets[0]));
 int other=A22ReadTickets(_Symbol,InpMagic+1,(int)POSITION_TYPE_SELL,otherTickets,otherLots,otherRead);
 A22Check("OTHER_MAGIC_READ",otherRead&&other>=0);
 bool noOverlap=true;
 for(int i=0;i<sells;i++)for(int j=0;j<other;j++)if(sellTickets[i]==otherTickets[j])noOverlap=false;
 A22Check("OTHER_MAGIC_NO_OVERLAP",noOverlap);
 double sellSum=0.0,buySum=0.0;
 for(int i=0;i<sells;i++)sellSum+=sellLots[i];
 for(int i=0;i<buys;i++)buySum+=buyLots[i];
 SMA_PositionMetrics100 metrics;string why="";
 bool metricsOk=MAReadPositionMetrics100(_Symbol,InpMagic,metrics,why);
 A22Check("METRICS_READ",metricsOk);
 A22Check("SELL_COUNT_MATCH",metricsOk&&metrics.sellCount==sells);
 A22Check("BUY_COUNT_MATCH",metricsOk&&metrics.buyCount==buys);
 A22Check("SELL_LOTS_MATCH",metricsOk&&MathAbs(metrics.sellLots-sellSum)<0.0000001);
 A22Check("BUY_LOTS_MATCH",metricsOk&&MathAbs(metrics.buyLots-buySum)<0.0000001);
 for(int i=0;i<sells;i++)Print("[MA_ME_TICKET_INFO] side=SELL ticket=",sellTickets[i]," lots=",DoubleToString(sellLots[i],2));
 for(int i=0;i<buys;i++)Print("[MA_ME_TICKET_INFO] side=BUY ticket=",buyTickets[i]," lots=",DoubleToString(buyLots[i],2));
 Print("[MA_ME_TICKET_INFO] symbol=",_Symbol," magic=",InpMagic," owned_sell=",sells," owned_buy=",buys);
 if(g_fails>0)Print("[MA_ME_TICKET_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(sells+buys==0)Print("[MA_ME_TICKET_INCONCLUSIVE] cases=",g_cases," zero_owned_positions=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_TICKET_PASS] cases=",g_cases," owned_ticket_read_only=PASS execution_target_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
