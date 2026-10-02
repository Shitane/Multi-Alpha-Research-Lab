//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Route_LiveMarket_NoOrders_Gate_v1_01.mq5|
//| Exact SAVE24 route + live MT5 tick/RSI diagnostics. NO ORDERS.   |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Live_Evaluator_v1_00.mqh"

input string InpEntryName="BUILDER_E01";
input string InpManageName="BUILDER_M01";
input string InpExitName="BUILDER_X01";
input int    InpRSIPeriod=8;
input int    InpSamplesToPass=20;

CMultiAlphaBuilderSavedDefinitionRoute100 g_route;
CMultiAlphaBuilderSavedLiveEvaluator100 g_live;
SMA_BuilderSavedDefinition100 g_e={},g_m={},g_x={};
int g_rsi=INVALID_HANDLE;
int g_samples=0,g_pass=0,g_ticks=0,g_tick_fail=0,g_rsi_wait=0;
bool g_done=false;
datetime g_started=0,g_last_diag=0;

void PrintDiag(const string stage)
{
 int bars=Bars(_Symbol,_Period);
 int calc=(g_rsi==INVALID_HANDLE ? -1 : BarsCalculated(g_rsi));
 Print("[SAVED_LIVE101_DIAG] stage=",stage,
       " ticks=",g_ticks," samples=",g_samples,
       " tick_fail=",g_tick_fail," rsi_wait=",g_rsi_wait,
       " bars=",bars," rsi_calculated=",calc,
       " symbol=",_Symbol," tf=",EnumToString(_Period),
       " connected=",(TerminalInfoInteger(TERMINAL_CONNECTED)?1:0),
       " NO_ORDERS=1");
}

int OnInit()
{
 string why="";
 if(!g_route.LoadRoute(InpEntryName,InpManageName,InpExitName,g_e,g_m,g_x,why))
 {
  Print("RESULT: FAIL - saved Builder route is NOT READY / ",why);
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
  return INIT_FAILED;
 }
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 if(g_rsi==INVALID_HANDLE)
 {
  Print("RESULT: FAIL - iRSI handle creation failed error=",GetLastError());
  return INIT_FAILED;
 }
 g_started=TimeLocal();
 g_last_diag=g_started;
 EventSetTimer(5);
 Print("============================================================");
 Print("MULTI ALPHA / SAVED BUILDER ROUTE LIVE MARKET GATE v1.01");
 Print("ENTRY=",InpEntryName," / ",g_e.expression);
 Print("MANAGE=",InpManageName," / ",g_m.expression);
 Print("EXIT=",InpExitName," / ",g_x.expression);
 Print("symbol=",_Symbol," timeframe=",EnumToString(_Period)," RSI=",InpRSIPeriod,
       " target_samples=",InpSamplesToPass);
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 PrintDiag("INIT");
 Print("============================================================");
 return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
 EventKillTimer();
 if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);
 Print("[SAVED_LIVE101_STOP] reason=",reason," ticks=",g_ticks,
       " samples=",g_samples," pass=",g_pass," NO_ORDERS=1");
}

void OnTimer()
{
 if(g_done)return;
 datetime now=TimeLocal();
 if(now-g_last_diag>=15)
 {
  g_last_diag=now;
  PrintDiag(g_ticks==0 ? "WAITING_FOR_ONTICK" : (g_samples==0 ? "WAITING_FOR_RSI" : "RUNNING"));
 }
}

void OnTick()
{
 if(g_done)return;
 g_ticks++;

 MqlTick tick={};
 ResetLastError();
 if(!SymbolInfoTick(_Symbol,tick))
 {
  g_tick_fail++;
  if(g_tick_fail<=3)Print("[SAVED_LIVE101_TICK_FAIL] n=",g_tick_fail," error=",GetLastError());
  return;
 }

 double b[1];
 ResetLastError();
 int copied=CopyBuffer(g_rsi,0,0,1,b);
 if(copied!=1)
 {
  g_rsi_wait++;
  if(g_rsi_wait<=3 || (g_rsi_wait%20)==0)
   Print("[SAVED_LIVE101_RSI_WAIT] tick=",g_ticks," copied=",copied,
         " calculated=",BarsCalculated(g_rsi)," error=",GetLastError());
  return;
 }

 SMA_BuilderSavedLiveContext100 x={};
 x.rsi=b[0];x.buy_count=0;x.sell_count=0;x.position_count=0;
 x.cycle_new=true;x.emergency_unlocked=true;x.time_allowed=true;
 x.news_clear=true;x.spread_ok=true;x.filters_ok=true;

 bool ev=false,mv=false,xv=false; string et="",mt="",xt="",er="",mr="",xr="";
 bool eo=g_live.Evaluate(g_e,x,ev,et,er);
 bool mo=g_live.Evaluate(g_m,x,mv,mt,mr);
 bool xo=g_live.Evaluate(g_x,x,xv,xt,xr);
 bool ok=eo&&mo&&xo;
 g_samples++; if(ok)g_pass++;

 Print("[SAVED_LIVE101] tick=",g_ticks," sample=",g_samples,
       " time=",TimeToString(tick.time,TIME_DATE|TIME_SECONDS),
       " bid=",DoubleToString(tick.bid,_Digits),
       " rsi=",DoubleToString(x.rsi,2),
       " entry=",(ev?1:0)," manage=",(mv?1:0)," exit=",(xv?1:0),
       " eval_ok=",(ok?1:0));
 if(!eo)Print(" ENTRY ERROR: ",er); else Print(" ENTRY TRACE: ",et);
 if(!mo)Print(" MANAGE ERROR: ",mr); else Print(" MANAGE TRACE: ",mt);
 if(!xo)Print(" EXIT ERROR: ",xr); else Print(" EXIT TRACE: ",xt);

 if(g_samples>=InpSamplesToPass)
 {
  g_done=true;
  Print("============================================================");
  Print("TOTAL EVALUATED ",g_pass,"/",g_samples," ticks_received=",g_ticks,
        " rsi_wait=",g_rsi_wait);
  Print(g_pass==g_samples
        ?"RESULT: PASS - exact saved ENTRY/MANAGE/EXIT Builder route evaluated on live MT5 market context"
        :"RESULT: FAIL - saved Builder live evaluation error");
  Print("SCOPE: live SymbolInfoTick + live RSI; virtual empty position state");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
  Print("============================================================");
 }
}
