//+------------------------------------------------------------------+
//| MA_O01_R2_Live4RoleGate_v1_00.mq5                              |
//| P2-D: canonical O01 ENTRY->GRID->MANAGE->EXIT live integration. |
//| Decision/state observation only. NO ORDERS / VIRTUAL NOT FILL.  |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Interpreter_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh>
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpRSIPeriod=8;
input int InpATRPeriod=15;
input ENUM_TIMEFRAMES InpTF2=PERIOD_CURRENT;
input int InpTargetSamples=20;

CMultiAlphaBuilderInterpreter103 g_entry;
CMultiAlphaBuilderGridInterpreter100 g_grid;
int g_rsi=INVALID_HANDLE,g_atr1=INVALID_HANDLE,g_atr2=INVALID_HANDLE;
int g_samples=0,g_buy=0,g_sell=0,g_gridBuy=0,g_gridSell=0,g_manageValid=0,g_exitValid=0;
bool g_done=false;

bool FinitePrice(const double x){return MathIsValidNumber(x)&&x>0.0;}
bool InRange(const double x){return MathIsValidNumber(x)&&x>=0.0&&x<=10000.0;}

bool ValidateRole(const int role,int &used,string &reason)
{
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);used=0;
 for(int i=0;i<40;i++)
 {
  if(p[role][i]==""||p[role][i]=="EMPTY")continue;
  used++;
  if(!MA103ValidatePart(role,p[role][i],v[role][i],reason))
  {
   reason=MA101RoleName(role)+" slot="+IntegerToString(i+1)+" part="+p[role][i]+" "+reason;
   return false;
  }
 }
 int expected=(role==MA_BUILDER_ROLE_MANAGE101?9:19);
 if(used!=expected){reason="USED COUNT "+IntegerToString(used)+" EXPECTED "+IntegerToString(expected);return false;}
 reason="VALID";return true;
}

int OnInit()
{
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string gp[],gv[],why="";ArrayResize(gp,40);ArrayResize(gv,40);
 for(int i=0;i<40;i++){gp[i]=p[1][i];gv[i]=v[1][i];}
 if(!g_grid.ValidatePlan(gp,gv,why))
 {
  Print("[O01_R2_LIVE4_START] result=FAIL reason=GRID_PLAN ",why," NO_ORDERS=1");
  return INIT_FAILED;
 }
 int mu=0,xu=0;string mw="",xw="";
 if(!ValidateRole(MA_BUILDER_ROLE_MANAGE101,mu,mw)||!ValidateRole(MA_BUILDER_ROLE_EXIT101,xu,xw))
 {
  Print("[O01_R2_LIVE4_START] result=FAIL manage=",mw," exit=",xw," NO_ORDERS=1");
  return INIT_FAILED;
 }
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 g_atr1=iATR(_Symbol,_Period,InpATRPeriod);
 ENUM_TIMEFRAMES tf2=(InpTF2==PERIOD_CURRENT?_Period:InpTF2);
 g_atr2=iATR(_Symbol,tf2,InpATRPeriod);
 if(g_rsi==INVALID_HANDLE||g_atr1==INVALID_HANDLE||g_atr2==INVALID_HANDLE)
 {
  Print("[O01_R2_LIVE4_START] result=FAIL reason=INDICATOR_HANDLE NO_ORDERS=1");
  return INIT_FAILED;
 }
 EventSetTimer(1);
 Print("[O01_R2_LIVE4_START] symbol=",_Symbol," tf=",EnumToString(_Period),
       " tf2=",EnumToString(tf2)," target=",InpTargetSamples,
       " order=ENTRY->GRID->MANAGE->EXIT manageUsed=",mu," exitUsed=",xu,
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
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
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick)||_Point<=0.0)return;
 double r[1],a1[1],a2[1];
 if(CopyBuffer(g_rsi,0,0,1,r)!=1||CopyBuffer(g_atr1,0,0,1,a1)!=1||CopyBuffer(g_atr2,0,0,1,a2)!=1)return;

 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string ep[];bool cv[];ArrayResize(ep,40);ArrayResize(cv,40);
 for(int i=0;i<40;i++){ep[i]=p[0][i];cv[i]=true;}
 double atr1pts=a1[0]/_Point,atr2pts=a2[0]/_Point;
 bool marketOK=FinitePrice(tick.bid)&&FinitePrice(tick.ask)&&tick.ask>=tick.bid;
 cv[8]=marketOK;cv[10]=InRange(atr1pts);cv[12]=InRange(atr2pts);cv[16]=(r[0]<30.0);
 cv[28]=marketOK;cv[30]=InRange(atr1pts);cv[32]=InRange(atr2pts);cv[36]=(r[0]>70.0);

 bool buy=false,sell=false;string trace="",why="";
 if(!g_entry.EvaluateEntry40(ep,cv,buy,sell,trace,why))
 {
  g_done=true;Print("[O01_R2_LIVE4_GATE] result=FAIL stage=ENTRY reason=",why," NO_ORDERS=1");return;
 }

 string gp[],gv[];bool gate[];ArrayResize(gp,40);ArrayResize(gv,40);ArrayResize(gate,40);
 for(int i=0;i<40;i++){gp[i]=p[1][i];gv[i]=v[1][i];gate[i]=true;}
 gate[12]=marketOK;
 bool ab=false,as=false;string bs="",bw="",ss="",sw="";
 bool pb=g_grid.Evaluate(gp,gv,gate,MA_GRID_SIDE_BUY100,ab,as,bs,bw);
 bool gridBuy=pb&&ab&&!as;
 ab=false;as=false;
 bool ps=g_grid.Evaluate(gp,gv,gate,MA_GRID_SIDE_SELL100,ab,as,ss,sw);
 bool gridSell=ps&&!ab&&as;
 if(!pb||!ps)
 {
  g_done=true;Print("[O01_R2_LIVE4_GATE] result=FAIL stage=GRID buyReason=",bw," sellReason=",sw," NO_ORDERS=1");return;
 }

 int mu=0,xu=0;string mw="",xw="";
 bool manageOK=ValidateRole(MA_BUILDER_ROLE_MANAGE101,mu,mw);
 bool exitOK=ValidateRole(MA_BUILDER_ROLE_EXIT101,xu,xw);
 bool pass=marketOK&&manageOK&&exitOK;
 g_samples++;if(buy)g_buy++;if(sell)g_sell++;if(gridBuy)g_gridBuy++;if(gridSell)g_gridSell++;
 if(manageOK)g_manageValid++;if(exitOK)g_exitValid++;

 Print("[O01_R2_LIVE4_SAMPLE] n=",g_samples,
       " bid=",DoubleToString(tick.bid,_Digits)," ask=",DoubleToString(tick.ask,_Digits),
       " RSI=",DoubleToString(r[0],2)," ATR1pts=",DoubleToString(atr1pts,1),
       " ENTRY_BUY=",(int)buy," ENTRY_SELL=",(int)sell,
       " GRID_BUY=",(int)gridBuy," GRID_SELL=",(int)gridSell,
       " MANAGE=",(manageOK?"VALID":"INVALID")," EXIT=",(exitOK?"VALID":"INVALID"),
       " result=",(pass?"PASS":"FAIL"));

 if(!pass||g_samples>=InpTargetSamples)
 {
  g_done=true;
  Print("[O01_R2_LIVE4_GATE] canonical=1.02 entryInterpreter=1.03 gridInterpreter=1.00 schema=1.03",
        " samples=",g_samples," entryBuy=",g_buy," entrySell=",g_sell,
        " gridBuy=",g_gridBuy," gridSell=",g_gridSell,
        " manageValid=",g_manageValid," exitValid=",g_exitValid,
        " order=ENTRY->GRID->MANAGE->EXIT result=",(pass?"PASS":"FAIL"),
        " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 }
}
void OnTimer(){Sample();}
void OnTick(){Sample();}
