#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_ME_Metrics_Gate_v1_00.mqh"
// A14-9. Read-only comparison against independently enumerated owned positions.
// Set InpMagic to the magic of EXISTING positions. This EA never places orders.
input long InpMagic=987654321;
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_OWNED_MATCH_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Reset100(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 if(InpMagic<0){Print("[MA_OWNED_MATCH_FAIL] invalid_magic");return INIT_FAILED;}
 int buy=0,sell=0,other=0;
 double buyLots=0,sellLots=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){Print("[MA_OWNED_MATCH_FAIL] position_select");return INIT_FAILED;}
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic)
  {other++;continue;}
  long side=PositionGetInteger(POSITION_TYPE);
  if(side==POSITION_TYPE_BUY){buy++;buyLots+=PositionGetDouble(POSITION_VOLUME);}
  else if(side==POSITION_TYPE_SELL){sell++;sellLots+=PositionGetDouble(POSITION_VOLUME);}
  else{Print("[MA_OWNED_MATCH_FAIL] invalid_side");return INIT_FAILED;}
 }
 SMA_PositionMetrics100 metrics;string reason="";
 Check("METRICS_READ",MAReadPositionMetrics100(_Symbol,InpMagic,metrics,reason));
 Check("BUY_COUNT_MATCH",metrics.buyCount==buy);
 Check("SELL_COUNT_MATCH",metrics.sellCount==sell);
 Check("BUY_LOTS_MATCH",MathAbs(metrics.buyLots-buyLots)<0.0000001);
 Check("SELL_LOTS_MATCH",MathAbs(metrics.sellLots-sellLots)<0.0000001);
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],action="";bool fire=false;
 Reset100(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=BUY;COND=EQ;VALUE="+IntegerToString(buy);
 p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE",store.SaveDefinition(2,99,"MATCH_MANAGE",p,v,true));
 Check("MANAGE_MATCH_TRUE",MASavedMEMetricsIntent100(store,2,99,_Symbol,InpMagic,fire,action,reason)&&fire&&action=="SINGLE_TRAILING");
 v[97]="SIDE=BUY;COND=GT;VALUE="+IntegerToString(buy);
 Check("SAVE_MANAGE_FALSE",store.SaveDefinition(2,99,"FALSE_MANAGE",p,v,true));
 Check("MANAGE_MATCH_FALSE",MASavedMEMetricsIntent100(store,2,99,_Symbol,InpMagic,fire,action,reason)&&!fire);
 Reset100(p,v);
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sell);
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT",store.SaveDefinition(3,99,"MATCH_EXIT",p,v,true));
 Check("EXIT_MATCH_TRUE",MASavedMEMetricsIntent100(store,3,99,_Symbol,InpMagic,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 v[0]="SIDE=SELL;COND=GT;VALUE="+IntegerToString(sell);
 Check("SAVE_EXIT_FALSE",store.SaveDefinition(3,99,"FALSE_EXIT",p,v,true));
 Check("EXIT_MATCH_FALSE",MASavedMEMetricsIntent100(store,3,99,_Symbol,InpMagic,fire,action,reason)&&!fire);
 Print("[MA_OWNED_MATCH_INFO] symbol=",_Symbol," magic=",InpMagic,
       " buy=",buy," sell=",sell," other_positions=",other," account_positions=",PositionsTotal());
 if(failures>0)Print("[MA_OWNED_MATCH_FAIL] failures=",failures," cases=",checks);
 else if(buy+sell==0)
  Print("[MA_OWNED_MATCH_INCONCLUSIVE] cases=",checks," zero_owned_positions=1 real_matching_positions_proven=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 else
  Print("[MA_OWNED_MATCH_PASS] cases=",checks," real_matching_positions_proven=1 side_count_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick(){}
