#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Position_Metrics100_v1_00.mqh"
// A14-10: deterministic synthetic position records; NO live positions or orders.
// Independently verifies expected counts, lots, profit and weighted prices.
// Does NOT call MAReadPositionMetrics100; cannot certify broker-position adapter.
struct SyntheticPosition { string symbol; long magic; bool buy; double lots,open,profit; };
int checks=0,failures=0;
void Check(const string n,const bool ok)
{
 checks++;Print("[MA_SYNTH_OWNED_CASE] ",n," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
bool Near(const double a,const double b){return MathAbs(a-b)<0.0000001;}
bool Aggregate(const SyntheticPosition &rows[],const string symbol,const long magic,
 SMA_PositionMetrics100 &out)
{
 MAResetPositionMetrics100(out);
 if(symbol==""||magic<0)return false;
 double bw=0,sw=0;
 for(int i=0;i<ArraySize(rows);i++)
 {
  if(rows[i].symbol!=symbol||rows[i].magic!=magic)continue;
  if(rows[i].lots<=0||rows[i].open<=0||!MathIsValidNumber(rows[i].lots)||
     !MathIsValidNumber(rows[i].open)||!MathIsValidNumber(rows[i].profit))
  {MAResetPositionMetrics100(out);return false;}
  if(rows[i].buy)
  {
   if(out.buyCount==0){out.buyMinOpen=rows[i].open;out.buyMaxOpen=rows[i].open;}
   else{out.buyMinOpen=MathMin(out.buyMinOpen,rows[i].open);out.buyMaxOpen=MathMax(out.buyMaxOpen,rows[i].open);}
   out.buyCount++;out.buyLots+=rows[i].lots;out.buyProfit+=rows[i].profit;
   bw+=rows[i].lots*rows[i].open;
  }
  else
  {
   if(out.sellCount==0){out.sellMinOpen=rows[i].open;out.sellMaxOpen=rows[i].open;}
   else{out.sellMinOpen=MathMin(out.sellMinOpen,rows[i].open);out.sellMaxOpen=MathMax(out.sellMaxOpen,rows[i].open);}
   out.sellCount++;out.sellLots+=rows[i].lots;out.sellProfit+=rows[i].profit;
   sw+=rows[i].lots*rows[i].open;
  }
 }
 if(out.buyLots>0)out.buyWeightedOpen=bw/out.buyLots;
 if(out.sellLots>0)out.sellWeightedOpen=sw/out.sellLots;
 return true;
}
int OnInit()
{
 SyntheticPosition rows[];
 ArrayResize(rows,6);
 rows[0].symbol="XAUUSD-m";rows[0].magic=101;rows[0].buy=true;rows[0].lots=0.01;rows[0].open=2600;rows[0].profit=10;
 rows[1].symbol="XAUUSD-m";rows[1].magic=101;rows[1].buy=true;rows[1].lots=0.02;rows[1].open=2615;rows[1].profit=-4;
 rows[2].symbol="XAUUSD-m";rows[2].magic=101;rows[2].buy=false;rows[2].lots=0.03;rows[2].open=2630;rows[2].profit=8;
 rows[3].symbol="XAUUSD-m";rows[3].magic=202;rows[3].buy=true;rows[3].lots=1;rows[3].open=999;rows[3].profit=999;
 rows[4].symbol="GBPUSD";rows[4].magic=101;rows[4].buy=false;rows[4].lots=2;rows[4].open=1.2;rows[4].profit=999;
 rows[5].symbol="XAUUSD-m";rows[5].magic=101;rows[5].buy=false;rows[5].lots=0.01;rows[5].open=2620;rows[5].profit=-3;
 SMA_PositionMetrics100 m;
 Check("AGGREGATE_NONZERO",Aggregate(rows,"XAUUSD-m",101,m));
 Check("BUY_COUNT_2",m.buyCount==2);
 Check("SELL_COUNT_2",m.sellCount==2);
 Check("BUY_LOTS_003",Near(m.buyLots,0.03));
 Check("SELL_LOTS_004",Near(m.sellLots,0.04));
 Check("BUY_PROFIT_6",Near(m.buyProfit,6));
 Check("SELL_PROFIT_5",Near(m.sellProfit,5));
 Check("BUY_WEIGHTED_2610",Near(m.buyWeightedOpen,2610));
 Check("SELL_WEIGHTED_26275",Near(m.sellWeightedOpen,2627.5));
 Check("BUY_EXTREMA",Near(m.buyMinOpen,2600)&&Near(m.buyMaxOpen,2615));
 Check("SELL_EXTREMA",Near(m.sellMinOpen,2620)&&Near(m.sellMaxOpen,2630));
 Check("OTHER_MAGIC_ISOLATION",Aggregate(rows,"XAUUSD-m",202,m)&&m.buyCount==1&&m.sellCount==0&&Near(m.buyLots,1));
 Check("OTHER_SYMBOL_ISOLATION",Aggregate(rows,"GBPUSD",101,m)&&m.buyCount==0&&m.sellCount==1&&Near(m.sellLots,2));
 Check("ZERO_MATCHES",Aggregate(rows,"XAUUSD-m",303,m)&&m.buyCount==0&&m.sellCount==0&&Near(m.buyLots,0));
 Check("EMPTY_SYMBOL_REJECT",!Aggregate(rows,"",101,m));
 Check("NEGATIVE_MAGIC_REJECT",!Aggregate(rows,"XAUUSD-m",-1,m));
 rows[0].lots=-0.01;
 Check("INVALID_LOT_REJECT",!Aggregate(rows,"XAUUSD-m",101,m)&&m.buyCount==0&&m.sellCount==0);
 if(failures==0)Print("[MA_SYNTH_OWNED_PASS] cases=",checks," synthetic_only=1 nonzero_count_lots_profit=PASS live_position_adapter_proven=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SYNTH_OWNED_FAIL] cases=",checks," failures=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
