#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_ME_Metrics_Gate_v1_00.mqh"
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_SAVED_METRICS100_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Reset100(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],reason="",action="";
 bool fire=false;long magic=987654321;
 string noSymbol="__MA_METRICS_NO_MATCH__";
 Reset100(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=BUY;COND=EQ;VALUE=0";
 p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE100",store.SaveDefinition(2,99,"M100",p,v,true));
 Check("MANAGE_ZERO_TRUE",MASavedMEMetricsIntent100(store,2,99,noSymbol,magic,fire,action,reason)&&fire&&action=="SINGLE_TRAILING");
 Check("MANAGE_READ_ONLY",MASavedMEMetricsIntent100(store,2,99,_Symbol,magic,fire,action,reason)&&reason=="READ_ONLY_METRICS_INTENT_SIDE_COUNT_ONLY");
 v[97]="SIDE=BUY;COND=GT;VALUE=2147483647";
 Check("SAVE_FALSE",store.SaveDefinition(2,99,"FALSE",p,v,true));
 Check("MANAGE_FALSE",MASavedMEMetricsIntent100(store,2,99,noSymbol,magic,fire,action,reason)&&!fire);
 Reset100(p,v);
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE=0";
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT100",store.SaveDefinition(3,99,"E100",p,v,true));
 Check("EXIT_ZERO_TRUE",MASavedMEMetricsIntent100(store,3,99,noSymbol,magic,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 Check("UNSAVED_REJECT",!MASavedMEMetricsIntent100(store,3,98,noSymbol,magic,fire,action,reason)&&reason=="SLOT_UNSAVED"&&!fire);
 Check("WRONG_ROLE_REJECT",!MASavedMEMetricsIntent100(store,1,99,noSymbol,magic,fire,action,reason)&&reason=="ROLE_NOT_MANAGE_EXIT");
 Check("SLOT_RANGE_REJECT",!MASavedMEMetricsIntent100(store,3,100,noSymbol,magic,fire,action,reason)&&reason=="SLOT_OUT_OF_RANGE");
 Check("EMPTY_SYMBOL_REJECT",!MASavedMEMetricsIntent100(store,3,99,"",magic,fire,action,reason)&&reason=="METRICS_EMPTY_SYMBOL");
 Check("NEGATIVE_MAGIC_REJECT",!MASavedMEMetricsIntent100(store,3,99,noSymbol,-1,fire,action,reason)&&reason=="METRICS_NEGATIVE_MAGIC");
 Reset100(p,v);p[0]="AVG_PRICE";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"UNSUPPORTED",p,v,true));
 Check("AVG_PRICE_FAIL_CLOSED",!MASavedMEMetricsIntent100(store,3,99,noSymbol,magic,fire,action,reason)&&reason=="UNSUPPORTED_METRIC_CONDITION_AVG_PRICE"&&!fire&&action=="");
 Reset100(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE=0";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_DISABLED",store.SaveDefinition(3,99,"OFF",p,v,false));
 Check("DISABLED_REJECT",!MASavedMEMetricsIntent100(store,3,99,noSymbol,magic,fire,action,reason)&&reason=="SLOT_DISABLED");
 Print("[MA_SAVED_METRICS100_INFO] symbol=",_Symbol," magic=",magic," account_positions=",PositionsTotal());
 if(failures==0)Print("[MA_SAVED_METRICS100_PASS] cases=",checks," metrics_snapshot=1 side_count_only=1 other_metrics_fail_closed=1 real_matching_positions_unproven=1 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SAVED_METRICS100_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
