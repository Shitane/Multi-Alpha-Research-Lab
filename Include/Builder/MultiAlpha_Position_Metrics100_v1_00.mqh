#ifndef MULTIALPHA_POSITION_METRICS100_V1_00_MQH
#define MULTIALPHA_POSITION_METRICS100_V1_00_MQH
// A14-7: read-only owned position metrics. Exact symbol and magic.
// No trade operations. Monetary P/L uses POSITION_PROFIT (account currency).
struct SMA_PositionMetrics100
{
 int buyCount,sellCount;
 double buyLots,sellLots,buyProfit,sellProfit;
 double buyWeightedOpen,sellWeightedOpen;
 double buyMinOpen,buyMaxOpen,sellMinOpen,sellMaxOpen;
};
void MAResetPositionMetrics100(SMA_PositionMetrics100 &s)
{
 s.buyCount=0;s.sellCount=0;
 s.buyLots=0;s.sellLots=0;s.buyProfit=0;s.sellProfit=0;
 s.buyWeightedOpen=0;s.sellWeightedOpen=0;
 s.buyMinOpen=0;s.buyMaxOpen=0;s.sellMinOpen=0;s.sellMaxOpen=0;
}
bool MAReadPositionMetrics100(const string symbol,const long magic,
 SMA_PositionMetrics100 &s,string &reason)
{
 MAResetPositionMetrics100(s);
 if(symbol==""){reason="EMPTY_SYMBOL";return false;}
 if(magic<0){reason="NEGATIVE_MAGIC";return false;}
 double buyWeightedSum=0,sellWeightedSum=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){reason="POSITION_SELECT_FAILED";MAResetPositionMetrics100(s);return false;}
  if(PositionGetString(POSITION_SYMBOL)!=symbol||PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  ENUM_POSITION_TYPE side=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
  double lots=PositionGetDouble(POSITION_VOLUME);
  double open=PositionGetDouble(POSITION_PRICE_OPEN);
  double profit=PositionGetDouble(POSITION_PROFIT);
  if(lots<=0||!MathIsValidNumber(lots)||!MathIsValidNumber(open)||open<=0||!MathIsValidNumber(profit))
  {reason="INVALID_POSITION_METRICS";MAResetPositionMetrics100(s);return false;}
  if(side==POSITION_TYPE_BUY)
  {
   if(s.buyCount==0){s.buyMinOpen=open;s.buyMaxOpen=open;}
   else{s.buyMinOpen=MathMin(s.buyMinOpen,open);s.buyMaxOpen=MathMax(s.buyMaxOpen,open);}
   s.buyCount++;s.buyLots+=lots;s.buyProfit+=profit;buyWeightedSum+=lots*open;
  }
  else if(side==POSITION_TYPE_SELL)
  {
   if(s.sellCount==0){s.sellMinOpen=open;s.sellMaxOpen=open;}
   else{s.sellMinOpen=MathMin(s.sellMinOpen,open);s.sellMaxOpen=MathMax(s.sellMaxOpen,open);}
   s.sellCount++;s.sellLots+=lots;s.sellProfit+=profit;sellWeightedSum+=lots*open;
  }
  else{reason="UNKNOWN_POSITION_TYPE";MAResetPositionMetrics100(s);return false;}
 }
 if(s.buyLots>0)s.buyWeightedOpen=buyWeightedSum/s.buyLots;
 if(s.sellLots>0)s.sellWeightedOpen=sellWeightedSum/s.sellLots;
 reason="READ_ONLY_METRICS";return true;
}
#endif
