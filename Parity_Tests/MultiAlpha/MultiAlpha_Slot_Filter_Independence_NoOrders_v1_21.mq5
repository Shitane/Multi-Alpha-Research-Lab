//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Filter_Independence_NoOrders_v1_21.mq5          |
//| Gate: 50 FILTER slots stay independent across named round-trip.   |
//| NO broker operations.                                            |
//+------------------------------------------------------------------+
#property strict
#property version "1.21"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Slot_Filter_Preset_v1_20.mqh"

bool Same121(const SMA_CommonFilterConfig110 &a,const SMA_CommonFilterConfig110 &b)
{
 return a.trading_time==b.trading_time && a.news==b.news && a.fomc==b.fomc &&
        a.nfp==b.nfp && a.cpi==b.cpi && a.month_end==b.month_end &&
        a.month_start==b.month_start && a.quarter_end==b.quarter_end &&
        a.year_end==b.year_end && a.rollover==b.rollover && a.friday==b.friday &&
        a.spread==b.spread && a.volatility==b.volatility &&
        a.start_hour==b.start_hour && a.start_minute==b.start_minute &&
        a.end_hour==b.end_hour && a.end_minute==b.end_minute &&
        a.news_before_min==b.news_before_min && a.news_after_min==b.news_after_min &&
        a.fomc_before_hours==b.fomc_before_hours && a.fomc_after_hours==b.fomc_after_hours &&
        a.nfp_before_min==b.nfp_before_min && a.nfp_after_min==b.nfp_after_min &&
        a.cpi_before_min==b.cpi_before_min && a.cpi_after_min==b.cpi_after_min &&
        a.month_end_trading_days==b.month_end_trading_days &&
        a.month_start_trading_days==b.month_start_trading_days &&
        a.quarter_end_trading_days==b.quarter_end_trading_days &&
        a.year_end_trading_days==b.year_end_trading_days &&
        a.rollover_before_min==b.rollover_before_min && a.rollover_after_min==b.rollover_after_min &&
        a.friday_stop_hour==b.friday_stop_hour && a.friday_stop_minute==b.friday_stop_minute &&
        MathAbs(a.max_spread_points-b.max_spread_points)<0.000001 &&
        MathAbs(a.min_atr_points-b.min_atr_points)<0.000001 &&
        MathAbs(a.max_atr_points-b.max_atr_points)<0.000001 &&
        a.time_scope==b.time_scope && a.news_scope==b.news_scope && a.fomc_scope==b.fomc_scope &&
        a.nfp_scope==b.nfp_scope && a.cpi_scope==b.cpi_scope &&
        a.month_end_scope==b.month_end_scope && a.month_start_scope==b.month_start_scope &&
        a.quarter_end_scope==b.quarter_end_scope && a.year_end_scope==b.year_end_scope &&
        a.rollover_scope==b.rollover_scope && a.friday_scope==b.friday_scope &&
        a.spread_scope==b.spread_scope && a.volatility_scope==b.volatility_scope;
}
int OnInit()
{
 CMultiAlphaSlotFilterPreset120 src,dst;src.Init();dst.Init();string reason="";
 for(int i=1;i<=50;i++)
 {
  SMA_CommonFilterConfig110 c=src.Get(i);
  c.trading_time=((i%2)==1); c.start_hour=i%24; c.start_minute=i%60;
  c.end_hour=(i+7)%24; c.end_minute=(i*3)%60;
  c.news=((i%3)==0); c.news_before_min=i; c.news_after_min=i+10;
  c.fomc=((i%5)==0); c.fomc_before_hours=i%24; c.fomc_after_hours=(i+1)%24;
  c.nfp=((i%7)==0); c.cpi=((i%11)==0);
  c.month_end=((i%4)==0); c.month_start=((i%6)==0);
  c.quarter_end=((i%8)==0); c.year_end=((i%9)==0);
  c.rollover=((i%10)==0); c.friday=((i%12)==0);
  c.spread=true; c.max_spread_points=10.0+i;
  c.volatility=true; c.min_atr_points=i; c.max_atr_points=100.0+i;
  if(!src.Set(i,c,reason)){Print("[MA_FILTER_SLOT121_FAIL] phase=set slot=",i," reason=",reason);return INIT_FAILED;}
 }
 string name="MA_Filter_50slot_independence_v121";
 if(!src.SaveNamed(name,reason)){Print("[MA_FILTER_SLOT121_FAIL] phase=save reason=",reason);return INIT_FAILED;}
 if(!dst.LoadNamed(name,reason)){Print("[MA_FILTER_SLOT121_FAIL] phase=load reason=",reason);return INIT_FAILED;}
 for(int i=1;i<=50;i++)
 {
  if(!Same121(src.Get(i),dst.Get(i))){Print("[MA_FILTER_SLOT121_FAIL] phase=compare slot=",i);return INIT_FAILED;}
 }
 bool distinct=(dst.Get(1).start_hour!=dst.Get(2).start_hour &&
                dst.Get(2).max_spread_points!=dst.Get(50).max_spread_points);
 Print("[MA_FILTER_SLOT121_ROUNDTRIP] pass=",(distinct?1:0),
       " slots=50 slot01_start=",dst.Get(1).start_hour,
       " slot02_start=",dst.Get(2).start_hour,
       " slot50_spread=",DoubleToString(dst.Get(50).max_spread_points,1),
       " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return distinct?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
