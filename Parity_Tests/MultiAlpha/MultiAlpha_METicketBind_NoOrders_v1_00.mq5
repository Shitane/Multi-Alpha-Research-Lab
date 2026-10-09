#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-23: saved EXIT target -> read-only ticket binding. Never executes orders.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
void A23Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_TICKET_BIND_CASE] ",name," ",ok?"PASS":"FAIL");
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
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEExplicitTargetPreview100 target;
 string parts[],values[];
 int sells=0,buys=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return INIT_FAILED;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sells++;
  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)buys++;
 }
 ulong tickets[];double lots[];
 A23Check("UNSAVED_REJECT",!A23Preview(store,"SELL",target));
 A23Parts(parts,values,"SELL",sells);
 A23Check("SAVE_SELL",store.SaveDefinition(3,99,"A23_SELL",parts,values,true));
 bool sellPreview=A23Preview(store,"SELL",target);
 A23Check("SELL_PREVIEW",sells==0?!sellPreview:sellPreview);
 bool sellBind=A23Bind(target,_Symbol,InpMagic,tickets,lots);
 A23Check("SELL_TICKET_BIND",sells==0?!sellBind:(sellPreview&&sellBind&&ArraySize(tickets)==sells));
 for(int i=0;i<ArraySize(tickets);i++)
  Print("[MA_ME_TICKET_BIND_INFO] side=SELL ticket=",tickets[i]," lots=",DoubleToString(lots[i],2));
 A23Check("WRONG_MAGIC_REJECT",!A23Bind(target,_Symbol,InpMagic+1,tickets,lots));
 A23Check("WRONG_SYMBOL_REJECT",!A23Bind(target,_Symbol+"_OTHER",InpMagic,tickets,lots));
 A23Check("ZERO_MAGIC_REJECT",!A23Bind(target,_Symbol,0,tickets,lots));
 A23Check("EMPTY_SYMBOL_REJECT",!A23Bind(target,"",InpMagic,tickets,lots));
 A23Check("OPPOSITE_TARGET_REJECT",!A23Preview(store,"BUY",target));
 A23Parts(parts,values,"BUY",buys);
 A23Check("SAVE_BUY",store.SaveDefinition(3,99,"A23_BUY",parts,values,true));
 bool buyPreview=A23Preview(store,"BUY",target);
 A23Check("BUY_PREVIEW",buys==0?!buyPreview:buyPreview);
 bool buyBind=A23Bind(target,_Symbol,InpMagic,tickets,lots);
 A23Check("BUY_TICKET_BIND",buys==0?!buyBind:(buyPreview&&buyBind&&ArraySize(tickets)==buys));
 A23Check("OTHER_SIDE_REJECT",!A23Preview(store,"SELL",target));
 SMA_MEExplicitTargetPreview100 blocked;
 MAResetMEExplicitTargetPreview100(blocked);
 A23Check("BLOCKED_PREVIEW_REJECT",!A23Bind(blocked,_Symbol,InpMagic,tickets,lots));
 blocked.state=MA_ME_TARGET_PREVIEW;blocked.targetSide=(int)POSITION_TYPE_SELL;blocked.brokerArmed=true;
 A23Check("ARMED_PREVIEW_REJECT",!A23Bind(blocked,_Symbol,InpMagic,tickets,lots));
 A23Check("OTHER_MAGIC_MATCH_REJECT",!A23TicketMatch(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic+1,(int)POSITION_TYPE_SELL,1,0.01));
 A23Check("OTHER_SIDE_MATCH_REJECT",!A23TicketMatch(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic,(int)POSITION_TYPE_BUY,1,0.01));
 A23Check("ZERO_TICKET_REJECT",!A23TicketMatch(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0,0.01));
 A23Check("ZERO_LOTS_REJECT",!A23TicketMatch(_Symbol,InpMagic,(int)POSITION_TYPE_SELL,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,1,0.0));
 Print("[MA_ME_TICKET_BIND_INFO] symbol=",_Symbol," magic=",InpMagic," owned_sell=",sells," owned_buy=",buys);
 if(g_fails>0)Print("[MA_ME_TICKET_BIND_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(sells+buys==0)Print("[MA_ME_TICKET_BIND_INCONCLUSIVE] cases=",g_cases," zero_owned_positions=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_TICKET_BIND_PASS] cases=",g_cases," saved_target_ticket_binding=PASS execution_target_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
