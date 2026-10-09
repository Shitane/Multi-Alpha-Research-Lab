#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Adapter_Preview_v1_00.mqh>
#include <Builder/MultiAlpha_ME_Final_Preview_Gate_v1_00.mqh>
// A14-39: saved MANAGE/EXIT slot -> live owned-set -> final gate.
// Read-only, no OrderSend, CTrade, PositionClose or PositionModify.
input long InpMagic=46102031;
int a39_cases=0,a39_failures=0;
void A39Check(const string label,const bool ok)
{
 a39_cases++;if(!ok)a39_failures++;
 Print("[MA_ME_SAVED_FINAL_CASE] ",label," ",ok?"PASS":"FAIL");
}
void A39Parts(string &parts[],string &values[],const string side,
 const int count,const string action,const bool idle=false)
{
 ArrayResize(parts,100);ArrayResize(values,100);
 for(int i=0;i<100;i++){parts[i]="EMPTY";values[i]="";}
 parts[0]="SIDE_COUNT";
 values[0]="SIDE="+side+";COND="+(idle?"GT":"EQ")+";VALUE="+IntegerToString(count);
 parts[1]="AND";parts[2]=action;
 if(action=="SINGLE_TRAILING")
  values[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool A39Preview(const CMultiAlphaModuleLibraryStore101 &store,const int role,
 SMA_MEAdapterPreview100 &preview)
{
 MAResetMEAdapterPreview100(preview);
 SMA_MEReadOnlyDecision100 decision;
 SMA_MERequestBoundary100 request;
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,decision))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(decision,_Symbol,InpMagic,request))return false;
 return MAPreviewMERequest100(request,preview);
}
bool A39Gate(SMA_MEFinalPosition100 &before[],SMA_MEFinalPosition100 &after[],
 const ulong ticket,const SMA_MEAdapterPreview100 &m,
 const SMA_MEAdapterPreview100 &e,SMA_MEFinalPreview100 &out)
{
 bool validM=(m.state==MA_ME_PREVIEW_ACCEPTED||m.state==MA_ME_PREVIEW_IDLE)
  &&m.role==2&&m.slotIndex==99&&m.symbol==_Symbol&&m.magic==InpMagic&&!m.brokerArmed;
 bool validE=(e.state==MA_ME_PREVIEW_ACCEPTED||e.state==MA_ME_PREVIEW_IDLE)
  &&e.role==3&&e.slotIndex==99&&e.symbol==_Symbol&&e.magic==InpMagic&&!e.brokerArmed;
 MAResetMEFinalPreview100(out);
 if(!validM||!validE){out.reason="UPSTREAM_INVALID";return false;}
 return MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,ticket,
  m.state==MA_ME_PREVIEW_ACCEPTED,e.state==MA_ME_PREVIEW_ACCEPTED,
  m.brokerArmed||e.brokerArmed,out);
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEFinalPosition100 before[],after[];
 SMA_MEAdapterPreview100 m,e;
 SMA_MEFinalPreview100 out;
 string p[],v[];
 A39Check("LIVE_CAPTURE",MACaptureMEFinalOwned100(_Symbol,InpMagic,before));
 A39Check("UNSAVED_MANAGE_REJECT",!A39Preview(store,2,m));
 A39Check("UNSAVED_EXIT_REJECT",!A39Preview(store,3,e));
 if(ArraySize(before)==0)
 {
  Print("[MA_ME_SAVED_FINAL_INCONCLUSIVE] no_owned_positions=1 cases=",a39_cases,
   " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return INIT_SUCCEEDED;
 }
 int target=0,side=before[target].side,count=0;
 string sideName=side==(int)POSITION_TYPE_SELL?"SELL":"BUY";
 for(int i=0;i<ArraySize(before);i++)if(before[i].side==side)count++;
 A39Parts(p,v,sideName,count,"SINGLE_TRAILING");
 A39Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A39_MANAGE",p,v,true));
 bool mp=A39Preview(store,2,m)&&m.state==MA_ME_PREVIEW_ACCEPTED
  &&m.action=="SINGLE_TRAILING"&&!m.brokerArmed;
 A39Check("SAVED_MANAGE_PREVIEW",mp);
 A39Parts(p,v,sideName,count,"CLOSE_SIDE");
 A39Check("SAVE_EXIT",store.SaveDefinition(3,99,"A39_EXIT",p,v,true));
 bool ep=A39Preview(store,3,e)&&e.state==MA_ME_PREVIEW_ACCEPTED
  &&e.action=="CLOSE_SIDE"&&!e.brokerArmed;
 A39Check("SAVED_EXIT_PREVIEW",ep);
 bool refreshed=MACaptureMEFinalOwned100(_Symbol,InpMagic,after);
 A39Check("LIVE_REFRESH",refreshed);
 bool same=refreshed&&MASameMEFinalSet100(before,after,_Symbol,InpMagic);
 A39Check("LIVE_SET_UNCHANGED",same);
 bool ok=A39Gate(before,after,before[target].ticket,m,e,out);
 A39Check("SAVED_EXIT_PRIORITY_FINAL",mp&&ep&&same&&ok
  &&out.state==MA_ME_FINAL_PREVIEW&&out.action==2&&!out.brokerArmed);
 A39Parts(p,v,sideName,count,"CLOSE_SIDE",true);
 A39Check("SAVE_EXIT_IDLE",store.SaveDefinition(3,99,"A39_EXIT_IDLE",p,v,true));
 bool idleExit=A39Preview(store,3,e)&&e.state==MA_ME_PREVIEW_IDLE;
 A39Check("SAVED_EXIT_IDLE",idleExit);
 ok=A39Gate(before,after,before[target].ticket,m,e,out);
 A39Check("MANAGE_ONLY_FINAL",mp&&idleExit&&same&&ok
  &&out.state==MA_ME_FINAL_PREVIEW&&out.action==1);
 A39Parts(p,v,sideName,count,"SINGLE_TRAILING",true);
 A39Check("SAVE_MANAGE_IDLE",store.SaveDefinition(2,99,"A39_MANAGE_IDLE",p,v,true));
 bool idleManage=A39Preview(store,2,m)&&m.state==MA_ME_PREVIEW_IDLE;
 A39Check("SAVED_MANAGE_IDLE",idleManage);
 ok=A39Gate(before,after,before[target].ticket,m,e,out);
 A39Check("BOTH_IDLE_FINAL",idleManage&&idleExit&&same&&ok
  &&out.state==MA_ME_FINAL_IDLE&&out.action==0);
 A39Check("UNKNOWN_TICKET_REJECT",!A39Gate(before,after,0,m,e,out)
  &&out.state==MA_ME_FINAL_BLOCKED);
 if(ArraySize(after)>0)
 {
  double original=after[0].lots;
  after[0].lots=original+0.01;
  A39Check("STALE_LOTS_REJECT",!A39Gate(before,after,before[target].ticket,m,e,out)
   &&out.state==MA_ME_FINAL_BLOCKED);
  after[0].lots=original;
 }
 A39Check("RESTORED_SET_ACCEPT",A39Gate(before,after,before[target].ticket,m,e,out)
  &&out.state==MA_ME_FINAL_IDLE);
 Print("[MA_ME_SAVED_FINAL_INFO] symbol=",_Symbol," magic=",InpMagic,
  " live_owned=",ArraySize(before)," ticket=",before[target].ticket,
  " cases=",a39_cases," failures=",a39_failures);
 if(a39_failures>0)
  Print("[MA_ME_SAVED_FINAL_FAIL] cases=",a39_cases," failures=",a39_failures,
   " NO_ORDERS=1");
 else if(!same||!mp||!ep)
  Print("[MA_ME_SAVED_FINAL_INCONCLUSIVE] cases=",a39_cases,
   " saved_or_live_preconditions_missing=1 runtime_certified=0 NO_ORDERS=1");
 else
  Print("[MA_ME_SAVED_FINAL_PASS] cases=",a39_cases,
   " saved_slot_to_final_gate=PASS live_multi_certified=0 runtime_certified=0",
   " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
