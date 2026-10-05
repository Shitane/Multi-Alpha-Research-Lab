//+------------------------------------------------------------------+
//| MA_O01_R2_ManageExitMissingPartsGate_v1_00.mq5                  |
//| P1-C: O01 Manage/Exit missing-Part schema gate. NO ORDERS.       |
//+------------------------------------------------------------------+
#property strict
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>

bool T(int role,string part,string par,bool expected)
{
 string why="";bool got=MA103ValidatePart(role,part,par,why);bool pass=(got==expected);
 Print("[O01_R2_MX_PART] role=",MA101RoleName(role)," part=",part," expected=",(int)expected,
       " got=",(int)got," result=",(pass?"PASS":"FAIL")," reason=",why);
 return pass;
}
int OnInit()
{
 bool ok=true;
 // Exact O01 defaults / semantics.
 ok&=T(MA_BUILDER_ROLE_MANAGE101,"OVERLAP","ENABLED=1;ORDER=8;PERCENT=3.0",true);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"BASKET_FIXED_TP","POINTS=100;EXIT_MODE=FIXED",true);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"SINGLE_MONEY_TP","MONEY=15.0;TP_MODE=MONEY",true);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"CLOSE_OPPOSITE","ENABLED=0;AFTER=TP_OR_SL_OR_TRAILING",true);

 // Cross-role rejection.
 ok&=T(MA_BUILDER_ROLE_GRID101,"OVERLAP","ENABLED=1;ORDER=8;PERCENT=3.0",false);
 ok&=T(MA_BUILDER_ROLE_MANAGE101,"BASKET_FIXED_TP","POINTS=100;EXIT_MODE=FIXED",false);
 ok&=T(MA_BUILDER_ROLE_ENTRY101,"SINGLE_MONEY_TP","MONEY=15.0;TP_MODE=MONEY",false);
 ok&=T(MA_BUILDER_ROLE_GRID101,"CLOSE_OPPOSITE","ENABLED=0;AFTER=TP_OR_SL_OR_TRAILING",false);

 // Invalid parameter rejection.
 ok&=T(MA_BUILDER_ROLE_MANAGE101,"OVERLAP","ENABLED=1;ORDER=1;PERCENT=3.0",false);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"BASKET_FIXED_TP","POINTS=-1;EXIT_MODE=FIXED",false);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"SINGLE_MONEY_TP","MONEY=-1;TP_MODE=MONEY",false);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"CLOSE_OPPOSITE","ENABLED=1;AFTER=GRID",false);

 Print("[O01_R2_MANAGE_EXIT_MISSING_PARTS_GATE] schema=",MA_BUILDER_PART_SCHEMA_103_VERSION,
       " source=O01_MANAGESIDE+TRYOVERLAP result=",(ok?"PASS":"FAIL"),
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
