#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-21: saved EXIT -> live metrics -> decision -> request -> preview
// -> capability -> SIDE_COUNT predicate -> owned-side audit -> explicit target.
// Read-only, no CTrade, no broker execution adapter.
input long InpMagic=46102031;
int g_checks=0,g_failures=0;
void A21Check(const string name,const bool ok)
{
 g_checks++;if(!ok)g_failures++;
 Print("[MA_ME_SAVED_TARGET_CASE] ",name," ",ok?"PASS":"FAIL");
}
void A21Parts(string &parts[],string &values[],const string side,const int count)
{
 ArrayResize(parts,100);ArrayResize(values,100);
 for(int i=0;i<100;i++){parts[i]="EMPTY";values[i]="";}
 parts[0]="SIDE_COUNT";
 values[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 parts[1]="AND";parts[2]="CLOSE_SIDE";
}
bool A21Pipeline(const CMultiAlphaModuleLibraryStore101 &store,
 const string explicitTarget,
 SMA_MEExplicitTargetPreview100 &target,
 string &stage)
{
 SMA_MEReadOnlyDecision100 decision;
 SMA_MERequestBoundary100 request;
 SMA_MEAdapterPreview100 preview;
 SMA_MEExecutionCapability100 cap;
 SMA_MECloseSideResolution100 candidate;
 SMA_MEOwnedSideAudit100 owned;
 MAResetMEExplicitTargetPreview100(target);
 stage="DECISION";
 if(!MABuildMEReadOnlyDecision100(store,3,99,_Symbol,InpMagic,decision))return false;
 stage="REQUEST";
 if(!MAConvertMEReadOnlyDecisionToRequest100(decision,_Symbol,InpMagic,request))return false;
 stage="PREVIEW";
 if(!MAPreviewMERequest100(request,preview))return false;
 stage="CAPABILITY";
 if(!MAEvaluateMEExecutionCapability100(preview,cap))return false;
 stage="PREDICATE";
 if(!MAResolveCloseSideCandidate100(store,preview,cap,candidate))return false;
 stage="OWNED";
 if(!MAAuditMEOwnedCandidateSide100(preview,candidate,owned))return false;
 stage="TARGET";
 return MAPreviewMEExplicitTarget100(preview,cap,candidate,owned,explicitTarget,target);
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEExplicitTargetPreview100 target;
 string parts[],values[],stage="";
 int sells=0,buys=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){Print("[MA_ME_SAVED_TARGET_FAIL] POSITION_SELECT_FAILED");return INIT_FAILED;}
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||
     PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)sells++;
  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)buys++;
 }
 A21Check("UNSAVED_REJECT",!A21Pipeline(store,"SELL",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Parts(parts,values,"SELL",sells);
 A21Check("SAVE_EXIT_SELL",store.SaveDefinition(3,99,"A21_SELL",parts,values,true));
 bool sellOk=A21Pipeline(store,"SELL",target,stage);
 if(!sellOk)Print("[MA_ME_SAVED_TARGET_INFO] SELL_BLOCK_STAGE=",stage," reason=",target.reason);
 A21Check("SELL_LIVE_TARGET",sells==0?!sellOk:(sellOk&&target.state==MA_ME_TARGET_PREVIEW&&target.targetSide==(int)POSITION_TYPE_SELL&&!target.brokerArmed));
 A21Check("SELL_OPPOSITE_REJECT",!A21Pipeline(store,"BUY",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Check("SELL_EMPTY_REJECT",!A21Pipeline(store,"",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Check("SELL_UNKNOWN_REJECT",!A21Pipeline(store,"CURRENT",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Parts(parts,values,"BUY",buys);
 A21Check("SAVE_EXIT_BUY",store.SaveDefinition(3,99,"A21_BUY",parts,values,true));
 bool buyOk=A21Pipeline(store,"BUY",target,stage);
 if(!buyOk)Print("[MA_ME_SAVED_TARGET_INFO] BUY_BLOCK_STAGE=",stage," reason=",target.reason);
 A21Check("BUY_LIVE_TARGET",buys==0?!buyOk:(buyOk&&target.state==MA_ME_TARGET_PREVIEW&&target.targetSide==(int)POSITION_TYPE_BUY&&!target.brokerArmed));
 A21Check("BUY_OPPOSITE_REJECT",!A21Pipeline(store,"SELL",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Parts(parts,values,"SELL",sells);
 values[0]="SIDE=SELL;COND=GT;VALUE="+IntegerToString(sells);
 A21Check("SAVE_IDLE",store.SaveDefinition(3,99,"A21_IDLE",parts,values,true));
 A21Check("IDLE_REJECT",!A21Pipeline(store,"SELL",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Parts(parts,values,"SELL",sells);
 parts[1]="OR";
 A21Check("SAVE_OR",store.SaveDefinition(3,99,"A21_OR",parts,values,true));
 A21Check("OR_REJECT",!A21Pipeline(store,"SELL",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 A21Parts(parts,values,"SELL",sells);
 parts[0]="AVG_PRICE";
 A21Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"A21_UNSUPPORTED",parts,values,true));
 A21Check("UNSUPPORTED_REJECT",!A21Pipeline(store,"SELL",target,stage)&&target.state==MA_ME_TARGET_BLOCKED);
 Print("[MA_ME_SAVED_TARGET_INFO] symbol=",_Symbol," magic=",InpMagic," owned_sell=",sells," owned_buy=",buys);
 if(g_failures>0)Print("[MA_ME_SAVED_TARGET_FAIL] cases=",g_checks," failures=",g_failures," NO_ORDERS=1");
 else if(sells==0&&buys==0)
  Print("[MA_ME_SAVED_TARGET_INCONCLUSIVE] cases=",g_checks," no_owned_positions=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_SAVED_TARGET_PASS] cases=",g_checks," saved_exit_live_target_preview=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
