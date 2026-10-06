//+------------------------------------------------------------------+
//| MA_O01_R2_WS_ComposerGate_v1_00.mq5                             |
//| Gate: one v3_11 workspace slot -> Composer v1_04 -> READY.       |
//| Data/validation only. NO ORDERS / VIRTUAL NOT FILL.              |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_Builder_Slot_Workspace_Store_v1_03.mqh>
#include <Builder\MultiAlpha_Builder_Instance_Composer_v1_04.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

input int InpWorkspaceSlot=1;
input int InpInstance=1;
input string InpLogicalSymbol="XAUUSD";
input long InpMagic=46102031;

CMultiAlphaBuilderSlotWorkspaceStore103 g_ws;
CMultiAlphaBuilderInstanceComposer103 g_composer;

int OnInit()
{
 if(InpWorkspaceSlot<1||InpWorkspaceSlot>50||InpInstance<1||InpInstance>50||InpMagic<=0)
  return INIT_PARAMETERS_INCORRECT;

 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 string names[4]={"O01_ENTRY_CANONICAL","O01_GRID_CANONICAL","O01_MANAGE_CANONICAL","O01_EXIT_CANONICAL"};

 for(int role=0;role<4;role++)
 {
  string a[],b[];ArrayResize(a,40);ArrayResize(b,40);
  for(int i=0;i<40;i++){a[i]=p[role][i];b[i]=v[role][i];}
  if(!g_ws.PutRole(InpWorkspaceSlot,role,names[role],a,b))
  {Print("[O01_R2_WS_COMPOSER_GATE] result=FAIL stage=WORKSPACE_PUT role=",role," NO_ORDERS=1");return INIT_FAILED;}
 }

 bool assigned[4]={false,false,false,false};
 string fail="";
 for(int role=0;role<4;role++)
 {
  string name="",a[],b[],reason="";
  if(!g_ws.GetRole(InpWorkspaceSlot,role,name,a,b))
  {fail="WORKSPACE_GET role="+IntegerToString(role);break;}
  assigned[role]=g_composer.AssignRole(InpInstance,role,name,a,b,reason);
  if(!assigned[role]){fail="ASSIGN role="+IntegerToString(role)+" reason="+reason;break;}
 }

 g_composer.SetIdentity(InpInstance,InpLogicalSymbol,InpMagic);
 string readyReason="";bool ready=g_composer.Ready(InpInstance,readyReason);
 bool pass=assigned[0]&&assigned[1]&&assigned[2]&&assigned[3]&&ready&&
           g_ws.Revision(InpWorkspaceSlot)==4&&g_composer.Revision(InpInstance)==4;

 Print("[O01_R2_WS_COMPOSER_GATE] workspaceSlot=",InpWorkspaceSlot,
       " instance=",InpInstance,
       " ENTRY=",(assigned[0]?"ASSIGNED":"FAIL"),
       " GRID=",(assigned[1]?"ASSIGNED":"FAIL"),
       " MANAGE=",(assigned[2]?"ASSIGNED":"FAIL"),
       " EXIT=",(assigned[3]?"ASSIGNED":"FAIL"),
       " workspaceRev=",g_ws.Revision(InpWorkspaceSlot),
       " composerRev=",g_composer.Revision(InpInstance),
       " ready=",(ready?"READY":"DRAFT"),
       " reason=",(fail==""?readyReason:fail),
       " result=",(pass?"PASS":"FAIL"),
       " path=V3_11_WORKSPACE_TO_COMPOSER_V1_04",
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1 ORDER_SEND_CALLED=0");
 Print("[O01_R2_WS_COMPOSER_SUMMARY] ",g_composer.Summary(InpInstance));
 return pass?INIT_SUCCEEDED:INIT_FAILED;
}
