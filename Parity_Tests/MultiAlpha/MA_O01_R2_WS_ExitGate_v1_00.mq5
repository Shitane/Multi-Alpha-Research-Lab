//+------------------------------------------------------------------+
//| MA_O01_R2_WS_ExitGate_v1_00.mq5                                 |
//| Gate: O01 EXIT 40 Parts -> v3_11 workspace -> schema validate.   |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpWorkspaceSlot=1;
CMultiAlphaBuilderSlotWorkspaceStore103 g_ws;

int OnInit()
{
 if(InpWorkspaceSlot<1||InpWorkspaceSlot>50)return INIT_PARAMETERS_INCORRECT;

 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string xp[],xv[];ArrayResize(xp,40);ArrayResize(xv,40);
 for(int i=0;i<40;i++){xp[i]=p[3][i];xv[i]=v[3][i];}

 if(!g_ws.PutRole(InpWorkspaceSlot,3,"O01_EXIT_CANONICAL",xp,xv))return INIT_FAILED;

 string name="",rp[],rv[];
 if(!g_ws.GetRole(InpWorkspaceSlot,3,name,rp,rv)||name!="O01_EXIT_CANONICAL")return INIT_FAILED;

 for(int i=0;i<40;i++)
  if(rp[i]!=xp[i]||rv[i]!=xv[i])
  {
   Print("[O01_R2_WS_EXIT_GATE] result=FAIL reason=ROUNDTRIP slot=",i+1," NO_ORDERS=1");
   return INIT_FAILED;
  }

 int used=0;string why="";
 for(int i=0;i<40;i++)
 {
  if(rp[i]==""||rp[i]=="EMPTY")continue;
  used++;
  if(!MA103ValidatePart(MA_BUILDER_ROLE_EXIT101,rp[i],rv[i],why))
  {
   Print("[O01_R2_WS_EXIT_GATE] result=FAIL reason=SCHEMA slot=",i+1,
         " part=",rp[i]," detail=",why," NO_ORDERS=1");
   return INIT_FAILED;
  }
 }

 bool pass=(used==19);
 Print("[O01_R2_WS_EXIT_GATE] slot=",InpWorkspaceSlot,
       " roundtrip=PASS schema=PASS used=",used," expected=19",
       " result=",(pass?"PASS":"FAIL"),
       " path=CANONICAL_TO_WORKSPACE_TO_EXIT_SCHEMA NO_ORDERS=1 VIRTUAL_NOT_FILL=1 ORDER_SEND_CALLED=0");
 return pass?INIT_SUCCEEDED:INIT_FAILED;
}
