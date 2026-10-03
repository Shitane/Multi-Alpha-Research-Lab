//+------------------------------------------------------------------+
//| MA_Builder_O01_Entry_Parity_Tester_v1_01.mq5                    |
//| O01 reference vs generic saved-Builder ENTRY on tester ticks.    |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Live_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_O01_Entry_Evaluator_v1_00.mqh"

input int InpRSIPeriod=8;
input double InpLower=30.0;
input double InpUpper=70.0;
input int InpSamplesToPass=2000;

CMultiAlphaBuilderSavedLiveEvaluator100 g_saved;
CMultiAlphaBuilderO01EntryEvaluator100 g_ref;
SMA_BuilderSavedDefinition100 g_buy={},g_sell={};
int g_rsi=INVALID_HANDLE,g_samples=0,g_match=0,g_buy_hits=0,g_sell_hits=0;
bool g_done=false;

void ClearDef(SMA_BuilderSavedDefinition100 &d,const string name)
{
 d.role=0;d.name=name;d.loaded=true;d.valid=true;d.reason="READY";d.expression="";
 for(int i=0;i<24;i++){d.part[i]="EMPTY";d.param[i]="";}
}
void MakeDefs()
{
 ClearDef(g_buy,"O01_ENTRY_BUY_GENERIC");
 string bp[13]={"CYCLE_NEW","AND","EMERGENCY_UNLOCKED","AND","TIME_ALLOWED","AND","NEWS_CLEAR","AND","SPREAD_OK","AND","FILTERS_OK","AND","SIDE_COUNT_ZERO"};
 for(int i=0;i<13;i++)g_buy.part[i]=bp[i];
 g_buy.part[13]="AND";g_buy.part[14]="RSI_THRESHOLD";
 g_buy.param[14]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL="+DoubleToString(InpLower,1);
 ClearDef(g_sell,"O01_ENTRY_SELL_GENERIC");
 string sp[13]={"CYCLE_NEW","AND","EMERGENCY_UNLOCKED","AND","TIME_ALLOWED","AND","NEWS_CLEAR","AND","SPREAD_OK","AND","FILTERS_OK","AND","SIDE_COUNT_ZERO"};
 for(int i=0;i<13;i++)g_sell.part[i]=sp[i];
 g_sell.part[13]="AND";g_sell.part[14]="RSI_THRESHOLD";
 g_sell.param[14]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=GT;LEVEL="+DoubleToString(InpUpper,1);
}
string Sig(const ENUM_O01_ENTRY_SIGNAL s){if(s==O01_ENTRY_BUY)return "BUY";if(s==O01_ENTRY_SELL)return "SELL";return "NONE";}

int OnInit()
{
 if(!MQLInfoInteger(MQL_TESTER)){Print("RESULT: FAIL - Strategy Tester only");return INIT_FAILED;}
 MakeDefs();
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 if(g_rsi==INVALID_HANDLE){Print("RESULT: FAIL - RSI handle");return INIT_FAILED;}
 Print("O01 ENTRY REFERENCE vs GENERIC BUILDER / TESTER v1.01");
 Print("BUY: common gates AND BUY_SIDE_ZERO AND RSI<",InpLower);
 Print("SELL: common gates AND SELL_SIDE_ZERO AND RSI>",InpUpper);
 Print("samples=",InpSamplesToPass," NO ORDERS / VIRTUAL NOT FILL");
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);}

void OnTick()
{
 if(g_done)return;
 double b[1];if(CopyBuffer(g_rsi,0,0,1,b)!=1)return;

 SO01EntryConfig c={};c.new_cycles=true;c.trade_buy=true;c.trade_sell=true;c.rsi_lower=InpLower;c.rsi_upper=InpUpper;
 SO01EntryContext x={};x.emergency_lock=false;x.time_allowed=true;x.news_blocked=false;x.spread_ok=true;x.filters_ok=true;x.buy_count=0;x.sell_count=0;x.rsi=b[0];
 ENUM_O01_ENTRY_SIGNAL rs=g_ref.Evaluate(c,x);

 SMA_BuilderSavedLiveContext100 sx={};sx.rsi=b[0];sx.buy_count=0;sx.sell_count=0;sx.position_count=0;sx.cycle_new=true;sx.emergency_unlocked=true;sx.time_allowed=true;sx.news_clear=true;sx.spread_ok=true;sx.filters_ok=true;
 bool bv=false,sv=false;string bt="",st="",br="",sr="";
 bool bok=g_saved.Evaluate(g_buy,sx,bv,bt,br),sok=g_saved.Evaluate(g_sell,sx,sv,st,sr);
 ENUM_O01_ENTRY_SIGNAL bs=O01_ENTRY_NONE;
 if(bv&&!sv)bs=O01_ENTRY_BUY; else if(sv&&!bv)bs=O01_ENTRY_SELL;
 bool same=bok&&sok&&(rs==bs);
 g_samples++;if(same)g_match++;if(rs==O01_ENTRY_BUY)g_buy_hits++;if(rs==O01_ENTRY_SELL)g_sell_hits++;
 if(!same)Print("[O01_ENTRY_PARITY_FAIL] n=",g_samples," rsi=",DoubleToString(b[0],2)," REF=",Sig(rs)," BUILDER=",Sig(bs)," buy_ok=",bok," sell_ok=",sok," br=",br," sr=",sr);
 if(g_samples>=InpSamplesToPass)
 {
  g_done=true;
  Print("TOTAL PARITY ",g_match,"/",g_samples," BUY_HITS=",g_buy_hits," SELL_HITS=",g_sell_hits);
  if(g_match==g_samples && g_buy_hits>0 && g_sell_hits>0)
   Print("RESULT: PASS - O01 reference ENTRY == generic Builder ENTRY with both BUY and SELL observed");
  else if(g_match==g_samples)
   Print("RESULT: INCOMPLETE - decisions match but both BUY and SELL were not observed");
  else Print("RESULT: FAIL - O01 reference ENTRY != generic Builder ENTRY");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 }
}
