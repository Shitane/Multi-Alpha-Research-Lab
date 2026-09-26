//+------------------------------------------------------------------+
//| O01_GSG_RSI30_Runtime_Panel_Core_v1_40.mq5                      |
//| MAIN LINE: v1.33 parity logic + v1.40 architecture foundation.   |
//|                                                                  |
//| Phase 1 intentionally remains NO ORDERS / VIRTUAL NOT FILL.      |
//| DEMO execution is declared but locked until execution adapter     |
//| and demo-account safety gates are implemented and verified.       |
//+------------------------------------------------------------------+
#property strict
#property version "1.40"

#include "..\\..\\Include\\O01\\O01_GSG_RSI30_Runtime_Adapter_v1_20.mqh"
#include "..\\..\\Include\\O01\\O01_Settings_Panel_v1_42.mqh"
#include "..\\..\\Include\\O01\\MultiAlpha_Foundation_v1_40.mqh"

enum O01_TIME_MODE { O01_AUTO_GMT=0,O01_SERVER_TIME=1,O01_CUSTOM_GMT=2 };

input ENUM_MA_EXECUTION_MODE InpExecutionMode=MA_EXECUTION_NO_ORDERS;

SO01RuntimeSettings110 runtime_cfg;
CO01SettingsPanel141 panel;
CO01RuntimeAdapter120 adapter;
CO01CoreInterface core;
SMA140StrategyIdentity strategy;
SMA140PanelTheme panel_theme;

struct VPos{double price,lot;datetime time,bar;};
VPos buy[],sell[];
SO01TrailState bt,st;
int rh=INVALID_HANDLE,a1h=INVALID_HANDLE,a2h=INVALID_HANDLE;
datetime lastBuyBar=0,lastSellBar=0;
ulong ticks=0,entries=0,grids=0,closes=0,singleTrail=0,basketTrail=0,vsl=0,timeBlocks=0,newsBlocks=0,spreadBlocks=0,filterBlocks=0;

void Defaults(){
 runtime_cfg.new_cycles=true;runtime_cfg.trade_buy=true;runtime_cfg.trade_sell=true;runtime_cfg.allow_grid_outside_time=true;runtime_cfg.one_order_per_bar=true;runtime_cfg.pause_grid_while_trailing=true;
 runtime_cfg.rsi_period=8;runtime_cfg.rsi_lower=30;runtime_cfg.rsi_upper=70;runtime_cfg.atr1_period=15;runtime_cfg.atr2_period=15;runtime_cfg.atr2_timeframe=PERIOD_CURRENT;runtime_cfg.atr1_min_points=0;runtime_cfg.atr1_max_points=10000;runtime_cfg.atr2_min_points=0;runtime_cfg.atr2_max_points=10000;
 runtime_cfg.initial_lot=.01;runtime_cfg.lot_multiplier=1.5;runtime_cfg.max_lot=5;runtime_cfg.max_total_lots_per_side=1.2;runtime_cfg.max_orders=10;runtime_cfg.fixed_distance_points=200;runtime_cfg.dynamic_start_order=3;runtime_cfg.dynamic_start_points=300;runtime_cfg.distance_multiplier=1.2;
 runtime_cfg.virtual_sl_points=1500;runtime_cfg.single_trail_start=110;runtime_cfg.single_trail_lock=60;runtime_cfg.single_trail_distance=50;runtime_cfg.single_trail_step=10;runtime_cfg.basket_trail_start=100;runtime_cfg.basket_trail_lock=50;runtime_cfg.basket_trail_distance=50;runtime_cfg.basket_trail_step=10;
 runtime_cfg.warning_dd=8;runtime_cfg.pause_grid_dd=12;runtime_cfg.emergency_close_dd=15;runtime_cfg.time_mode=0;runtime_cfg.start_hour=7;runtime_cfg.start_minute=0;runtime_cfg.end_hour=11;runtime_cfg.end_minute=0;runtime_cfg.use_news_filter=true;runtime_cfg.news_manage_only=true;
}
double B(int h){double x[1];return CopyBuffer(h,0,0,1,x)==1?x[0]:EMPTY_VALUE;}
int C(VPos &p[]){return ArraySize(p);}
double Lots(VPos &p[]){double s=0;for(int i=0;i<C(p);i++)s+=p[i].lot;return s;}
double Avg(VPos &p[]){double pv=0,v=0;for(int i=0;i<C(p);i++){pv+=p[i].price*p[i].lot;v+=p[i].lot;}return v>0?pv/v:0;}
double LastPrice(VPos &p[]){return C(p)?p[C(p)-1].price:0;}
double LastLot(VPos &p[]){return C(p)?p[C(p)-1].lot:runtime_cfg.initial_lot;}
double NormLot(double x){double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN),mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX),step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);if(step<=0)step=.01;x=MathMax(mn,MathMin(mx,MathMin(runtime_cfg.max_lot,x)));return NormalizeDouble(MathRound(x/step)*step,2);}
double Dist(int n){if(n<runtime_cfg.dynamic_start_order)return runtime_cfg.fixed_distance_points;return runtime_cfg.dynamic_start_points*MathPow(runtime_cfg.distance_multiplier,n-runtime_cfg.dynamic_start_order);}
int NM(int m){while(m<0)m+=1440;while(m>=1440)m-=1440;return m;}
bool Win(int m,int s,int e){return s==e||(s<e?(m>=s&&m<e):(m>=s||m<e));}
bool TimeOK(){MqlDateTime d;TimeToStruct(TimeTradeServer(),d);if(d.day_of_week<1||d.day_of_week>5)return false;int m=d.hour*60+d.min,s=runtime_cfg.start_hour*60+runtime_cfg.start_minute,e=runtime_cfg.end_hour*60+runtime_cfg.end_minute;if(runtime_cfg.time_mode==O01_AUTO_GMT||runtime_cfg.time_mode==O01_CUSTOM_GMT){s=NM(s+180);e=NM(e+180);}return Win(m,s,e);}
bool SpreadOK(){return true;}
bool NewsNewBlocked(){return false;}
bool NewsGridBlocked(){return false;}
void Add(VPos &p[],double px,double lot){int n=C(p);ArrayResize(p,n+1);p[n].price=px;p[n].lot=lot;p[n].time=TimeCurrent();p[n].bar=iTime(_Symbol,_Period,0);}
void Clear(VPos &p[]){ArrayResize(p,0);}
string EN(ENUM_O01_EXIT_DECISION d){if(d==O01_EXIT_VIRTUAL_SL)return "VIRTUAL_SL";if(d==O01_EXIT_SINGLE_TRAILING)return "SINGLE_TRAILING";if(d==O01_EXIT_BASKET_TRAILING)return "BASKET_TRAILING";if(d==O01_EXIT_FIXED_TP)return "FIXED_TP";return "NONE";}
void LO(string side,string tag,double px,double lot,int n){Print("[O01_RUNTIME140_OPEN] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," instance=",strategy.instance_id," side=",side," tag=",tag," count=",n," lot=",DoubleToString(lot,2)," px=",DoubleToString(px,_Digits)," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}
void LX(string side,ENUM_O01_EXIT_DECISION d,int n,double avg,double px,double mv){Print("[O01_RUNTIME140_EXIT] t=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)," instance=",strategy.instance_id," side=",side," reason=",EN(d)," count=",n," avg=",DoubleToString(avg,_Digits)," px=",DoubleToString(px,_Digits)," move_pts=",DoubleToString(mv,1)," EXECUTION=",MA140_ExecutionText(InpExecutionMode)," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");}

bool RebuildIndicatorHandles()
{
 int nr=iRSI(_Symbol,_Period,runtime_cfg.rsi_period,PRICE_CLOSE);
 int na1=iATR(_Symbol,_Period,runtime_cfg.atr1_period);
 int na2=iATR(_Symbol,(ENUM_TIMEFRAMES)runtime_cfg.atr2_timeframe,runtime_cfg.atr2_period);
 if(nr==INVALID_HANDLE||na1==INVALID_HANDLE||na2==INVALID_HANDLE)
 {
  if(nr!=INVALID_HANDLE)IndicatorRelease(nr);if(na1!=INVALID_HANDLE)IndicatorRelease(na1);if(na2!=INVALID_HANDLE)IndicatorRelease(na2);
  Print("[O01_RUNTIME140_HANDLES] rebuild failed");
  return false;
 }
 if(rh!=INVALID_HANDLE)IndicatorRelease(rh);if(a1h!=INVALID_HANDLE)IndicatorRelease(a1h);if(a2h!=INVALID_HANDLE)IndicatorRelease(a2h);
 rh=nr;a1h=na1;a2h=na2;
 Print("[O01_RUNTIME140_HANDLES] rebuilt RSI=",runtime_cfg.rsi_period," ATR1=",runtime_cfg.atr1_period," ATR2=",runtime_cfg.atr2_period," TF2=",runtime_cfg.atr2_timeframe);
 return true;
}

void Manage(bool isBuy,VPos &p[],SO01TrailState &ts,MqlTick &t){
 int n=C(p);if(n<=0){core.ResetTrail(ts);return;}double avg=Avg(p),px=isBuy?t.bid:t.ask,mv=isBuy?(px-avg)/_Point:(avg-px)/_Point;
 SO01ExitConfig xc;adapter.ExitConfig(runtime_cfg,n,xc);ENUM_O01_EXIT_DECISION d=core.EvaluateExit(isBuy,n,mv,xc,ts);
 if(d!=O01_EXIT_NONE){LX(isBuy?"BUY":"SELL",d,n,avg,px,mv);closes++;if(d==O01_EXIT_SINGLE_TRAILING)singleTrail++;if(d==O01_EXIT_BASKET_TRAILING)basketTrail++;if(d==O01_EXIT_VIRTUAL_SL)vsl++;Clear(p);core.ResetTrail(ts);return;}
 if(n>=runtime_cfg.max_orders||(runtime_cfg.pause_grid_while_trailing&&ts.active))return;if(!runtime_cfg.allow_grid_outside_time&&!TimeOK())return;if(NewsGridBlocked()||!SpreadOK())return;datetime bar=iTime(_Symbol,_Period,0);if(runtime_cfg.one_order_per_bar&&(isBuy?lastBuyBar:lastSellBar)==bar)return;
 double lp=LastPrice(p),ds=Dist(n+1);bool met=isBuy?t.ask<=lp-ds*_Point:t.bid>=lp+ds*_Point;if(!met)return;double lot=NormLot(LastLot(p)*runtime_cfg.lot_multiplier);if(runtime_cfg.max_total_lots_per_side>0&&Lots(p)+lot>runtime_cfg.max_total_lots_per_side+1e-9)return;double op=isBuy?t.ask:t.bid;Add(p,op,lot);if(isBuy)lastBuyBar=bar;else lastSellBar=bar;grids++;LO(isBuy?"BUY":"SELL","GRID #"+IntegerToString(n+1),op,lot,C(p));
}

int OnInit(){
 Defaults();MA140_DefaultIdentity(strategy,_Symbol);MA140_DefaultTheme(panel_theme);
 // Phase-1 safety gate: the main line knows the requested execution mode,
 // but broker execution is not connected until the execution adapter is verified.
 if(InpExecutionMode==MA_EXECUTION_DEMO)
 {
  Print("[O01_RUNTIME140_SAFETY] DEMO requested but execution adapter is not armed in phase 1. Initialization stopped.");
  return INIT_PARAMETERS_INCORRECT;
 }
 if(!adapter.Validate(runtime_cfg))return INIT_PARAMETERS_INCORRECT;
 if(!RebuildIndicatorHandles())return INIT_FAILED;
 panel.Create(runtime_cfg,strategy,panel_theme);
 Print("[O01_RUNTIME140_START] CORE=1.00 ADAPTER=1.20 PANEL=1.42 FOUNDATION=1.40 instance=",strategy.instance_id," symbol=",strategy.symbol," entry=",strategy.entry_module," manage=",strategy.manage_module," exit=",strategy.exit_module," EXECUTION=NO_ORDERS VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){
 panel.Delete();if(rh!=INVALID_HANDLE)IndicatorRelease(rh);if(a1h!=INVALID_HANDLE)IndicatorRelease(a1h);if(a2h!=INVALID_HANDLE)IndicatorRelease(a2h);
 Print("[O01_RUNTIME140_SUMMARY] ticks=",ticks," entries=",entries," grids=",grids," closes=",closes," single_trail=",singleTrail," basket_trail=",basketTrail," virtual_sl=",vsl," buy_open=",C(buy)," sell_open=",C(sell)," time_blocks=",timeBlocks," news_blocks=",newsBlocks," spread_blocks=",spreadBlocks," filter_blocks=",filterBlocks," EXECUTION=NO_ORDERS VIRTUAL_NOT_FILL=1");
}
void OnTick(){
 static ulong diag_ticks=0; diag_ticks++;
 if(diag_ticks==1 || diag_ticks%100000==0) Print("[O01_TICK_DIAG] ticks=",diag_ticks," time=",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
 int pr=panel.PollButtons(runtime_cfg);
 if(pr!=0){
  Print("[O01_RUNTIME140_PANEL_POLL] result=",pr," EXECUTION=NO_ORDERS");
  if(pr>0) RebuildIndicatorHandles();
 }
 ticks++;MqlTick t;if(!SymbolInfoTick(_Symbol,t))return;Manage(true,buy,bt,t);Manage(false,sell,st,t);
 double r=B(rh),a1=B(a1h),a2=B(a2h);if(r==EMPTY_VALUE||a1==EMPTY_VALUE||a2==EMPTY_VALUE)return;
 if(!TimeOK()){if(r<runtime_cfg.rsi_lower||r>runtime_cfg.rsi_upper)timeBlocks++;return;}if(NewsNewBlocked()){newsBlocks++;return;}if(!SpreadOK()){spreadBlocks++;return;}
 double p1=a1/_Point,p2=a2/_Point;if(!(p1>=runtime_cfg.atr1_min_points&&p1<=runtime_cfg.atr1_max_points&&p2>=runtime_cfg.atr2_min_points&&p2<=runtime_cfg.atr2_max_points)){filterBlocks++;return;}
 SO01EntryConfig ec;adapter.EntryConfig(runtime_cfg,ec);SO01EntryContext x;x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=C(buy);x.sell_count=C(sell);x.rsi=r;ENUM_O01_ENTRY_SIGNAL sig=core.EvaluateEntry(ec,x);datetime bar=iTime(_Symbol,_Period,0);
 if(sig==O01_ENTRY_BUY&&(!runtime_cfg.one_order_per_bar||lastBuyBar!=bar)){double l=NormLot(runtime_cfg.initial_lot);Add(buy,t.ask,l);lastBuyBar=bar;entries++;LO("BUY","INITIAL",t.ask,l,C(buy));}
 if(sig==O01_ENTRY_SELL&&(!runtime_cfg.one_order_per_bar||lastSellBar!=bar)){double l=NormLot(runtime_cfg.initial_lot);Add(sell,t.bid,l);lastSellBar=bar;entries++;LO("SELL","INITIAL",t.bid,l,C(sell));}
}
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam){
 Print("[O01_CHART_EVENT] id=",id," name=",sparam," lparam=",lparam," dparam=",DoubleToString(dparam,2));
 SO01RuntimeSettings110 before=runtime_cfg;
 int r=panel.Event(id,sparam,runtime_cfg);
 if(r!=0)
 {
  bool ok=adapter.Validate(runtime_cfg);
  if(!ok){runtime_cfg=before;Print("[O01_RUNTIME140_PANEL] result=",r," valid=0 rolled_back=1");return;}
  bool handleChanged=(before.rsi_period!=runtime_cfg.rsi_period||before.atr1_period!=runtime_cfg.atr1_period||before.atr2_period!=runtime_cfg.atr2_period||before.atr2_timeframe!=runtime_cfg.atr2_timeframe);
  if(handleChanged&&!RebuildIndicatorHandles()){runtime_cfg=before;RebuildIndicatorHandles();Print("[O01_RUNTIME140_PANEL] result=",r," valid=1 handles=FAIL rolled_back=1");return;}
  Print("[O01_RUNTIME140_PANEL] result=",r," valid=1 handles_rebuilt=",(int)handleChanged," EXECUTION=NO_ORDERS");
 }
}
