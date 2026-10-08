#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_ME_Position_Gate_v1_00.mqh"
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_SAVED_ME_POSITION_CASE] ",name," ",ok?"PASS":"FAIL");
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
 bool fire=false;
 long magic=987654321;
 // Symbol guaranteed not to match any broker position in this test.
 string noSymbol="__MA_NO_MATCH_SYMBOL__";
 Reset100(p,v);
 p[97]="SIDE_COUNT";v[97]="SIDE=BUY;COND=EQ;VALUE=0";
 p[98]="AND";p[99]="SINGLE_TRAILING";
 v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE100",store.SaveDefinition(2,99,"M100",p,v,true));
 Check("MANAGE_ZERO_TRUE",MASavedMEPositionIntent100(store,2,99,noSymbol,magic,fire,action,reason)&&fire&&action=="SINGLE_TRAILING");
 Check("MANAGE_LIVE_SNAPSHOT",MASavedMEPositionIntent100(store,2,99,_Symbol,magic,fire,action,reason)&&reason=="READ_ONLY_POSITION_INTENT");
 v[97]="SIDE=BUY;COND=GT;VALUE=2147483647";
 Check("SAVE_MANAGE_FALSE",store.SaveDefinition(2,99,"M100_FALSE",p,v,true));
 Check("MANAGE_FALSE",MASavedMEPositionIntent100(store,2,99,noSymbol,magic,fire,action,reason)&&!fire);
 Reset100(p,v);
 p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE=0";
 p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_EXIT100",store.SaveDefinition(3,99,"E100",p,v,true));
 Check("EXIT_ZERO_TRUE",MASavedMEPositionIntent100(store,3,99,noSymbol,magic,fire,action,reason)&&fire&&action=="CLOSE_SIDE");
 Check("EXIT_OTHER_SYMBOL_FALSE",MASavedMEPositionIntent100(store,3,99,_Symbol,magic,fire,action,reason)&&reason=="READ_ONLY_POSITION_INTENT");
 Check("UNSAVED_REJECT",!MASavedMEPositionIntent100(store,3,98,_Symbol,magic,fire,action,reason)&&reason=="SLOT_UNSAVED"&&!fire&&action=="");
 Check("WRONG_ROLE_REJECT",!MASavedMEPositionIntent100(store,1,99,_Symbol,magic,fire,action,reason)&&reason=="ROLE_NOT_MANAGE_EXIT");
 Check("SLOT100_INDEX_REJECT",!MASavedMEPositionIntent100(store,3,100,_Symbol,magic,fire,action,reason)&&reason=="SLOT_OUT_OF_RANGE");
 Check("EMPTY_SYMBOL_REJECT",!MASavedMEPositionIntent100(store,3,99,"",magic,fire,action,reason)&&reason=="POSITION_EMPTY_SYMBOL");
 Check("NEGATIVE_MAGIC_REJECT",!MASavedMEPositionIntent100(store,3,99,_Symbol,-1,fire,action,reason)&&reason=="POSITION_NEGATIVE_MAGIC");
 p[0]="MOVE_POINTS";v[0]="";Check("SAVE_UNSUPPORTED",store.SaveDefinition(3,99,"UNSUPPORTED",p,v,true));
 Check("UNSUPPORTED_REJECT",!MASavedMEPositionIntent100(store,3,99,noSymbol,magic,fire,action,reason)&&reason=="CONDITION_UNSUPPORTED_CONDITION_MOVE_POINTS"&&!fire);
 Reset100(p,v);p[0]="SIDE_COUNT";v[0]="SIDE=SELL;COND=EQ;VALUE=0";p[1]="AND";p[2]="CLOSE_SIDE";
 Check("SAVE_DISABLED",store.SaveDefinition(3,99,"OFF",p,v,false));
 Check("DISABLED_REJECT",!MASavedMEPositionIntent100(store,3,99,noSymbol,magic,fire,action,reason)&&reason=="SLOT_DISABLED");
 Print("[MA_SAVED_ME_POSITION_INFO] symbol=",_Symbol," magic=",magic," account_positions=",PositionsTotal());
 if(failures==0)Print("[MA_SAVED_ME_POSITION_PASS] cases=",checks," real_position_snapshot=1 side_count_only=1 no_matching_positions_allowed=1 trade_execution=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_SAVED_ME_POSITION_FAIL] failures=",failures," cases=",checks);
 return INIT_SUCCEEDED;
}
void OnTick(){}
