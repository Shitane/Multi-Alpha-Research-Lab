#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-27: position-set snapshot comparisons, read-only. No trade APIs.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
void A27Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_SET_CASE] ",name," ",ok?"PASS":"FAIL");
}
struct SMA_A27Position
{
 ulong ticket;
 string symbol;
 long magic;
 int side;
 double lots;
};
bool A27Valid(const SMA_A27Position &p,const string symbol,const long magic,const int side)
{
 return p.ticket>0&&p.symbol==symbol&&p.magic==magic&&p.side==side&&
 p.lots>0.0&&MathIsValidNumber(p.lots);
}
bool A27Compare(const SMA_A27Position &saved[],const SMA_A27Position &current[],
 const string symbol,const long magic,const int side)
{
 if(symbol==""||magic<=0||(side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL))
  return false;
 int n=ArraySize(saved);
 if(n<=0||n!=ArraySize(current))return false;
 for(int i=0;i<n;i++)
 {
  if(!A27Valid(saved[i],symbol,magic,side))return false;
  if(!A27Valid(current[i],symbol,magic,side))return false;
  for(int j=0;j<i;j++)
   if(saved[i].ticket==saved[j].ticket||current[i].ticket==current[j].ticket)
    return false;
  bool found=false;
  for(int k=0;k<n;k++)
   if(saved[i].ticket==current[k].ticket)
   {
    if(MathAbs(saved[i].lots-current[k].lots)>0.00000001)return false;
    found=true;
   }
  if(!found)return false;
 }
 return true;
}
void A27Copy(const SMA_A27Position &src[],SMA_A27Position &dst[])
{
 int n=ArraySize(src);ArrayResize(dst,n);
 for(int i=0;i<n;i++)dst[i]=src[i];
}
void A27Make(SMA_A27Position &p,const ulong ticket,const double lots,
 const string symbol,const long magic,const int side)
{
 p.ticket=ticket;p.lots=lots;p.symbol=symbol;p.magic=magic;p.side=side;
}
int OnInit()
{
 const string sym=_Symbol;
 const int side=(int)POSITION_TYPE_SELL;
 SMA_A27Position baseline[],candidate[];
 ArrayResize(baseline,2);
 A27Make(baseline[0],(ulong)900000001,0.01,sym,InpMagic,side);
 A27Make(baseline[1],(ulong)900000002,0.02,sym,InpMagic,side);
 A27Copy(baseline,candidate);
 A27Check("UNCHANGED_ACCEPT",A27Compare(baseline,candidate,sym,InpMagic,side));
 SMA_A27Position tmp=candidate[0];candidate[0]=candidate[1];candidate[1]=tmp;
 A27Check("REORDER_ACCEPT",A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);ArrayResize(candidate,3);
 A27Make(candidate[2],(ulong)900000003,0.01,sym,InpMagic,side);
 A27Check("ADDED_POSITION_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);ArrayResize(candidate,1);
 A27Check("REMOVED_POSITION_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].lots=0.005;
 A27Check("PARTIAL_CLOSE_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].lots=0.03;
 A27Check("VOLUME_INCREASE_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].ticket=(ulong)900000004;
 A27Check("REPLACED_TICKET_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[1].ticket=candidate[0].ticket;
 A27Check("DUPLICATE_CURRENT_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].magic=InpMagic+1;
 A27Check("OTHER_MAGIC_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].symbol=sym+"_X";
 A27Check("OTHER_SYMBOL_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].side=(int)POSITION_TYPE_BUY;
 A27Check("OPPOSITE_SIDE_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].lots=0;
 A27Check("ZERO_LOTS_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);candidate[0].ticket=0;
 A27Check("ZERO_TICKET_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 A27Copy(baseline,candidate);ArrayResize(baseline,0);
 A27Check("EMPTY_BASELINE_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 ArrayResize(baseline,2);
 A27Make(baseline[0],(ulong)900000001,0.01,sym,InpMagic,side);
 A27Make(baseline[1],(ulong)900000001,0.02,sym,InpMagic,side);
 A27Copy(baseline,candidate);
 A27Check("DUPLICATE_SAVED_REJECT",!A27Compare(baseline,candidate,sym,InpMagic,side));
 int owned=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t==0)continue;
  if(PositionGetString(POSITION_SYMBOL)==sym&&
     PositionGetInteger(POSITION_MAGIC)==InpMagic&&
     (int)PositionGetInteger(POSITION_TYPE)==side)owned++;
 }
 Print("[MA_ME_SET_INFO] symbol=",sym," magic=",InpMagic," live_owned_sell=",owned,
       " fixture_positions=2 cases=",g_cases," failures=",g_fails);
 if(g_fails>0)
  Print("[MA_ME_SET_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else
  Print("[MA_ME_SET_PASS] cases=",g_cases,
   " position_set_fixture=PASS live_set_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
