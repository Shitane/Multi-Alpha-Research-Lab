#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-37: saved MANAGE/EXIT -> per-ticket arbitration -> set recheck -> final preview.
// Read-only. Fixture arbitration is not live multi-position certification.
input long InpMagic=46102031;
int a37_cases=0,a37_failures=0;
struct A37Pos {ulong ticket;string symbol;long magic;int side;double lots;};
struct A37Final {int state;ulong ticket;int action;string reason;bool brokerArmed;};
#define A37_BLOCKED 0
#define A37_IDLE 1
#define A37_PREVIEW 2
void A37Check(const string label,const bool ok)
{
 a37_cases++;if(!ok)a37_failures++;
 Print("[MA_ME_CONFLICT_FINAL_CASE] ",label," ",ok?"PASS":"FAIL");
}
void A37Set(A37Pos &p,const ulong t,const string s,const long m,const int side,const double lots)
{p.ticket=t;p.symbol=s;p.magic=m;p.side=side;p.lots=lots;}
void A37Copy(A37Pos &d,const A37Pos &s)
{A37Set(d,s.ticket,s.symbol,s.magic,s.side,s.lots);}
bool A37Valid(const A37Pos &p)
{
 return p.ticket>0&&p.symbol==_Symbol&&InpMagic>0&&p.magic==InpMagic&&
 (p.side==(int)POSITION_TYPE_BUY||p.side==(int)POSITION_TYPE_SELL)&&
 p.lots>0&&MathIsValidNumber(p.lots);
}
bool A37Equal(const A37Pos &a,const A37Pos &b)
{
 return a.ticket==b.ticket&&a.symbol==b.symbol&&a.magic==b.magic&&
 a.side==b.side&&MathAbs(a.lots-b.lots)<0.00000001;
}
bool A37SameSet(A37Pos &before[],A37Pos &after[])
{
 int n=ArraySize(before);
 if(n<=0||n!=ArraySize(after))return false;
 for(int i=0;i<n;i++)
 {
  if(!A37Valid(before[i])||!A37Valid(after[i]))return false;
  for(int j=0;j<i;j++)
   if(before[i].ticket==before[j].ticket||after[i].ticket==after[j].ticket)return false;
  int found=0;
  for(int k=0;k<n;k++)if(A37Equal(before[i],after[k]))found++;
  if(found!=1)return false;
 }
 return true;
}
bool A37Capture(A37Pos &out[])
{
 ArrayResize(out,0);
 if(_Symbol==""||InpMagic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return false;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||
     PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  int n=ArraySize(out);ArrayResize(out,n+1);
  A37Set(out[n],ticket,PositionGetString(POSITION_SYMBOL),
   PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE),
   PositionGetDouble(POSITION_VOLUME));
  if(!A37Valid(out[n]))return false;
 }
 return true;
}
void A37Parts(string &p[],string &v[],const string side,const int count,const string action)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";v[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 p[1]="AND";p[2]=action;
 if(action=="SINGLE_TRAILING")v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool A37PreviewSaved(const CMultiAlphaModuleLibraryStore101 &store,const int role,
 SMA_MEAdapterPreview100 &out)
{
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 MAResetMEAdapterPreview100(out);
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,out);
}
void A37Reset(A37Final &out)
{out.state=A37_BLOCKED;out.ticket=0;out.action=0;out.reason="BLOCKED";out.brokerArmed=false;}
// 0=IDLE, 1=MANAGE preview, 2=EXIT preview. Never executable.
bool A37Decide(A37Pos &before[],A37Pos &after[],const ulong target,
 const bool manage,const bool exitSignal,A37Final &out)
{
 A37Reset(out);
 if(!A37SameSet(before,after)){out.reason="STALE_SET";return false;}
 int count=0;
 for(int i=0;i<ArraySize(after);i++)if(after[i].ticket==target)count++;
 if(count!=1){out.reason="TARGET_NOT_OWNED";return false;}
 out.ticket=target;
 out.action=exitSignal?2:(manage?1:0);
 out.state=out.action==0?A37_IDLE:A37_PREVIEW;
 out.reason=out.action==0?"NO_SIGNAL":"PREVIEW_ONLY_NOT_EXECUTABLE";
 return true;
}
int OnInit()
{
 A37Pos live[],fresh[];
 bool captured=A37Capture(live);
 A37Check("LIVE_CAPTURE",captured);
 if(!captured)
 {
  Print("[MA_ME_CONFLICT_FINAL_FAIL] capture_failed=1 cases=",a37_cases," failures=",a37_failures," NO_ORDERS=1");
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
 A37Check("UNSAVED_MANAGE_REJECT",!A37PreviewSaved(store,2,mp));
 A37Check("UNSAVED_EXIT_REJECT",!A37PreviewSaved(store,3,ep));
 if(buys+sells==0)
 {
  Print("[MA_ME_CONFLICT_FINAL_INCONCLUSIVE] cases=",a37_cases,
   " zero_owned=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return INIT_SUCCEEDED;
 }
 string side=sells>0?"SELL":"BUY";
 int count=sells>0?sells:buys;
 string p[],v[];
 A37Parts(p,v,side,count,"SINGLE_TRAILING");
 A37Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A37_MANAGE",p,v,true));
 bool m=A37PreviewSaved(store,2,mp)&&mp.state==MA_ME_PREVIEW_ACCEPTED&&
 mp.action=="SINGLE_TRAILING"&&!mp.brokerArmed;
 A37Check("SAVED_MANAGE_PREVIEW",m);
 A37Parts(p,v,side,count,"CLOSE_SIDE");
 A37Check("SAVE_EXIT",store.SaveDefinition(3,99,"A37_EXIT",p,v,true));
 bool e=A37PreviewSaved(store,3,ep)&&ep.state==MA_ME_PREVIEW_ACCEPTED&&
 ep.action=="CLOSE_SIDE"&&!ep.brokerArmed;
 A37Check("SAVED_EXIT_PREVIEW",e);
 A37Pos before[],after[];
 ArrayResize(before,3);ArrayResize(after,3);
 int t=side=="SELL"?(int)POSITION_TYPE_SELL:(int)POSITION_TYPE_BUY;
 A37Set(before[0],101,_Symbol,InpMagic,t,0.01);
 A37Set(before[1],102,_Symbol,InpMagic,t,0.02);
 A37Set(before[2],103,_Symbol,InpMagic,t,0.03);
 for(int i=0;i<3;i++)A37Copy(after[i],before[i]);
 A37Final out;
 bool ok=A37Decide(before,after,101,m,e,out);
 A37Check("SAME_TICKET_EXIT_WINS",ok&&out.state==A37_PREVIEW&&out.action==2&&!out.brokerArmed);
 ok=A37Decide(before,after,102,m,false,out);
 A37Check("OTHER_TICKET_MANAGE",ok&&out.action==1&&out.ticket==102);
 ok=A37Decide(before,after,103,false,e,out);
 A37Check("THIRD_TICKET_EXIT",ok&&out.action==2&&out.ticket==103);
 ok=A37Decide(before,after,103,false,false,out);
 A37Check("NO_SIGNAL_IDLE",ok&&out.state==A37_IDLE&&out.action==0);
 A37Pos tmp;A37Copy(tmp,after[0]);A37Copy(after[0],after[2]);A37Copy(after[2],tmp);
 ok=A37Decide(before,after,101,m,e,out);
 A37Check("REORDER_ACCEPT",ok&&out.action==2);
 for(int i=0;i<3;i++)A37Copy(after[i],before[i]);
 after[0].lots=0.005;
 A37Check("PARTIAL_CLOSE_BLOCK",!A37Decide(before,after,101,m,e,out)&&out.state==A37_BLOCKED&&out.action==0);
 after[0].lots=0.04;
 A37Check("VOLUME_INCREASE_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].ticket=104;
 A37Check("REPLACED_TICKET_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].magic=InpMagic+1;
 A37Check("MAGIC_CHANGED_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].symbol=_Symbol+"_OTHER";
 A37Check("SYMBOL_CHANGED_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].side=1-t;
 A37Check("SIDE_CHANGED_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].ticket=after[1].ticket;
 A37Check("DUPLICATE_TICKET_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].ticket=0;
 A37Check("ZERO_TICKET_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);after[0].lots=0;
 A37Check("ZERO_LOTS_BLOCK",!A37Decide(before,after,101,m,e,out));
 A37Copy(after[0],before[0]);ArrayResize(after,2);
 A37Check("REMOVED_POSITION_BLOCK",!A37Decide(before,after,101,m,e,out));
 ArrayResize(after,4);
 for(int i=0;i<3;i++)A37Copy(after[i],before[i]);
 A37Set(after[3],104,_Symbol,InpMagic,t,0.04);
 A37Check("ADDED_POSITION_BLOCK",!A37Decide(before,after,101,m,e,out));
 ArrayResize(after,3);
 for(int i=0;i<3;i++)A37Copy(after[i],before[i]);
 A37Check("UNKNOWN_TARGET_BLOCK",!A37Decide(before,after,999,m,e,out)&&out.state==A37_BLOCKED);
 A37Check("ZERO_TARGET_BLOCK",!A37Decide(before,after,0,m,e,out));
 bool refreshed=A37Capture(fresh);
 A37Check("LIVE_REFRESH",refreshed);
 bool same=refreshed&&A37SameSet(live,fresh);
 A37Check("LIVE_UNCHANGED_SET",same);
 if(same)
 {
  int targetIndex=-1;
  for(int i=0;i<ArraySize(live);i++)if(live[i].side==t){targetIndex=i;break;}
  if(targetIndex>=0)
  {
   bool liveOK=A37Decide(live,fresh,live[targetIndex].ticket,m,e,out);
   A37Check("LIVE_TARGET_FINAL_PREVIEW",liveOK&&out.state==A37_PREVIEW&&out.action==2&&!out.brokerArmed);
   Print("[MA_ME_CONFLICT_FINAL_INFO] live_ticket=",out.ticket,
    " action=",out.action," reason=",out.reason);
  }
  else A37Check("LIVE_TARGET_FINAL_PREVIEW",false);
 }
 else A37Check("LIVE_TARGET_FINAL_PREVIEW",false);
 Print("[MA_ME_CONFLICT_FINAL_INFO] symbol=",_Symbol," magic=",InpMagic,
  " live_owned=",ArraySize(live)," fixture_positions=3 cases=",a37_cases," failures=",a37_failures);
 if(a37_failures>0)
  Print("[MA_ME_CONFLICT_FINAL_FAIL] cases=",a37_cases," failures=",a37_failures," NO_ORDERS=1");
 else
  Print("[MA_ME_CONFLICT_FINAL_PASS] cases=",a37_cases,
   " saved_preview_conflict_recheck_final_preview=PASS live_multi_certified=0 builder_execution_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
