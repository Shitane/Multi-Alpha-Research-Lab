//+------------------------------------------------------------------+
//| MA_O01_R2_LiveEntryGate_v1_00.mq5                              |
//| P2-A: canonical O01 ENTRY 40-Part -> live tick/indicator gate.   |
//| NO ORDERS / VIRTUAL NOT FILL / no broker trade API calls.        |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Interpreter_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpRSIPeriod=8;
input int InpATRPeriod=15;
input ENUM_TIMEFRAMES InpTF2=PERIOD_CURRENT;
input int InpTargetSamples=20;

CMultiAlphaBuilderInterpreter103 g_interp;
int g_rsi=INVALID_HANDLE,g_atr1=INVALID_HANDLE,g_atr2=INVALID_HANDLE;
int g_samples=0,g_buy=0,g_sell=0,g_none=0;
bool g_done=false;

bool InRange(const double points){return points>=0.0 && points<=10000.0;}

int OnInit()
{
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 g_atr1=iATR(_Symbol,_Period,InpATRPeriod);
 ENUM_TIMEFRAMES tf2=(InpTF2==PERIOD_CURRENT ? _Period : InpTF2);
 g_atr2=iATR(_Symbol,tf2,InpATRPeriod);
 if(g_rsi==INVALID_HANDLE || g_atr1==INVALID_HANDLE || g_atr2==INVALID_HANDLE)
 {
  Print("[O01_R2_LIVE_ENTRY_GATE] result=FAIL reason=INDICATOR_HANDLE NO_ORDERS=1");
  return INIT_FAILED;
 }
 EventSetTimer(1);
 Print("[O01_R2_LIVE_ENTRY_START] symbol=",_Symbol," tf=",EnumToString(_Period),
       " tf2=",EnumToString(tf2)," RSI=",InpRSIPeriod," ATR=",InpATRPeriod,
       " target=",InpTargetSamples," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
 EventKillTimer();
 if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);
 if(g_atr1!=INVALID_HANDLE)IndicatorRelease(g_atr1);
 if(g_atr2!=INVALID_HANDLE)IndicatorRelease(g_atr2);
}

void Sample()
{
 if(g_done)return;
 MqlTick tick;
 if(!SymbolInfoTick(_Symbol,tick))return;
 double r[1],a1[1],a2[1];
 if(CopyBuffer(g_rsi,0,0,1,r)!=1 || CopyBuffer(g_atr1,0,0,1,a1)!=1 || CopyBuffer(g_atr2,0,0,1,a2)!=1)return;
 if(_Point<=0.0)return;

 string p[4][40],v[4][40]; MAO01LoadCanonical102(p,v);
 string ep[]; bool cv[];
 ArrayResize(ep,40);ArrayResize(cv,40);
 for(int i=0;i<40;i++){ep[i]=p[0][i];cv[i]=true;}

 double atr1pts=a1[0]/_Point,atr2pts=a2[0]/_Point;
 bool spread_ok=(tick.ask>0.0 && tick.bid>0.0 && tick.ask>=tick.bid);
 // Common O01 guards are deliberately virtual-TRUE in this gate.
 // Live inputs are RSI, ATR(15)x2 and broker tick/spread sanity.
 cv[0]=true; cv[2]=true; cv[4]=true; cv[6]=true; cv[8]=spread_ok;
 cv[10]=InRange(atr1pts); cv[12]=InRange(atr2pts); cv[14]=true; cv[16]=(r[0]<30.0);
 cv[20]=true;cv[22]=true;cv[24]=true;cv[26]=true;cv[28]=spread_ok;
 cv[30]=InRange(atr1pts);cv[32]=InRange(atr2pts);cv[34]=true;cv[36]=(r[0]>70.0);

 bool buy=false,sell=false;string trace="",why="";
 bool parsed=g_interp.EvaluateEntry40(ep,cv,buy,sell,trace,why);
 if(!parsed)
 {
  g_done=true;
  Print("[O01_R2_LIVE_ENTRY_GATE] result=FAIL reason=",why," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  return;
 }
 g_samples++;if(buy)g_buy++;if(sell)g_sell++;if(!buy&&!sell)g_none++;
 Print("[O01_R2_LIVE_ENTRY_SAMPLE] n=",g_samples,
       " bid=",DoubleToString(tick.bid,_Digits)," ask=",DoubleToString(tick.ask,_Digits),
       " RSI=",DoubleToString(r[0],2),
       " ATR1pts=",DoubleToString(atr1pts,1)," ATR2pts=",DoubleToString(atr2pts,1),
       " BUY=",(int)buy," SELL=",(int)sell," trace=",trace," result=PASS");

 if(g_samples>=InpTargetSamples)
 {
  g_done=true;
  Print("[O01_R2_LIVE_ENTRY_GATE] canonical=1.02 interpreter=1.03 samples=",g_samples,
        " buy=",g_buy," sell=",g_sell," none=",g_none,
        " result=PASS NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 }
}
void OnTimer(){Sample();}
void OnTick(){Sample();}
