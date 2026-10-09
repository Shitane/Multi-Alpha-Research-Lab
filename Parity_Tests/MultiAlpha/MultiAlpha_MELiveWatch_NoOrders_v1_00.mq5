#property strict
#property version "1.00"
// A14-43: passive 30-second watch; verify only when 2+ owned positions exist.
// No order or position mutation. No live multi certification with fewer than 2 positions.
#include <Builder/MultiAlpha_ME_Adapter_Preview_v1_00.mqh>
#include <Builder/MultiAlpha_ME_Final_Preview_Gate_v1_00.mqh>
// A14-43: PASSIVE WATCH of LIVE owned position set, saved side predicates and per-ticket final preview.
// Strictly read-only. No OrderSend, CTrade, PositionClose or PositionModify.
input long InpMagic=46102031;
int a43_cases=0,a43_fails=0;
void A43Check(string label,bool ok)
{
 a43_cases++;if(!ok)a43_fails++;
 Print("[MA_ME_LIVE_WATCH_CASE] ",label," ",ok?"PASS":"FAIL");
}
void A43Parts(string &p[],string &v[],int sellCount,string action,bool idle=false)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";
 v[0]="SIDE=SELL;COND="+(idle?"GT":"EQ")+";VALUE="+IntegerToString(sellCount);
 p[1]="AND";p[2]=action;
 if(action=="SINGLE_TRAILING")v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool A43Preview(const CMultiAlphaModuleLibraryStore101 &store,int role,SMA_MEAdapterPreview100 &out)
{
 MAResetMEAdapterPreview100(out);
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,out);
}
bool A43Gate(SMA_MEFinalPosition100 &before[],SMA_MEFinalPosition100 &after[],
 ulong ticket,const SMA_MEAdapterPreview100 &m,const SMA_MEAdapterPreview100 &e,
 SMA_MEFinalPreview100 &out)
{
 MAResetMEFinalPreview100(out);
 bool vm=(m.state==MA_ME_PREVIEW_ACCEPTED||m.state==MA_ME_PREVIEW_IDLE)
  &&m.role==2&&m.slotIndex==99&&m.symbol==_Symbol&&m.magic==InpMagic&&!m.brokerArmed;
 bool ve=(e.state==MA_ME_PREVIEW_ACCEPTED||e.state==MA_ME_PREVIEW_IDLE)
  &&e.role==3&&e.slotIndex==99&&e.symbol==_Symbol&&e.magic==InpMagic&&!e.brokerArmed;
 if(!vm||!ve){out.reason="INVALID_UPSTREAM";return false;}
 int matches=0,side=-1;
 for(int i=0;i<ArraySize(before);i++)
  if(before[i].ticket==ticket){matches++;side=before[i].side;}
 if(matches!=1){out.reason="UNKNOWN_TICKET";return false;}
 bool sell=side==(int)POSITION_TYPE_SELL;
 return MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,ticket,
  sell&&m.state==MA_ME_PREVIEW_ACCEPTED,
  sell&&e.state==MA_ME_PREVIEW_ACCEPTED,false,out);
}
int A43Run()
{
 a43_cases=0;a43_fails=0;
 SMA_MEFinalPosition100 before[],after[];
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEAdapterPreview100 m,e;
 SMA_MEFinalPreview100 out;
 string p[],v[];
 bool captured=MACaptureMEFinalOwned100(_Symbol,InpMagic,before);
 int total=ArraySize(before),sellCount=0,buyCount=0;
 for(int i=0;i<total;i++)
 {
  if(before[i].side==(int)POSITION_TYPE_SELL)sellCount++;
  if(before[i].side==(int)POSITION_TYPE_BUY)buyCount++;
 }
 A43Check("LIVE_CAPTURE",captured);
 if(!captured||total==0)
 {
  Print("[MA_ME_LIVE_WATCH_INCONCLUSIVE] live_owned=",total,
   " reason=NO_VALID_OWNED_SET cases=",a43_cases,
   " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
  return INIT_SUCCEEDED;
 }
 A43Parts(p,v,sellCount,"SINGLE_TRAILING");
 A43Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A43_MANAGE",p,v,true));
 A43Parts(p,v,sellCount,"CLOSE_SIDE");
 A43Check("SAVE_EXIT",store.SaveDefinition(3,99,"A43_EXIT",p,v,true));
 bool mp=A43Preview(store,2,m)&&m.state==MA_ME_PREVIEW_ACCEPTED&&!m.brokerArmed;
 bool ep=A43Preview(store,3,e)&&e.state==MA_ME_PREVIEW_ACCEPTED&&!e.brokerArmed;
 A43Check("SAVED_MANAGE_PREVIEW",mp);
 A43Check("SAVED_EXIT_PREVIEW",ep);
 bool refreshed=MACaptureMEFinalOwned100(_Symbol,InpMagic,after);
 A43Check("LIVE_REFRESH",refreshed);
 bool unchanged=refreshed&&MASameMEFinalSet100(before,after,_Symbol,InpMagic);
 A43Check("LIVE_SET_UNCHANGED",unchanged);
 if(unchanged&&mp&&ep)
 {
  for(int i=0;i<total;i++)
  {
   bool ok=A43Gate(before,after,before[i].ticket,m,e,out);
   bool isSell=before[i].side==(int)POSITION_TYPE_SELL;
   A43Check("TICKET_EXIT_OR_IDLE_"+IntegerToString(i),
    ok&&!out.brokerArmed&&out.ticket==before[i].ticket&&
    (isSell?(out.state==MA_ME_FINAL_PREVIEW&&out.action==2):
      (out.state==MA_ME_FINAL_IDLE&&out.action==0)));
  }
  A43Check("UNKNOWN_TICKET_REJECT",
   !A43Gate(before,after,0,m,e,out)&&out.state==MA_ME_FINAL_BLOCKED);
  after[0].lots+=0.01;
  A43Check("STALE_LOTS_REJECT",
   !A43Gate(before,after,before[0].ticket,m,e,out)&&out.state==MA_ME_FINAL_BLOCKED);
  refreshed=MACaptureMEFinalOwned100(_Symbol,InpMagic,after);
  unchanged=refreshed&&MASameMEFinalSet100(before,after,_Symbol,InpMagic);
  A43Check("LIVE_RESTORE",unchanged);
 }
 A43Parts(p,v,sellCount,"CLOSE_SIDE",true);
 A43Check("SAVE_EXIT_IDLE",store.SaveDefinition(3,99,"A43_EXIT_IDLE",p,v,true));
 bool ei=A43Preview(store,3,e)&&e.state==MA_ME_PREVIEW_IDLE;
 A43Check("SAVED_EXIT_IDLE",ei);
 if(unchanged&&mp&&ei)
  for(int i=0;i<total;i++)
  {
   bool ok=A43Gate(before,after,before[i].ticket,m,e,out);
   bool isSell=before[i].side==(int)POSITION_TYPE_SELL;
   A43Check("TICKET_MANAGE_OR_IDLE_"+IntegerToString(i),
    ok&&!out.brokerArmed&&out.ticket==before[i].ticket&&
    (isSell?(out.state==MA_ME_FINAL_PREVIEW&&out.action==1):
      (out.state==MA_ME_FINAL_IDLE&&out.action==0)));
  }
 Print("[MA_ME_LIVE_WATCH_INFO] symbol=",_Symbol," magic=",InpMagic,
  " live_owned=",total," live_sell=",sellCount," live_buy=",buyCount,
  " cases=",a43_cases," failures=",a43_fails);
 if(a43_fails>0)
  Print("[MA_ME_LIVE_WATCH_FAIL] cases=",a43_cases," failures=",a43_fails,
   " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else if(total<2)
  Print("[MA_ME_LIVE_WATCH_INCONCLUSIVE] cases=",a43_cases,
   " single_owned_position_pass=1 live_multi_certified=0 generic_ticket_predicates_certified=0",
   " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_LIVE_WATCH_PASS] cases=",a43_cases,
   " live_multi_owned_set=PASS saved_side_scoped_preview=PASS",
   " generic_ticket_predicates_certified=0 runtime_certified=0",
   " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
bool a43_done=false;
int OnInit()
{
 EventSetTimer(30);
 Print("[MA_ME_LIVE_WATCH_START] interval_seconds=30 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 OnTimer();
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){EventKillTimer();}
void OnTimer()
{
 if(a43_done)return;
 int owned=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)continue;
  if(PositionGetString(POSITION_SYMBOL)==_Symbol && PositionGetInteger(POSITION_MAGIC)==InpMagic)owned++;
 }
 if(owned<2)
 {
  Print("[MA_ME_LIVE_WATCH_WAIT] live_owned=",owned," required=2 live_multi_certified=0 NO_ORDERS=1");
  return;
 }
 Print("[MA_ME_LIVE_WATCH_TRIGGER] live_owned=",owned," read_only=1");
 A43Run();
 a43_done=true;
}
void OnTick(){}

