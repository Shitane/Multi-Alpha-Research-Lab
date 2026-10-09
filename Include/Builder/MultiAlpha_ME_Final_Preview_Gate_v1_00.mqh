#ifndef MULTIALPHA_ME_FINAL_PREVIEW_GATE_V1_00_MQH
#define MULTIALPHA_ME_FINAL_PREVIEW_GATE_V1_00_MQH
// A14-38 reusable read-only final gate. No trading APIs.
// Upstream saved-slot preview signals must be validated by caller.
#define MA_ME_FINAL_BLOCKED 0
#define MA_ME_FINAL_IDLE 1
#define MA_ME_FINAL_PREVIEW 2
struct SMA_MEFinalPosition100
{
 ulong ticket;
 string symbol;
 long magic;
 int side;
 double lots;
};
struct SMA_MEFinalPreview100
{
 int state;
 ulong ticket;
 int action; // 0 idle, 1 manage, 2 exit
 string reason;
 bool brokerArmed;
};
void MAResetMEFinalPreview100(SMA_MEFinalPreview100 &out)
{
 out.state=MA_ME_FINAL_BLOCKED;out.ticket=0;out.action=0;
 out.reason="BLOCKED";out.brokerArmed=false;
}
bool MAValidMEFinalPosition100(const SMA_MEFinalPosition100 &p,
 const string symbol,const long magic)
{
 return symbol!=""&&magic>0&&p.ticket>0&&p.symbol==symbol&&p.magic==magic&&
 (p.side==(int)POSITION_TYPE_BUY||p.side==(int)POSITION_TYPE_SELL)&&
 p.lots>0&&MathIsValidNumber(p.lots);
}
bool MAEqualMEFinalPosition100(const SMA_MEFinalPosition100 &a,
 const SMA_MEFinalPosition100 &b)
{
 return a.ticket==b.ticket&&a.symbol==b.symbol&&a.magic==b.magic&&
 a.side==b.side&&MathAbs(a.lots-b.lots)<0.00000001;
}
bool MASameMEFinalSet100(SMA_MEFinalPosition100 &before[],
 SMA_MEFinalPosition100 &after[],const string symbol,const long magic)
{
 int n=ArraySize(before);
 if(n<=0||n!=ArraySize(after))return false;
 for(int i=0;i<n;i++)
 {
  if(!MAValidMEFinalPosition100(before[i],symbol,magic)||
     !MAValidMEFinalPosition100(after[i],symbol,magic))return false;
  for(int j=0;j<i;j++)
   if(before[i].ticket==before[j].ticket||after[i].ticket==after[j].ticket)return false;
  int matches=0;
  for(int k=0;k<n;k++)if(MAEqualMEFinalPosition100(before[i],after[k]))matches++;
  if(matches!=1)return false;
 }
 return true;
}
bool MACaptureMEFinalOwned100(const string symbol,const long magic,
 SMA_MEFinalPosition100 &out[])
{
 ArrayResize(out,0);
 if(symbol==""||magic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){ArrayResize(out,0);return false;}
  if(PositionGetString(POSITION_SYMBOL)!=symbol||
     PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  int n=ArraySize(out);
  if(ArrayResize(out,n+1)!=n+1){ArrayResize(out,0);return false;}
  out[n].ticket=ticket;
  out[n].symbol=PositionGetString(POSITION_SYMBOL);
  out[n].magic=PositionGetInteger(POSITION_MAGIC);
  out[n].side=(int)PositionGetInteger(POSITION_TYPE);
  out[n].lots=PositionGetDouble(POSITION_VOLUME);
  if(!MAValidMEFinalPosition100(out[n],symbol,magic))
  {ArrayResize(out,0);return false;}
 }
 return true;
}
bool MABuildMEFinalPreview100(SMA_MEFinalPosition100 &before[],
 SMA_MEFinalPosition100 &after[],const string symbol,const long magic,
 const ulong ticket,const bool managePreview,const bool exitPreview,
 const bool upstreamBrokerArmed,SMA_MEFinalPreview100 &out)
{
 MAResetMEFinalPreview100(out);
 if(upstreamBrokerArmed){out.reason="ARMED_UPSTREAM";return false;}
 if(!MASameMEFinalSet100(before,after,symbol,magic))
 {out.reason="STALE_OR_INVALID_SET";return false;}
 int matches=0;
 for(int i=0;i<ArraySize(after);i++)if(after[i].ticket==ticket)matches++;
 if(matches!=1){out.reason="TARGET_NOT_OWNED";return false;}
 out.ticket=ticket;
 out.action=exitPreview?2:(managePreview?1:0);
 out.state=out.action==0?MA_ME_FINAL_IDLE:MA_ME_FINAL_PREVIEW;
 out.reason=out.action==0?"NO_SIGNAL":"PREVIEW_ONLY_NOT_EXECUTABLE";
 return true;
}
#endif
