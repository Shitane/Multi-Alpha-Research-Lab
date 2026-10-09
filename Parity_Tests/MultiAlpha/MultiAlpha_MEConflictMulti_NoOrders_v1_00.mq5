#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-35: saved MANAGE/EXIT preview -> per-ticket arbitration.
// Multi-position fixture only. No OrderSend, CTrade or position mutation.
input long InpMagic=46102031;
int a35_cases=0,a35_fails=0;
struct A35Pos {ulong ticket;string symbol;long magic;int side;double lots;};
void A35Check(const string label,const bool ok)
{
 a35_cases++;if(!ok)a35_fails++;
 Print("[MA_ME_CONFLICT_MULTI_CASE] ",label," ",ok?"PASS":"FAIL");
}
void A35Set(A35Pos &p,const ulong t,const string s,const long m,const int side,const double lots)
{p.ticket=t;p.symbol=s;p.magic=m;p.side=side;p.lots=lots;}
void A35Parts(string &p[],string &v[],const string side,const int count,const string action)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";v[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 p[1]="AND";p[2]=action;
 if(action=="SINGLE_TRAILING")v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool A35Preview(const CMultiAlphaModuleLibraryStore101 &store,const int role,SMA_MEAdapterPreview100 &p)
{
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 MAResetMEAdapterPreview100(p);
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,p);
}
bool A35Valid(const A35Pos &p)
{
 return p.ticket>0&&p.symbol==_Symbol&&p.magic==InpMagic&&InpMagic>0&&
 (p.side==(int)POSITION_TYPE_BUY||p.side==(int)POSITION_TYPE_SELL)&&
 p.lots>0&&MathIsValidNumber(p.lots);
}
bool A35Arbitrate(A35Pos &positions[],bool &manage[],bool &exitSignal[],int &decision[])
{
 int count=ArraySize(positions);
 ArrayResize(decision,0);
 if(count<=0||count!=ArraySize(manage)||count!=ArraySize(exitSignal))return false;
 for(int i=0;i<count;i++)
 {
  if(!A35Valid(positions[i]))return false;
  for(int j=0;j<i;j++)if(positions[i].ticket==positions[j].ticket)return false;
 }
 ArrayResize(decision,count);
 for(int i=0;i<count;i++)
  decision[i]=exitSignal[i]?2:(manage[i]?1:0);
 return true;
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEAdapterPreview100 mp,ep;
 string parts[],values[];
 int buys=0,sells=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);if(t==0)continue;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  int side=(int)PositionGetInteger(POSITION_TYPE);
  if(side==(int)POSITION_TYPE_BUY)buys++;
  if(side==(int)POSITION_TYPE_SELL)sells++;
 }
 A35Check("UNSAVED_MANAGE_REJECT",!A35Preview(store,2,mp));
 A35Check("UNSAVED_EXIT_REJECT",!A35Preview(store,3,ep));
 const string targetSide=sells>0?"SELL":"BUY";
 const int targetCount=sells>0?sells:buys;
 if(targetCount==0)
 {
  Print("[MA_ME_CONFLICT_MULTI_INCONCLUSIVE] cases=",a35_cases,
        " no_owned_position=1 fixture_not_run=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return INIT_SUCCEEDED;
 }
 A35Parts(parts,values,targetSide,targetCount,"SINGLE_TRAILING");
 A35Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A35_MANAGE",parts,values,true));
 bool m=A35Preview(store,2,mp)&&mp.state==MA_ME_PREVIEW_ACCEPTED&&
   mp.action=="SINGLE_TRAILING"&&!mp.brokerArmed;
 A35Check("SAVED_MANAGE_PREVIEW",m);
 A35Parts(parts,values,targetSide,targetCount,"CLOSE_SIDE");
 A35Check("SAVE_EXIT",store.SaveDefinition(3,99,"A35_EXIT",parts,values,true));
 bool e=A35Preview(store,3,ep)&&ep.state==MA_ME_PREVIEW_ACCEPTED&&
   ep.action=="CLOSE_SIDE"&&!ep.brokerArmed;
 A35Check("SAVED_EXIT_PREVIEW",e);
 A35Pos pos[];bool ms[],es[];int result[];
 ArrayResize(pos,3);ArrayResize(ms,3);ArrayResize(es,3);
 int targetType=targetSide=="SELL"?(int)POSITION_TYPE_SELL:(int)POSITION_TYPE_BUY;
 A35Set(pos[0],101,_Symbol,InpMagic,targetType,0.01);
 A35Set(pos[1],102,_Symbol,InpMagic,targetType,0.02);
 A35Set(pos[2],103,_Symbol,InpMagic,targetType,0.03);
 ms[0]=m;ms[1]=m;ms[2]=false;
 es[0]=e;es[1]=false;es[2]=e;
 bool ready=A35Arbitrate(pos,ms,es,result);
 A35Check("MULTI_FIXTURE_READY",ready&&ArraySize(result)==3);
 A35Check("SAME_TICKET_EXIT_PRIORITY",ready&&result[0]==2);
 A35Check("OTHER_TICKET_MANAGE_INDEPENDENT",ready&&result[1]==1);
 A35Check("THIRD_TICKET_EXIT_INDEPENDENT",ready&&result[2]==2);
 es[0]=false;
 ready=A35Arbitrate(pos,ms,es,result);
 A35Check("EXIT_REMOVED_MANAGE_RESTORED",ready&&result[0]==1&&result[1]==1&&result[2]==2);
 ms[1]=false;
 ready=A35Arbitrate(pos,ms,es,result);
 A35Check("OTHER_TICKET_IDLE",ready&&result[0]==1&&result[1]==0&&result[2]==2);
 es[2]=false;
 ready=A35Arbitrate(pos,ms,es,result);
 A35Check("NO_SIGNAL_ISOLATED",ready&&result[0]==1&&result[1]==0&&result[2]==0);
 pos[2].ticket=pos[0].ticket;
 A35Check("DUPLICATE_TICKET_REJECT",!A35Arbitrate(pos,ms,es,result));
 pos[2].ticket=103;pos[2].magic=InpMagic+1;
 A35Check("FOREIGN_MAGIC_REJECT",!A35Arbitrate(pos,ms,es,result));
 pos[2].magic=InpMagic;pos[2].symbol=_Symbol+"_OTHER";
 A35Check("FOREIGN_SYMBOL_REJECT",!A35Arbitrate(pos,ms,es,result));
 pos[2].symbol=_Symbol;pos[2].lots=0;
 A35Check("ZERO_VOLUME_REJECT",!A35Arbitrate(pos,ms,es,result));
 pos[2].lots=0.03;pos[2].side=9;
 A35Check("INVALID_SIDE_REJECT",!A35Arbitrate(pos,ms,es,result));
 pos[2].side=targetType;pos[2].ticket=0;
 A35Check("ZERO_TICKET_REJECT",!A35Arbitrate(pos,ms,es,result));
 pos[2].ticket=103;
 ArrayResize(es,2);
 A35Check("ARRAY_LENGTH_MISMATCH_REJECT",!A35Arbitrate(pos,ms,es,result));
 ArrayResize(es,3);es[0]=false;es[1]=false;es[2]=false;
 ArrayResize(pos,0);ArrayResize(ms,0);ArrayResize(es,0);
 A35Check("EMPTY_SET_REJECT",!A35Arbitrate(pos,ms,es,result));
 Print("[MA_ME_CONFLICT_MULTI_INFO] symbol=",_Symbol," magic=",InpMagic,
  " live_owned_buy=",buys," live_owned_sell=",sells,
  " fixture_positions=3 cases=",a35_cases," failures=",a35_fails);
 if(a35_fails>0)
  Print("[MA_ME_CONFLICT_MULTI_FAIL] cases=",a35_cases," failures=",a35_fails," NO_ORDERS=1");
 else
  Print("[MA_ME_CONFLICT_MULTI_PASS] cases=",a35_cases,
   " saved_preview_arbitration_fixture=PASS live_multi_certified=0 builder_execution_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
