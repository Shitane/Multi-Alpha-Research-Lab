//+------------------------------------------------------------------+
//| MA_O01_R2_RoleSchema_Gate_v1_00.mq5                             |
//| Compile/runtime gate for canonical 4-role schema. NO ORDERS.     |
//+------------------------------------------------------------------+
#property strict
#include <Builder\\MultiAlpha_Builder_Part_Schema_v1_01.mqh>

int OnInit()
{
 bool ok=true;string why="";
 ok&=(MA_BUILDER_ROLE_ENTRY101==0 && MA_BUILDER_ROLE_GRID101==1 && MA_BUILDER_ROLE_MANAGE101==2 && MA_BUILDER_ROLE_EXIT101==3);
 ok&=MA101ValidatePart(MA_BUILDER_ROLE_ENTRY101,"RSI_THRESHOLD","PERIOD=8;COND=LT;LEVEL=30",why);
 ok&=MA101ValidatePart(MA_BUILDER_ROLE_ENTRY101,"TIME_ALLOWED","",why);
 ok&=MA101ValidatePart(MA_BUILDER_ROLE_GRID101,"FIXED_DISTANCE","POINTS=200",why);
 ok&=MA101ValidatePart(MA_BUILDER_ROLE_GRID101,"ADD_BUY","",why);
 ok&=MA101ValidatePart(MA_BUILDER_ROLE_MANAGE101,"AVG_PRICE","",why);
 ok&=MA101ValidatePart(MA_BUILDER_ROLE_EXIT101,"VIRTUAL_SL","POINTS=1500",why);
 bool reject_grid_in_entry=!MA101ValidatePart(MA_BUILDER_ROLE_ENTRY101,"ADD_BUY","",why);
 bool reject_entry_in_grid=!MA101ValidatePart(MA_BUILDER_ROLE_GRID101,"RSI_THRESHOLD","PERIOD=8;COND=LT;LEVEL=30",why);
 ok&=reject_grid_in_entry&&reject_entry_in_grid;
 Print("[O01_R2_ROLE_SCHEMA] version=",MA_BUILDER_PART_SCHEMA_VERSION,
       " order=",MA101RoleName(0),"->",MA101RoleName(1),"->",MA101RoleName(2),"->",MA101RoleName(3),
       " cross_role_reject=",(reject_grid_in_entry&&reject_entry_in_grid?1:0),
       " result=",(ok?"PASS":"FAIL")," NO_ORDERS=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
