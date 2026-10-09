#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Ticket_Metrics_v1_00.mqh>
// A14-44: live per-ticket read-only metrics; no OrderSend/CTrade/position mutation.
input long InpMagic=46102031;
int a44_cases=0,a44_failures=0;
void A44Check(const string name,const bool ok)
{
 a44_cases++;if(!ok)a44_failures++;
 Print("[MA_ME_TICKET_METRICS_CASE] ",name," ",ok?"PASS":"FAIL");
}
int OnInit()
{
 SMA_METicketMetrics100 p;
 string reason="";
 bool fire=false;
 datetime now=TimeCurrent();
 A44Check("ZERO_TICKET_REJECT",!MAReadMETicketMetrics100(0,_Symbol,InpMagic,now,p,reason)&&p.ticket==0);
 A44Check("EMPTY_SYMBOL_REJECT",!MAReadMETicketMetrics100(1,"",InpMagic,now,p,reason));
 A44Check("BAD_MAGIC_REJECT",!MAReadMETicketMetrics100(1,_Symbol,-1,now,p,reason));
 A44Check("BAD_TIME_REJECT",!MAReadMETicketMetrics100(1,_Symbol,InpMagic,0,p,reason));
 SMA_METicketMetrics100 fixture;
 MAResetMETicketMetrics100(fixture);
 fixture.ticket=123;fixture.symbol=_Symbol;fixture.magic=InpMagic;
 fixture.side=(int)POSITION_TYPE_SELL;fixture.lots=0.01;
 fixture.openPrice=2600.0;fixture.profit=15.0;
 fixture.openTime=now-120;fixture.ageSeconds=120;
 A44Check("PROFIT_GE_MATCH",MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_GE,10.0,fire,reason)&&fire);
 A44Check("PROFIT_LE_IDLE",MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_LE,10.0,fire,reason)&&!fire);
 A44Check("AGE_GE_MATCH",MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_AGE_SECONDS,MA_TICKET_CMP_GE,120.0,fire,reason)&&fire);
 A44Check("AGE_LE_IDLE",MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_AGE_SECONDS,MA_TICKET_CMP_LE,119.0,fire,reason)&&!fire);
 A44Check("OPEN_PRICE_GE_MATCH",MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_OPEN_PRICE,MA_TICKET_CMP_GE,2600.0,fire,reason)&&fire);
 A44Check("UNKNOWN_METRIC_REJECT",!MAEvaluateMETicketPredicate100(fixture,99,MA_TICKET_CMP_GE,0,fire,reason)&&!fire);
 A44Check("UNKNOWN_COMPARE_REJECT",!MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_PROFIT,99,0,fire,reason)&&!fire);
 A44Check("NAN_REJECT",!MAEvaluateMETicketPredicate100(fixture,MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_GE,MathSqrt(-1.0),fire,reason)&&!fire);
 SMA_METicketMetrics100 live;
 int owned=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){A44Check("POSITION_ENUMERATION",false);break;}
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  owned++;
  bool ok=MAReadMETicketMetrics100(ticket,_Symbol,InpMagic,now,live,reason);
  A44Check("LIVE_OWNED_TICKET_"+IntegerToString(owned),ok&&live.ticket==ticket&&live.ageSeconds>=0);
  if(ok)
  {
   A44Check("LIVE_PROFIT_SELF_COMPARE_"+IntegerToString(owned),
     MAEvaluateMETicketPredicate100(live,MA_TICKET_METRIC_PROFIT,MA_TICKET_CMP_GE,live.profit,fire,reason)&&fire);
   A44Check("LIVE_AGE_SELF_COMPARE_"+IntegerToString(owned),
     MAEvaluateMETicketPredicate100(live,MA_TICKET_METRIC_AGE_SECONDS,MA_TICKET_CMP_GE,(double)live.ageSeconds,fire,reason)&&fire);
  }
 }
 Print("[MA_ME_TICKET_METRICS_INFO] symbol=",_Symbol," magic=",InpMagic," live_owned=",owned," cases=",a44_cases," failures=",a44_failures);
 if(a44_failures>0)Print("[MA_ME_TICKET_METRICS_FAIL] cases=",a44_cases," failures=",a44_failures," NO_ORDERS=1");
 else if(owned==0)Print("[MA_ME_TICKET_METRICS_INCONCLUSIVE] cases=",a44_cases," live_owned=0 fixture_only=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 else Print("[MA_ME_TICKET_METRICS_PASS] cases=",a44_cases," live_owned=",owned," per_ticket_read_only=PASS saved_slot_integration=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick(){}
