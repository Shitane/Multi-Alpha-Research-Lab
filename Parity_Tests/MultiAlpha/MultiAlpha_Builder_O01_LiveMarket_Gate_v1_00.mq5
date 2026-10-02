//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_LiveMarket_Gate_v1_00.mq5                |
//| Live MT5 tick/RSI -> verified Builder runtime adapter. NO ORDERS. |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Runtime_Tick_Adapter_v1_00.mqh"

#define TEST_NO_ORDERS 1
#define TEST_VIRTUAL_NOT_FILL 1

input int    InpRSIPeriod=8;
input double InpRSILower=30.0;
input double InpRSIUpper=70.0;
input int    InpSamplesToPass=20;

CMultiAlphaBuilderO01RuntimeTickAdapter100 g_adapter;
int g_rsi_handle=INVALID_HANDLE;
int g_samples=0;
int g_matches=0;
bool g_done=false;

void EntryConfig(SO01EntryConfig &c)
{
 c.trade_buy=true;c.trade_sell=true;c.new_cycles=true;
 c.rsi_lower=InpRSILower;c.rsi_upper=InpRSIUpper;
}
void ManageConfig(SO01ManageConfig &c)
{
 c.max_orders=5;c.fixed_distance_points=100;c.dynamic_start_order=99;c.dynamic_start_points=100;
 c.distance_multiplier=1.0;c.lot_multiplier=2.0;c.max_lot=0.0;c.max_total_lots_per_side=0.0;
 c.pause_grid_while_trailing=false;c.allow_grid_outside_time=true;c.one_order_per_bar=false;
}
void ExitConfig(SO01ExitConfig &c)
{
 c.sl_points=500;c.tp_points=100;c.trailing=false;
 c.trail_start=100;c.trail_distance=50;c.trail_lock=0;c.trail_step=10;
}
bool SameDecision(const SMA_BuilderO01RuntimeDecision100 &a,
                  const SMA_BuilderO01RuntimeDecision100 &b,
                  const SO01TrailState &ta,const SO01TrailState &tb)
{
 return a.route_ready&&b.route_ready&&
        a.entry_signal==b.entry_signal&&
        a.manage_decision.action==b.manage_decision.action&&
        MathAbs(a.manage_decision.requested_lot-b.manage_decision.requested_lot)<1e-9&&
        a.exit_decision==b.exit_decision&&
        ta.active==tb.active&&
        MathAbs(ta.peak_pts-tb.peak_pts)<1e-9&&
        MathAbs(ta.stop_pts-tb.stop_pts)<1e-9;
}
int OnInit()
{
 if(InpRSIPeriod<=0||InpRSILower<0||InpRSIUpper>100||InpRSILower>=InpRSIUpper||InpSamplesToPass<=0)
 {
  Print("RESULT: FAIL - invalid inputs");
  return INIT_PARAMETERS_INCORRECT;
 }
 g_rsi_handle=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 if(g_rsi_handle==INVALID_HANDLE)
 {
  Print("RESULT: FAIL - iRSI handle creation failed error=",GetLastError());
  return INIT_FAILED;
 }
 Print("============================================================");
 Print("MULTI ALPHA LOGIC BUILDER / O01 LIVE MARKET INPUT GATE / NO ORDERS");
 Print("symbol=",_Symbol," timeframe=",EnumToString(_Period)," RSI=",InpRSIPeriod,
       " lower=",DoubleToString(InpRSILower,1)," upper=",DoubleToString(InpRSIUpper,1),
       " target_samples=",InpSamplesToPass);
 Print("NO ORDERS / VIRTUAL NOT FILL / NO BROKER API CALLS");
 Print("============================================================");
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason)
{
 if(g_rsi_handle!=INVALID_HANDLE) IndicatorRelease(g_rsi_handle);
}
void OnTick()
{
 if(g_done) return;

 MqlTick tick={};
 if(!SymbolInfoTick(_Symbol,tick)) return;
 double rsi_buf[1];
 if(CopyBuffer(g_rsi_handle,0,0,1,rsi_buf)!=1) return;

 SO01EntryConfig ec; EntryConfig(ec);
 SO01EntryContext ex={};
 ex.rsi=rsi_buf[0]; ex.buy_count=0; ex.sell_count=0;
 ex.emergency_lock=false; ex.time_allowed=true; ex.news_blocked=false;
 ex.spread_ok=true; ex.filters_ok=true;

 SO01ManageConfig mc; ManageConfig(mc);
 SO01ManageContext mx={};
 mx.position_count=0; mx.trailing_active=false; mx.time_allowed=true;
 mx.news_grid_blocked=false; mx.spread_ok=true; mx.same_bar_as_last_order=false;
 mx.point=_Point; mx.market_price=tick.bid; mx.last_price=tick.bid;
 mx.last_lot=0.01; mx.current_total_lots=0.0;

 SO01ExitConfig xc; ExitConfig(xc);
 SO01TrailState tf={}; tf.active=false;tf.peak_pts=0;tf.stop_pts=0;tf.position_count=0;
 SO01TrailState ts=tf;
 SMA_BuilderO01RuntimeDecision100 f={},s={};

 bool full=g_adapter.EvaluateFull("BUILDER_O01_FULL",ec,ex,true,mc,mx,true,0,0.0,xc,tf,f);
 bool split=g_adapter.EvaluateSplit("BUILDER_E01","BUILDER_M01","BUILDER_X01",
                                    ec,ex,true,mc,mx,true,0,0.0,xc,ts,s);
 bool same=full&&split&&SameDecision(f,s,tf,ts);
 g_samples++;
 if(same) g_matches++;

 Print("[LIVE_MARKET100] sample=",g_samples,
       " time=",TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
       " bid=",DoubleToString(tick.bid,_Digits),
       " ask=",DoubleToString(tick.ask,_Digits),
       " rsi=",DoubleToString(ex.rsi,2),
       " entry_full=",(int)f.entry_signal,
       " entry_split=",(int)s.entry_signal,
       " manage_full=",(int)f.manage_decision.action,
       " manage_split=",(int)s.manage_decision.action,
       " exit_full=",(int)f.exit_decision,
       " exit_split=",(int)s.exit_decision,
       " match=",(same?1:0));

 if(g_samples>=InpSamplesToPass)
 {
  g_done=true;
  Print("============================================================");
  Print("TOTAL ",g_matches,"/",g_samples);
  Print(g_matches==g_samples
        ? "RESULT: PASS - O01 Builder live MT5 market input FULL == SPLIT"
        : "RESULT: FAIL - O01 Builder live MT5 market input mismatch");
  Print("SCOPE: live SymbolInfoTick + live RSI; virtual empty position state");
  Print("NO ORDERS / VIRTUAL NOT FILL / NO BROKER API CALLS");
  Print("============================================================");
 }
}
