#property strict
#property version "1.01"
#include "../../../Include/Builder/MultiAlpha_Saved_ME_Metrics_Gate_v1_01.mqh"
// A14-12: live existing positions -> saved MANAGE/EXIT SIDE_COUNT intents.
// READ ONLY. No trading. A nonzero owned position is required for PASS.
input long InpMagic=46102031;
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;
 Print("[MA_LIVE_SAVED_ME_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Reset100(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 if(_Symbol==""||InpMagic<0)
 {
  Print("[MA_LIVE_SAVED_ME_FAIL] INVALID_INPUT NO_ORDERS=1");
  return INIT_FAILED;
 }
 int buys=0,sells=0,other=0;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){Print("[MA_LIVE_SAVED_ME_FAIL] POSITION_SELECT_FAILED");return INIT_FAILED;}
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||PositionGetInteger(POSITION_MAGIC)!=InpMagic){other++;continue;}
  long side=PositionGetInteger(POSITION_TYPE);
  if(side==POSITION_TYPE_BUY)buys++;
  else if(side==POSITION_TYPE_SELL)sells++;
  else{Print("[MA_LIVE_SAVED_ME_FAIL] UNKNOWN_POSITION_TYPE");return INIT_FAILED;}
 }
 Print("[MA_LIVE_SAVED_ME_INFO] symbol=",_Symbol," magic=",InpMagic,
       " buy=",buys," sell=",sells," other=",other," total=",PositionsTotal());
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],reason="",action="";
 bool fire=false;
 Reset100(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);
 p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE_100",store.SaveDefinition(2,99,"LIVE_M",p,v,true));
 bool ok=MASavedMEMetricsIntent100(store,2,99,_Symbol,InpMagic,fire,action,reason);
 Check("MANAGE_MATCH_TRUE",ok&&fire&&action=="SINGLE_TRAILING"&&reason=="READ_ONLY_METRICS_INTENT_SIDE_COUNT_ONLY");
 v[97]="SIDE=SELL;COND=GT;VALUE="+IntegerToString(sells);
 Check("SAVE_MANAGE_FALSE",store.SaveDefinition(2,99,"LIVE_M_FALSE",p,v,true));
 ok=MASavedMEMetricsIntent100(store,2,99,_Symbol,InpMagic,fire,action,reason);
 Check("MANAGE_MATCH_FALSE",ok&&!fire&&action=="");
 Reset100(p,v);
 p[0]="SIDE_COUNT";v[0]="SIDE=BUY;COND=EQ;VALUE="+IntegerToString(buys);
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT_100",store.SaveDefinition(3,99,"LIVE_E",p,v,true));
 ok=MASavedMEMetricsIntent100(store,3,99,_Symbol,InpMagic,fire,action,reason);
 Check("EXIT_MATCH_TRUE",ok&&fire&&action=="CLOSE_SIDE");
 v[0]="SIDE=BUY;COND=GT;VALUE="+IntegerToString(buys);
 Check("SAVE_EXIT_FALSE",store.SaveDefinition(3,99,"LIVE_E_FALSE",p,v,true));
 ok=MASavedMEMetricsIntent100(store,3,99,_Symbol,InpMagic,fire,action,reason);
 Check("EXIT_MATCH_FALSE",ok&&!fire&&action=="");
 Check("UNSAVED_REJECT",!MASavedMEMetricsIntent100(store,3,98,_Symbol,InpMagic,fire,action,reason)&&reason=="SLOT_UNSAVED"&&!fire);
 Reset100(p,v);p[0]="AVG_PRICE";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"BAD",p,v,true));
 Check("UNSUPPORTED_FAIL_CLOSED",!MASavedMEMetricsIntent100(store,3,99,_Symbol,InpMagic,fire,action,reason)&&reason=="UNSUPPORTED_METRIC_CONDITION_AVG_PRICE"&&!fire&&action=="");
 Reset100(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE="+IntegerToString(sells);p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_DISABLED",store.SaveDefinition(3,99,"OFF",p,v,false));
 Check("DISABLED_REJECT",!MASavedMEMetricsIntent100(store,3,99,_Symbol,InpMagic,fire,action,reason)&&reason=="SLOT_DISABLED"&&!fire);
 if(failures>0)Print("[MA_LIVE_SAVED_ME_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 else if(buys+sells==0)Print("[MA_LIVE_SAVED_ME_INCONCLUSIVE] cases=",checks," zero_owned=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_LIVE_SAVED_ME_PASS] cases=",checks," owned_nonzero=1 saved_manage_exit_side_count=PASS intent_only=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
