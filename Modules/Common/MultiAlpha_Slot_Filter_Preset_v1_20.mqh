//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Filter_Preset_v1_20.mqh                         |
//| Named-preset persistence for 50 independent slot FILTER configs. |
//| Configuration only. NO broker operations.                        |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_FILTER_PRESET_V1_20_MQH
#define MULTIALPHA_SLOT_FILTER_PRESET_V1_20_MQH
#include "MultiAlpha_Common_Filter_v1_10.mqh"

#define MA_FILTER_PRESET_FORMAT_V120 "MA_FILTER_PRESET_V1_20"
#define MA_FILTER_PRESET_SLOTS_V120 50

bool MAFilterValidHour120(const int v){return v>=0&&v<=23;}
bool MAFilterValidMinute120(const int v){return v>=0&&v<=59;}
bool MAFilterValidScope120(const int v){return v==MA_FILTER_NEW_V110||v==MA_FILTER_ADD_V110||v==MA_FILTER_BOTH_V110;}

bool MAFilterValidate120(const SMA_CommonFilterConfig110 &c,string &reason)
{
 reason="";
 if(!MAFilterValidHour120(c.start_hour)||!MAFilterValidHour120(c.end_hour)){reason="time hour must be 0..23";return false;}
 if(!MAFilterValidMinute120(c.start_minute)||!MAFilterValidMinute120(c.end_minute)){reason="time minute must be 0..59";return false;}
 if(c.news_before_min<0||c.news_after_min<0||c.fomc_before_hours<0||c.fomc_after_hours<0||c.nfp_before_min<0||c.nfp_after_min<0||c.cpi_before_min<0||c.cpi_after_min<0){reason="event before/after must be >=0";return false;}
 if(c.month_end_trading_days<0||c.month_start_trading_days<0||c.quarter_end_trading_days<0||c.year_end_trading_days<0){reason="calendar trading days must be >=0";return false;}
 if(c.rollover_before_min<0||c.rollover_after_min<0){reason="rollover before/after must be >=0";return false;}
 if(!MAFilterValidHour120(c.friday_stop_hour)||!MAFilterValidMinute120(c.friday_stop_minute)){reason="Friday stop time invalid";return false;}
 if(c.max_spread_points<0||c.min_atr_points<0||c.max_atr_points<0){reason="spread/ATR thresholds must be >=0";return false;}
 if(c.max_atr_points>0&&c.min_atr_points>c.max_atr_points){reason="ATR min exceeds ATR max";return false;}
 int sc[]={c.time_scope,c.news_scope,c.fomc_scope,c.nfp_scope,c.cpi_scope,c.month_end_scope,c.month_start_scope,c.quarter_end_scope,c.year_end_scope,c.rollover_scope,c.friday_scope,c.spread_scope,c.volatility_scope};
 for(int i=0;i<ArraySize(sc);i++)if(!MAFilterValidScope120(sc[i])){reason="invalid permission scope";return false;}
 return true;
}
string MAFilterSafePresetName120(string name)
{
 StringTrimLeft(name);StringTrimRight(name);
 string out="";
 for(int i=0;i<StringLen(name);i++)
 {
  ushort ch=StringGetCharacter(name,i);
  bool ok=(ch>='0'&&ch<='9')||(ch>='A'&&ch<='Z')||(ch>='a'&&ch<='z')||ch=='_'||ch=='-';
  if(ok)out+=ShortToString(ch);
 }
 return out;
}
string MAFilterPresetFile120(const string preset_name)
{
 string n=MAFilterSafePresetName120(preset_name);
 return "MultiAlpha\\Presets\\"+n+"_filters_v120.csv";
}
class CMultiAlphaSlotFilterPreset120
{
 SMA_CommonFilterConfig110 m_cfg[MA_FILTER_PRESET_SLOTS_V120];
public:
 void Init(){for(int i=0;i<MA_FILTER_PRESET_SLOTS_V120;i++)MAFilterDefaults110(m_cfg[i]);}
 SMA_CommonFilterConfig110 Get(const int slot)const{return m_cfg[MathMax(1,MathMin(MA_FILTER_PRESET_SLOTS_V120,slot))-1];}
 bool Set(const int slot,const SMA_CommonFilterConfig110 &v,string &reason)
 {
  if(slot<1||slot>MA_FILTER_PRESET_SLOTS_V120){reason="slot must be 1..50";return false;}
  if(!MAFilterValidate120(v,reason))return false;
  m_cfg[slot-1]=v;return true;
 }
 bool SaveNamed(const string preset_name,string &reason)
 {
  string safe=MAFilterSafePresetName120(preset_name);
  if(StringLen(safe)==0){reason="preset name is empty/invalid";return false;}
  for(int i=0;i<MA_FILTER_PRESET_SLOTS_V120;i++){string vr="";if(!MAFilterValidate120(m_cfg[i],vr)){reason=StringFormat("slot %02d: %s",i+1,vr);return false;}}
  int h=FileOpen(MAFilterPresetFile120(safe),FILE_WRITE|FILE_CSV|FILE_ANSI|FILE_COMMON,',');
  if(h==INVALID_HANDLE){reason="FileOpen WRITE failed "+IntegerToString(GetLastError());return false;}
  FileWrite(h,MA_FILTER_PRESET_FORMAT_V120,MA_FILTER_PRESET_SLOTS_V120);
  for(int i=0;i<MA_FILTER_PRESET_SLOTS_V120;i++)
  {
   SMA_CommonFilterConfig110 c=m_cfg[i];
   FileWrite(h,i+1,
    (int)c.trading_time,(int)c.news,(int)c.fomc,(int)c.nfp,(int)c.cpi,(int)c.month_end,(int)c.month_start,(int)c.quarter_end,(int)c.year_end,(int)c.rollover,(int)c.friday,(int)c.spread,(int)c.volatility,
    c.start_hour,c.start_minute,c.end_hour,c.end_minute,
    c.news_before_min,c.news_after_min,c.fomc_before_hours,c.fomc_after_hours,c.nfp_before_min,c.nfp_after_min,c.cpi_before_min,c.cpi_after_min,
    c.month_end_trading_days,c.month_start_trading_days,c.quarter_end_trading_days,c.year_end_trading_days,
    c.rollover_before_min,c.rollover_after_min,c.friday_stop_hour,c.friday_stop_minute,
    DoubleToString(c.max_spread_points,8),DoubleToString(c.min_atr_points,8),DoubleToString(c.max_atr_points,8),
    c.time_scope,c.news_scope,c.fomc_scope,c.nfp_scope,c.cpi_scope,c.month_end_scope,c.month_start_scope,c.quarter_end_scope,c.year_end_scope,c.rollover_scope,c.friday_scope,c.spread_scope,c.volatility_scope);
  }
  FileClose(h);reason="";return true;
 }
 bool LoadNamed(const string preset_name,string &reason)
 {
  string safe=MAFilterSafePresetName120(preset_name);
  if(StringLen(safe)==0){reason="preset name is empty/invalid";return false;}
  int h=FileOpen(MAFilterPresetFile120(safe),FILE_READ|FILE_CSV|FILE_ANSI|FILE_COMMON,',');
  if(h==INVALID_HANDLE){reason="FileOpen READ failed "+IntegerToString(GetLastError());return false;}
  string fmt=FileReadString(h);int count=(int)FileReadNumber(h);
  if(fmt!=MA_FILTER_PRESET_FORMAT_V120||count!=MA_FILTER_PRESET_SLOTS_V120){FileClose(h);reason="preset format/slot count mismatch";return false;}
  SMA_CommonFilterConfig110 temp[MA_FILTER_PRESET_SLOTS_V120];
  for(int i=0;i<MA_FILTER_PRESET_SLOTS_V120;i++)
  {
   if(FileIsEnding(h)){FileClose(h);reason=StringFormat("unexpected EOF at slot %02d",i+1);return false;}
   int slot=(int)FileReadNumber(h);if(slot!=i+1){FileClose(h);reason=StringFormat("slot order mismatch at %02d",i+1);return false;}
   SMA_CommonFilterConfig110 c;
   c.trading_time=(bool)FileReadNumber(h);c.news=(bool)FileReadNumber(h);c.fomc=(bool)FileReadNumber(h);c.nfp=(bool)FileReadNumber(h);c.cpi=(bool)FileReadNumber(h);c.month_end=(bool)FileReadNumber(h);c.month_start=(bool)FileReadNumber(h);c.quarter_end=(bool)FileReadNumber(h);c.year_end=(bool)FileReadNumber(h);c.rollover=(bool)FileReadNumber(h);c.friday=(bool)FileReadNumber(h);c.spread=(bool)FileReadNumber(h);c.volatility=(bool)FileReadNumber(h);
   c.start_hour=(int)FileReadNumber(h);c.start_minute=(int)FileReadNumber(h);c.end_hour=(int)FileReadNumber(h);c.end_minute=(int)FileReadNumber(h);
   c.news_before_min=(int)FileReadNumber(h);c.news_after_min=(int)FileReadNumber(h);c.fomc_before_hours=(int)FileReadNumber(h);c.fomc_after_hours=(int)FileReadNumber(h);c.nfp_before_min=(int)FileReadNumber(h);c.nfp_after_min=(int)FileReadNumber(h);c.cpi_before_min=(int)FileReadNumber(h);c.cpi_after_min=(int)FileReadNumber(h);
   c.month_end_trading_days=(int)FileReadNumber(h);c.month_start_trading_days=(int)FileReadNumber(h);c.quarter_end_trading_days=(int)FileReadNumber(h);c.year_end_trading_days=(int)FileReadNumber(h);
   c.rollover_before_min=(int)FileReadNumber(h);c.rollover_after_min=(int)FileReadNumber(h);c.friday_stop_hour=(int)FileReadNumber(h);c.friday_stop_minute=(int)FileReadNumber(h);
   c.max_spread_points=FileReadNumber(h);c.min_atr_points=FileReadNumber(h);c.max_atr_points=FileReadNumber(h);
   c.time_scope=(int)FileReadNumber(h);c.news_scope=(int)FileReadNumber(h);c.fomc_scope=(int)FileReadNumber(h);c.nfp_scope=(int)FileReadNumber(h);c.cpi_scope=(int)FileReadNumber(h);c.month_end_scope=(int)FileReadNumber(h);c.month_start_scope=(int)FileReadNumber(h);c.quarter_end_scope=(int)FileReadNumber(h);c.year_end_scope=(int)FileReadNumber(h);c.rollover_scope=(int)FileReadNumber(h);c.friday_scope=(int)FileReadNumber(h);c.spread_scope=(int)FileReadNumber(h);c.volatility_scope=(int)FileReadNumber(h);
   string vr="";if(!MAFilterValidate120(c,vr)){FileClose(h);reason=StringFormat("slot %02d invalid: %s",slot,vr);return false;}temp[i]=c;
  }
  FileClose(h);
  for(int i=0;i<MA_FILTER_PRESET_SLOTS_V120;i++)m_cfg[i]=temp[i];
  reason="";return true;
 }
};
#endif
