//+------------------------------------------------------------------+
//| MA_O01_R2_WS_ManageGate_v1_00.mq5                               |
//| Gate: O01 MANAGE 40 Parts -> v3_11 workspace -> schema validate. |
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
 string mp[],mv[];ArrayResize(mp,40);ArrayResize(mv,40);
 for(int i=0;i<40;i++){mp[i]=p[2][i];mv[i]=v[2][i];}

 if(!g_ws.PutRole(InpWorkspaceSlot,2,"O01_MANAGE_CANONICAL",mp,mv))return INIT_FAILED;

 string name="",rp[],rv[];
 if(!g_ws.GetRole(InpWorkspaceSlot,2,name,rp,rv)||name!="O01_MANAGE_CANONICAL")return INIT_FAILED;

 for(int i=0;i<40;i++)
  if(rp[i]!=mp[i]||rv[i]!=mv[i])
  {
   Print("[O01_R2_WS_MANAGE_GATE] result=FAIL reason=ROUNDTRIP slot=",i+1," NO_ORDERS=1");
   return INIT_FAILED;
  }

 int used=0;string why="";
 for(int i=0;i<40;i++)
 {
  if(rp[i]==""||rp[i]=="EMPTY")continue;
  used++;
  if(!MA103ValidatePart(MA_BUILDER_ROLE_MANAGE101,rp[i],rv[i],why))
  {
   Print("[O01_R2_WS_MANAGE_GATE] result=FAIL reason=SCHEMA slot=",i+1,
         " part=",rp[i]," detail=",why," NO_ORDERS=1");
   return INIT_FAILED;
  }
 }

 bool pass=(used==9);
 Print("[O01_R2_WS_MANAGE_GATE] slot=",InpWorkspaceSlot,
       " roundtrip=PASS schema=PASS used=",used," expected=9",
       " result=",(pass?"PASS":"FAIL"),
       " path=CANONICAL_TO_WORKSPACE_TO_MANAGE_SCHEMA NO_ORDERS=1 VIRTUAL_NOT_FILL=1 ORDER_SEND_CALLED=0");
 return pass?INIT_SUCCEEDED:INIT_FAILED;
}
