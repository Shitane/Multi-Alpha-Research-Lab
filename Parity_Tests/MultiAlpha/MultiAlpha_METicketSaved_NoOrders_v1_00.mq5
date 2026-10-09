#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Ticket_Saved_Bridge_v1_00.mqh>
// A14-45. Read-only test, no trading functions.
input long InpMagic=46102031;
int a45_cases=0,a45_failures=0;
void A45Check(string label,bool ok)
{
 a45_cases++;if(!ok)a45_failures++;
 Print("[MA_ME_TICKET_SAVED_CASE] ",label," ",ok?"PASS":"FAIL");
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 bool preview=false;string action="",reason="";
 datetime now=TimeCurrent();
 A45Check("UNSAVED_REJECT",!MAMETicketSavedPreview100(store,2,99,_Symbol,InpMagic,1,now,
 MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_GE,0,preview,action,reason)&&!preview);
 string p[],v[];ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 int sells=0;ulong owned=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);
  if(t==0)continue;
  if(PositionGetString(POSITION_SYMBOL)==_Symbol&&
     PositionGetInteger(POSITION_MAGIC)==InpMagic&&
     PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
  {sells++;owned=t;}
 }
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 p[1]="AND";p[2]="SINGLE_TRAILING";
 v[2]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 A45Check("SAVE_MANAGE",store.SaveDefinition(2,99,"A45_MANAGE",p,v,true));
 if(owned!=0)
 {
  SMA_METicketMetrics100 m;
  bool read=MAReadMETicketMetrics100(owned,_Symbol,InpMagic,now,m,reason);
  A45Check("LIVE_TICKET_READ",read);
  if(read)
  {
   bool ok=MAMETicketSavedPreview100(store,2,99,_Symbol,InpMagic,owned,now,
    MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_GE,m.profit,preview,action,reason);
   A45Check("SAVED_AND_TICKET_PREVIEW",ok&&preview&&action=="SINGLE_TRAILING");
   ok=MAMETicketSavedPreview100(store,2,99,_Symbol,InpMagic,owned,now,
    MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_LE,m.profit-1000000.0,preview,action,reason);
   A45Check("TICKET_PREDICATE_IDLE",ok&&!preview&&action=="");
   ok=MAMETicketSavedPreview100(store,2,99,_Symbol,InpMagic,owned,now,
    99,MA_TICKET_CMP_GE,0,preview,action,reason);
   A45Check("UNSUPPORTED_METRIC_REJECT",!ok&&!preview);
  }
 }
 Print("[MA_ME_TICKET_SAVED_INFO] symbol=",_Symbol," magic=",InpMagic,
       " owned_sell=",sells," cases=",a45_cases," failures=",a45_failures);
 if(a45_failures>0)Print("[MA_ME_TICKET_SAVED_FAIL] cases=",a45_cases," failures=",a45_failures," NO_ORDERS=1");
 else if(owned==0)Print("[MA_ME_TICKET_SAVED_INCONCLUSIVE] cases=",a45_cases,
 " owned_sell=0 fixture_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 else Print("[MA_ME_TICKET_SAVED_PASS] cases=",a45_cases,
 " saved_and_ticket_preview=PASS builder_ticket_part_integrated=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick(){}
