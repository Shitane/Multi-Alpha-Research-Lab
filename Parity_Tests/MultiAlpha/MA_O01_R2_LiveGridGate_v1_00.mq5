//+------------------------------------------------------------------+
//| MA_O01_R2_LiveGridGate_v1_00.mq5                               |
//| P2-B: canonical O01 GRID 40-Part -> live broker/runtime gate.    |
//| NO ORDERS / VIRTUAL NOT FILL / no broker trade API calls.        |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>
#include <Builder\MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh>

input int InpTargetSamples=20;

CMultiAlphaBuilderGridInterpreter100 g_grid;
int g_samples=0,g_buyAllow=0,g_sellAllow=0,g_blocked=0;
bool g_done=false;

bool FinitePrice(const double x){return MathIsValidNumber(x) && x>0.0;}

void LoadGrid(string &p[],string &v[])
{
 string allP[4][40],allV[4][40];MAO01LoadCanonical102(allP,allV);
 ArrayResize(p,40);ArrayResize(v,40);
 for(int i=0;i<40;i++){p[i]=allP[1][i];v[i]=allV[1][i];}
}

int OnInit()
{
 string p[],v[],why="";LoadGrid(p,v);
 bool ok=g_grid.ValidatePlan(p,v,why);
 Print("[O01_R2_LIVE_GRID_START] symbol=",_Symbol," tf=",EnumToString(_Period),
       " target=",InpTargetSamples," plan=",(ok?"VALID":"INVALID")," reason=",why,
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 if(!ok)return INIT_FAILED;
 EventSetTimer(1);
 return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){EventKillTimer();}

void Sample()
{
 if(g_done)return;
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick))return;
 string p[],v[];LoadGrid(p,v);

 bool gate[];ArrayResize(gate,40);for(int i=0;i<40;i++)gate[i]=true;

 // P2-B deliberately keeps account/strategy-dependent O01 guards virtual-TRUE.
 // The live broker gate in this step is tick/spread sanity at SPREAD_OK.
 bool spread_ok=(FinitePrice(tick.bid)&&FinitePrice(tick.ask)&&tick.ask>=tick.bid);
 gate[12]=spread_ok;

 bool buy=false,sell=false;string stop="",why="";
 bool pb=g_grid.Evaluate(p,v,gate,MA_GRID_SIDE_BUY100,buy,sell,stop,why);
 bool buyAllow=pb&&buy&&!sell;
 string buyStop=stop,buyWhy=why;

 buy=false;sell=false;stop="";why="";
 bool ps=g_grid.Evaluate(p,v,gate,MA_GRID_SIDE_SELL100,buy,sell,stop,why);
 bool sellAllow=ps&&!buy&&sell;
 string sellStop=stop,sellWhy=why;

 bool pass=pb&&ps;
 if(!pass)
 {
  g_done=true;
  Print("[O01_R2_LIVE_GRID_GATE] result=FAIL reason=INTERPRETER buyReason=",buyWhy,
        " sellReason=",sellWhy," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  return;
 }

 g_samples++;
 if(buyAllow)g_buyAllow++;
 if(sellAllow)g_sellAllow++;
 if(!buyAllow||!sellAllow)g_blocked++;

 Print("[O01_R2_LIVE_GRID_SAMPLE] n=",g_samples,
       " bid=",DoubleToString(tick.bid,_Digits)," ask=",DoubleToString(tick.ask,_Digits),
       " spreadPts=",DoubleToString((tick.ask-tick.bid)/_Point,1),
       " spreadOK=",(int)spread_ok,
       " buyAllow=",(int)buyAllow," buyStop=",buyStop," buyReason=",buyWhy,
       " sellAllow=",(int)sellAllow," sellStop=",sellStop," sellReason=",sellWhy,
       " result=PASS");

 if(g_samples>=InpTargetSamples)
 {
  g_done=true;
  Print("[O01_R2_LIVE_GRID_GATE] canonical=1.02 interpreter=1.00 samples=",g_samples,
        " buyAllow=",g_buyAllow," sellAllow=",g_sellAllow," blockedSamples=",g_blocked,
        " result=PASS NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 }
}
void OnTimer(){Sample();}
void OnTick(){Sample();}
