//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Core_Integration_NoOrders_v1_00.mq5              |
//| Core-interface integration regression against SPLIT105. NO ORDERS.     |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\..\Include\O01\O01_GSG_RSI30_Core_Interface_v1_00.mqh"

enum O01_TIME_MODE { O01_AUTO_GMT=0,O01_SERVER_TIME=1,O01_CUSTOM_GMT=2 };
input int InpRSIPeriod=8; input double InpRSILower=30.0,InpRSIUpper=70.0;
input int InpATR1Period=15,InpATR2Period=15; input ENUM_TIMEFRAMES InpATR2Timeframe=PERIOD_CURRENT;
input double InpATR1MinPoints=0,InpATR1MaxPoints=10000,InpATR2MinPoints=0,InpATR2MaxPoints=10000;
input O01_TIME_MODE InpTimeMode=O01_AUTO_GMT;
input int InpAutoGMTStartHour=7,InpAutoGMTStartMinute=0,InpAutoGMTEndHour=11,InpAutoGMTEndMinute=0;
input int InpServerStartHour=10,InpServerStartMinute=0,InpServerEndHour=14,InpServerEndMinute=0;
input int InpCustomGMTStartHour=7,InpCustomGMTStartMinute=0,InpCustomGMTEndHour=11,InpCustomGMTEndMinute=0;
input bool InpUseFixedTesterGMTOffset=true; input double InpFixedTesterGMTOffsetHours=3.0;
input bool InpTradeMonday=true,InpTradeTuesday=true,InpTradeWednesday=true,InpTradeThursday=true,InpTradeFriday=true;
input bool InpBlockMondayWindow=false; input int InpMondayBlockStartHour=10,InpMondayBlockStartMinute=30,InpMondayBlockEndHour=11,InpMondayBlockEndMinute=0;
input bool InpBlockFridayWindow=false; input int InpFridayBlockStartHour=10,InpFridayBlockStartMinute=30,InpFridayBlockEndHour=11,InpFridayBlockEndMinute=30;
input int InpMaxSpreadPoints=0;
input bool InpUseNewsGateAdapter=false; input bool InpNewsBlocked=false; input bool InpNewsManageOnly=true;
input double InpInitialLot=.01,InpLotMultiplier=1.5,InpMaxLot=5,InpMaxTotalLotsPerSide=1.2;
input int InpMaxOrders=10,InpFixedDistancePoints=200,InpDynamicStartOrder=3,InpDynamicStartPoints=300; input double InpDistanceMultiplier=1.2;
input bool InpOneOrderPerBar=true,InpPauseGridWhileTrailing=true,InpAllowGridOutsideTime=true;
input int InpVirtualSLPoints=1500,InpSingleTrailStart=110,InpSingleTrailLock=60,InpSingleTrailDistance=50,InpSingleTrailStep=10;
input int InpBasketTrailStart=100,InpBasketTrailLock=50,InpBasketTrailDistance=50,InpBasketTrailStep=10;

struct VPos{double price,lot;datetime time,bar;}; VPos buy[],sell[];
SO01TrailState bt,st; CO01CoreInterface core;
int rh=INVALID_HANDLE,a1h=INVALID_HANDLE,a2h=INVALID_HANDLE; datetime lastBuyBar=0,lastSellBar=0;
ulong ticks=0,entries=0,grids=0,closes=0,singleTrail=0,basketTrail=0,vsl=0,timeBlocks=0,newsBlocks=0,spreadBlocks=0,filterBlocks=0;

double B(int h){double x[1];return CopyBuffer(h,0,0,1,x)==1?x[0]:EMPTY_VALUE;}
int C(VPos &p[]){return ArraySize(p);} double Lots(VPos &p[]){double s=0;for(int i=0;i<C(p);i++)s+=p[i].lot;return s;}
double Avg(VPos &p[]){double pv=0,v=0;for(int i=0;i<C(p);i++){pv+=p[i].price*p[i].lot;v+=p[i].lot;}return v>0?pv/v:0;}
double LastPrice(VPos &p[]){return C(p)?p[C(p)-1].price:0;} double LastLot(VPos &p[]){return C(p)?p[C(p)-1].lot:InpInitialLot;}
double NormLot(double x){double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX),stp=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);if(stp<=0)stp=.01;x=MathMax(mn,MathMin(mx,MathMin(InpMaxLot,x)));return NormalizeDouble(MathRound(x/stp)*stp,2);}
double Dist(int n){if(n<InpDynamicStartOrder)return InpFixedDistancePoints;return InpDynamicStartPoints*MathPow(InpDistanceMultiplier,n-InpDynamicStartOrder);}
int NM(int m){while(m<0)m+=1440;while(m>=1440)m-=1440;return m;} bool Win(int m,int s,int e){return s==e||(s<e?(m>=s&&m<e):(m>=s||m<e));}
bool DayOK(int d){if(d==1)return InpTradeMonday;if(d==2)return InpTradeTuesday;if(d==3)return InpTradeWednesday;if(d==4)return InpTradeThursday;if(d==5)return InpTradeFriday;return false;}
double Offset(){if(InpUseFixedTesterGMTOffset)return InpFixedTesterGMTOffsetHours;datetime s=TimeTradeServer(),g=TimeGMT();if(s<=0||g<=0)return 0;return MathRound(((double)(s-g)/3600.0)*4.0)/4.0;}
void Window(int &s,int &e){if(InpTimeMode==O01_SERVER_TIME){s=NM(InpServerStartHour*60+InpServerStartMinute);e=NM(InpServerEndHour*60+InpServerEndMinute);return;}int gs=(InpTimeMode==O01_CUSTOM_GMT?InpCustomGMTStartHour:InpAutoGMTStartHour)*60+(InpTimeMode==O01_CUSTOM_GMT?InpCustomGMTStartMinute:InpAutoGMTStartMinute);int ge=(InpTimeMode==O01_CUSTOM_GMT?InpCustomGMTEndHour:InpAutoGMTEndHour)*60+(InpTimeMode==O01_CUSTOM_GMT?InpCustomGMTEndMinute:InpAutoGMTEndMinute);int sh=(int)MathRound(Offset()*60);s=NM(gs+sh);e=NM(ge+sh);}
bool TimeOK(){MqlDateTime d;TimeToStruct(TimeTradeServer(),d);if(!DayOK(d.day_of_week))return false;int m=d.hour*60+d.min,s,e;Window(s,e);if(!Win(m,s,e))return false;if(d.day_of_week==1&&InpBlockMondayWindow&&Win(m,InpMondayBlockStartHour*60+InpMondayBlockStartMinute,InpMondayBlockEndHour*60+InpMondayBlockEndMinute))return false;if(d.day_of_week==5&&InpBlockFridayWindow&&Win(m,InpFridayBlockStartHour*60+InpFridayBlockStartMinute,InpFridayBlockEndHour*60+InpFridayBlockEndMinute))return false;return true;}
bool SpreadOK(){if(InpMaxSpreadPoints<=0)return true;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return false;return (t.ask-t.bid)/_Point<=InpMaxSpreadPoints;}
bool NewsNewBlocked(){return InpUseNewsGateAdapter&&InpNewsBlocked;} bool NewsGridBlocked(){return InpUseNewsGateAdapter&&InpNewsBlocked&&InpNewsManageOnly;}
void Add(VPos &p[],double px,double lot){int n=C(p);ArrayResize(p,n+1);p[n].price=px;p[n].lot=lot;p[n].time=TimeCurrent();p[n].bar=iTime(_Symbol,_Period,0);} void Clear(VPos &p[]){ArrayResize(p,0);}
string EN(ENUM_O01_EXIT_DECISION d){if(d==O01_EXIT_VIRTUAL_SL)return "VIRTUAL_SL";if(d==O01_EXIT_SINGLE_TRAILING)return "SINGLE_TRAILING";if(d==O01_EXIT_BASKET_TRAILING)return "BASKET_TRAILING";if(d==O01_EXIT_FIXED_TP)return "FIXED_TP";return "NONE";}
void LO(string side,string tag,double px,double lot,int n){Print("[O01_CORE100_OPEN] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," side=",side," tag=",tag," count=",n," lot=",DoubleToString(lot,2)," px=",DoubleToString(px,_Digits)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
void LX(string side,ENUM_O01_EXIT_DECISION d,int n,double avg,double px,double mv){Print("[O01_CORE100_EXIT] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," side=",side," reason=",EN(d)," count=",n," avg=",DoubleToString(avg,_Digits)," px=",DoubleToString(px,_Digits)," move_pts=",DoubleToString(mv,1)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}

void Manage(bool isBuy,VPos &p[],SO01TrailState &ts,MqlTick &t){
 int n=C(p);if(n<=0){ts.active=false;ts.peak_pts=0;ts.stop_pts=0;ts.position_count=0;return;}double avg=Avg(p),px=isBuy?t.bid:t.ask,mv=isBuy?(px-avg)/_Point:(avg-px)/_Point;
 SO01ExitConfig c;c.trailing=true;c.tp_points=n==1?110:100;c.sl_points=InpVirtualSLPoints;c.trail_start=n==1?InpSingleTrailStart:InpBasketTrailStart;c.trail_lock=n==1?InpSingleTrailLock:InpBasketTrailLock;c.trail_distance=n==1?InpSingleTrailDistance:InpBasketTrailDistance;c.trail_step=n==1?InpSingleTrailStep:InpBasketTrailStep;
 ENUM_O01_EXIT_DECISION d=core.EvaluateExit(isBuy,n,mv,c,ts);if(d!=O01_EXIT_NONE){LX(isBuy?"BUY":"SELL",d,n,avg,px,mv);closes++;if(d==O01_EXIT_SINGLE_TRAILING)singleTrail++;if(d==O01_EXIT_BASKET_TRAILING)basketTrail++;if(d==O01_EXIT_VIRTUAL_SL)vsl++;Clear(p);ts.active=false;ts.peak_pts=0;ts.stop_pts=0;ts.position_count=0;return;}
 if(n>=InpMaxOrders||(InpPauseGridWhileTrailing&&ts.active))return;if(!InpAllowGridOutsideTime&&!TimeOK())return;if(NewsGridBlocked()||!SpreadOK())return;datetime bar=iTime(_Symbol,_Period,0);if(InpOneOrderPerBar&&(isBuy?lastBuyBar:lastSellBar)==bar)return;
 double lp=LastPrice(p),ds=Dist(n+1);bool met=isBuy?t.ask<=lp-ds*_Point:t.bid>=lp+ds*_Point;if(!met)return;double lot=NormLot(LastLot(p)*InpLotMultiplier);if(InpMaxTotalLotsPerSide>0&&Lots(p)+lot>InpMaxTotalLotsPerSide+1e-9)return;double op=isBuy?t.ask:t.bid;Add(p,op,lot);if(isBuy)lastBuyBar=bar;else lastSellBar=bar;grids++;LO(isBuy?"BUY":"SELL","GRID #"+IntegerToString(n+1),op,lot,C(p));
}
int OnInit(){rh=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);a1h=iATR(_Symbol,_Period,InpATR1Period);a2h=iATR(_Symbol,InpATR2Timeframe,InpATR2Period);if(rh==INVALID_HANDLE||a1h==INVALID_HANDLE||a2h==INVALID_HANDLE)return INIT_FAILED;int s,e;Window(s,e);Print("[O01_CORE100_START] BASELINE=O01_SPLIT105 INTERFACE=1.00 effective_server=",s/60,":",s%60,"-",e/60,":",e%60," offset=",DoubleToString(Offset(),2)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");return INIT_SUCCEEDED;}
void OnDeinit(const int r){IndicatorRelease(rh);IndicatorRelease(a1h);IndicatorRelease(a2h);Print("[O01_CORE100_SUMMARY] ticks=",ticks," entries=",entries," grids=",grids," closes=",closes," single_trail=",singleTrail," basket_trail=",basketTrail," virtual_sl=",vsl," buy_open=",C(buy)," sell_open=",C(sell)," time_blocks=",timeBlocks," news_blocks=",newsBlocks," spread_blocks=",spreadBlocks," filter_blocks=",filterBlocks," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
void OnTick(){
 ticks++;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;Manage(true,buy,bt,t);Manage(false,sell,st,t);
 double r=B(rh),a1=B(a1h),a2=B(a2h);if(r==EMPTY_VALUE||a1==EMPTY_VALUE||a2==EMPTY_VALUE)return;
 if(!TimeOK()){if(r<InpRSILower||r>InpRSIUpper)timeBlocks++;return;}if(NewsNewBlocked()){newsBlocks++;return;}if(!SpreadOK()){spreadBlocks++;return;}
 double p1=a1/_Point,p2=a2/_Point;if(!(p1>=InpATR1MinPoints&&p1<=InpATR1MaxPoints&&p2>=InpATR2MinPoints&&p2<=InpATR2MaxPoints)){filterBlocks++;return;}
 SO01EntryConfig c;c.new_cycles=true;c.trade_buy=true;c.trade_sell=true;c.rsi_lower=InpRSILower;c.rsi_upper=InpRSIUpper;SO01EntryContext x;x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=C(buy);x.sell_count=C(sell);x.rsi=r;ENUM_O01_ENTRY_SIGNAL s=core.EvaluateEntry(c,x);datetime bar=iTime(_Symbol,_Period,0);
 if(s==O01_ENTRY_BUY&&(!InpOneOrderPerBar||lastBuyBar!=bar)){double l=NormLot(InpInitialLot);Add(buy,t.ask,l);lastBuyBar=bar;entries++;LO("BUY","INITIAL",t.ask,l,C(buy));}
 if(s==O01_ENTRY_SELL&&(!InpOneOrderPerBar||lastSellBar!=bar)){double l=NormLot(InpInitialLot);Add(sell,t.bid,l);lastSellBar=bar;entries++;LO("SELL","INITIAL",t.bid,l,C(sell));}
}