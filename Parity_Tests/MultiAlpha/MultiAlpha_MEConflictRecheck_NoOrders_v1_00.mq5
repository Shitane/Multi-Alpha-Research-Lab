#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-36: saved MANAGE/EXIT -> ticket arbitration -> immutable set recheck.
// No orders, no position modifications. Multi-position scenarios are fixtures.
input long InpMagic=46102031;
int a36_cases=0,a36_failures=0;
struct A36Pos {ulong ticket;string symbol;long magic;int side;double lots;};
void A36Check(const string label,const bool ok)
{
 a36_cases++;if(!ok)a36_failures++;
 Print("[MA_ME_CONFLICT_RECHECK_CASE] ",label," ",ok?"PASS":"FAIL");
}
void A36Set(A36Pos &p,const ulong t,const string s,const long m,const int side,const double lots)
{p.ticket=t;p.symbol=s;p.magic=m;p.side=side;p.lots=lots;}
void A36Copy(A36Pos &dst,const A36Pos &src)
{A36Set(dst,src.ticket,src.symbol,src.magic,src.side,src.lots);}
bool A36Valid(const A36Pos &p)
{
 return p.ticket>0&&p.symbol==_Symbol&&InpMagic>0&&p.magic==InpMagic&&
 (p.side==(int)POSITION_TYPE_BUY||p.side==(int)POSITION_TYPE_SELL)&&
 p.lots>0&&MathIsValidNumber(p.lots);
}
bool A36Same(const A36Pos &a,const A36Pos &b)
{
 return a.ticket==b.ticket&&a.symbol==b.symbol&&a.magic==b.magic&&
 a.side==b.side&&MathAbs(a.lots-b.lots)<0.00000001;
}
bool A36Recheck(A36Pos &saved[],A36Pos &current[])
{
 int n=ArraySize(saved);
 if(n<=0||n!=ArraySize(current))return false;
 for(int i=0;i<n;i++)
 {
  if(!A36Valid(saved[i])||!A36Valid(current[i]))return false;
  for(int j=0;j<i;j++)
  {
   if(saved[i].ticket==saved[j].ticket||current[i].ticket==current[j].ticket)return false;
  }
  int matches=0;
  for(int k=0;k<n;k++)if(A36Same(saved[i],current[k]))matches++;
  if(matches!=1)return false;
 }
 return true;
}
bool A36Arbitrate(A36Pos &saved[],bool &manage[],bool &exitSignal[],int &result[])
{
 ArrayResize(result,0);
 int n=ArraySize(saved);
 if(n<=0||n!=ArraySize(manage)||n!=ArraySize(exitSignal))return false;
 for(int i=0;i<n;i++)
 {
  if(!A36Valid(saved[i]))return false;
  for(int j=0;j<i;j++)if(saved[i].ticket==saved[j].ticket)return false;
 }
 ArrayResize(result,n);
 for(int i=0;i<n;i++)result[i]=exitSignal[i]?2:(manage[i]?1:0);
 return true;
}
bool A36Capture(A36Pos &out[])
{
 ArrayResize(out,0);
 if(_Symbol==""||InpMagic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return false;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  int n=ArraySize(out);ArrayResize(out,n+1);
  A36Set(out[n],ticket,PositionGetString(POSITION_SYMBOL),
    PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE),
    PositionGetDouble(POSITION_VOLUME));
  if(!A36Valid(out[n]))return false;
 }
 return true;
}
void A36Parts(string &p[],string &v[],const string side,const int count,const string action)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";v[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 p[1]="AND";p[2]=action;
 if(action=="SINGLE_TRAILING")v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool A36Preview(const CMultiAlphaModuleLibraryStore101 &store,const int role,SMA_MEAdapterPreview100 &p)
{
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 MAResetMEAdapterPreview100(p);
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,p);
}
int OnInit()
{
 A36Pos live[],fresh[];
 bool captured=A36Capture(live);
 A36Check("LIVE_CAPTURE",captured);
 if(!captured)
 {
  Print("[MA_ME_CONFLICT_RECHECK_FAIL] live_capture_failed=1 cases=",a36_cases," failures=",a36_failures," NO_ORDERS=1");
  return INIT_SUCCEEDED;
 }
 int buys=0,sells=0;
 for(int i=0;i<ArraySize(live);i++)
 {
  if(live[i].side==(int)POSITION_TYPE_BUY)buys++;
  if(live[i].side==(int)POSITION_TYPE_SELL)sells++;
 }
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEAdapterPreview100 mp,ep;
 A36Check("UNSAVED_MANAGE_REJECT",!A36Preview(store,2,mp));
 A36Check("UNSAVED_EXIT_REJECT",!A36Preview(store,3,ep));
 if(buys+sells==0)
 {
  Print("[MA_ME_CONFLICT_RECHECK_INCONCLUSIVE] cases=",a36_cases,
   " zero_owned=1 fixture_not_run=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return INIT_SUCCEEDED;
 }
 string side=sells>0?"SELL":"BUY";
 int count=sells>0?sells:buys;
 string p[],v[];
 A36Parts(p,v,side,count,"SINGLE_TRAILING");
 A36Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A36_MANAGE",p,v,true));
 bool m=A36Preview(store,2,mp)&&mp.state==MA_ME_PREVIEW_ACCEPTED&&
 mp.action=="SINGLE_TRAILING"&&!mp.brokerArmed;
 A36Check("SAVED_MANAGE_PREVIEW",m);
 A36Parts(p,v,side,count,"CLOSE_SIDE");
 A36Check("SAVE_EXIT",store.SaveDefinition(3,99,"A36_EXIT",p,v,true));
 bool e=A36Preview(store,3,ep)&&ep.state==MA_ME_PREVIEW_ACCEPTED&&
 ep.action=="CLOSE_SIDE"&&!ep.brokerArmed;
 A36Check("SAVED_EXIT_PREVIEW",e);
 A36Pos base[],now[];
 ArrayResize(base,3);ArrayResize(now,3);
 int t=side=="SELL"?(int)POSITION_TYPE_SELL:(int)POSITION_TYPE_BUY;
 A36Set(base[0],101,_Symbol,InpMagic,t,0.01);
 A36Set(base[1],102,_Symbol,InpMagic,t,0.02);
 A36Set(base[2],103,_Symbol,InpMagic,t,0.03);
 for(int i=0;i<3;i++)A36Copy(now[i],base[i]);
 bool ms[],es[];int result[];
 ArrayResize(ms,3);ArrayResize(es,3);
 ms[0]=m;ms[1]=m;ms[2]=false;
 es[0]=e;es[1]=false;es[2]=e;
 bool arb=A36Arbitrate(base,ms,es,result);
 A36Check("ARBITRATION_READY",arb&&ArraySize(result)==3);
 A36Check("SAME_TICKET_EXIT_PRIORITY",arb&&result[0]==2);
 A36Check("OTHER_TICKET_MANAGE",arb&&result[1]==1);
 A36Check("THIRD_TICKET_EXIT",arb&&result[2]==2);
 A36Check("UNCHANGED_SET_ACCEPT",A36Recheck(base,now));
 A36Pos tmp;A36Copy(tmp,now[0]);A36Copy(now[0],now[2]);A36Copy(now[2],tmp);
 A36Check("REORDER_ACCEPT",A36Recheck(base,now));
 for(int i=0;i<3;i++)A36Copy(now[i],base[i]);
 now[0].lots=0.005;
 A36Check("PARTIAL_CLOSE_REJECT",!A36Recheck(base,now));
 now[0].lots=0.04;
 A36Check("VOLUME_INCREASE_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].ticket=104;
 A36Check("REPLACED_TICKET_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].side=1-t;
 A36Check("SIDE_CHANGED_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].magic=InpMagic+1;
 A36Check("MAGIC_CHANGED_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].symbol=_Symbol+"_OTHER";
 A36Check("SYMBOL_CHANGED_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].ticket=now[1].ticket;
 A36Check("DUPLICATE_CURRENT_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].ticket=0;
 A36Check("ZERO_TICKET_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);now[0].lots=0;
 A36Check("ZERO_VOLUME_REJECT",!A36Recheck(base,now));
 A36Copy(now[0],base[0]);ArrayResize(now,2);
 A36Check("REMOVED_POSITION_REJECT",!A36Recheck(base,now));
 ArrayResize(now,4);
 for(int i=0;i<3;i++)A36Copy(now[i],base[i]);
 A36Set(now[3],104,_Symbol,InpMagic,t,0.04);
 A36Check("ADDED_POSITION_REJECT",!A36Recheck(base,now));
 ArrayResize(now,3);for(int i=0;i<3;i++)A36Copy(now[i],base[i]);
 base[2].ticket=base[1].ticket;
 A36Check("DUPLICATE_SAVED_REJECT",!A36Recheck(base,now));
 base[2].ticket=103;
 A36Check("RESTORED_SET_ACCEPT",A36Recheck(base,now));
 bool refreshed=A36Capture(fresh);
 A36Check("LIVE_REFRESH",refreshed);
 bool liveSame=refreshed&&A36Recheck(live,fresh);
 A36Check("LIVE_UNCHANGED_SET",liveSame);
 if(refreshed&&ArraySize(live)==1&&ArraySize(fresh)==1)
  Print("[MA_ME_CONFLICT_RECHECK_INFO] live_ticket=",live[0].ticket,
   " lots=",DoubleToString(live[0].lots,8));
 Print("[MA_ME_CONFLICT_RECHECK_INFO] symbol=",_Symbol," magic=",InpMagic,
  " live_owned=",ArraySize(live)," fixture_positions=3 cases=",a36_cases," failures=",a36_failures);
 if(a36_failures>0)
  Print("[MA_ME_CONFLICT_RECHECK_FAIL] cases=",a36_cases," failures=",a36_failures," NO_ORDERS=1");
 else
  Print("[MA_ME_CONFLICT_RECHECK_PASS] cases=",a36_cases,
   " saved_preview_arbitration_set_recheck=PASS live_multi_certified=0 builder_execution_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
