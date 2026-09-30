//+------------------------------------------------------------------+
//| MultiAlpha_Common_Filter_v1_00.mqh                              |
//| Slot-local common Trade Permission Gate. NO broker operations.   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_COMMON_FILTER_V1_00_MQH
#define MULTIALPHA_COMMON_FILTER_V1_00_MQH
#define MA_FILTER_SLOT_COUNT_V100 50
enum ENUM_MA_FILTER_SCOPE_V100 { MA_FILTER_NEW_V100=1,MA_FILTER_ADD_V100=2,MA_FILTER_BOTH_V100=3 };
struct SMA_CommonFilterConfig100
{
 bool trading_time,news,fomc,nfp,cpi,month_end,month_start,quarter_end;
 int start_hour,start_minute,end_hour,end_minute;
 int fomc_before_hours,fomc_after_hours;
 int month_end_trading_days,month_start_trading_days;
 int time_scope,news_scope,fomc_scope,nfp_scope,cpi_scope,month_end_scope,month_start_scope,quarter_end_scope;
};
struct SMA_FilterExternalState100
{
 bool news_block,fomc_block,nfp_block,cpi_block,month_end_block,month_start_block,quarter_end_block;
};
struct SMA_FilterPermission100 { bool new_entry,add_entry; string new_reason,add_reason; };
void MAFilterDefaults100(SMA_CommonFilterConfig100 &c)
{
 c.trading_time=false;c.news=false;c.fomc=false;c.nfp=false;c.cpi=false;c.month_end=false;c.month_start=false;c.quarter_end=false;
 c.start_hour=10;c.start_minute=0;c.end_hour=14;c.end_minute=0;c.fomc_before_hours=12;c.fomc_after_hours=12;c.month_end_trading_days=1;c.month_start_trading_days=1;
 c.time_scope=MA_FILTER_BOTH_V100;c.news_scope=MA_FILTER_BOTH_V100;c.fomc_scope=MA_FILTER_BOTH_V100;c.nfp_scope=MA_FILTER_BOTH_V100;c.cpi_scope=MA_FILTER_BOTH_V100;c.month_end_scope=MA_FILTER_BOTH_V100;c.month_start_scope=MA_FILTER_BOTH_V100;c.quarter_end_scope=MA_FILTER_BOTH_V100;
}
bool MAFilterScopeBlocks100(const int scope,const bool add){return ((scope&(add?MA_FILTER_ADD_V100:MA_FILTER_NEW_V100))!=0);}
bool MAFilterTimeInside100(const SMA_CommonFilterConfig100 &c,const datetime now)
{
 MqlDateTime d;TimeToStruct(now,d);int m=d.hour*60+d.min, a=c.start_hour*60+c.start_minute,b=c.end_hour*60+c.end_minute;
 if(a==b)return true;return (a<b ? (m>=a&&m<b) : (m>=a||m<b));
}
void MAFilterBlock100(bool &allow,string &why,const bool enabled,const bool blocked,const int scope,const bool add,const string reason)
{if(allow&&enabled&&blocked&&MAFilterScopeBlocks100(scope,add)){allow=false;why=reason;}}
SMA_FilterPermission100 MAFilterEvaluate100(const SMA_CommonFilterConfig100 &c,const SMA_FilterExternalState100 &x,const datetime now)
{
 SMA_FilterPermission100 p;p.new_entry=true;p.add_entry=true;p.new_reason="ALLOW";p.add_reason="ALLOW";
 bool time_block=!MAFilterTimeInside100(c,now);
 for(int k=0;k<2;k++){bool add=(k==1);bool allow=true;string why="ALLOW";
  MAFilterBlock100(allow,why,c.trading_time,time_block,c.time_scope,add,"TRADING TIME");
  MAFilterBlock100(allow,why,c.news,x.news_block,c.news_scope,add,"NEWS");
  MAFilterBlock100(allow,why,c.fomc,x.fomc_block,c.fomc_scope,add,"FOMC");
  MAFilterBlock100(allow,why,c.nfp,x.nfp_block,c.nfp_scope,add,"NFP");
  MAFilterBlock100(allow,why,c.cpi,x.cpi_block,c.cpi_scope,add,"CPI");
  MAFilterBlock100(allow,why,c.month_end,x.month_end_block,c.month_end_scope,add,"MONTH END");
  MAFilterBlock100(allow,why,c.month_start,x.month_start_block,c.month_start_scope,add,"MONTH START");
  MAFilterBlock100(allow,why,c.quarter_end,x.quarter_end_block,c.quarter_end_scope,add,"QUARTER END");
  if(add){p.add_entry=allow;p.add_reason=why;}else{p.new_entry=allow;p.new_reason=why;}
 }return p;
}
class CMultiAlphaFilterStore100
{
 SMA_CommonFilterConfig100 c[MA_FILTER_SLOT_COUNT_V100];
public:
 void Init(){for(int i=0;i<MA_FILTER_SLOT_COUNT_V100;i++)MAFilterDefaults100(c[i]);}
 SMA_CommonFilterConfig100 Get(const int slot)const{return c[MathMax(1,MathMin(MA_FILTER_SLOT_COUNT_V100,slot))-1];}
 void Set(const int slot,const SMA_CommonFilterConfig100 &v){if(slot>=1&&slot<=MA_FILTER_SLOT_COUNT_V100)c[slot-1]=v;}
};
#endif
