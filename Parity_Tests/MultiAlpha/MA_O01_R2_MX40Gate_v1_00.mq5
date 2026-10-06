//+------------------------------------------------------------------+
//| MA_O01_R2_MX40Gate_v1_00.mq5                                   |
//| P1-D: canonical MANAGE/EXIT 40-Part order/parameter gate.        |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>

bool ExpectSlot(string &p[][40],string &v[][40],int role,int slot,string part,string params="")
{
 bool pass=(p[role][slot]==part && v[role][slot]==params);
 Print("[O01_R2_MX40_SLOT] role=",MA101RoleName(role)," slot=",slot+1,
       " part=",p[role][slot]," params=",v[role][slot],
       " expectedPart=",part," expectedParams=",params,
       " result=",(pass?"PASS":"FAIL"));
 return pass;
}
bool ValidateRole(string &p[][40],string &v[][40],int role,int expectedUsed)
{
 bool ok=true;int used=0;string why="";
 for(int i=0;i<40;i++)
 {
  if(p[role][i]=="" || p[role][i]=="EMPTY")continue;
  used++;
  if(!MA103ValidatePart(role,p[role][i],v[role][i],why))
  {
   Print("[O01_R2_MX40_PART_FAIL] role=",MA101RoleName(role)," slot=",i+1,
         " part=",p[role][i]," params=",v[role][i]," reason=",why);
   ok=false;
  }
 }
 bool countOk=(used==expectedUsed);ok&=countOk;
 Print("[O01_R2_MX40_ROLE] role=",MA101RoleName(role)," used=",used,
       " expectedUsed=",expectedUsed," result=",(ok?"PASS":"FAIL"));
 return ok;
}
int OnInit()
{
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);bool ok=true;

 ok&=ValidateRole(p,v,MA_BUILDER_ROLE_MANAGE101,9);
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_MANAGE101,0,"POSITION_COUNT","");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_MANAGE101,2,"AVG_PRICE","");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_MANAGE101,4,"LAST_PRICE","");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_MANAGE101,6,"MOVE_POINTS","");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_MANAGE101,8,"OVERLAP","ENABLED=1;ORDER=8;PERCENT=3.0");

 ok&=ValidateRole(p,v,MA_BUILDER_ROLE_EXIT101,19);
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,6,"VIRTUAL_SL","POINTS=1500");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,8,"FIXED_TP","POINTS=110;SCOPE=SINGLE");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,10,"SINGLE_TRAILING","START=110;LOCK=60;DISTANCE=50;STEP=10");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,12,"BASKET_TRAILING","START=100;LOCK=50;DISTANCE=50;STEP=10");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,14,"BASKET_FIXED_TP","POINTS=100;EXIT_MODE=FIXED");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,16,"SINGLE_MONEY_TP","MONEY=15.0;TP_MODE=MONEY");
 ok&=ExpectSlot(p,v,MA_BUILDER_ROLE_EXIT101,18,"CLOSE_OPPOSITE","ENABLED=0;AFTER=TP_OR_SL_OR_TRAILING");

 Print("[O01_R2_MX40_GATE] seed=",MA_O01_CANONICAL_40P_102_VERSION,
       " schema=",MA_BUILDER_PART_SCHEMA_103_VERSION,
       " order=ENTRY->GRID->MANAGE->EXIT result=",(ok?"PASS":"FAIL"),
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
