#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Position_Metrics100_v1_00.mqh"
// A14-11: independently enumerate EXISTING live positions; no orders.
// Attach to a chart matching the symbol, set InpMagic to an existing owned magic.
// Zero matching positions are INCONCLUSIVE, never PASS.
input long InpMagic=987654321;
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;
 Print("[MA_LIVE_OWNED_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
bool Near(const double a,const double b)
{
 return MathAbs(a-b)<=0.0000001*MathMax(1.0,MathMax(MathAbs(a),MathAbs(b)));
}
int OnInit()
{
 if(_Symbol==""||InpMagic<0)
 {
  Print("[MA_LIVE_OWNED_FAIL] INVALID_INPUT NO_ORDERS=1");
  return INIT_FAILED;
 }
 int bc=0,sc=0,other=0;
 double bl=0,sl,bp=0,sp=0,bws=0,sws=0,bmin=0,bmax=0,smin=0,smax=0;
 sl=0;
 // Independent enumeration: only PositionGetTicket/PositionGet* reads.
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)
  {
   Print("[MA_LIVE_OWNED_FAIL] SELECT_FAILED index=",i);
   return INIT_FAILED;
  }
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic)
  {
   other++;
   continue;
  }
  long side=PositionGetInteger(POSITION_TYPE);
  double lot=PositionGetDouble(POSITION_VOLUME);
  double price=PositionGetDouble(POSITION_PRICE_OPEN);
  double profit=PositionGetDouble(POSITION_PROFIT);
  if(lot<=0||price<=0||!MathIsValidNumber(lot)||!MathIsValidNumber(price)||!MathIsValidNumber(profit))
  {
   Print("[MA_LIVE_OWNED_FAIL] INVALID_POSITION ticket=",ticket);
   return INIT_FAILED;
  }
  if(side==POSITION_TYPE_BUY)
  {
   if(bc==0){bmin=price;bmax=price;}
   else{bmin=MathMin(bmin,price);bmax=MathMax(bmax,price);}
   bc++;bl+=lot;bp+=profit;bws+=lot*price;
  }
  else if(side==POSITION_TYPE_SELL)
  {
   if(sc==0){smin=price;smax=price;}
   else{smin=MathMin(smin,price);smax=MathMax(smax,price);}
   sc++;sl+=lot;sp+=profit;sws+=lot*price;
  }
  else
  {
   Print("[MA_LIVE_OWNED_FAIL] UNKNOWN_SIDE ticket=",ticket);
   return INIT_FAILED;
  }
 }
 SMA_PositionMetrics100 m;
 string reason="";
 bool read=MAReadPositionMetrics100(_Symbol,InpMagic,m,reason);
 Check("ADAPTER_READ",read);
 if(read)
 {
  Check("BUY_COUNT",m.buyCount==bc);
  Check("SELL_COUNT",m.sellCount==sc);
  Check("BUY_LOTS",Near(m.buyLots,bl));
  Check("SELL_LOTS",Near(m.sellLots,sl));
  Check("BUY_PROFIT",Near(m.buyProfit,bp));
  Check("SELL_PROFIT",Near(m.sellProfit,sp));
  Check("BUY_WEIGHTED",Near(m.buyWeightedOpen,bl>0?bws/bl:0));
  Check("SELL_WEIGHTED",Near(m.sellWeightedOpen,sl>0?sws/sl:0));
  Check("BUY_EXTREMA",Near(m.buyMinOpen,bmin)&&Near(m.buyMaxOpen,bmax));
  Check("SELL_EXTREMA",Near(m.sellMinOpen,smin)&&Near(m.sellMaxOpen,smax));
  Check("NONNEGATIVE",m.buyCount>=0&&m.sellCount>=0&&m.buyLots>=0&&m.sellLots>=0);
 }
 Print("[MA_LIVE_OWNED_INFO] symbol=",_Symbol," magic=",InpMagic,
       " owned_buy=",bc," owned_sell=",sc," other_positions=",other,
       " account_positions=",PositionsTotal()," reason=",reason);
 if(failures>0)
  Print("[MA_LIVE_OWNED_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 else if(bc+sc==0)
  Print("[MA_LIVE_OWNED_INCONCLUSIVE] cases=",checks,
        " zero_owned_positions=1 live_nonzero_proven=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_LIVE_OWNED_PASS] cases=",checks,
        " nonzero_owned_positions=1 metrics_comparison=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
