//+------------------------------------------------------------------+
//| MA_O01_R2_WS_EntryGate_v1_00.mq5                                |
//| Gate: O01 ENTRY 40 Parts -> v3_11 workspace store -> v1_03.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include <Builder\MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Interpreter_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpWorkspaceSlot=1;
input int InpRSIPeriod=8;
input int InpATRPeriod=15;
input ENUM_TIMEFRAMES InpTF2=PERIOD_CURRENT;
input int InpTargetSamples=20;

CMultiAlphaBuilderSlotWorkspaceStore103 g_ws;
CMultiAlphaBuilderInterpreter103 g_interp;
int g_rsi=INVALID_HANDLE,g_atr1=INVALID_HANDLE,g_atr2=INVALID_HANDLE;
int g_samples=0;
bool g_done=false;

bool InRange(const double p){return p>=0.0&&p<=10000.0;}

bool SeedEntryToWorkspace()
{
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string ep[],ev[];ArrayResize(ep,40);ArrayResize(ev,40);
 for(int i=0;i<40;i++){ep[i]=p[0][i];ev[i]=v[0][i];}
 if(!g_ws.PutRole(InpWorkspaceSlot,0,"O01_ENTRY_CANONICAL",ep,ev))return false;
 string name="",rp[],rv[];
 if(!g_ws.GetRole(InpWorkspaceSlot,0,name,rp,rv))return false;
 if(name!="O01_ENTRY_CANONICAL"||ArraySize(rp)!=40||ArraySize(rv)!=40)return false;
 for(int i=0;i<40;i++)if(rp[i]!=ep[i]||rv[i]!=ev[i])return false;
 Print("[O01_R2_WS_SEED] slot=",InpWorkspaceSlot," role=ENTRY roundtrip=PASS revision=",g_ws.Revision(InpWorkspaceSlot)," NO_ORDERS=1");
 return true;
}

void Evaluate()
{
 if(g_done)return;
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick))return;
 double r[1],a1[1],a2[1];
 if(CopyBuffer(g_rsi,0,0,1,r)!=1||CopyBuffer(g_atr1,0,0,1,a1)!=1||CopyBuffer(g_atr2,0,0,1,a2)!=1)return;
 if(_Point<=0.0)return;

 string name="",parts[],params[];
 if(!g_ws.GetRole(InpWorkspaceSlot,0,name,parts,params))
 {Print("[O01_R2_WS_ENTRY_GATE] result=FAIL reason=WORKSPACE_READ NO_ORDERS=1");g_done=true;return;}

 bool cv[];ArrayResize(cv,40);for(int i=0;i<40;i++)cv[i]=true;
 double atr1pts=a1[0]/_Point,atr2pts=a2[0]/_Point;
 bool spread_ok=(tick.ask>0.0&&tick.bid>0.0&&tick.ask>=tick.bid);
 cv[0]=true;cv[2]=true;cv[4]=true;cv[6]=true;cv[8]=spread_ok;
 cv[10]=InRange(atr1pts);cv[12]=InRange(atr2pts);cv[14]=true;cv[16]=(r[0]<30.0);
 cv[20]=true;cv[22]=true;cv[24]=true;cv[26]=true;cv[28]=spread_ok;
 cv[30]=InRange(atr1pts);cv[32]=InRange(atr2pts);cv[34]=true;cv[36]=(r[0]>70.0);

 bool buy=false,sell=false;string trace="",why="";
 if(!g_interp.EvaluateEntry40(parts,cv,buy,sell,trace,why))
 {Print("[O01_R2_WS_ENTRY_GATE] result=FAIL reason=",why," NO_ORDERS=1");g_done=true;return;}

 g_samples++;
 Print("[O01_R2_WS_ENTRY_SAMPLE] n=",g_samples," RSI=",DoubleToString(r[0],2),
       " BUY=",(int)buy," SELL=",(int)sell," source=WORKSPACE_SLOT_",InpWorkspaceSlot,
       " ORDER_SEND_CALLED=0");
 if(g_samples>=InpTargetSamples)
 {
  Print("[O01_R2_WS_ENTRY_GATE] samples=",g_samples,
        " result=PASS path=CANONICAL_TO_WORKSPACE_TO_INTERPRETER NO_ORDERS=1 VIRTUAL_NOT_FILL=1 ORDER_SEND_CALLED=0");
  g_done=true;
 }
}

int OnInit()
{
 if(InpWorkspaceSlot<1||InpWorkspaceSlot>50||InpTargetSamples<1)return INIT_PARAMETERS_INCORRECT;
 if(!SeedEntryToWorkspace())return INIT_FAILED;
 g_rsi=iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
 g_atr1=iATR(_Symbol,_Period,InpATRPeriod);
 ENUM_TIMEFRAMES tf2=(InpTF2==PERIOD_CURRENT?_Period:InpTF2);
 g_atr2=iATR(_Symbol,tf2,InpATRPeriod);
 if(g_rsi==INVALID_HANDLE||g_atr1==INVALID_HANDLE||g_atr2==INVALID_HANDLE)return INIT_FAILED;
 Print("[O01_R2_WS_ENTRY_START] symbol=",_Symbol," tf=",EnumToString(_Period),
       " slot=",InpWorkspaceSlot," source=V3_11_WORKSPACE_STORE target=",InpTargetSamples,
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 EventSetTimer(1);return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){EventKillTimer();if(g_rsi!=INVALID_HANDLE)IndicatorRelease(g_rsi);if(g_atr1!=INVALID_HANDLE)IndicatorRelease(g_atr1);if(g_atr2!=INVALID_HANDLE)IndicatorRelease(g_atr2);}
void OnTick(){Evaluate();}
void OnTimer(){Evaluate();}
