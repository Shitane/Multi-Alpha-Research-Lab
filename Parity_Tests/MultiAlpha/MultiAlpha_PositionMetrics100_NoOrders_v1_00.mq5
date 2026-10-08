#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Position_Metrics100_v1_00.mqh"
int checks=0,failures=0;
void Check(const string n,const bool ok)
{
 checks++;Print("[MA_METRICS100_CASE] ",n," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
bool Near(const double a,const double b){return MathAbs(a-b)<0.000001;}
int OnInit()
{
 SMA_PositionMetrics100 m;string why="";
 const long magic=987654321;
 Check("EMPTY_SYMBOL_REJECT",!MAReadPositionMetrics100("",magic,m,why)&&why=="EMPTY_SYMBOL");
 Check("NEGATIVE_MAGIC_REJECT",!MAReadPositionMetrics100(_Symbol,-1,m,why)&&why=="NEGATIVE_MAGIC");
 Check("OTHER_SYMBOL_ZERO",MAReadPositionMetrics100("__MA_NO_MATCH_SYMBOL__",magic,m,why)&&m.buyCount==0&&m.sellCount==0&&Near(m.buyLots,0)&&Near(m.sellLots,0));
 bool ok=MAReadPositionMetrics100(_Symbol,magic,m,why);
 Check("READ_SUCCESS",ok&&why=="READ_ONLY_METRICS");
 int bc=0,sc=0;double bl=0,sl=0,bp=0,sp=0,bw=0,sw=0,bmin=0,bmax=0,smin=0,smax=0;
 bool valid=true;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){valid=false;break;}
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  double vol=PositionGetDouble(POSITION_VOLUME),price=PositionGetDouble(POSITION_PRICE_OPEN),pl=PositionGetDouble(POSITION_PROFIT);
  ENUM_POSITION_TYPE side=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
  if(side==POSITION_TYPE_BUY)
  {
   if(bc==0){bmin=price;bmax=price;}else{bmin=MathMin(bmin,price);bmax=MathMax(bmax,price);}
   bc++;bl+=vol;bp+=pl;bw+=vol*price;
  }
  else if(side==POSITION_TYPE_SELL)
  {
   if(sc==0){smin=price;smax=price;}else{smin=MathMin(smin,price);smax=MathMax(smax,price);}
   sc++;sl+=vol;sp+=pl;sw+=vol*price;
  }
  else valid=false;
 }
 Check("EXACT_OWNED_COUNTS",ok&&valid&&m.buyCount==bc&&m.sellCount==sc);
 Check("EXACT_OWNED_LOTS",ok&&Near(m.buyLots,bl)&&Near(m.sellLots,sl));
 Check("EXACT_OWNED_PROFIT",ok&&Near(m.buyProfit,bp)&&Near(m.sellProfit,sp));
 Check("WEIGHTED_OPEN",ok&&Near(m.buyWeightedOpen,bl>0?bw/bl:0)&&Near(m.sellWeightedOpen,sl>0?sw/sl:0));
 Check("OPEN_PRICE_EXTREMA",ok&&Near(m.buyMinOpen,bmin)&&Near(m.buyMaxOpen,bmax)&&Near(m.sellMinOpen,smin)&&Near(m.sellMaxOpen,smax));
 Check("NONNEGATIVE_COUNTS_LOTS",ok&&m.buyCount>=0&&m.sellCount>=0&&m.buyLots>=0&&m.sellLots>=0);
 SMA_PositionMetrics100 repeat;string why2="";
 Check("REPEAT_READ",MAReadPositionMetrics100(_Symbol,magic,repeat,why2)&&repeat.buyCount==m.buyCount&&repeat.sellCount==m.sellCount);
 Print("[MA_METRICS100_INFO] symbol=",_Symbol," magic=",magic," buy=",m.buyCount," sell=",m.sellCount," buyLots=",m.buyLots," sellLots=",m.sellLots," account_positions=",PositionsTotal());
 if(failures==0)Print("[MA_METRICS100_PASS] cases=",checks," read_only=1 price_lots_profit=1 exact_symbol_magic=1 zero_matches_allowed=1 no_orders=1 runtime_certified=0 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_METRICS100_FAIL] cases=",checks," failures=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
