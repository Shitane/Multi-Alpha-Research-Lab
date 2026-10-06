//+------------------------------------------------------------------+
//| MA_O01_R2_VLifeGate_v1_00.mq5                                  |
//| P2-E: O01 four-role virtual lifecycle gate. NO REAL ORDERS.      |
//| Live ticks drive a deterministic virtual state-machine only.     |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

#include <Builder\MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh>
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>
#include <Builder\MultiAlpha_Builder_O01_Exit_Evaluator_v1_00.mqh>

input int InpTargetCycles=3;

enum EVLifeState
{
 VLS_ENTRY=0,
 VLS_GRID=1,
 VLS_MANAGE=2,
 VLS_EXIT=3
};

CMultiAlphaBuilderGridInterpreter100 g_grid;
CMultiAlphaBuilderO01ExitEvaluator100 g_exit;
EVLifeState g_state=VLS_ENTRY;

int g_cycles=0;
int g_steps=0;
bool g_done=false;
double g_entryPrice=0.0;
double g_gridPrice=0.0;
double g_avgPrice=0.0;
SO01TrailState g_trail;

bool FinitePrice(const double x)
{
 return MathIsValidNumber(x)&&x>0.0;
}

bool ValidateRole(const int role,int &used,string &reason)
{
 string p[4][40],v[4][40];
 MAO01LoadCanonical102(p,v);
 used=0;
 for(int i=0;i<40;i++)
 {
  if(p[role][i]==""||p[role][i]=="EMPTY") continue;
  used++;
  if(!MA103ValidatePart(role,p[role][i],v[role][i],reason))
  {
   reason=MA101RoleName(role)+" slot="+IntegerToString(i+1)+" part="+p[role][i]+" "+reason;
   return false;
  }
 }
 int expected=(role==MA_BUILDER_ROLE_MANAGE101 ? 9 : 19);
 if(used!=expected)
 {
  reason="USED COUNT "+IntegerToString(used)+" EXPECTED "+IntegerToString(expected);
  return false;
 }
 reason="VALID";
 return true;
}

bool GridPlanOK(string &reason)
{
 string p[4][40],v[4][40];
 MAO01LoadCanonical102(p,v);
 string gp[],gv[];
 ArrayResize(gp,40);
 ArrayResize(gv,40);
 for(int i=0;i<40;i++)
 {
  gp[i]=p[MA_BUILDER_ROLE_GRID101][i];
  gv[i]=v[MA_BUILDER_ROLE_GRID101][i];
 }
 return g_grid.ValidatePlan(gp,gv,reason);
}

bool GridAllow(const bool isBuy,const bool marketOK,string &reason)
{
 string p[4][40],v[4][40];
 MAO01LoadCanonical102(p,v);
 string gp[],gv[];
 bool gate[];
 ArrayResize(gp,40);
 ArrayResize(gv,40);
 ArrayResize(gate,40);
 for(int i=0;i<40;i++)
 {
  gp[i]=p[MA_BUILDER_ROLE_GRID101][i];
  gv[i]=v[MA_BUILDER_ROLE_GRID101][i];
  gate[i]=true;
 }
 gate[12]=marketOK;

 bool allowBuy=false,allowSell=false;
 string stop="";
 bool ok=g_grid.Evaluate(gp,gv,gate,
                         isBuy?MA_GRID_SIDE_BUY100:MA_GRID_SIDE_SELL100,
                         allowBuy,allowSell,stop,reason);
 if(!ok) return false;
 return (isBuy ? (allowBuy&&!allowSell) : (!allowBuy&&allowSell));
}

void ResetVirtualCycle()
{
 g_state=VLS_ENTRY;
 g_entryPrice=0.0;
 g_gridPrice=0.0;
 g_avgPrice=0.0;
 g_trail.active=false;
 g_trail.peak_pts=0.0;
 g_trail.stop_pts=0.0;
 g_trail.position_count=0;
}

int OnInit()
{
 string why="";
 if(!GridPlanOK(why))
 {
  Print("[O01_R2_VLIFE_START] result=FAIL stage=GRID_PLAN reason=",why," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  return INIT_FAILED;
 }

 int mu=0,xu=0;
 string mw="",xw="";
 if(!ValidateRole(MA_BUILDER_ROLE_MANAGE101,mu,mw) ||
    !ValidateRole(MA_BUILDER_ROLE_EXIT101,xu,xw))
 {
  Print("[O01_R2_VLIFE_START] result=FAIL stage=ROLE_VALIDATE manage=",mw,
        " exit=",xw," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  return INIT_FAILED;
 }

 ResetVirtualCycle();
 EventSetTimer(1);
 Print("[O01_R2_VLIFE_START] symbol=",_Symbol,
       " tf=",EnumToString(_Period),
       " targetCycles=",InpTargetCycles,
       " order=ENTRY->GRID->MANAGE->EXIT",
       " mode=DETERMINISTIC_VIRTUAL_STATE",
       " manageUsed=",mu," exitUsed=",xu,
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
 EventKillTimer();
}

void Step()
{
 if(g_done) return;

 MqlTick tick;
 if(!SymbolInfoTick(_Symbol,tick) || _Point<=0.0) return;
 bool marketOK=FinitePrice(tick.bid)&&FinitePrice(tick.ask)&&tick.ask>=tick.bid;
 if(!marketOK) return;

 g_steps++;

 if(g_state==VLS_ENTRY)
 {
  // Seed only the virtual state. No trade request and no broker fill.
  g_entryPrice=tick.ask;
  g_avgPrice=g_entryPrice;
  Print("[O01_R2_VLIFE_STEP] cycle=",g_cycles+1,
        " role=ENTRY action=VIRTUAL_SEED price=",DoubleToString(g_entryPrice,_Digits),
        " result=PASS NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  g_state=VLS_GRID;
  return;
 }

 if(g_state==VLS_GRID)
 {
  string why="";
  bool allow=GridAllow(true,marketOK,why);
  if(!allow)
  {
   g_done=true;
   Print("[O01_R2_VLIFE_GATE] result=FAIL stage=GRID reason=",why,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return;
  }

  // Deterministic synthetic grid price verifies lifecycle plumbing only.
  g_gridPrice=g_entryPrice-200.0*_Point;
  g_avgPrice=(g_entryPrice+g_gridPrice)/2.0;
  Print("[O01_R2_VLIFE_STEP] cycle=",g_cycles+1,
        " role=GRID action=VIRTUAL_ADD count=2 avg=",DoubleToString(g_avgPrice,_Digits),
        " gridPrice=",DoubleToString(g_gridPrice,_Digits),
        " result=PASS NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  g_state=VLS_MANAGE;
  return;
 }

 if(g_state==VLS_MANAGE)
 {
  int used=0;
  string why="";
  bool ok=ValidateRole(MA_BUILDER_ROLE_MANAGE101,used,why);
  if(!ok)
  {
   g_done=true;
   Print("[O01_R2_VLIFE_GATE] result=FAIL stage=MANAGE reason=",why,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return;
  }

  Print("[O01_R2_VLIFE_STEP] cycle=",g_cycles+1,
        " role=MANAGE state=VIRTUAL_BASKET count=2 used=",used,
        " avg=",DoubleToString(g_avgPrice,_Digits),
        " result=PASS NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
  g_state=VLS_EXIT;
  return;
 }

 if(g_state==VLS_EXIT)
 {
  int used=0;
  string why="";
  if(!ValidateRole(MA_BUILDER_ROLE_EXIT101,used,why))
  {
   g_done=true;
   Print("[O01_R2_VLIFE_GATE] result=FAIL stage=EXIT_VALIDATE reason=",why,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return;
  }

  SO01ExitConfig cfg;
  cfg.trailing=false;
  cfg.tp_points=100;
  cfg.sl_points=1500;
  cfg.trail_start=100;
  cfg.trail_lock=50;
  cfg.trail_distance=50;
  cfg.trail_step=10;

  // Two-position basket: synthetic +100 points must request FIXED_TP.
  ENUM_O01_EXIT_DECISION d=g_exit.Evaluate(true,2,100.0,cfg,g_trail);
  bool ok=(d==O01_EXIT_FIXED_TP);
  Print("[O01_R2_VLIFE_STEP] cycle=",g_cycles+1,
        " role=EXIT action=",(ok?"VIRTUAL_CLOSE_FIXED_TP":"UNEXPECTED"),
        " count=2 movePts=100 used=",used,
        " result=",(ok?"PASS":"FAIL"),
        " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");

  if(!ok)
  {
   g_done=true;
   Print("[O01_R2_VLIFE_GATE] result=FAIL stage=EXIT_DECISION decision=",(int)d,
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return;
  }

  g_cycles++;
  if(g_cycles>=InpTargetCycles)
  {
   g_done=true;
   Print("[O01_R2_VLIFE_GATE] canonical=1.02 gridInterpreter=1.00 schema=1.03 exitEvaluator=1.00",
         " cycles=",g_cycles," steps=",g_steps,
         " order=ENTRY->GRID->MANAGE->EXIT result=PASS",
         " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
   return;
  }

  ResetVirtualCycle();
 }
}

void OnTimer(){Step();}
void OnTick(){Step();}
