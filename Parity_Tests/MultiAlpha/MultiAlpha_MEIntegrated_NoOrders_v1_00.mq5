#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-25 saved EXIT -> preview -> ticket bind -> read-only recheck. No orders.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
void A25Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_INTEGRATED_CASE] ",name," ",ok?"PASS":"FAIL");
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
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string parts[],values[];
 ulong tickets[];double lots[];
 int sells=0,buys=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t==0)continue;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||
     PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sells++;
  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)buys++;
 }
 A25Check("UNSAVED_REJECT",!A25Pipeline(store,"SELL",tickets,lots));
 A23Parts(parts,values,"SELL",sells);
 A25Check("SAVE_SELL",store.SaveDefinition(3,99,"A25_SELL",parts,values,true));
 bool sell=A25Pipeline(store,"SELL",tickets,lots);
 A25Check("SELL_INTEGRATED",sells==0?!sell:(sell&&ArraySize(tickets)==sells));
 if(sell)
 {
  bool all=true;
  for(int i=0;i<ArraySize(tickets);i++)
  {
   bool ok=A25Recheck(tickets[i],lots[i],_Symbol,InpMagic,(int)POSITION_TYPE_SELL);
   if(!ok)all=false;
   Print("[MA_ME_INTEGRATED_INFO] side=SELL ticket=",tickets[i],
    " lots=",DoubleToString(lots[i],2)," rechecked=",ok?1:0);
  }
  A25Check("SELL_RECHECK_ALL",all);
  A25Check("WRONG_MAGIC_REJECT",!A25Recheck(tickets[0],lots[0],_Symbol,InpMagic+1,(int)POSITION_TYPE_SELL));
  A25Check("WRONG_SYMBOL_REJECT",!A25Recheck(tickets[0],lots[0],_Symbol+"_OTHER",InpMagic,(int)POSITION_TYPE_SELL));
  A25Check("OPPOSITE_SIDE_REJECT",!A25Recheck(tickets[0],lots[0],_Symbol,InpMagic,(int)POSITION_TYPE_BUY));
  A25Check("STALE_VOLUME_REJECT",!A25Recheck(tickets[0],lots[0]+0.01,_Symbol,InpMagic,(int)POSITION_TYPE_SELL));
 }
 A25Check("WRONG_TARGET_REJECT",!A25Pipeline(store,"BUY",tickets,lots));
 A23Parts(parts,values,"BUY",buys);
 A25Check("SAVE_BUY",store.SaveDefinition(3,99,"A25_BUY",parts,values,true));
 bool buy=A25Pipeline(store,"BUY",tickets,lots);
 A25Check("BUY_INTEGRATED",buys==0?!buy:(buy&&ArraySize(tickets)==buys));
 A25Check("SELL_TARGET_REJECT",!A25Pipeline(store,"SELL",tickets,lots));
 A25Check("ZERO_TICKET_REJECT",!A25Recheck(0,0.01,_Symbol,InpMagic,(int)POSITION_TYPE_SELL));
 A25Check("ZERO_VOLUME_REJECT",!A25Recheck(1,0.0,_Symbol,InpMagic,(int)POSITION_TYPE_SELL));
 A25Check("MISSING_TICKET_REJECT",!A25Recheck(1234567,0.01,_Symbol,InpMagic,(int)POSITION_TYPE_SELL));
 Print("[MA_ME_INTEGRATED_INFO] symbol=",_Symbol," magic=",InpMagic,
 " owned_sell=",sells," owned_buy=",buys," cases=",g_cases," failures=",g_fails);
 if(g_fails>0)Print("[MA_ME_INTEGRATED_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(sells+buys==0)Print("[MA_ME_INTEGRATED_INCONCLUSIVE] cases=",g_cases," zero_owned_positions=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_INTEGRATED_PASS] cases=",g_cases," saved_exit_ticket_recheck=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
