#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_CloseSide_Resolution_v1_00.mqh"
// No CTrade, no adapter Init, no PositionClose. Static in-memory fixtures only.
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_ME_SIDE_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Parts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE=1";
 p[1]="AND";p[2]="CLOSE_SIDE";
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEAdapterPreview100 preview;
 SMA_MEExecutionCapability100 cap;
 SMA_MECloseSideResolution100 out;
 string p[],v[];
 MAResetMEAdapterPreview100(preview);
 preview.state=MA_ME_PREVIEW_ACCEPTED;preview.role=3;preview.slotIndex=99;
 preview.symbol=_Symbol;preview.magic=46102031;preview.action="CLOSE_SIDE";
 Check("UNSAVED_REJECT",MAEvaluateMEExecutionCapability100(preview,cap)&&
   !MAResolveCloseSideCandidate100(store,preview,cap,out));
 Parts(p,v);
 Check("SAVE_EXIT",store.SaveDefinition(3,99,"SIDE_EXIT",p,v,true));
 Check("SELL_CANDIDATE",MAEvaluateMEExecutionCapability100(preview,cap)&&
   MAResolveCloseSideCandidate100(store,preview,cap,out)&&
   out.side==(int)POSITION_TYPE_SELL&&!out.brokerArmed);
 Check("NOT_AUTHORIZED",out.reason=="SIDE_COUNT_PREDICATE_SIDE_ONLY_NOT_AUTHORIZED_TARGET");
 v[0]="SIDE=BUY;COND=EQ;VALUE=1";
 Check("SAVE_BUY",store.SaveDefinition(3,99,"SIDE_BUY",p,v,true));
 Check("BUY_CANDIDATE",MAResolveCloseSideCandidate100(store,preview,cap,out)&&
   out.side==(int)POSITION_TYPE_BUY);
 p[3]="AND";p[4]="SIDE_COUNT";v[4]="SIDE=SELL;COND=EQ;VALUE=1";
 Check("SAVE_MIXED",store.SaveDefinition(3,99,"SIDE_MIXED",p,v,true));
 Check("MIXED_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 Parts(p,v);p[1]="OR";
 Check("SAVE_OR",store.SaveDefinition(3,99,"SIDE_OR",p,v,true));
 Check("OR_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 Parts(p,v);p[0]="AVG_PRICE";
 Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"SIDE_UNSUPPORTED",p,v,true));
 Check("UNSUPPORTED_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 Parts(p,v);
 Check("RESTORE",store.SaveDefinition(3,99,"SIDE_RESTORE",p,v,true));
 preview.brokerArmed=true;
 Check("ARMED_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 preview.brokerArmed=false;cap.brokerArmed=true;
 Check("CAP_ARMED_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 cap.brokerArmed=false;preview.action="CLOSE_OPPOSITE";
 Check("OPPOSITE_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 preview.action="CLOSE_SIDE";preview.role=2;
 Check("MANAGE_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 preview.role=3;preview.slotIndex=100;
 Check("SLOT_RANGE_REJECT",!MAResolveCloseSideCandidate100(store,preview,cap,out));
 if(failures==0)
  Print("[MA_ME_SIDE_PASS] cases=",checks,
   " predicate_side_only=1 execution_target_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_SIDE_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
