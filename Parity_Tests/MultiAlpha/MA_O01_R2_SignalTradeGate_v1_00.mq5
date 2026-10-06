//+------------------------------------------------------------------+
//| MA_O01_R2_SignalTradeGate_v1_00.mq5                             |
//| P2-H: canonical O01 ENTRY signal -> demo-only one trade.         |
//| REAL OrderSend only after a real canonical BUY/SELL signal.      |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Interpreter_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input double InpVolume=0.01;
input ulong InpMagic=46102031;
input bool InpArmRealOrder=false;
input int InpRSIPeriod=8;
input int InpATRPeriod=15;
input ENUM_TIMEFRAMES InpTF2=PERIOD_CURRENT;

CMultiAlphaBuilderInterpreter103 g_interp;
int g_rsi=INVALID_HANDLE,g_atr1=INVALID_HANDLE,g_atr2=INVALID_HANDLE;
bool g_send_attempted=false;
int g_samples=0;

bool InRange(const double points){return points>=0.0 && points<=10000.0;}
bool IsDemo(){long m=AccountInfoInteger(ACCOUNT_TRADE_MODE);return m==ACCOUNT_TRADE_MODE_DEMO||m==ACCOUNT_TRADE_MODE_CONTEST;}
bool HasExposure(){return PositionsTotal()>0||OrdersTotal()>0;}

ENUM_ORDER_TYPE_FILLING FillMode()
{
 long f=0;
 if(SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE,f))
 {
  if((f&SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK)return ORDER_FILLING_FOK;
  if((f&SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC)return ORDER_FILLING_IOC;
 }
 return ORDER_FILLING_RETURN;
}

void EvaluateAndMaybeSend()
{
 if(g_send_attempted)return;
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick))return;
 double r[1],a1[1],a2[1];
 if(CopyBuffer(g_rsi,0,0,1,r)!=1||CopyBuffer(g_atr1,0,0,1,a1)!=1||CopyBuffer(g_atr2,0,0,1,a2)!=1)return;
 if(_Point<=0.0)return;

 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string ep[];bool cv[];ArrayResize(ep,40);ArrayResize(cv,40);
 for(int i=0;i<40;i++){ep[i]=p[0][i];cv[i]=true;}

 double atr1pts=a1[0]/_Point,atr2pts=a2[0]/_Point;
 bool spread_ok=(tick.ask>0.0&&tick.bid>0.0&&tick.ask>=tick.bid);
 cv[0]=true;cv[2]=true;cv[4]=true;cv[6]=true;cv[8]=spread_ok;
 cv[10]=InRange(atr1pts);cv[12]=InRange(atr2pts);cv[14]=true;cv[16]=(r[0]<30.0);
 cv[20]=true;cv[22]=true;cv[24]=true;cv[26]=true;cv[28]=spread_ok;
 cv[30]=InRange(atr1pts);cv[32]=InRange(atr2pts);cv[34]=true;cv[36]=(r[0]>70.0);

 bool buy=false,sell=false;string trace="",why="";
 if(!g_interp.EvaluateEntry40(ep,cv,buy,sell,trace,why))
 {Print("[O01_R2_SIGNAL_TRADE_GATE] result=FAIL reason=",why," ORDER_SEND_CALLED=0");g_send_attempted=true;return;}

 g_samples++;
 Print("[O01_R2_SIGNAL_SAMPLE] n=",g_samples," RSI=",DoubleToString(r[0],2),
       " ATR1pts=",DoubleToString(atr1pts,1)," BUY=",(int)buy," SELL=",(int)sell,
       " armed=",(InpArmRealOrder?1:0)," ORDER_SEND_CALLED=0");

 if(!buy&&!sell)return;
 if(buy&&sell){Print("[O01_R2_SIGNAL_TRADE_GATE] result=BLOCK reason=DUAL_SIGNAL ORDER_SEND_CALLED=0");g_send_attempted=true;return;}

 string side=buy?"BUY":"SELL";
 Print("[O01_R2_SIGNAL_HIT] side=",side," RSI=",DoubleToString(r[0],2)," trace=",trace);

 if(!InpArmRealOrder){Print("[O01_R2_SIGNAL_TRADE_GATE] result=BLOCK reason=NOT_ARMED signal=",side," ORDER_SEND_CALLED=0");g_send_attempted=true;return;}
 if(!IsDemo()){Print("[O01_R2_SIGNAL_TRADE_GATE] result=BLOCK reason=NOT_DEMO ORDER_SEND_CALLED=0");g_send_attempted=true;return;}
 if(MathAbs(InpVolume-0.01)>1e-12){Print("[O01_R2_SIGNAL_TRADE_GATE] result=BLOCK reason=VOLUME_NOT_001 ORDER_SEND_CALLED=0");g_send_attempted=true;return;}
 if(HasExposure()){Print("[O01_R2_SIGNAL_TRADE_GATE] result=BLOCK reason=EXISTING_EXPOSURE ORDER_SEND_CALLED=0");g_send_attempted=true;return;}

 MqlTradeRequest req;MqlTradeResult res;ZeroMemory(req);ZeroMemory(res);
 req.action=TRADE_ACTION_DEAL;req.magic=InpMagic;req.symbol=_Symbol;req.volume=InpVolume;
 req.type=buy?ORDER_TYPE_BUY:ORDER_TYPE_SELL;req.price=buy?tick.ask:tick.bid;
 req.deviation=20;req.type_time=ORDER_TIME_GTC;req.type_filling=FillMode();req.comment="MA_O01_R2_SIGNAL";
 g_send_attempted=true;ResetLastError();
 bool sent=OrderSend(req,res);int err=GetLastError();
 bool pass=sent&&(res.retcode==TRADE_RETCODE_DONE||res.retcode==TRADE_RETCODE_DONE_PARTIAL||res.retcode==TRADE_RETCODE_PLACED);
 Print("[O01_R2_SIGNAL_TRADE_RESULT] side=",side," sent=",(sent?1:0)," retcode=",res.retcode,
       " order=",res.order," deal=",res.deal," err=",err," ORDER_SEND_CALLED=1 MAX_SENDS=1");
 Print("[O01_R2_SIGNAL_TRADE_GATE] result=",(pass?"PASS":"FAIL")," source=CANONICAL_ENTRY_40P side=",side,
       " DEMO_ONLY=1 volume=",DoubleToString(InpVolume,2)," ORDER_SEND_CALLED=1 MAX_SENDS=1");
}

int OnInit()
{
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 g_atr1=iATR(_Symbol,_Period,InpATRPeriod);
 ENUM_TIMEFRAMES tf2=InpTF2==PERIOD_CURRENT?_Period:InpTF2;
 g_atr2=iATR(_Symbol,tf2,InpATRPeriod);
 if(g_rsi==INVALID_HANDLE||g_atr1==INVALID_HANDLE||g_atr2==INVALID_HANDLE)return INIT_FAILED;
 Print("[O01_R2_SIGNAL_TRADE_START] symbol=",_Symbol," tf=",EnumToString(_Period),
       " RSI=",InpRSIPeriod," ATR=",InpATRPeriod," armed=",(InpArmRealOrder?1:0),
       " DEMO_ONLY=1 SIGNAL_SOURCE=CANONICAL_ENTRY_40P MAX_SENDS=1");
 EventSetTimer(1);return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){EventKillTimer();if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);if(g_atr1!=INVALID_HANDLE)IndicatorRelease(g_atr1);if(g_atr2!=INVALID_HANDLE)IndicatorRelease(g_atr2);}
void OnTimer(){EvaluateAndMaybeSend();}
void OnTick(){EvaluateAndMaybeSend();}
