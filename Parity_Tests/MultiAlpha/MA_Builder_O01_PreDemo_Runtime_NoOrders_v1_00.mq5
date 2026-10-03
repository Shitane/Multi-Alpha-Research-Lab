//+------------------------------------------------------------------+
//| MA_Builder_O01_PreDemo_Runtime_NoOrders_v1_00.mq5               |
//| Single-instance persisted Builder route, live-market pre-demo.    |
//| NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0.           |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\Runtime\\MultiAlpha_Symbol_Resolver_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Entry_Action_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Manage_Action_Evaluator_v1_00.mqh"
#include "..\\..\\..\\Include\\Builder\\MultiAlpha_Builder_Saved_Exit_Action_Evaluator_v1_00.mqh"

input string InpLogicalSymbol="XAUUSD";
input bool   InpUseCustom=true;
input string InpCustomBrokerSymbol="XAUUSD-m";
input ENUM_TIMEFRAMES InpTimeframe=PERIOD_M1;
input string InpEntryName="O01_ENTRY_GENERIC_V1";
input string InpManageName="O01_MANAGE_GENERIC_V1";
input string InpExitTrailOnName="O01_EXIT_GENERIC_V1";
input string InpExitTrailOffName="O01_EXIT_FIXEDTP_GENERIC_V1";
input int InpRSIPeriod=8;
input int InpTargetSamples=20;

CMultiAlphaSymbolResolver100 g_resolver;
CMultiAlphaBuilderSavedEntryActionEvaluator100 g_entry_eval;
CMultiAlphaBuilderSavedManageActionEvaluator100 g_manage_eval;
CMultiAlphaBuilderSavedExitActionEvaluator100 g_exit_eval;
SMA_SymbolSpec100 g_spec;
SMA_BuilderSavedDefinition100 g_entry,g_manage,g_exit_on,g_exit_off;
int g_rsi=INVALID_HANDLE,g_samples=0,g_entry_buy=0,g_entry_sell=0,g_manage_add=0,g_exit_signal=0;
bool g_done=false;

bool LoadDef(const int role,const string name,SMA_BuilderSavedDefinition100 &d)
{
 string prefix=(role==0?"ENTRY":(role==1?"MANAGE":"EXIT"));
 string fn="MultiAlpha_Builder_"+prefix+"_"+name+".csv";
 int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');
 if(h==INVALID_HANDLE){Print("RESULT: FAIL CLOSED - NOT FOUND: ",fn);return false;}
 string sig=FileReadString(h),ver=FileReadString(h);int got=(int)FileReadNumber(h),count=(int)FileReadNumber(h);
 if(sig!="MA_BUILDER_ROLE"||got!=role||count!=24){FileClose(h);Print("RESULT: FAIL CLOSED - INVALID ",prefix," FILE: ",fn);return false;}
 d.role=role;d.name=name;d.loaded=true;d.valid=true;d.reason="READY";d.expression="";
 for(int i=0;i<24;i++){d.part[i]="EMPTY";d.param[i]="";}
 for(int i=0;i<24&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string p=FileReadString(h),a=FileReadString(h);if(no>=1&&no<=24){d.part[no-1]=p;d.param[no-1]=a;}}
 FileClose(h);Print("LOADED: ",fn);return true;
}

int OnInit()
{
 bool ok=(InpUseCustom?g_resolver.ResolveCustom(InpLogicalSymbol,InpCustomBrokerSymbol,g_spec):g_resolver.ResolveAuto(InpLogicalSymbol,g_spec));
 Print("MULTI ALPHA / O01 BUILDER PRE-DEMO RUNTIME / NO ORDERS v1.00");
 if(!ok){Print("RESULT: FAIL CLOSED - ",g_spec.reason);Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_FAILED;}
 Print("SYMBOL: logical=",InpLogicalSymbol," broker=",g_spec.broker_symbol," point=",DoubleToString(g_spec.point,10)," digits=",g_spec.digits);
 if(!LoadDef(0,InpEntryName,g_entry)||!LoadDef(1,InpManageName,g_manage)||!LoadDef(2,InpExitTrailOnName,g_exit_on)||!LoadDef(2,InpExitTrailOffName,g_exit_off))return INIT_FAILED;
 g_rsi=iRSI(g_spec.broker_symbol,InpTimeframe,InpRSIPeriod,PRICE_CLOSE);
 if(g_rsi==INVALID_HANDLE){Print("RESULT: FAIL CLOSED - RSI HANDLE");return INIT_FAILED;}
 EventSetTimer(1);
 Print("ROUTE=",InpEntryName," -> ",InpManageName," -> ",InpExitTrailOnName," / ",InpExitTrailOffName);
 Print("TARGET_SAMPLES=",InpTargetSamples," TF=",EnumToString(InpTimeframe)," RSI=",InpRSIPeriod);
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 return INIT_SUCCEEDED;
}
void OnDeinit(const int reason)
{
 EventKillTimer();if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);
 Print("[PREDEMO100_STOP] reason=",reason," samples=",g_samples," entry_buy=",g_entry_buy," entry_sell=",g_entry_sell," manage_add=",g_manage_add," exit_signal=",g_exit_signal," NO_ORDERS=1");
}
void Sample()
{
 if(g_done)return;
 MqlTick t;if(!SymbolInfoTick(g_spec.broker_symbol,t))return;
 double rr[1];if(CopyBuffer(g_rsi,0,0,1,rr)!=1)return;

 SMA_BuilderSavedEntryContext100 ex={};ex.rsi=rr[0];ex.buy_count=0;ex.sell_count=0;ex.cycle_new=true;ex.emergency_unlocked=true;ex.time_allowed=true;ex.news_clear=true;ex.spread_ok=true;ex.filters_ok=true;
 ENUM_MA_BUILDER_ENTRY_ACTION100 ea;string tr,why;
 if(!g_entry_eval.Evaluate(g_entry,ex,ea,tr,why)){Print("RESULT: FAIL CLOSED - ENTRY: ",why);g_done=true;return;}
 if(ea==MA_BUILDER_ENTRY_BUY100)g_entry_buy++;if(ea==MA_BUILDER_ENTRY_SELL100)g_entry_sell++;

 // Virtual state only. It proves the persisted MANAGE/EXIT evaluators remain callable
 // in the resolved live broker context without creating or filling positions.
 bool side=((g_samples&1)==0);int pc=1+(g_samples%4);
 SO01ManageContext mx={};mx.time_allowed=true;mx.news_grid_blocked=false;mx.spread_ok=true;mx.trailing_active=false;mx.same_bar_as_last_order=false;mx.position_count=pc;mx.current_total_lots=0.01*pc;mx.last_lot=0.01;mx.point=g_spec.point;
 double required=(pc+1<3?100.0:150.0*MathPow(1.5,(pc+1)-3));
 if(side){mx.market_price=t.bid;mx.last_price=t.bid+(required+10.0)*g_spec.point;}else{mx.market_price=t.ask;mx.last_price=t.ask-(required+10.0)*g_spec.point;}
 SO01ManageDecision md;if(!g_manage_eval.Evaluate(g_manage,side,mx,md,tr,why)){Print("RESULT: FAIL CLOSED - MANAGE: ",why);g_done=true;return;}
 if(md.action==O01_MANAGE_ADD_GRID)g_manage_add++;

 SMA_BuilderSavedDefinition100 xd=((g_samples%2)==0?g_exit_on:g_exit_off);
 SO01TrailState ts={};ENUM_O01_EXIT_DECISION xa;
 if(!g_exit_eval.Evaluate(xd,side,pc,0.0,ts,xa,tr,why)){Print("RESULT: FAIL CLOSED - EXIT: ",why);g_done=true;return;}
 if(xa!=O01_EXIT_NONE)g_exit_signal++;

 g_samples++;
 Print("[PREDEMO100_SAMPLE] n=",g_samples," symbol=",g_spec.broker_symbol," bid=",DoubleToString(t.bid,g_spec.digits)," ask=",DoubleToString(t.ask,g_spec.digits)," rsi=",DoubleToString(rr[0],2)," entry=",(int)ea," manage=",md.action," exit=",(int)xa);
 if(g_samples>=InpTargetSamples)
 {
  g_done=true;
  Print("RESULT: PASS - persisted Builder route evaluated in resolved live broker context");
  Print("SAMPLES=",g_samples," ENTRY_BUY=",g_entry_buy," ENTRY_SELL=",g_entry_sell," MANAGE_ADD=",g_manage_add," EXIT_SIGNAL=",g_exit_signal);
  Print("SCOPE: single-instance pre-demo; live tick/RSI + persisted SAVE24 route + virtual position state");
  Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 }
}
void OnTimer(){Sample();}
void OnTick(){Sample();}
