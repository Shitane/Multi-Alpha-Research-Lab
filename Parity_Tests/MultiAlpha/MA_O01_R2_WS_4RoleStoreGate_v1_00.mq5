//+------------------------------------------------------------------+
//| MA_O01_R2_WS_4RoleStoreGate_v1_00.mq5                           |
//| Gate: O01 four roles in one v3_11 workspace slot.                |
//| Data/validation only. NO ORDERS / VIRTUAL NOT FILL.              |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Interpreter_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh>
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpWorkspaceSlot=1;
CMultiAlphaBuilderSlotWorkspaceStore103 g_ws;
CMultiAlphaBuilderInterpreter103 g_entry;
CMultiAlphaBuilderGridInterpreter100 g_grid;

bool ValidateSchemaRole(const int role,const string &p[],const string &v[],const int expected,string &why)
{
 int used=0;
 for(int i=0;i<40;i++)
 {
  if(p[i]==""||p[i]=="EMPTY")continue;
  used++;
  if(!MA103ValidatePart(role,p[i],v[i],why))return false;
 }
 if(used!=expected){why="USED="+IntegerToString(used)+" EXPECTED="+IntegerToString(expected);return false;}
 why="VALID";return true;
}

int OnInit()
{
 if(InpWorkspaceSlot<1||InpWorkspaceSlot>50)return INIT_PARAMETERS_INCORRECT;
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string names[4]={"O01_ENTRY_CANONICAL","O01_GRID_CANONICAL","O01_MANAGE_CANONICAL","O01_EXIT_CANONICAL"};

 for(int role=0;role<4;role++)
 {
  string a[],b[];ArrayResize(a,40);ArrayResize(b,40);
  for(int i=0;i<40;i++){a[i]=p[role][i];b[i]=v[role][i];}
  if(!g_ws.PutRole(InpWorkspaceSlot,role,names[role],a,b))return INIT_FAILED;
 }

 bool allRoundtrip=true,entryOK=false,gridOK=false,manageOK=false,exitOK=false;
 string why="";
 for(int role=0;role<4;role++)
 {
  string n="",a[],b[];
  if(!g_ws.GetRole(InpWorkspaceSlot,role,n,a,b)||n!=names[role]){allRoundtrip=false;break;}
  for(int i=0;i<40;i++)if(a[i]!=p[role][i]||b[i]!=v[role][i]){allRoundtrip=false;break;}
  if(!allRoundtrip)break;

  if(role==0)
  {
   bool gate[];ArrayResize(gate,40);for(int i=0;i<40;i++)gate[i]=true;
   bool buy=false,sell=false;string trace="";
   entryOK=g_entry.EvaluateEntry40(a,gate,buy,sell,trace,why);
  }
  else if(role==1)gridOK=g_grid.ValidatePlan(a,b,why);
  else if(role==2)manageOK=ValidateSchemaRole(MA_BUILDER_ROLE_MANAGE101,a,b,9,why);
  else if(role==3)exitOK=ValidateSchemaRole(MA_BUILDER_ROLE_EXIT101,a,b,19,why);
 }

 bool pass=allRoundtrip&&entryOK&&gridOK&&manageOK&&exitOK&&g_ws.Revision(InpWorkspaceSlot)==4;
 Print("[O01_R2_WS4_STORE_GATE] slot=",InpWorkspaceSlot,
       " roundtrip=",(allRoundtrip?"PASS":"FAIL"),
       " ENTRY=",(entryOK?"VALID":"INVALID"),
       " GRID=",(gridOK?"VALID":"INVALID"),
       " MANAGE=",(manageOK?"VALID":"INVALID"),
       " EXIT=",(exitOK?"VALID":"INVALID"),
       " revision=",g_ws.Revision(InpWorkspaceSlot)," expectedRevision=4",
       " result=",(pass?"PASS":"FAIL"),
       " path=O01_4ROLES_TO_ONE_V3_11_WORKSPACE_SLOT",
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1 ORDER_SEND_CALLED=0");
 return pass?INIT_SUCCEEDED:INIT_FAILED;
}
