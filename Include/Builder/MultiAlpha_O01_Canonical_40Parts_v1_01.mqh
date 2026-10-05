//+------------------------------------------------------------------+
//| MultiAlpha_O01_Canonical_40Parts_v1_01.mqh                      |
//| P1-B: source-ordered O01 GRID pipeline inside one 40-Part role.  |
//| CURRENT side is resolved by ManageSide(BUY/SELL) at runtime.     |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_O01_CANONICAL_40PARTS_V1_01_MQH
#define MULTIALPHA_O01_CANONICAL_40PARTS_V1_01_MQH
#include "MultiAlpha_O01_Canonical_40Parts_v1_00.mqh"
#define MA_O01_CANONICAL_40P_101_VERSION "1.01"

void MAO01LoadCanonical101(string &p[][40],string &v[][40])
{
 MAO01LoadCanonical100(p,v);

 // GRID is evaluated once per CURRENT side, matching O01 ManageSide(type).
 for(int i=0;i<40;i++){p[1][i]="EMPTY";v[1][i]="";}
 string g[33]={
  "SIDE_COUNT","AND","MAX_ORDERS","AND","DD_BELOW","AND","TRAILING_PAUSE","AND",
  "GRID_TIME_ALLOWED","AND","GRID_NEWS_CLEAR","AND","SPREAD_OK","AND","ONE_ORDER_PER_BAR","AND",
  "LAST_PRICE","AND","FIXED_DISTANCE","AND","DYNAMIC_DISTANCE","AND","DISTANCE_REACHED","AND",
  "LOT_MULTIPLIER","AND","MAX_LOT","AND","MAX_TOTAL_LOT","AND","ADD_BUY","OR","ADD_SELL"
 };
 for(int i=0;i<33;i++)p[1][i]=g[i];

 v[1][0]="SIDE=CURRENT;COND=GT;VALUE=0";
 v[1][2]="COUNT=10";
 v[1][4]="ENABLED=1;PERCENT=12.0";
 v[1][6]="ENABLED=1";
 v[1][8]="ALLOW_OUTSIDE=1";
 v[1][10]="MODE=MANAGE_ONLY";
 v[1][14]="ENABLED=1";
 v[1][18]="POINTS=200";
 v[1][20]="START_ORDER=3;START_POINTS=300;MULT=1.20";
 v[1][22]="SIDE=CURRENT;BASIS=NEWEST_POSITION";
 v[1][24]="MULT=1.50";
 v[1][26]="LOT=5.00";
 v[1][28]="LOT=1.20";
}
#endif
