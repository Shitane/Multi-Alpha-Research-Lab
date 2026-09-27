//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Full_NoOrders_Adapter_v1_00.mqh                  |
//| Frozen whole-path FULL adapter derived from REF105 observer.     |
//| IMPORTANT: NO broker orders. Virtual positions are NOT fills.    |
//+------------------------------------------------------------------+
#ifndef O01_GSG_RSI30_FULL_NOORDERS_ADAPTER_V1_00_MQH
#define O01_GSG_RSI30_FULL_NOORDERS_ADAPTER_V1_00_MQH

enum O01_FULL_TIME_MODE { O01_FULL_AUTO_GMT=0,O01_FULL_SERVER_TIME=1,O01_FULL_CUSTOM_GMT=2 };

struct SO01FullNoOrdersConfig100
{
 int rsi_period; double rsi_lower,rsi_upper;
 int atr1_period,atr2_period; ENUM_TIMEFRAMES atr2_timeframe;
 double atr1_min_points,atr1_max_points,atr2_min_points,atr2_max_points;
 int time_mode;
 int auto_start_h,auto_start_m,auto_end_h,auto_end_m;
 int server_start_h,server_start_m,server_end_h,server_end_m;
 int custom_start_h,custom_start_m,custom_end_h,custom_end_m;
 bool fixed_tester_offset; double fixed_tester_offset_hours;
 bool mon,tue,wed,thu,fri;
 bool block_mon; int mon_bs_h,mon_bs_m,mon_be_h,mon_be_m;
 bool block_fri; int fri_bs_h,fri_bs_m,fri_be_h,fri_be_m;
 int max_spread_points;
 bool use_news_gate,news_blocked,news_manage_only;
 double initial_lot,lot_multiplier,max_lot,max_total_lots_per_side;
 int max_orders,fixed_distance_points,dynamic_start_order,dynamic_start_points; double distance_multiplier;
 bool one_order_per_bar,pause_grid_while_trailing,allow_grid_outside_time;
 int virtual_sl_points,single_trail_start,single_trail_lock,single_trail_distance,single_trail_step;
 int basket_trail_start,basket_trail_lock,basket_trail_distance,basket_trail_step;
};

struct SO01FullVPos100 { double price,lot; datetime time,bar; };
struct SO01FullTrail100 { bool active; double peak_pts,stop_pts; int position_count; };

class CO01FullNoOrdersAdapter100
{
private:
 SO01FullNoOrdersConfig100 c;
 SO01FullVPos100 buy[],sell[];
 SO01FullTrail100 bt,st;
 int rh,a1h,a2h; datetime lastBuyBar,lastSellBar;
 ulong ticks,entries,grids,closes,singleTrail,basketTrail,vsl,timeBlocks,newsBlocks,spreadBlocks,filterBlocks;

 double B(const int h){double x[1];return CopyBuffer(h,0,0,1,x)==1?x[0]:EMPTY_VALUE;}
 int C(SO01FullVPos100 &p[]){return ArraySize(p);}
 double Lots(SO01FullVPos100 &p[]){double s=0;for(int i=0;i<C(p);i++)s+=p[i].lot;return s;}
 double Avg(SO01FullVPos100 &p[]){double pv=0,v=0;for(int i=0;i<C(p);i++){pv+=p[i].price*p[i].lot;v+=p[i].lot;}return v>0?pv/v:0;}
 double LastPrice(SO01FullVPos100 &p[]){return C(p)?p[C(p)-1].price:0;}
 double LastLot(SO01FullVPos100 &p[]){return C(p)?p[C(p)-1].lot:c.initial_lot;}
 double NormLot(double x){double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX),stp=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);if(stp<=0)stp=.01;x=MathMax(mn,MathMin(mx,MathMin(c.max_lot,x)));return NormalizeDouble(MathRound(x/stp)*stp,2);}
 double Dist(const int n){if(n<c.dynamic_start_order)return c.fixed_distance_points;return c.dynamic_start_points*MathPow(c.distance_multiplier,n-c.dynamic_start_order);}
 int NM(int m){while(m<0)m+=1440;while(m>=1440)m-=1440;return m;}
 bool Win(const int m,const int s,const int e){return s==e||(s<e?(m>=s&&m<e):(m>=s||m<e));}
 bool DayOK(const int d){if(d==1)return c.mon;if(d==2)return c.tue;if(d==3)return c.wed;if(d==4)return c.thu;if(d==5)return c.fri;return false;}
 double Offset(){if(c.fixed_tester_offset)return c.fixed_tester_offset_hours;datetime s=TimeTradeServer(),g=TimeGMT();if(s<=0||g<=0)return 0;return MathRound(((double)(s-g)/3600.0)*4.0)/4.0;}
 void Window(int &s,int &e){if(c.time_mode==O01_FULL_SERVER_TIME){s=NM(c.server_start_h*60+c.server_start_m);e=NM(c.server_end_h*60+c.server_end_m);return;}int gs=(c.time_mode==O01_FULL_CUSTOM_GMT?c.custom_start_h:c.auto_start_h)*60+(c.time_mode==O01_FULL_CUSTOM_GMT?c.custom_start_m:c.auto_start_m);int ge=(c.time_mode==O01_FULL_CUSTOM_GMT?c.custom_end_h:c.auto_end_h)*60+(c.time_mode==O01_FULL_CUSTOM_GMT?c.custom_end_m:c.auto_end_m);int sh=(int)MathRound(Offset()*60);s=NM(gs+sh);e=NM(ge+sh);}
 bool TimeOK(){MqlDateTime d;TimeToStruct(TimeTradeServer(),d);if(!DayOK(d.day_of_week))return false;int m=d.hour*60+d.min,s,e;Window(s,e);if(!Win(m,s,e))return false;if(d.day_of_week==1&&c.block_mon&&Win(m,c.mon_bs_h*60+c.mon_bs_m,c.mon_be_h*60+c.mon_be_m))return false;if(d.day_of_week==5&&c.block_fri&&Win(m,c.fri_bs_h*60+c.fri_bs_m,c.fri_be_h*60+c.fri_be_m))return false;return true;}
 bool SpreadOK(){if(c.max_spread_points<=0)return true;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return false;return (t.ask-t.bid)/_Point<=c.max_spread_points;}
 bool NewsNewBlocked(){return c.use_news_gate&&c.news_blocked;}
 bool NewsGridBlocked(){return c.use_news_gate&&c.news_blocked&&c.news_manage_only;}
 void Add(SO01FullVPos100 &p[],double px,double lot){int n=C(p);ArrayResize(p,n+1);p[n].price=px;p[n].lot=lot;p[n].time=TimeCurrent();p[n].bar=iTime(_Symbol,_Period,0);}
 void Clear(SO01FullVPos100 &p[]){ArrayResize(p,0);}
 void LO(string side,string tag,double px,double lot,int n){Print("[O01_FULL100_OPEN] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," side=",side," tag=",tag," count=",n," lot=",DoubleToString(lot,2)," px=",DoubleToString(px,_Digits)," STRUCTURE=FULL NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
 void LX(string side,string reason,int n,double avg,double px,double mv){Print("[O01_FULL100_EXIT] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," side=",side," reason=",reason," count=",n," avg=",DoubleToString(avg,_Digits)," px=",DoubleToString(px,_Digits)," move_pts=",DoubleToString(mv,1)," STRUCTURE=FULL NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
 string RefExit(int n,double mv,SO01FullTrail100 &ts){int sl=c.virtual_sl_points,start=n==1?c.single_trail_start:c.basket_trail_start,lock=n==1?c.single_trail_lock:c.basket_trail_lock,dist=n==1?c.single_trail_distance:c.basket_trail_distance,step=n==1?c.single_trail_step:c.basket_trail_step;if(sl>0&&mv<=-(double)sl)return "VIRTUAL_SL";if(ts.active&&ts.position_count!=n){ts.active=false;ts.peak_pts=0;ts.stop_pts=0;}if(!ts.active){if(start<=0||mv<(double)start){ts.position_count=n;return "NONE";}ts.active=true;ts.peak_pts=mv;ts.stop_pts=MathMax((double)lock,ts.peak_pts-(double)dist);ts.position_count=n;}else if(mv>ts.peak_pts&&(step<=0||mv-ts.peak_pts>=(double)step)){ts.peak_pts=mv;ts.stop_pts=MathMax(ts.stop_pts,MathMax((double)lock,ts.peak_pts-(double)dist));}if(ts.active&&mv<=ts.stop_pts)return n==1?"SINGLE_TRAILING":"BASKET_TRAILING";return "NONE";}
 void Manage(bool isBuy,SO01FullVPos100 &p[],SO01FullTrail100 &ts,MqlTick &t){int n=C(p);if(n<=0){ts.active=false;ts.peak_pts=0;ts.stop_pts=0;ts.position_count=0;return;}double avg=Avg(p),px=isBuy?t.bid:t.ask,mv=isBuy?(px-avg)/_Point:(avg-px)/_Point;string d=RefExit(n,mv,ts);if(d!="NONE"){LX(isBuy?"BUY":"SELL",d,n,avg,px,mv);closes++;if(d=="SINGLE_TRAILING")singleTrail++;if(d=="BASKET_TRAILING")basketTrail++;if(d=="VIRTUAL_SL")vsl++;Clear(p);ts.active=false;ts.peak_pts=0;ts.stop_pts=0;ts.position_count=0;return;}if(n>=c.max_orders||(c.pause_grid_while_trailing&&ts.active))return;if(!c.allow_grid_outside_time&&!TimeOK())return;if(NewsGridBlocked()||!SpreadOK())return;datetime bar=iTime(_Symbol,_Period,0);if(c.one_order_per_bar&&(isBuy?lastBuyBar:lastSellBar)==bar)return;double lp=LastPrice(p),ds=Dist(n+1);bool met=isBuy?t.ask<=lp-ds*_Point:t.bid>=lp+ds*_Point;if(!met)return;double lot=NormLot(LastLot(p)*c.lot_multiplier);if(c.max_total_lots_per_side>0&&Lots(p)+lot>c.max_total_lots_per_side+1e-9)return;double op=isBuy?t.ask:t.bid;Add(p,op,lot);if(isBuy)lastBuyBar=bar;else lastSellBar=bar;grids++;LO(isBuy?"BUY":"SELL","GRID #"+IntegerToString(n+1),op,lot,C(p));}

public:
 CO01FullNoOrdersAdapter100(){rh=INVALID_HANDLE;a1h=INVALID_HANDLE;a2h=INVALID_HANDLE;lastBuyBar=0;lastSellBar=0;ticks=entries=grids=closes=singleTrail=basketTrail=vsl=timeBlocks=newsBlocks=spreadBlocks=filterBlocks=0;}
 int Init(const SO01FullNoOrdersConfig100 &cfg){c=cfg;rh=iRSI(_Symbol,_Period,c.rsi_period,PRICE_CLOSE);a1h=iATR(_Symbol,_Period,c.atr1_period);a2h=iATR(_Symbol,c.atr2_timeframe,c.atr2_period);if(rh==INVALID_HANDLE||a1h==INVALID_HANDLE||a2h==INVALID_HANDLE)return INIT_FAILED;int s,e;Window(s,e);Print("[O01_FULL100_START] SOURCE=REF105_FROZEN_WHOLE_PATH effective_server=",s/60,":",s%60,"-",e/60,":",e%60," offset=",DoubleToString(Offset(),2)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");return INIT_SUCCEEDED;}
 void Deinit(){if(rh!=INVALID_HANDLE)IndicatorRelease(rh);if(a1h!=INVALID_HANDLE)IndicatorRelease(a1h);if(a2h!=INVALID_HANDLE)IndicatorRelease(a2h);Print("[O01_FULL100_SUMMARY] ticks=",ticks," entries=",entries," grids=",grids," closes=",closes," single_trail=",singleTrail," basket_trail=",basketTrail," virtual_sl=",vsl," buy_open=",C(buy)," sell_open=",C(sell)," time_blocks=",timeBlocks," news_blocks=",newsBlocks," spread_blocks=",spreadBlocks," filter_blocks=",filterBlocks," STRUCTURE=FULL NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
 void Tick(){ticks++;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;Manage(true,buy,bt,t);Manage(false,sell,st,t);double r=B(rh),a1=B(a1h),a2=B(a2h);if(r==EMPTY_VALUE||a1==EMPTY_VALUE||a2==EMPTY_VALUE)return;if(!TimeOK()){if(r<c.rsi_lower||r>c.rsi_upper)timeBlocks++;return;}if(NewsNewBlocked()){newsBlocks++;return;}if(!SpreadOK()){spreadBlocks++;return;}double p1=a1/_Point,p2=a2/_Point;if(!(p1>=c.atr1_min_points&&p1<=c.atr1_max_points&&p2>=c.atr2_min_points&&p2<=c.atr2_max_points)){filterBlocks++;return;}int sig=0;if(C(buy)==0&&r<c.rsi_lower)sig=1;else if(C(sell)==0&&r>c.rsi_upper)sig=-1;datetime bar=iTime(_Symbol,_Period,0);if(sig==1&&(!c.one_order_per_bar||lastBuyBar!=bar)){double l=NormLot(c.initial_lot);Add(buy,t.ask,l);lastBuyBar=bar;entries++;LO("BUY","INITIAL",t.ask,l,C(buy));}if(sig==-1&&(!c.one_order_per_bar||lastSellBar!=bar)){double l=NormLot(c.initial_lot);Add(sell,t.bid,l);lastSellBar=bar;entries++;LO("SELL","INITIAL",t.bid,l,C(sell));}}
};

#endif
