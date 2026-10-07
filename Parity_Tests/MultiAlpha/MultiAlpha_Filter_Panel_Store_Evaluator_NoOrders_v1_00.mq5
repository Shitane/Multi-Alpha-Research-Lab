//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Panel_Store_Evaluator_NoOrders_v1_00.mq5      |
//| B-P0-2F: visible Panel -> Store -> Evaluator evidence harness.    |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "../../../Include/Common/MultiAlpha_Common_Filter_v1_10.mqh"
#include "../../../Include/Common/MultiAlpha_Filter_Panel_v1_11.mqh"
#include "../../../Include/Common/MultiAlpha_Common_Filter_Evaluator_v1_11.mqh"
#include "../../../Include/Common/MultiAlpha_Filter_To_Builder_Adapter_v1_01.mqh"

CMultiAlphaFilterStore110 g_store;
CMultiAlphaFilterPanel111 g_panel;
int g_slot=1;

void ClearExternal2F(SMA_FilterExternalState110 &x)
{
 x.news_block=x.fomc_block=x.nfp_block=x.cpi_block=false;
 x.month_end_block=x.month_start_block=x.quarter_end_block=x.year_end_block=false;
 x.rollover_block=x.friday_block=x.spread_block=x.volatility_block=false;
}
void PrintRoundTrip2F(const string phase)
{
 SMA_CommonFilterConfig110 c=g_store.Get(g_slot);
 SMA_FilterExternalState110 x;ClearExternal2F(x);
 // Deterministic external blocks let the UI ON/OFF state be observed immediately.
 x.news_block=true;x.spread_block=true;
 SMA_FilterPermission110 p=MAFilterEvaluate111(c,x,TimeCurrent());
 SMA_BuilderFilterContext101 bc;MABuilderFilterContextDefaults101(bc);MAFilterPermissionToBuilder100(p,bc);
 Print("[MA_FILTERUI2F_STATE] phase=",phase," slot=",g_slot,
       " NEWS=",(c.news?1:0)," SPREAD=",(c.spread?1:0),
       " TIME=",(c.trading_time?1:0),
       " new_ok=",(bc.new_entry_ok?1:0)," add_ok=",(bc.add_entry_ok?1:0),
       " new_reason=",bc.new_reason," add_reason=",bc.add_reason,
       " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
}
int OnInit()
{
 g_store.Init();g_panel.Create();
 SMA_CommonFilterConfig110 c=g_store.Get(g_slot);
 // Make NEWS and SPREAD scope BOTH for deterministic UI click verification.
 c.news_scope=MA_FILTER_BOTH_V110;c.spread_scope=MA_FILTER_BOTH_V110;g_store.Set(g_slot,c);
 g_panel.Show(g_slot,g_store.Get(g_slot));
 Print("[MA_FILTERUI2F_START] Click NEWS or SPREAD. Edit fields if desired. Panel events are written to SLOT #01 Store. NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 PrintRoundTrip2F("START");
 return INIT_SUCCEEDED;
}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
 SMA_CommonFilterConfig110 c=g_store.Get(g_slot);
 int changed=g_panel.Event(id,sparam,c);
 if(changed!=0)
 {
  g_store.Set(g_slot,c);
  g_panel.Show(g_slot,g_store.Get(g_slot));
  Print("[MA_FILTERUI2F_EDIT] event=",id," object=",sparam," store_write=1 slot=",g_slot," NO_ORDERS=1");
  PrintRoundTrip2F("AFTER_UI_EDIT");
 }
}
void OnDeinit(const int reason){g_panel.Delete();Print("[MA_FILTERUI2F_STOP] reason=",reason," NO_ORDERS=1");}
void OnTick(){}
