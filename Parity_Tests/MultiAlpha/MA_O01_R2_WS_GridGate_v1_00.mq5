//+------------------------------------------------------------------+
//| MA_O01_R2_WS_GridGate_v1_00.mq5                                 |
//| Gate: O01 GRID 40 Parts -> v3_11 workspace -> GRID interpreter.  |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpWorkspaceSlot=1;
CMultiAlphaBuilderSlotWorkspaceStore103 g_ws;
CMultiAlphaBuilderGridInterpreter100 g_grid;

int OnInit()
{
 if(InpWorkspaceSlot<1||InpWorkspaceSlot>50)return INIT_PARAMETERS_INCORRECT;
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string gp[],gv[];ArrayResize(gp,40);ArrayResize(gv,40);
 for(int i=0;i<40;i++){gp[i]=p[1][i];gv[i]=v[1][i];}
 if(!g_ws.PutRole(InpWorkspaceSlot,1,"O01_GRID_CANONICAL",gp,gv))return INIT_FAILED;

 string name="",rp[],rv[];
 if(!g_ws.GetRole(InpWorkspaceSlot,1,name,rp,rv)||name!="O01_GRID_CANONICAL")return INIT_FAILED;
 for(int i=0;i<40;i++)
  if(rp[i]!=gp[i]||rv[i]!=gv[i])
  {Print("[O01_R2_WS_GRID_GATE] result=FAIL reason=ROUNDTRIP slot=",i+1," NO_ORDERS=1");return INIT_FAILED;}

 string why="";
 if(!g_grid.ValidatePlan(rp,rv,why))
 {Print("[O01_R2_WS_GRID_GATE] result=FAIL reason=",why," NO_ORDERS=1");return INIT_FAILED;}

 bool gate[];ArrayResize(gate,40);for(int i=0;i<40;i++)gate[i]=true;
 bool ab=false,as=false;string stop="",reason="";
 bool okb=g_grid.Evaluate(rp,rv,gate,MA_GRID_SIDE_BUY100,ab,as,stop,reason);
 bool buy=okb&&ab&&!as;
 ab=false;as=false;stop="";reason="";
 bool oks=g_grid.Evaluate(rp,rv,gate,MA_GRID_SIDE_SELL100,ab,as,stop,reason);
 bool sell=oks&&!ab&&as;
 bool pass=okb&&oks&&buy&&sell;
 Print("[O01_R2_WS_GRID_GATE] slot=",InpWorkspaceSlot,
       " roundtrip=PASS plan=PASS buy=",(int)buy," sell=",(int)sell,
       " result=",(pass?"PASS":"FAIL"),
       " path=CANONICAL_TO_WORKSPACE_TO_GRID_INTERPRETER NO_ORDERS=1 VIRTUAL_NOT_FILL=1 ORDER_SEND_CALLED=0");
 return pass?INIT_SUCCEEDED:INIT_FAILED;
}
