#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-34: saved MANAGE/EXIT decision -> same-ticket arbitration, preview only.
input long InpMagic=46102031;
int n=0,f=0;
void Test(const string label,const bool ok){n++;if(!ok)f++;Print("[MA_ME_CONFLICT_SAVED_CASE] ",label," ",ok?"PASS":"FAIL");}
void Parts(string &p[],string &v[],const string side,const int count,const string action)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";v[0]="SIDE="+side+";COND=EQ;VALUE="+IntegerToString(count);
 p[1]="AND";p[2]=action;
 if(action=="SINGLE_TRAILING")v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool Preview(const CMultiAlphaModuleLibraryStore101 &store,const int role,
             SMA_MEAdapterPreview100 &p)
{
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 MAResetMEAdapterPreview100(p);
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,p);
}
int Choose(const ulong ticket,const string symbol,const long magic,const int side,
           const double lots,const bool manage,const bool exitSignal)
{
 if(ticket==0||symbol!=_Symbol||magic!=InpMagic||InpMagic<=0||
    (side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL)||
    lots<=0||!MathIsValidNumber(lots))return 0;
 if(exitSignal)return 2;
 if(manage)return 1;
 return 0;
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEAdapterPreview100 managePreview,exitPreview;
 string parts[],values[];
 int buys=0,sells=0;ulong targetTicket=0;double targetLots=0;int targetSide=-1;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t==0)continue;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  int s=(int)PositionGetInteger(POSITION_TYPE);
  if(s==(int)POSITION_TYPE_BUY)buys++;
  if(s==(int)POSITION_TYPE_SELL)sells++;
  if(targetTicket==0){targetTicket=t;targetSide=s;targetLots=PositionGetDouble(POSITION_VOLUME);}
 }
 const int count=targetSide==(int)POSITION_TYPE_SELL?sells:buys;
 const string side=targetSide==(int)POSITION_TYPE_SELL?"SELL":"BUY";
 Test("UNSAVED_MANAGE_REJECT",!Preview(store,2,managePreview));
 Test("UNSAVED_EXIT_REJECT",!Preview(store,3,exitPreview));
 if(targetTicket==0)
 {
  Print("[MA_ME_CONFLICT_SAVED_INCONCLUSIVE] cases=",n," no_owned_position=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
  return INIT_SUCCEEDED;
 }
 Parts(parts,values,side,count,"SINGLE_TRAILING");
 Test("SAVE_MANAGE",store.SaveDefinition(2,99,"A34_MANAGE",parts,values,true));
 bool m=Preview(store,2,managePreview)&&managePreview.state==MA_ME_PREVIEW_ACCEPTED&&
   managePreview.action=="SINGLE_TRAILING"&&!managePreview.brokerArmed;
 Test("SAVED_MANAGE_PREVIEW",m);
 Parts(parts,values,side,count,"CLOSE_SIDE");
 Test("SAVE_EXIT",store.SaveDefinition(3,99,"A34_EXIT",parts,values,true));
 bool e=Preview(store,3,exitPreview)&&exitPreview.state==MA_ME_PREVIEW_ACCEPTED&&
   exitPreview.action=="CLOSE_SIDE"&&!exitPreview.brokerArmed;
 Test("SAVED_EXIT_PREVIEW",e);
 Test("SAME_TICKET_EXIT_PRIORITY",m&&e&&Choose(targetTicket,_Symbol,InpMagic,targetSide,targetLots,m,e)==2);
 Test("MANAGE_ONLY",m&&Choose(targetTicket,_Symbol,InpMagic,targetSide,targetLots,m,false)==1);
 Test("EXIT_ONLY",e&&Choose(targetTicket,_Symbol,InpMagic,targetSide,targetLots,false,e)==2);
 Test("NO_SIGNAL_BLOCK",Choose(targetTicket,_Symbol,InpMagic,targetSide,targetLots,false,false)==0);
 Test("WRONG_MAGIC_BLOCK",Choose(targetTicket,_Symbol,InpMagic+1,targetSide,targetLots,m,e)==0);
 Test("WRONG_SYMBOL_BLOCK",Choose(targetTicket,_Symbol+"_OTHER",InpMagic,targetSide,targetLots,m,e)==0);
 Test("ZERO_TICKET_BLOCK",Choose(0,_Symbol,InpMagic,targetSide,targetLots,m,e)==0);
 Test("ZERO_VOLUME_BLOCK",Choose(targetTicket,_Symbol,InpMagic,targetSide,0,m,e)==0);
 Test("OTHER_TICKET_INDEPENDENT_MANAGE",m&&Choose(targetTicket+1,_Symbol,InpMagic,targetSide,targetLots,m,false)==1);
 Parts(parts,values,side,count,"CLOSE_SIDE");
 values[0]="SIDE="+side+";COND=GT;VALUE="+IntegerToString(count);
 Test("SAVE_EXIT_IDLE",store.SaveDefinition(3,99,"A34_EXIT_IDLE",parts,values,true));
 Test("IDLE_EXIT_REJECT",!Preview(store,3,exitPreview));
 Print("[MA_ME_CONFLICT_SAVED_INFO] ticket=",targetTicket," side=",side,
       " lots=",DoubleToString(targetLots,8)," owned_buy=",buys," owned_sell=",sells,
       " manage_preview=",m," exit_preview=",e);
 if(f>0)Print("[MA_ME_CONFLICT_SAVED_FAIL] cases=",n," failures=",f," NO_ORDERS=1");
 else Print("[MA_ME_CONFLICT_SAVED_PASS] cases=",n,
  " saved_preview_arbitration=PASS ticket_arbitration_fixture=1 builder_execution_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
