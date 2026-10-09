#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Adapter_Preview_v1_00.mqh>
#include <Builder/MultiAlpha_ME_Final_Preview_Gate_v1_00.mqh>
// A14-41: saved SELL side predicates -> multi-ticket final preview, read only.
input long InpMagic=46102031;
int a41_cases=0,a41_fails=0;
void A41Check(string name,bool ok)
{
 a41_cases++;if(!ok)a41_fails++;
 Print("[MA_ME_SAVED_MULTI_CASE] ",name," ",ok?"PASS":"FAIL");
}
void A41Parts(string &p[],string &v[],int count,string action,bool idle=false)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND="+(idle?"GT":"EQ")+";VALUE="+IntegerToString(count);
 p[1]="AND";p[2]=action;
 if(action=="SINGLE_TRAILING")v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
}
bool A41Preview(const CMultiAlphaModuleLibraryStore101 &store,int role,SMA_MEAdapterPreview100 &out)
{
 MAResetMEAdapterPreview100(out);
 SMA_MEReadOnlyDecision100 d;SMA_MERequestBoundary100 r;
 if(!MABuildMEReadOnlyDecision100(store,role,99,_Symbol,InpMagic,d))return false;
 if(!MAConvertMEReadOnlyDecisionToRequest100(d,_Symbol,InpMagic,r))return false;
 return MAPreviewMERequest100(r,out);
}
void A41Set(SMA_MEFinalPosition100 &p,ulong ticket,int side,double lots)
{
 p.ticket=ticket;p.symbol=_Symbol;p.magic=InpMagic;p.side=side;p.lots=lots;
}
void A41Copy(SMA_MEFinalPosition100 &a[],SMA_MEFinalPosition100 &b[])
{
 ArrayResize(b,ArraySize(a));for(int i=0;i<ArraySize(a);i++)b[i]=a[i];
}
bool A41Gate(SMA_MEFinalPosition100 &a[],SMA_MEFinalPosition100 &b[],ulong ticket,
 const SMA_MEAdapterPreview100 &m,const SMA_MEAdapterPreview100 &e,SMA_MEFinalPreview100 &out)
{
 MAResetMEFinalPreview100(out);
 bool vm=(m.state==MA_ME_PREVIEW_ACCEPTED||m.state==MA_ME_PREVIEW_IDLE)
  &&m.role==2&&m.slotIndex==99&&m.symbol==_Symbol&&m.magic==InpMagic&&!m.brokerArmed;
 bool ve=(e.state==MA_ME_PREVIEW_ACCEPTED||e.state==MA_ME_PREVIEW_IDLE)
  &&e.role==3&&e.slotIndex==99&&e.symbol==_Symbol&&e.magic==InpMagic&&!e.brokerArmed;
 if(!vm||!ve){out.reason="INVALID_UPSTREAM";return false;}
 int matches=0,side=-1;
 for(int i=0;i<ArraySize(a);i++)if(a[i].ticket==ticket){matches++;side=a[i].side;}
 if(matches!=1){out.reason="UNKNOWN_TICKET";return false;}
 bool sell=(side==(int)POSITION_TYPE_SELL);
 return MABuildMEFinalPreview100(a,b,_Symbol,InpMagic,ticket,
  sell&&m.state==MA_ME_PREVIEW_ACCEPTED,
  sell&&e.state==MA_ME_PREVIEW_ACCEPTED,false,out);
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 SMA_MEFinalPosition100 base[],current[];
 SMA_MEAdapterPreview100 m,e;SMA_MEFinalPreview100 out;
 string p[],v[];
 ArrayResize(base,3);
 A41Set(base[0],941001,(int)POSITION_TYPE_SELL,0.01);
 A41Set(base[1],941002,(int)POSITION_TYPE_SELL,0.02);
 A41Set(base[2],941003,(int)POSITION_TYPE_BUY,0.03);
 A41Copy(base,current);
 A41Check("FIXTURE_VALID",MASameMEFinalSet100(base,current,_Symbol,InpMagic));
 int liveSell=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t>0&&PositionGetString(POSITION_SYMBOL)==_Symbol&&
   PositionGetInteger(POSITION_MAGIC)==InpMagic&&
   PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)liveSell++;
 }
 A41Parts(p,v,liveSell,"SINGLE_TRAILING");
 A41Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A41_MANAGE",p,v,true));
 A41Parts(p,v,liveSell,"CLOSE_SIDE");
 A41Check("SAVE_EXIT",store.SaveDefinition(3,99,"A41_EXIT",p,v,true));
 bool mp=A41Preview(store,2,m)&&m.state==MA_ME_PREVIEW_ACCEPTED&&!m.brokerArmed;
 bool ep=A41Preview(store,3,e)&&e.state==MA_ME_PREVIEW_ACCEPTED&&!e.brokerArmed;
 A41Check("MANAGE_SAVED_PREVIEW",mp);
 A41Check("EXIT_SAVED_PREVIEW",ep);
 bool ok=A41Gate(base,current,941001,m,e,out);
 A41Check("SELL1_EXIT_WINS",mp&&ep&&ok&&out.state==MA_ME_FINAL_PREVIEW&&out.action==2);
 ok=A41Gate(base,current,941002,m,e,out);
 A41Check("SELL2_EXIT_WINS",ok&&out.state==MA_ME_FINAL_PREVIEW&&out.action==2);
 ok=A41Gate(base,current,941003,m,e,out);
 A41Check("BUY_IDLE",ok&&out.state==MA_ME_FINAL_IDLE&&out.action==0);
 A41Parts(p,v,liveSell,"CLOSE_SIDE",true);
 A41Check("SAVE_EXIT_IDLE",store.SaveDefinition(3,99,"A41_EXIT_IDLE",p,v,true));
 bool ei=A41Preview(store,3,e)&&e.state==MA_ME_PREVIEW_IDLE;
 A41Check("EXIT_IDLE",ei);
 ok=A41Gate(base,current,941001,m,e,out);
 A41Check("SELL_MANAGE_ONLY",ei&&ok&&out.state==MA_ME_FINAL_PREVIEW&&out.action==1);
 ok=A41Gate(base,current,941003,m,e,out);
 A41Check("BUY_STILL_IDLE",ok&&out.state==MA_ME_FINAL_IDLE&&out.action==0);
 A41Check("UNKNOWN_BLOCK",!A41Gate(base,current,949999,m,e,out)&&out.state==MA_ME_FINAL_BLOCKED);
 current[1].lots+=0.01;
 A41Check("STALE_OTHER_BLOCK",!A41Gate(base,current,941001,m,e,out)&&out.state==MA_ME_FINAL_BLOCKED);
 A41Copy(base,current);
 A41Check("RESTORED_ACCEPT",A41Gate(base,current,941001,m,e,out)&&out.action==1);
 Print("[MA_ME_SAVED_MULTI_INFO] live_sell=",liveSell," fixture_positions=3 cases=",a41_cases," failures=",a41_fails);
 if(a41_fails>0||!mp||!ep||!ei)
  Print("[MA_ME_SAVED_MULTI_FAIL] cases=",a41_cases," failures=",a41_fails," NO_ORDERS=1");
 else
  Print("[MA_ME_SAVED_MULTI_PASS] cases=",a41_cases,
   " saved_side_scoped_fixture=PASS live_multi_certified=0 generic_ticket_predicates_certified=0",
   " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
