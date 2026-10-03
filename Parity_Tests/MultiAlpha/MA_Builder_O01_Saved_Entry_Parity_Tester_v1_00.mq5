//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Entry_Parity_Tester_v1_00.mq5              |
//| O01 reference vs persisted SAVE24 + generic action interpreter.  |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\O01\\O01_GSG_RSI30_Entry_Module_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Entry_Action_Evaluator_v1_00.mqh"
input string InpEntryName="O01_ENTRY_GENERIC_V1";
input int InpRSIPeriod=8;
input int InpMaxSamples=200000;
CO01EntryModule g_ref;
CMultiAlphaBuilderSavedDefinitionRoute100 g_loader;
CMultiAlphaBuilderSavedEntryActionEvaluator100 g_builder;
SMA_BuilderSavedDefinition100 g_e,g_m,g_x;
int g_rsi=INVALID_HANDLE,g_n=0,g_match=0,g_buy=0,g_sell=0;bool g_done=false;

int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 // Load ENTRY directly using a temporary valid route is intentionally avoided:
 // use the same SAVE24 file format and parse it here, then generic evaluator owns semantics.
 string fn="MultiAlpha_Builder_ENTRY_"+InpEntryName+".csv";
 int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){Print("RESULT: FAIL - NOT FOUND: ",fn);return INIT_FAILED;}
 string sig=FileReadString(h),ver=FileReadString(h);int role=(int)FileReadNumber(h),count=(int)FileReadNumber(h);
 if(sig!="MA_BUILDER_ROLE"||role!=0||count!=24){FileClose(h);Print("RESULT: FAIL - INVALID ENTRY FILE");return INIT_FAILED;}
 g_e.role=0;g_e.name=InpEntryName;g_e.loaded=true;g_e.valid=true;g_e.reason="READY";g_e.expression="";
 for(int i=0;i<24;i++){g_e.part[i]="EMPTY";g_e.param[i]="";}
 for(int i=0;i<24&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string p=FileReadString(h),a=FileReadString(h);if(no>=1&&no<=24){g_e.part[no-1]=p;g_e.param[no-1]=a;}}
 FileClose(h);
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);if(g_rsi==INVALID_HANDLE)return INIT_FAILED;
 Print("O01 REFERENCE vs SAVED GENERIC BUILDER ENTRY / TESTER v1.00");
 Print("SOURCE=",fn,"  STOP=both BUY+SELL observed or max_samples=",InpMaxSamples);
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);}
void OnTick()
{
 if(g_done)return;double r[1];if(CopyBuffer(g_rsi,0,0,1,r)!=1)return;
 SO01EntryConfig c={};c.new_cycles=true;c.trade_buy=true;c.trade_sell=true;c.rsi_lower=30;c.rsi_upper=70;
 SO01EntryContext x={};x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=0;x.sell_count=0;x.rsi=r[0];
 ENUM_O01_ENTRY_SIGNAL ref=g_ref.Evaluate(c,x);
 SMA_BuilderSavedEntryContext100 bx={};bx.rsi=r[0];bx.buy_count=0;bx.sell_count=0;bx.cycle_new=true;bx.emergency_unlocked=true;bx.time_allowed=true;bx.news_clear=true;bx.spread_ok=true;bx.filters_ok=true;
 ENUM_MA_BUILDER_ENTRY_ACTION100 got;string trace,why;if(!g_builder.Evaluate(g_e,bx,got,trace,why)){Print("RESULT: FAIL - ",why);g_done=true;return;}
 int b=(int)got;if((int)ref==b)g_match++;else Print("[SAVED_ENTRY_MISMATCH] n=",g_n," rsi=",r[0]," ref=",(int)ref," saved=",b," trace=",trace);
 if(ref==O01_ENTRY_BUY)g_buy++;if(ref==O01_ENTRY_SELL)g_sell++;g_n++;
 if((g_buy>0&&g_sell>0&&g_n>=1000)||g_n>=InpMaxSamples){g_done=true;Print("TOTAL SAVED ENTRY PARITY ",g_match,"/",g_n," BUY=",g_buy," SELL=",g_sell);
 bool ok=(g_match==g_n&&g_buy>0&&g_sell>0);Print(ok?"RESULT: PASS - O01 reference ENTRY == persisted SAVE24 generic Builder ENTRY":"RESULT: INCOMPLETE/FAIL - inspect counters");
 Print("SCOPE: persisted SAVE24 definition + generic action interpreter + real tester RSI/ticks");Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");}
}
