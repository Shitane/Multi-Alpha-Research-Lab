#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Ticket_Part_Bridge_v1_00.mqh>
// A14-46: experimental ticket Part in 100-Part saved definition.
// NO_ORDERS, no broker actions; NOT canonical Builder schema certification.
input long InpMagic=46102031;
int a46_cases=0,a46_failures=0;
void A46Check(const string name,const bool ok)
{
 a46_cases++;if(!ok)a46_failures++;
 Print("[MA_ME_TICKET_PART_CASE] ",name," ",ok?"PASS":"FAIL");
}
void A46Parts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="SIDE_COUNT";p[1]="AND";p[2]="SINGLE_TRAILING";
 v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 p[99]="TICKET_PROFIT";v[99]="COND=GE;VALUE=-1000000000";
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],reason="",action="";bool preview=false;
 A46Parts(p,v);
 ulong ticket=0;int sells=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t!=0&&PositionGetString(POSITION_SYMBOL)==_Symbol&&
   PositionGetInteger(POSITION_MAGIC)==InpMagic&&
   PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){ticket=t;sells++;}
 }
 v[0]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 A46Check("SAVE_PARTS_100",store.SaveDefinition(2,99,"A46_TICKET",p,v,true));
 int metric=0,cmp=0;double threshold=0;
 A46Check("PARSE_GE",MA46ParseTicketPart(p[99],v[99],metric,cmp,threshold,reason)&&
  metric==MA_TICKET_METRIC_PROFIT&&cmp==MA_TICKET_CMP_GE);
 A46Check("REJECT_BAD_COMPARISON",!MA46ParseTicketPart("TICKET_PROFIT","COND=GT;VALUE=0",metric,cmp,threshold,reason));
 A46Check("REJECT_BAD_VALUE",!MA46ParseTicketPart("TICKET_PROFIT","COND=GE;VALUE=abc",metric,cmp,threshold,reason));
 A46Check("REJECT_UNKNOWN_PART",!MA46ParseTicketPart("TICKET_UNKNOWN","COND=GE;VALUE=0",metric,cmp,threshold,reason));
 A46Check("UNSAVED_REJECT",!MA46SavedTicketPartPreview(store,2,98,_Symbol,InpMagic,ticket,TimeCurrent(),preview,action,reason));
 if(ticket!=0)
 {
  bool ok=MA46SavedTicketPartPreview(store,2,99,_Symbol,InpMagic,ticket,TimeCurrent(),preview,action,reason);
  A46Check("SAVED_TICKET_PART_PREVIEW",ok&&preview&&action=="SINGLE_TRAILING");
  v[99]="COND=LE;VALUE=-1000000000";
  A46Check("SAVE_IDLE",store.SaveDefinition(2,99,"A46_IDLE",p,v,true));
  ok=MA46SavedTicketPartPreview(store,2,99,_Symbol,InpMagic,ticket,TimeCurrent(),preview,action,reason);
  A46Check("TICKET_PART_IDLE",ok&&!preview&&action=="");
 }
 Print("[MA_ME_TICKET_PART_INFO] owned_sell=",sells," cases=",a46_cases," failures=",a46_failures);
 if(a46_failures>0)Print("[MA_ME_TICKET_PART_FAIL] cases=",a46_cases," failures=",a46_failures," NO_ORDERS=1");
 else if(ticket==0)Print("[MA_ME_TICKET_PART_INCONCLUSIVE] cases=",a46_cases," no_owned_sell=1 NO_ORDERS=1");
 else Print("[MA_ME_TICKET_PART_PASS] cases=",a46_cases,
 " experimental_sidecar=PASS canonical_schema_registered=0 builder_execution_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick(){}
