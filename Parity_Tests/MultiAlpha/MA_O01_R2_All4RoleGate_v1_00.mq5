//+------------------------------------------------------------------+
//| MA_O01_R2_All4RoleGate_v1_00.mq5                               |
//| P1-E: canonical O01 full 4-role / 40-Part integration gate.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

bool CheckRole(string &p[][40],string &v[][40],int role,int expectedUsed)
{
 bool ok=true; int used=0; string why="";
 for(int i=0;i<40;i++)
 {
  if(p[role][i]=="" || p[role][i]=="EMPTY") continue;
  used++;
  if(!MA103ValidatePart(role,p[role][i],v[role][i],why))
  {
   Print("[O01_R2_ALL4_PART_FAIL] role=",MA101RoleName(role)," slot=",i+1,
         " part=",p[role][i]," params=",v[role][i]," reason=",why);
   ok=false;
  }
 }
 bool countOk=(used==expectedUsed); ok&=countOk;
 Print("[O01_R2_ALL4_ROLE] role=",MA101RoleName(role)," used=",used,
       " expectedUsed=",expectedUsed," result=",(ok?"PASS":"FAIL"));
 return ok;
}

bool HasAt(string &p[][40],int role,int slot,string part)
{
 bool pass=(p[role][slot]==part);
 Print("[O01_R2_ALL4_ANCHOR] role=",MA101RoleName(role)," slot=",slot+1,
       " part=",p[role][slot]," expected=",part," result=",(pass?"PASS":"FAIL"));
 return pass;
}

int OnInit()
{
 string p[4][40],v[4][40];
 MAO01LoadCanonical102(p,v);
 bool ok=true;

 // Full canonical role validation/counts.
 ok&=CheckRole(p,v,MA_BUILDER_ROLE_ENTRY101,39);
 ok&=CheckRole(p,v,MA_BUILDER_ROLE_GRID101,33);
 ok&=CheckRole(p,v,MA_BUILDER_ROLE_MANAGE101,9);
 ok&=CheckRole(p,v,MA_BUILDER_ROLE_EXIT101,19);

 // Role-boundary anchors: signal -> add -> state -> protection/exit.
 ok&=HasAt(p,MA_BUILDER_ROLE_ENTRY101,18,"BUY");
 ok&=HasAt(p,MA_BUILDER_ROLE_ENTRY101,38,"SELL");
 ok&=HasAt(p,MA_BUILDER_ROLE_GRID101,30,"ADD_BUY");
 ok&=HasAt(p,MA_BUILDER_ROLE_GRID101,32,"ADD_SELL");
 ok&=HasAt(p,MA_BUILDER_ROLE_MANAGE101,8,"OVERLAP");
 ok&=HasAt(p,MA_BUILDER_ROLE_EXIT101,6,"VIRTUAL_SL");
 ok&=HasAt(p,MA_BUILDER_ROLE_EXIT101,18,"CLOSE_OPPOSITE");

 int total=39+33+9+19;
 Print("[O01_R2_ALL4_GATE] seed=",MA_O01_CANONICAL_40P_102_VERSION,
       " schema=",MA_BUILDER_PART_SCHEMA_103_VERSION,
       " order=ENTRY->GRID->MANAGE->EXIT totalUsed=",total,
       " result=",(ok?"PASS":"FAIL"),
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
