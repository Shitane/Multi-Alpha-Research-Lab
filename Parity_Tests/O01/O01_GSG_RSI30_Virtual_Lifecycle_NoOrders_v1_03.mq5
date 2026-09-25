//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Virtual_Lifecycle_NoOrders_v1_03.mq5              |
//| O01 virtual Entry/Grid/Exit lifecycle parity lab. NO ORDERS.     |
//+------------------------------------------------------------------+
#property strict
#property version "1.03"
#include "..\..\Include\O01\O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "..\..\Include\O01\O01_GSG_RSI30_Exit_Module_v1_00.mqh"

input int InpRSIPeriod=8;
input double InpRSILower=30.0,InpRSIUpper=70.0;
input int InpATR1Period=15,InpATR2Period=15;
input double InpATR1MinPoints=0.0,InpATR1MaxPoints=10000.0,InpATR2MinPoints=0.0,InpATR2MaxPoints=10000.0;
input bool InpUseServerSession=true;
input int InpStartHour=10,InpStartMinute=0,InpEndHour=14,InpEndMinute=0;
input double InpInitialLot=0.01,InpLotMultiplier=1.50,InpMaxLot=5.00,InpMaxTotalLotsPerSide=1.20;
input int InpMaxOrders=10,InpFixedDistancePoints=200,InpDynamicStartOrder=3,InpDynamicStartPoints=300;
input double InpDistanceMultiplier=1.20;
input bool InpOneOrderPerBar=true,InpPauseGridWhileTrailing=true;
input int InpVirtualSLPoints=1500;
input int InpSingleTrailStart=110,InpSingleTrailLock=60,InpSingleTrailDistance=50,InpSingleTrailStep=10;
input int InpBasketTrailStart=100,InpBasketTrailLock=50,InpBasketTrailDistance=50,InpBasketTrailStep=10;

struct VPos { double price,lot; datetime time,bar; };
VPos buy[],sell[];
SO01TrailState bt,st;
CO01EntryModule entry; CO01ExitModule exits;
int rh=INVALID_HANDLE,a1h=INVALID_HANDLE,a2h=INVALID_HANDLE;
ulong ticks=0,entries=0,grids=0,closes=0,single_trail=0,basket_trail=0,vsl=0,session_blocks=0;
datetime lastBuyBar=0,lastSellBar=0;

double B(const int h){double x[1]; return (CopyBuffer(h,0,0,1,x)==1?x[0]:EMPTY_VALUE);}
int C(VPos &p[]){return ArraySize(p);}
double Lots(VPos &p[]){double s=0; for(int i=0;i<C(p);i++)s+=p[i].lot; return s;}
double Avg(VPos &p[]){double pv=0,v=0; for(int i=0;i<C(p);i++){pv+=p[i].price*p[i].lot;v+=p[i].lot;} return v>0?pv/v:0;}
double LastPrice(VPos &p[]){return C(p)>0?p[C(p)-1].price:0;}
double LastLot(VPos &p[]){return C(p)>0?p[C(p)-1].lot:InpInitialLot;}
double NormLot(double x){double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);if(step<=0)step=.01;x=MathMin(InpMaxLot,x);return NormalizeDouble(MathRound(x/step)*step,2);}
double Dist(int n){if(n<InpDynamicStartOrder)return InpFixedDistancePoints;return InpDynamicStartPoints*MathPow(InpDistanceMultiplier,n-InpDynamicStartOrder);}
bool SessionOK(){if(!InpUseServerSession)return true;MqlDateTime d;TimeToStruct(TimeTradeServer(),d);if(d.day_of_week==0||d.day_of_week==6)return false;int m=d.hour*60+d.min,s=InpStartHour*60+InpStartMinute,e=InpEndHour*60+InpEndMinute;return s==e|| (s<e?(m>=s&&m<e):(m>=s||m<e));}
void Add(VPos &p[],double price,double lot){int n=C(p);ArrayResize(p,n+1);p[n].price=price;p[n].lot=lot;p[n].time=TimeCurrent();p[n].bar=iTime(_Symbol,_Period,0);}
void Clear(VPos &p[]){ArrayResize(p,0);}
string ExitName(ENUM_O01_EXIT_DECISION d){if(d==O01_EXIT_VIRTUAL_SL)return "VIRTUAL_SL";if(d==O01_EXIT_SINGLE_TRAILING)return "SINGLE_TRAILING";if(d==O01_EXIT_BASKET_TRAILING)return "BASKET_TRAILING";if(d==O01_EXIT_FIXED_TP)return "FIXED_TP";return "NONE";}

void LogOpen(string side,string tag,double price,double lot,int count){
 Print("[O01_VIRTUAL_OPEN] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," side=",side," tag=",tag,
 " count=",count," lot=",DoubleToString(lot,2)," px=",DoubleToString(price,_Digits)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
void LogExit(string side,ENUM_O01_EXIT_DECISION d,int count,double avg,double px,double move){
 Print("[O01_VIRTUAL_EXIT] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," side=",side," reason=",ExitName(d),
 " count=",count," avg=",DoubleToString(avg,_Digits)," px=",DoubleToString(px,_Digits)," move_pts=",DoubleToString(move,1),
 " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}

bool Manage(bool isBuy,VPos &p[],SO01TrailState &ts,MqlTick &t){
 int n=C(p); if(n<=0){ts.active=false;ts.peak_pts=0;ts.stop_pts=0;ts.position_count=0;return false;}
 double avg=Avg(p),px=isBuy?t.bid:t.ask,move=isBuy?(px-avg)/_Point:(avg-px)/_Point;
 SO01ExitConfig c;c.trailing=true;c.tp_points=(n==1?110:100);c.sl_points=InpVirtualSLPoints;
 c.trail_start=(n==1?InpSingleTrailStart:InpBasketTrailStart);c.trail_lock=(n==1?InpSingleTrailLock:InpBasketTrailLock);
 c.trail_distance=(n==1?InpSingleTrailDistance:InpBasketTrailDistance);c.trail_step=(n==1?InpSingleTrailStep:InpBasketTrailStep);
 ENUM_O01_EXIT_DECISION d=exits.Evaluate(isBuy,n,move,c,ts);
 if(d!=O01_EXIT_NONE){LogExit(isBuy?"BUY":"SELL",d,n,avg,px,move);closes++;if(d==O01_EXIT_SINGLE_TRAILING)single_trail++;if(d==O01_EXIT_BASKET_TRAILING)basket_trail++;if(d==O01_EXIT_VIRTUAL_SL)vsl++;Clear(p);ts.active=false;ts.peak_pts=0;ts.stop_pts=0;ts.position_count=0;return true;}
 if(n>=InpMaxOrders || (InpPauseGridWhileTrailing&&ts.active))return false;
 datetime bar=iTime(_Symbol,_Period,0); if(InpOneOrderPerBar && (isBuy?lastBuyBar:lastSellBar)==bar)return false;
 double lp=LastPrice(p),distance=Dist(n+1); bool met=isBuy?(t.ask<=lp-distance*_Point):(t.bid>=lp+distance*_Point);if(!met)return false;
 double lot=NormLot(LastLot(p)*InpLotMultiplier);if(InpMaxTotalLotsPerSide>0&&Lots(p)+lot>InpMaxTotalLotsPerSide+1e-9)return false;
 double op=isBuy?t.ask:t.bid;Add(p,op,lot);if(isBuy)lastBuyBar=bar;else lastSellBar=bar;grids++;LogOpen(isBuy?"BUY":"SELL","GRID #"+IntegerToString(n+1),op,lot,C(p));return false;
}

int OnInit(){
 rh=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);a1h=iATR(_Symbol,_Period,InpATR1Period);a2h=iATR(_Symbol,_Period,InpATR2Period);
 if(rh==INVALID_HANDLE||a1h==INVALID_HANDLE||a2h==INVALID_HANDLE)return INIT_FAILED;
 Print("[O01_VIRTUAL_LIFECYCLE_START] version=1.03 session=SERVER ",InpStartHour,":",InpStartMinute,"-",InpEndHour,":",InpEndMinute,
 " NO_ORDERS=1 VIRTUAL_NOT_FILL=1 NEWS_ADAPTER=PENDING DD_ADAPTER=PENDING SPREAD_LIMIT=OFF");return INIT_SUCCEEDED;}
void OnDeinit(const int reason){IndicatorRelease(rh);IndicatorRelease(a1h);IndicatorRelease(a2h);
 Print("[O01_VIRTUAL_SUMMARY] ticks=",ticks," entries=",entries," grids=",grids," closes=",closes," single_trail=",single_trail,
 " basket_trail=",basket_trail," virtual_sl=",vsl," buy_open=",C(buy)," sell_open=",C(sell)," session_blocks=",session_blocks,
 " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}

void OnTick(){
 ticks++;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;
 // Source-faithful ordering: manage existing sides before evaluating new cycles.
 Manage(true,buy,bt,t);Manage(false,sell,st,t);
 double r=B(rh),a1=B(a1h),a2=B(a2h);if(r==EMPTY_VALUE||a1==EMPTY_VALUE||a2==EMPTY_VALUE)return;
 bool time=SessionOK();if(!time){if(r<InpRSILower||r>InpRSIUpper)session_blocks++;return;}
 double p1=a1/_Point,p2=a2/_Point;bool filt=p1>=InpATR1MinPoints&&p1<=InpATR1MaxPoints&&p2>=InpATR2MinPoints&&p2<=InpATR2MaxPoints;if(!filt)return;
 SO01EntryConfig c;c.new_cycles=true;c.trade_buy=true;c.trade_sell=true;c.rsi_lower=InpRSILower;c.rsi_upper=InpRSIUpper;
 SO01EntryContext x;x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=C(buy);x.sell_count=C(sell);x.rsi=r;
 ENUM_O01_ENTRY_SIGNAL s=entry.Evaluate(c,x);datetime bar=iTime(_Symbol,_Period,0);
 if(s==O01_ENTRY_BUY && (!InpOneOrderPerBar||lastBuyBar!=bar)){Add(buy,t.ask,NormLot(InpInitialLot));lastBuyBar=bar;entries++;LogOpen("BUY","INITIAL",t.ask,NormLot(InpInitialLot),C(buy));}
 if(s==O01_ENTRY_SELL&& (!InpOneOrderPerBar||lastSellBar!=bar)){Add(sell,t.bid,NormLot(InpInitialLot));lastSellBar=bar;entries++;LogOpen("SELL","INITIAL",t.bid,NormLot(InpInitialLot),C(sell));}
}
