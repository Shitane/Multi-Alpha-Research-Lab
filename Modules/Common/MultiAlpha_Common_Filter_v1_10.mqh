//+------------------------------------------------------------------+
//| MultiAlpha_Common_Filter_v1_10.mqh                              |
//| Slot-local modular filter parts + editable parameters.           |
//| Config/UI contract only. NO broker operations.                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_COMMON_FILTER_V1_10_MQH
#define MULTIALPHA_COMMON_FILTER_V1_10_MQH
#define MA_FILTER_SLOT_COUNT_V110 50
enum ENUM_MA_FILTER_SCOPE_V110 { MA_FILTER_NEW_V110=1,MA_FILTER_ADD_V110=2,MA_FILTER_BOTH_V110=3 };
struct SMA_CommonFilterConfig110
{
 bool trading_time,news,fomc,nfp,cpi,month_end,month_start,quarter_end,year_end,rollover,friday,spread,volatility;
 int start_hour,start_minute,end_hour,end_minute;
 int news_before_min,news_after_min,fomc_before_hours,fomc_after_hours,nfp_before_min,nfp_after_min,cpi_before_min,cpi_after_min;
 int month_end_trading_days,month_start_trading_days,quarter_end_trading_days,year_end_trading_days;
 int rollover_before_min,rollover_after_min,friday_stop_hour,friday_stop_minute;
 double max_spread_points,min_atr_points,max_atr_points;
 int time_scope,news_scope,fomc_scope,nfp_scope,cpi_scope,month_end_scope,month_start_scope,quarter_end_scope,year_end_scope,rollover_scope,friday_scope,spread_scope,volatility_scope;
};
struct SMA_FilterExternalState110
{
 bool news_block,fomc_block,nfp_block,cpi_block,month_end_block,month_start_block,quarter_end_block,year_end_block,rollover_block,friday_block,spread_block,volatility_block;
};
struct SMA_FilterPermission110 { bool new_entry,add_entry; string new_reason,add_reason; };
void MAFilterDefaults110(SMA_CommonFilterConfig110 &c)
{
 c.trading_time=c.news=c.fomc=c.nfp=c.cpi=c.month_end=c.month_start=c.quarter_end=c.year_end=c.rollover=c.friday=c.spread=c.volatility=false;
 c.start_hour=10;c.start_minute=0;c.end_hour=14;c.end_minute=0;
 c.news_before_min=30;c.news_after_min=30;c.fomc_before_hours=12;c.fomc_after_hours=12;c.nfp_before_min=60;c.nfp_after_min=60;c.cpi_before_min=60;c.cpi_after_min=60;
 c.month_end_trading_days=1;c.month_start_trading_days=1;c.quarter_end_trading_days=1;c.year_end_trading_days=2;
 c.rollover_before_min=15;c.rollover_after_min=15;c.friday_stop_hour=20;c.friday_stop_minute=0;
 c.max_spread_points=0;c.min_atr_points=0;c.max_atr_points=0;
 c.time_scope=c.news_scope=c.fomc_scope=c.nfp_scope=c.cpi_scope=c.month_end_scope=c.month_start_scope=c.quarter_end_scope=c.year_end_scope=c.rollover_scope=c.friday_scope=c.spread_scope=c.volatility_scope=MA_FILTER_BOTH_V110;
}
class CMultiAlphaFilterStore110
{
 SMA_CommonFilterConfig110 c[MA_FILTER_SLOT_COUNT_V110];
public:
 void Init(){for(int i=0;i<MA_FILTER_SLOT_COUNT_V110;i++)MAFilterDefaults110(c[i]);}
 SMA_CommonFilterConfig110 Get(const int slot)const{return c[MathMax(1,MathMin(MA_FILTER_SLOT_COUNT_V110,slot))-1];}
 void Set(const int slot,const SMA_CommonFilterConfig110 &v){if(slot>=1&&slot<=MA_FILTER_SLOT_COUNT_V110)c[slot-1]=v;}
};
#endif
