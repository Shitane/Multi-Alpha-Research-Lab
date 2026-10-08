#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Adapter_Preview_v1_00.mqh"
// A14-16: saved MANAGE/EXIT -> live owned metrics -> decision -> request -> preview.
// Read only; never sends or modifies orders.
input long InpMagic=46102031;
int checks=0,failures=0;
void Check(string name,bool ok)
{
 checks++;
 Print("[MA_ME_E2E_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void ResetParts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
bool Pipeline(const CMultiAlphaModuleLibraryStore101 &store,int role,int slot,
 SMA_MEReadOnlyDecision100 &d,SMA_MERequestBoundary100 &r,SMA_MEAdapterPreview100 &out)
{
 MAResetMEAdapterPreview100(out);
 MAResetMERequestBoundary100(r);
 if(!MABuildMEReadOnlyDecision100(store,role,slot,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,out);
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEReadOnlyDecision100 d;
 SMA_MERequestBoundary100 r;
 SMA_MEAdapterPreview100 out;
 string p[],v[];
 int sells=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){Print("[MA_ME_E2E_FAIL] POSITION_SELECT_FAILED");return INIT_FAILED;}
  if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
     PositionGetInteger(POSITION_MAGIC)==InpMagic &&
     PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sells++;
 }
 Check("UNSAVED_REJECT",!Pipeline(store,2,99,d,r,out) && out.state==MA_ME_PREVIEW_BLOCKED);
 ResetParts(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE_100",store.SaveDefinition(2,99,"E2E_MANAGE",p,v,true));
 Check("MANAGE_ACCEPT",Pipeline(store,2,99,d,r,out) &&
   d.state==MA_ME_DECISION_INTENT_ONLY &&
   r.state==MA_ME_REQUEST_CANDIDATE &&
   out.state==MA_ME_PREVIEW_ACCEPTED &&
   out.action=="SINGLE_TRAILING" && out.slotIndex==99 &&
   !r.brokerArmed && !out.brokerArmed);
 v[97]="SIDE=SELL;COND=GT;VALUE="+IntegerToString(sells);
 Check("SAVE_MANAGE_IDLE",store.SaveDefinition(2,99,"E2E_MANAGE_IDLE",p,v,true));
 Check("MANAGE_IDLE",Pipeline(store,2,99,d,r,out) &&
   d.state==MA_ME_DECISION_NO_SIGNAL &&
   r.state==MA_ME_REQUEST_NO_SIGNAL &&
   out.state==MA_ME_PREVIEW_IDLE && out.action=="");
 ResetParts(p,v);
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT",store.SaveDefinition(3,99,"E2E_EXIT",p,v,true));
 Check("EXIT_ACCEPT",Pipeline(store,3,99,d,r,out) &&
   d.state==MA_ME_DECISION_INTENT_ONLY &&
   r.state==MA_ME_REQUEST_CANDIDATE &&
   out.state==MA_ME_PREVIEW_ACCEPTED &&
   out.action=="CLOSE_SIDE" && !out.brokerArmed);
 v[0]="SIDE=SELL;COND=GT;VALUE="+IntegerToString(sells);
 Check("SAVE_EXIT_IDLE",store.SaveDefinition(3,99,"E2E_EXIT_IDLE",p,v,true));
 Check("EXIT_IDLE",Pipeline(store,3,99,d,r,out) &&
   d.state==MA_ME_DECISION_NO_SIGNAL &&
   r.state==MA_ME_REQUEST_NO_SIGNAL &&
   out.state==MA_ME_PREVIEW_IDLE);
 ResetParts(p,v);
 p[0]="AVG_PRICE";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"E2E_BAD",p,v,true));
 Check("UNSUPPORTED_REJECT",!Pipeline(store,3,99,d,r,out) &&
   out.state==MA_ME_PREVIEW_BLOCKED);
 Check("WRONG_ROLE_REJECT",!Pipeline(store,1,99,d,r,out) &&
   out.state==MA_ME_PREVIEW_BLOCKED);
 Check("SLOT_RANGE_REJECT",!Pipeline(store,3,100,d,r,out) &&
   out.state==MA_ME_PREVIEW_BLOCKED);
 Print("[MA_ME_E2E_INFO] symbol=",_Symbol," magic=",InpMagic," owned_sell=",sells);
 if(failures>0)
  Print("[MA_ME_E2E_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 else if(sells==0)
  Print("[MA_ME_E2E_INCONCLUSIVE] cases=",checks,
   " zero_owned_sell=1 fixture_checks=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_E2E_PASS] cases=",checks,
   " owned_sell_nonzero=1 read_only_pipeline=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
