//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Filter_Preset_NoOrders_v1_20.mq5                |
//| Contract test: slot-local FILTER named preset round-trip.         |
//| NO broker operations.                                            |
//+------------------------------------------------------------------+
#property strict
#property version "1.20"
#include "..\\..\\..\\Include\\Common\\MultiAlpha_Slot_Filter_Preset_v1_20.mqh"

int OnInit()
{
 CMultiAlphaSlotFilterPreset120 a,b;a.Init();b.Init();
 string reason="";
 SMA_CommonFilterConfig110 c1=a.Get(1);
 c1.trading_time=true;c1.start_hour=10;c1.start_minute=0;c1.end_hour=14;c1.end_minute=0;
 c1.fomc=true;c1.fomc_before_hours=12;c1.fomc_after_hours=12;
 if(!a.Set(1,c1,reason)){Print("[MA_FILTER_PRESET120_FAIL] phase=set1 reason=",reason);return INIT_FAILED;}
 SMA_CommonFilterConfig110 c2=a.Get(2);
 c2.news=true;c2.news_before_min=45;c2.news_after_min=90;c2.spread=true;c2.max_spread_points=35.0;
 if(!a.Set(2,c2,reason)){Print("[MA_FILTER_PRESET120_FAIL] phase=set2 reason=",reason);return INIT_FAILED;}
 string name="MA_Filter_v120_contract";
 if(!a.SaveNamed(name,reason)){Print("[MA_FILTER_PRESET120_FAIL] phase=save reason=",reason);return INIT_FAILED;}
 if(!b.LoadNamed(name,reason)){Print("[MA_FILTER_PRESET120_FAIL] phase=load reason=",reason);return INIT_FAILED;}
 SMA_CommonFilterConfig110 r1=b.Get(1),r2=b.Get(2),r3=b.Get(3);
 bool pass=(r1.trading_time&&r1.start_hour==10&&r1.end_hour==14&&r1.fomc&&r1.fomc_before_hours==12&&r1.fomc_after_hours==12&&
            r2.news&&r2.news_before_min==45&&r2.news_after_min==90&&r2.spread&&MathAbs(r2.max_spread_points-35.0)<0.000001&&
            !r3.trading_time&&!r3.news&&!r3.fomc&&!r3.spread);
 Print("[MA_FILTER_PRESET120_ROUNDTRIP] pass=",(pass?1:0),
       " slot01_time=",(int)r1.trading_time," slot01_fomc=",(int)r1.fomc,
       " slot02_news=",(int)r2.news," slot02_spread=",(int)r2.spread,
       " slot03_default_off=",((!r3.trading_time&&!r3.news&&!r3.fomc&&!r3.spread)?1:0),
       " NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return pass?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
