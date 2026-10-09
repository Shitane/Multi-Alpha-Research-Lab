#ifndef MULTIALPHA_ME_TICKET_METRICS_V1_00_MQH
#define MULTIALPHA_ME_TICKET_METRICS_V1_00_MQH
// Read-only per-ticket metrics. No order operations.
#define MA_TICKET_METRIC_PROFIT 1
#define MA_TICKET_METRIC_AGE_SECONDS 2
#define MA_TICKET_METRIC_OPEN_PRICE 3
#define MA_TICKET_CMP_GE 1
#define MA_TICKET_CMP_LE 2
struct SMA_METicketMetrics100
{
 ulong ticket;
 string symbol;
 long magic;
 int side;
 double lots;
 double openPrice;
 double profit;
 datetime openTime;
 int ageSeconds;
};
void MAResetMETicketMetrics100(SMA_METicketMetrics100 &p)
{
 p.ticket=0;p.symbol="";p.magic=-1;p.side=-1;
 p.lots=0;p.openPrice=0;p.profit=0;p.openTime=0;p.ageSeconds=0;
}
bool MAReadMETicketMetrics100(const ulong ticket,const string symbol,const long magic,
 const datetime now,SMA_METicketMetrics100 &p,string &reason)
{
 MAResetMETicketMetrics100(p);
 if(ticket==0||symbol==""||magic<=0||now<=0){reason="INVALID_ARGUMENT";return false;}
 if(!PositionSelectByTicket(ticket)){reason="TICKET_NOT_FOUND";return false;}
 if(PositionGetString(POSITION_SYMBOL)!=symbol||
    PositionGetInteger(POSITION_MAGIC)!=magic){reason="NOT_OWNED";return false;}
 p.ticket=ticket;p.symbol=symbol;p.magic=magic;
 p.side=(int)PositionGetInteger(POSITION_TYPE);
 p.lots=PositionGetDouble(POSITION_VOLUME);
 p.openPrice=PositionGetDouble(POSITION_PRICE_OPEN);
 p.profit=PositionGetDouble(POSITION_PROFIT);
 p.openTime=(datetime)PositionGetInteger(POSITION_TIME);
 if((p.side!=(int)POSITION_TYPE_BUY&&p.side!=(int)POSITION_TYPE_SELL)||
    p.lots<=0||p.openPrice<=0||p.openTime<=0||now<p.openTime||
    !MathIsValidNumber(p.lots)||!MathIsValidNumber(p.openPrice)||!MathIsValidNumber(p.profit))
 {MAResetMETicketMetrics100(p);reason="INVALID_METRICS";return false;}
 p.ageSeconds=(int)(now-p.openTime);
 reason="READ_ONLY_TICKET";return true;
}
bool MAEvaluateMETicketPredicate100(const SMA_METicketMetrics100 &p,
 const int metric,const int comparison,const double threshold,bool &fire,string &reason)
{
 fire=false;
 if(p.ticket==0||p.symbol==""||p.magic<=0||p.lots<=0||
    p.openPrice<=0||p.openTime<=0||p.ageSeconds<0||
    !MathIsValidNumber(p.profit)||!MathIsValidNumber(threshold))
 {reason="INVALID_SNAPSHOT_OR_THRESHOLD";return false;}
 double value=0;
 if(metric==MA_TICKET_METRIC_PROFIT)value=p.profit;
 else if(metric==MA_TICKET_METRIC_AGE_SECONDS)value=(double)p.ageSeconds;
 else if(metric==MA_TICKET_METRIC_OPEN_PRICE)value=p.openPrice;
 else{reason="UNSUPPORTED_METRIC";return false;}
 if(comparison==MA_TICKET_CMP_GE)fire=value>=threshold;
 else if(comparison==MA_TICKET_CMP_LE)fire=value<=threshold;
 else{reason="UNSUPPORTED_COMPARISON";return false;}
 reason=fire?"MATCH":"NO_SIGNAL";return true;
}
#endif
