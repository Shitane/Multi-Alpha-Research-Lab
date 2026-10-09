#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-32: saved EXIT predicate -> explicit target -> owned position-set snapshot.
// Read-only. No OrderSend, CTrade, PositionClose or PositionModify.
input long InpMagic=46102031;
int a32_cases=0,a32_fails=0;
struct A32Pos { ulong ticket; string symbol; long magic; int side; double lots; };
void A32Check(const string name,const bool ok)
{
 a32_cases++;if(!ok)a32_fails++;
 Print("[MA_ME_SAVED_SET_CASE] ",name," ",ok?"PASS":"FAIL");
}
void A32Copy(A32Pos &d,const A32Pos &s)
{d.ticket=s.ticket;d.symbol=s.symbol;d.magic=s.magic;d.side=s.side;d.lots=s.lots;}
bool A32Capture(A32Pos &out[],const string symbol,const long magic)
{
 ArrayResize(out,0);
 if(symbol==""||magic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t==0){ArrayResize(out,0);return false;}
  if(PositionGetString(POSITION_SYMBOL)!=symbol||
     PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  A32Pos p;
  p.ticket=t;p.symbol=PositionGetString(POSITION_SYMBOL);
  p.magic=PositionGetInteger(POSITION_MAGIC);
  p.side=(int)PositionGetInteger(POSITION_TYPE);
  p.lots=PositionGetDouble(POSITION_VOLUME);
  if(p.lots<=0||!MathIsValidNumber(p.lots)||
     (p.side!=(int)POSITION_TYPE_BUY&&p.side!=(int)POSITION_TYPE_SELL))
  {ArrayResize(out,0);return false;}
  for(int j=0;j<ArraySize(out);j++)
   if(out[j].ticket==p.ticket){ArrayResize(out,0);return false;}
  int n=ArraySize(out);ArrayResize(out,n+1);A32Copy(out[n],p);
 }
 return true;
}
bool A32Select(A32Pos &all[],const int side,A32Pos &selected[])
{
 ArrayResize(selected,0);
 if(side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL)return false;
 for(int i=0;i<ArraySize(all);i++)if(all[i].side==side)
 {
  int n=ArraySize(selected);ArrayResize(selected,n+1);
  A32Copy(selected[n],all[i]);
 }
 return ArraySize(selected)>0;
}
bool A32Same(A32Pos &saved[],A32Pos &current[])
{
 int n=ArraySize(saved);
 if(n<1||n!=ArraySize(current))return false;
 for(int i=0;i<n;i++)
 {
  if(saved[i].ticket==0||saved[i].lots<=0)return false;
  for(int k=0;k<i;k++)
   if(saved[i].ticket==saved[k].ticket||
      current[i].ticket==current[k].ticket)return false;
  bool found=false;
  for(int j=0;j<n;j++)
   if(saved[i].ticket==current[j].ticket&&
      saved[i].symbol==current[j].symbol&&saved[i].magic==current[j].magic&&
      saved[i].side==current[j].side&&
      MathAbs(saved[i].lots-current[j].lots)<0.00000001)
   {found=true;break;}
  if(!found)return false;
 }
 return true;
}
void A32Parts(string &parts[],string &values[],const string side,const int count)
{
 ArrayResize(parts,100);ArrayResize(values,100);
 for(int i=0;i<100;i++){parts[i]="EMPTY";values[i]="";}
 parts[0]="SIDE_COUNT";
 values[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 parts[1]="AND";parts[2]="CLOSE_SIDE";
}
bool A32Pipeline(const CMultiAlphaModuleLibraryStore101 &store,
 const string explicitSide,SMA_MEExplicitTargetPreview100 &target)
{
 SMA_MEReadOnlyDecision100 d;
 SMA_MERequestBoundary100 r;
 SMA_MEAdapterPreview100 p;
 SMA_MEExecutionCapability100 c;
 SMA_MECloseSideResolution100 s;
 SMA_MEOwnedSideAudit100 o;
 MAResetMEExplicitTargetPreview100(target);
 if(!MABuildMEReadOnlyDecision100(store,3,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 if(!MAPreviewMERequest100(r,p))return false;
 if(!MAEvaluateMEExecutionCapability100(p,c))return false;
 if(!MAResolveCloseSideCandidate100(store,p,c,s))return false;
 if(!MAAuditMEOwnedCandidateSide100(p,s,o))return false;
 return MAPreviewMEExplicitTarget100(p,c,s,o,explicitSide,target);
}
int OnInit()
{
 A32Pos all[],live[],baseline[],current[],changed[];
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEExplicitTargetPreview100 target;
 string parts[],values[];
 bool cap=A32Capture(all,_Symbol,InpMagic);
 A32Check("LIVE_CAPTURE",cap);
 int buys=0,sells=0;
 for(int i=0;i<ArraySize(all);i++)
 {
  if(all[i].side==(int)POSITION_TYPE_BUY)buys++;
  if(all[i].side==(int)POSITION_TYPE_SELL)sells++;
 }
 int side=(sells>0?(int)POSITION_TYPE_SELL:(int)POSITION_TYPE_BUY);
 int count=(sells>0?sells:buys);
 string sideName=side==(int)POSITION_TYPE_SELL?"SELL":"BUY";
 A32Check("UNSAVED_REJECT",!A32Pipeline(store,sideName,target));
 A32Parts(parts,values,sideName,count);
 A32Check("SAVE_EXIT",store.SaveDefinition(3,99,"A32_EXIT",parts,values,true));
 bool ready=cap&&count>0&&A32Pipeline(store,sideName,target)&&
   target.state==MA_ME_TARGET_PREVIEW&&!target.brokerArmed&&
   target.targetSide==side&&A32Select(all,side,baseline);
 if(count>0)A32Check("SAVED_EXIT_TARGET",ready);
 else Print("[MA_ME_SAVED_SET_INFO] ZERO_OWNED_SIDE: runtime target inconclusive");
 if(ready)
 {
  A32Check("TARGET_COUNT_MATCH",ArraySize(baseline)==count);
  bool refreshed=A32Capture(live,_Symbol,InpMagic)&&A32Select(live,side,current);
  A32Check("LIVE_REFRESH",refreshed);
  A32Check("UNCHANGED_SET",refreshed&&A32Same(baseline,current));
  A32Check("OPPOSITE_EXPLICIT_REJECT",!A32Pipeline(store,sideName=="SELL"?"BUY":"SELL",target));
  ArrayResize(changed,ArraySize(baseline));
  for(int i=0;i<ArraySize(baseline);i++)A32Copy(changed[i],baseline[i]);
  changed[0].lots+=0.01;
  A32Check("STALE_VOLUME_REJECT",!A32Same(changed,current));
  A32Copy(changed[0],baseline[0]);changed[0].ticket+=999999;
  A32Check("REPLACED_TICKET_REJECT",!A32Same(changed,current));
  A32Copy(changed[0],baseline[0]);changed[0].magic++;
  A32Check("FOREIGN_MAGIC_REJECT",!A32Same(changed,current));
  A32Copy(changed[0],baseline[0]);changed[0].side=1-side;
  A32Check("SIDE_CHANGED_REJECT",!A32Same(changed,current));
  if(ArraySize(baseline)>1)
  {
   A32Copy(changed[0],baseline[0]);A32Copy(changed[1],baseline[0]);
   A32Check("DUPLICATE_REJECT",!A32Same(changed,current));
   ArrayResize(changed,ArraySize(baseline)-1);
   A32Check("REMOVED_REJECT",!A32Same(changed,current));
  }
  A32Parts(parts,values,sideName,count);
  values[0]="SIDE="+sideName+";COND=GT;VALUE="+IntegerToString(count);
  A32Check("SAVE_IDLE",store.SaveDefinition(3,99,"A32_IDLE",parts,values,true));
  A32Check("IDLE_REJECT",!A32Pipeline(store,sideName,target));
 }
 Print("[MA_ME_SAVED_SET_INFO] symbol=",_Symbol," magic=",InpMagic,
       " owned=",ArraySize(all)," buys=",buys," sells=",sells,
       " target_count=",count," cases=",a32_cases," failures=",a32_fails);
 if(a32_fails>0)
  Print("[MA_ME_SAVED_SET_FAIL] cases=",a32_cases," failures=",a32_fails," NO_ORDERS=1");
 else if(!ready||count<2)
  Print("[MA_ME_SAVED_SET_INCONCLUSIVE] cases=",a32_cases,
        " single_target_checks=",(ready?"PASS":"NOT_RUN"),
        " live_multi_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_SAVED_SET_PASS] cases=",a32_cases,
        " saved_exit_live_multi_set=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
