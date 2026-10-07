//+------------------------------------------------------------------+
//| MultiAlpha_Common_Filter_Evaluator_v1_11.mqh                    |
//| B-P0-2E: v1.10 config + external state -> NEW/ADD permission.    |
//| Derived from proven v1.00 evaluator semantics. NO ORDERS.        |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_COMMON_FILTER_EVALUATOR_V1_11_MQH
#define MULTIALPHA_COMMON_FILTER_EVALUATOR_V1_11_MQH
#include "MultiAlpha_Common_Filter_v1_10.mqh"
#define MA_FILTER_EVALUATOR_111_VERSION "1.11"
bool MAFilterScopeBlocks111(const int scope,const bool add){return ((scope&(add?MA_FILTER_ADD_V110:MA_FILTER_NEW_V110))!=0);}
bool MAFilterTimeInside111(const SMA_CommonFilterConfig110 &c,const datetime now)
{
 MqlDateTime d;TimeToStruct(now,d);int m=d.hour*60+d.min,a=c.start_hour*60+c.start_minute,b=c.end_hour*60+c.end_minute;
 if(a==b)return true;return (a<b ? (m>=a&&m<b) : (m>=a||m<b));
}
void MAFilterBlock111(bool &allow,string &why,const bool enabled,const bool blocked,const int scope,const bool add,const string reason)
{if(allow&&enabled&&blocked&&MAFilterScopeBlocks111(scope,add)){allow=false;why=reason;}}
SMA_FilterPermission110 MAFilterEvaluate111(const SMA_CommonFilterConfig110 &c,const SMA_FilterExternalState110 &x,const datetime now)
{
 SMA_FilterPermission110 p;p.new_entry=true;p.add_entry=true;p.new_reason="ALLOW";p.add_reason="ALLOW";
 bool time_block=!MAFilterTimeInside111(c,now);
 for(int k=0;k<2;k++){bool add=(k==1),allow=true;string why="ALLOW";
  MAFilterBlock111(allow,why,c.trading_time,time_block,c.time_scope,add,"TRADING TIME");
  MAFilterBlock111(allow,why,c.news,x.news_block,c.news_scope,add,"NEWS");
  MAFilterBlock111(allow,why,c.fomc,x.fomc_block,c.fomc_scope,add,"FOMC");
  MAFilterBlock111(allow,why,c.nfp,x.nfp_block,c.nfp_scope,add,"NFP");
  MAFilterBlock111(allow,why,c.cpi,x.cpi_block,c.cpi_scope,add,"CPI");
  MAFilterBlock111(allow,why,c.month_end,x.month_end_block,c.month_end_scope,add,"MONTH END");
  MAFilterBlock111(allow,why,c.month_start,x.month_start_block,c.month_start_scope,add,"MONTH START");
  MAFilterBlock111(allow,why,c.quarter_end,x.quarter_end_block,c.quarter_end_scope,add,"QUARTER END");
  MAFilterBlock111(allow,why,c.year_end,x.year_end_block,c.year_end_scope,add,"YEAR END");
  MAFilterBlock111(allow,why,c.rollover,x.rollover_block,c.rollover_scope,add,"ROLLOVER");
  MAFilterBlock111(allow,why,c.friday,x.friday_block,c.friday_scope,add,"FRIDAY");
  MAFilterBlock111(allow,why,c.spread,x.spread_block,c.spread_scope,add,"SPREAD");
  MAFilterBlock111(allow,why,c.volatility,x.volatility_block,c.volatility_scope,add,"VOLATILITY");
  if(add){p.add_entry=allow;p.add_reason=why;}else{p.new_entry=allow;p.new_reason=why;}
 }return p;
}
#endif
