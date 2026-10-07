//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Store_Evaluator_Builder_NoOrders_v1_01.mq5    |
//| B-P0-2E deterministic store->evaluator->Builder round trip.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"
#include "../../../Include/Common/MultiAlpha_Common_Filter_Evaluator_v1_11.mqh"
#include "../../../Include/Common/MultiAlpha_Filter_To_Builder_Adapter_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Filter_Context_v1_01.mqh"
void ClearExternal100(SMA_FilterExternalState110 &x){x.news_block=x.fomc_block=x.nfp_block=x.cpi_block=false;x.month_end_block=x.month_start_block=x.quarter_end_block=x.year_end_block=false;x.rollover_block=x.friday_block=x.spread_block=x.volatility_block=false;}
bool Expect100(const string name,const bool got,const bool expected){if(got==expected){Print("[MA_FILTERE100_CASE] ",name," PASS got=",(got?1:0));return true;}Print("[MA_FILTERE100_FAIL] ",name," got=",(got?1:0)," expected=",(expected?1:0));return false;}
int OnInit()
{
 CMultiAlphaFilterStore110 store;store.Init();SMA_CommonFilterConfig110 c=store.Get(1);SMA_FilterExternalState110 x;ClearExternal100(x);SMA_BuilderFilterContext101 bc;MABuilderFilterContextDefaults101(bc);bool ok=true;
 SMA_FilterPermission110 p=MAFilterEvaluate111(c,x,D'2026.10.07 23:00');MAFilterPermissionToBuilder100(p,bc);
 ok=Expect100("ALL_OFF_NEW",bc.new_entry_ok,true)&&ok;ok=Expect100("ALL_OFF_ADD",bc.add_entry_ok,true)&&ok;
 c.news=true;c.news_scope=MA_FILTER_NEW_V110;store.Set(1,c);x.news_block=true;p=MAFilterEvaluate111(store.Get(1),x,D'2026.10.07 23:00');MAFilterPermissionToBuilder100(p,bc);
 ok=Expect100("NEWS_NEW_NEW",bc.new_entry_ok,false)&&ok;ok=Expect100("NEWS_NEW_ADD",bc.add_entry_ok,true)&&ok;
 c.news_scope=MA_FILTER_ADD_V110;store.Set(1,c);p=MAFilterEvaluate111(store.Get(1),x,D'2026.10.07 23:00');MAFilterPermissionToBuilder100(p,bc);
 ok=Expect100("NEWS_ADD_NEW",bc.new_entry_ok,true)&&ok;ok=Expect100("NEWS_ADD_ADD",bc.add_entry_ok,false)&&ok;
 c.news_scope=MA_FILTER_BOTH_V110;store.Set(1,c);p=MAFilterEvaluate111(store.Get(1),x,D'2026.10.07 23:00');MAFilterPermissionToBuilder100(p,bc);
 ok=Expect100("NEWS_BOTH_NEW",bc.new_entry_ok,false)&&ok;ok=Expect100("NEWS_BOTH_ADD",bc.add_entry_ok,false)&&ok;
 MAFilterDefaults110(c);c.trading_time=true;c.start_hour=10;c.end_hour=14;c.time_scope=MA_FILTER_NEW_V110;store.Set(1,c);ClearExternal100(x);
 p=MAFilterEvaluate111(store.Get(1),x,D'2026.10.07 11:00');MAFilterPermissionToBuilder100(p,bc);ok=Expect100("TIME_INSIDE_NEW",bc.new_entry_ok,true)&&ok;
 p=MAFilterEvaluate111(store.Get(1),x,D'2026.10.07 15:00');MAFilterPermissionToBuilder100(p,bc);ok=Expect100("TIME_OUTSIDE_NEW",bc.new_entry_ok,false)&&ok;ok=Expect100("TIME_OUTSIDE_ADD_UNSCOPED",bc.add_entry_ok,true)&&ok;
 MAFilterDefaults110(c);c.spread=true;c.spread_scope=MA_FILTER_BOTH_V110;store.Set(1,c);ClearExternal100(x);x.spread_block=true;
 p=MAFilterEvaluate111(store.Get(1),x,D'2026.10.07 12:00');MAFilterPermissionToBuilder100(p,bc);ok=Expect100("SPREAD_BOTH_NEW",bc.new_entry_ok,false)&&ok;ok=Expect100("SPREAD_BOTH_ADD",bc.add_entry_ok,false)&&ok;
 Print(ok?"[MA_FILTERE100_PASS] store=PASS evaluator=PASS scope=PASS adapter=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1":"[MA_FILTERE100_FAIL] aggregate=FAIL NO_ORDERS=1 BROKER_ACTIONS_ARMED=0");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
