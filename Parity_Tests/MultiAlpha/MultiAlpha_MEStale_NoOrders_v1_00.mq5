#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-26: immutable ticket snapshot / fail-closed recheck. No trade APIs.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
void A26Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_STALE_CASE] ",name," ",ok?"PASS":"FAIL");
}
void A23Parts(string &parts[],string &values[],const string side,const int count)
{
 ArrayResize(parts,100);ArrayResize(values,100);
 for(int i=0;i<100;i++){parts[i]="EMPTY";values[i]="";}
 parts[0]="SIDE_COUNT";
 values[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 parts[1]="AND";parts[2]="CLOSE_SIDE";
}
bool A23Preview(const CMultiAlphaModuleLibraryStore101 &store,
 const string targetSide,SMA_MEExplicitTargetPreview100 &target)
{
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 SMA_MEAdapterPreview100 p;SMA_MEExecutionCapability100 c;
 SMA_MECloseSideResolution100 s;SMA_MEOwnedSideAudit100 o;
 MAResetMEExplicitTargetPreview100(target);
 if(!MABuildMEReadOnlyDecision100(store,3,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 if(!MAPreviewMERequest100(r,p))return false;
 if(!MAEvaluateMEExecutionCapability100(p,c))return false;
 if(!MAResolveCloseSideCandidate100(store,p,c,s))return false;
 if(!MAAuditMEOwnedCandidateSide100(p,s,o))return false;
 return MAPreviewMEExplicitTarget100(p,c,s,o,targetSide,target);
}
bool A23TicketMatch(const string symbol,const long magic,const int side,
 const string actualSymbol,const long actualMagic,const int actualSide,
 const ulong ticket,const double lots)
{
 return symbol!=""&&magic>0&&
 (side==(int)POSITION_TYPE_BUY||side==(int)POSITION_TYPE_SELL)&&
 actualSymbol==symbol&&actualMagic==magic&&actualSide==side&&
 ticket>0&&lots>0.0&&MathIsValidNumber(lots);
}
bool A23Bind(const SMA_MEExplicitTargetPreview100 &target,
 const string symbol,const long magic,ulong &tickets[],double &lots[])
{
 ArrayResize(tickets,0);ArrayResize(lots,0);
 if(target.state!=MA_ME_TARGET_PREVIEW||target.brokerArmed||
    (target.targetSide!=(int)POSITION_TYPE_BUY&&target.targetSide!=(int)POSITION_TYPE_SELL)||
    symbol==""||magic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return false;
  string ps=PositionGetString(POSITION_SYMBOL);
  long pm=PositionGetInteger(POSITION_MAGIC);
  int side=(int)PositionGetInteger(POSITION_TYPE);
  if(ps!=symbol||pm!=magic||side!=target.targetSide)continue;
  double volume=PositionGetDouble(POSITION_VOLUME);
  if(!A23TicketMatch(symbol,magic,target.targetSide,ps,pm,side,ticket,volume))return false;
  int n=ArraySize(tickets);
  for(int j=0;j<n;j++)if(tickets[j]==ticket)return false;
  ArrayResize(tickets,n+1);ArrayResize(lots,n+1);
  tickets[n]=ticket;lots[n]=volume;
 }
 return ArraySize(tickets)>0;
}

bool A25Recheck(const ulong ticket,const double expectedLots,
 const string symbol,const long magic,const int side)
{
 if(ticket==0||expectedLots<=0.0||!MathIsValidNumber(expectedLots)||
    symbol==""||magic<=0||!PositionSelectByTicket(ticket))return false;
 return PositionGetString(POSITION_SYMBOL)==symbol&&
 PositionGetInteger(POSITION_MAGIC)==magic&&
 (int)PositionGetInteger(POSITION_TYPE)==side&&
 MathAbs(PositionGetDouble(POSITION_VOLUME)-expectedLots)<0.00000001;
}
bool A25Pipeline(const CMultiAlphaModuleLibraryStore101 &store,
 const string targetSide,ulong &tickets[],double &lots[])
{
 ArrayResize(tickets,0);ArrayResize(lots,0);
 SMA_MEExplicitTargetPreview100 target;
 if(!A23Preview(store,targetSide,target))return false;
 if(!A23Bind(target,_Symbol,InpMagic,tickets,lots))return false;
 for(int i=0;i<ArraySize(tickets);i++)
  if(!A25Recheck(tickets[i],lots[i],_Symbol,InpMagic,target.targetSide))
  {ArrayResize(tickets,0);ArrayResize(lots,0);return false;}
 return ArraySize(tickets)>0;
}

bool A26SnapshotValid(const ulong &tickets[],const double &lots[],
 const string symbol,const long magic,const int side)
{
 int n=ArraySize(tickets);
 if(n<=0||n!=ArraySize(lots)||symbol==""||magic<=0||
    (side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL))return false;
 for(int i=0;i<n;i++)
 {
  if(!A25Recheck(tickets[i],lots[i],symbol,magic,side))return false;
  for(int j=0;j<i;j++)if(tickets[i]==tickets[j])return false;
 }
 int live=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return false;
  if(PositionGetString(POSITION_SYMBOL)==symbol&&
     PositionGetInteger(POSITION_MAGIC)==magic&&
     (int)PositionGetInteger(POSITION_TYPE)==side)
 {
   live++;
   bool found=false;
   for(int j=0;j<n;j++)if(tickets[j]==ticket)found=true;
   if(!found)return false;
 }
 }
 return live==n;
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string parts[],values[];
 ulong tickets[];double lots[];
 int sells=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t==0)continue;
  if(PositionGetString(POSITION_SYMBOL)==_Symbol&&
     PositionGetInteger(POSITION_MAGIC)==InpMagic&&
     PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sells++;
 }
 A23Parts(parts,values,"SELL",sells);
 A26Check("SAVE_EXIT",store.SaveDefinition(3,99,"A26_EXIT",parts,values,true));
 bool pipeline=A25Pipeline(store,"SELL",tickets,lots);
 A26Check("PIPELINE_READY",sells==0?!pipeline:pipeline);
 if(pipeline)
 {
  int side=(int)POSITION_TYPE_SELL;
  A26Check("LIVE_SNAPSHOT_ACCEPT",A26SnapshotValid(tickets,lots,_Symbol,InpMagic,side));
  ulong t0=tickets[0];double l0=lots[0];
  ulong fakeTickets[];double fakeLots[];
  ArrayCopy(fakeTickets,tickets);ArrayCopy(fakeLots,lots);
  fakeTickets[0]=0;
  A26Check("ZERO_TICKET_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  ArrayCopy(fakeTickets,tickets);
  fakeTickets[0]=(ulong)(-1);
  A26Check("DISAPPEARED_TICKET_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  ArrayCopy(fakeTickets,tickets);ArrayCopy(fakeLots,lots);
  fakeLots[0]=l0+0.01;
  A26Check("VOLUME_CHANGED_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  fakeLots[0]=0.0;
  A26Check("CLOSED_VOLUME_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  A26Check("WRONG_MAGIC_REJECT",!A26SnapshotValid(tickets,lots,_Symbol,InpMagic+1,side));
  A26Check("WRONG_SYMBOL_REJECT",!A26SnapshotValid(tickets,lots,_Symbol+"_X",InpMagic,side));
  A26Check("WRONG_SIDE_REJECT",!A26SnapshotValid(tickets,lots,_Symbol,InpMagic,(int)POSITION_TYPE_BUY));
  ArrayResize(fakeTickets,0);ArrayResize(fakeLots,0);
  A26Check("EMPTY_SNAPSHOT_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  ArrayCopy(fakeTickets,tickets);ArrayCopy(fakeLots,lots);
  ArrayResize(fakeLots,ArraySize(fakeLots)+1);
  A26Check("ARRAY_LENGTH_MISMATCH_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  ArrayCopy(fakeTickets,tickets);ArrayCopy(fakeLots,lots);
  int n=ArraySize(fakeTickets);ArrayResize(fakeTickets,n+1);ArrayResize(fakeLots,n+1);
  fakeTickets[n]=t0;fakeLots[n]=l0;
  A26Check("DUPLICATE_TICKET_REJECT",!A26SnapshotValid(fakeTickets,fakeLots,_Symbol,InpMagic,side));
  Print("[MA_ME_STALE_INFO] live_ticket=",t0," lots=",DoubleToString(l0,2)," owned_sell=",sells);
 }
 A26Check("INVALID_MAGIC_REJECT",!A26SnapshotValid(tickets,lots,_Symbol,0,(int)POSITION_TYPE_SELL));
 A26Check("INVALID_SIDE_REJECT",!A26SnapshotValid(tickets,lots,_Symbol,InpMagic,9));
 Print("[MA_ME_STALE_INFO] symbol=",_Symbol," magic=",InpMagic," owned_sell=",sells," cases=",g_cases," failures=",g_fails);
 if(g_fails>0)Print("[MA_ME_STALE_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(!pipeline)Print("[MA_ME_STALE_INCONCLUSIVE] cases=",g_cases," live_sell_missing=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_STALE_PASS] cases=",g_cases," fail_closed_snapshot=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
