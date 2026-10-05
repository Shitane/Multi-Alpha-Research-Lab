//+------------------------------------------------------------------+
//| MA_O01_R2_GridMissingPartsGate_v1_00.mq5                        |
//| P1-A: O01 GRID missing-Part schema gate. NO ORDERS.              |
//+------------------------------------------------------------------+
#property strict
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_02.mqh>

bool T(int role,string part,string par,bool expected)
{
 string why="";bool got=MA102ValidatePart(role,part,par,why);bool pass=(got==expected);
 Print("[O01_R2_GRID_PART] role=",MA101RoleName(role)," part=",part," expected=",(int)expected,
       " got=",(int)got," result=",(pass?"PASS":"FAIL")," reason=",why);
 return pass;
}
int OnInit()
{
 bool ok=true;
 // Source-faithful O01 GRID guards.
 ok&=T(MA_BUILDER_ROLE_GRID101,"DD_BELOW","ENABLED=1;PERCENT=12.0",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"GRID_TIME_ALLOWED","ALLOW_OUTSIDE=1",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"GRID_NEWS_CLEAR","MODE=MANAGE_ONLY",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"SPREAD_OK","",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"DISTANCE_REACHED","SIDE=BUY;BASIS=NEWEST_POSITION",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"DISTANCE_REACHED","SIDE=SELL;BASIS=NEWEST_POSITION",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"ADD_BUY","",true);
 ok&=T(MA_BUILDER_ROLE_GRID101,"ADD_SELL","",true);

 // Cross-role rejection is part of the contract.
 ok&=T(MA_BUILDER_ROLE_ENTRY101,"DD_BELOW","ENABLED=1;PERCENT=12.0",false);
 ok&=T(MA_BUILDER_ROLE_MANAGE101,"DISTANCE_REACHED","SIDE=BUY;BASIS=NEWEST_POSITION",false);
 ok&=T(MA_BUILDER_ROLE_EXIT101,"GRID_NEWS_CLEAR","MODE=MANAGE_ONLY",false);

 // Invalid parameter rejection.
 ok&=T(MA_BUILDER_ROLE_GRID101,"DD_BELOW","ENABLED=1;PERCENT=-1",false);
 ok&=T(MA_BUILDER_ROLE_GRID101,"GRID_TIME_ALLOWED","ALLOW_OUTSIDE=MAYBE",false);
 ok&=T(MA_BUILDER_ROLE_GRID101,"GRID_NEWS_CLEAR","MODE=UNKNOWN",false);
 ok&=T(MA_BUILDER_ROLE_GRID101,"DISTANCE_REACHED","SIDE=BUY;BASIS=AVERAGE_PRICE",false);

 Print("[O01_R2_GRID_MISSING_PARTS_GATE] schema=",MA_BUILDER_PART_SCHEMA_102_VERSION,
       " source=O01_MANAGESIDE result=",(ok?"PASS":"FAIL"),
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
