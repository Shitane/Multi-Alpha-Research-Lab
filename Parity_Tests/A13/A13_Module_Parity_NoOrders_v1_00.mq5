//+------------------------------------------------------------------+
//| A13 Module Parity NoOrders v1.00                                |
//| Verify extracted A13 module against established baseline.        |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\Include\\A13_Dual_MA_Module_v1_00.mqh"

input double InpBrickSize=6.0; input int InpFastMAPeriod=9; input int InpSlowMAPeriod=152;
input double InpMinMASeparationBricks=4.15; input int InpEntryRunBricks=2;
input double InpTakeProfitBricks=55.0; input double InpStopLossBricks=32.0;
input int InpMaxHoldMinutes=1440; input int InpCooldownBricks=16; input double InpMaxSpreadFraction=0.35;

CA13DualMA g_a13; bool g_open=false,g_closed=false;int g_dir=0,g_cd=0;double g_open_price=0;datetime g_open_time=0;
long g_ticks=0,g_bricks=0,g_raw=0,g_entries=0,g_exits=0,g_time=0,g_tp=0,g_sl=0,g_maflip=0,g_spread=0,g_cdblocks=0;

bool Valid(const MqlTick&t){return MathIsValidNumber(t.bid)&&MathIsValidNumber(t.ask)&&t.bid>0&&t.ask>=t.bid&&t.time>0;}
void CloseV(const string why,const MqlTick&t){if(!g_open)return;double p=(g_dir>0?t.bid:t.ask);g_exits++;if(why=="TIME")g_time++;else if(why=="TP")g_tp++;else if(why=="SL")g_sl++;else if(why=="MA_FLIP")g_maflip++;
 PrintFormat("[A13_MODULE_EXIT] no=%I64d reason=%s dir=%s price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_exits,why,(g_dir>0?"BUY":"SELL"),p);
 g_open=false;g_dir=0;g_open_price=0;g_open_time=0;g_cd=InpCooldownBricks;g_closed=true;}
void PriceExit(const MqlTick&t){if(!g_open)return;double ex=(g_dir>0?t.bid:t.ask),mv=g_dir*(ex-g_open_price),b=g_a13.EffectiveBrick();
 if(mv>=InpTakeProfitBricks*b){CloseV("TP",t);return;}if(mv<=-InpStopLossBricks*b){CloseV("SL",t);return;}
 if(InpMaxHoldMinutes>0&&(long)(t.time-g_open_time)>=(long)InpMaxHoldMinutes*60)CloseV("TIME",t);}
int OnInit(){double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);if(!g_a13.Init(ts,InpBrickSize,InpFastMAPeriod,InpSlowMAPeriod,InpMinMASeparationBricks,InpEntryRunBricks))return INIT_FAILED;
 Print("[A13_MODULE_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1");return INIT_SUCCEEDED;}
void OnTick(){g_ticks++;g_closed=false;MqlTick t={};if(!SymbolInfoTick(_Symbol,t)||!Valid(t))return;PriceExit(t);
 int n=0,a=0;int sig=g_a13.PushBid(t.bid,n,a);if(g_a13.Failed())return;if(n==0)return;g_bricks+=n;
 if(g_cd>0){g_cd-=n;if(g_cd<0)g_cd=0;}
 if(g_open){if(a!=0&&a==-g_dir)CloseV("MA_FLIP",t);return;}if(g_closed)return;
 if(g_cd>0){if(sig!=0)g_cdblocks++;return;}if(sig==0)return;g_raw++;
 if((t.ask-t.bid)>g_a13.EffectiveBrick()*InpMaxSpreadFraction){g_spread++;return;}
 g_open=true;g_dir=sig;g_open_price=(sig>0?t.ask:t.bid);g_open_time=t.time;g_entries++;
 PrintFormat("[A13_MODULE_ENTRY] no=%I64d dir=%s price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_entries,(sig>0?"BUY":"SELL"),g_open_price);}
void OnDeinit(const int reason){PrintFormat("[A13_MODULE_SUMMARY] ticks=%I64d bricks=%I64d raw=%I64d entries=%I64d exits=%I64d open=%d tp=%I64d sl=%I64d time=%I64d maflip=%I64d spread_blocks=%I64d cooldown_blocks=%I64d failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
 g_ticks,g_bricks,g_raw,g_entries,g_exits,(int)g_open,g_tp,g_sl,g_time,g_maflip,g_spread,g_cdblocks,(int)g_a13.Failed(),reason);}
