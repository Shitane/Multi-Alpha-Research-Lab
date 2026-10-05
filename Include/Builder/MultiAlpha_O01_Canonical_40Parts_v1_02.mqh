//+------------------------------------------------------------------+
//| MultiAlpha_O01_Canonical_40Parts_v1_02.mqh                      |
//| P1-D: add confirmed O01 MANAGE/EXIT Parts to canonical 40P.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_O01_CANONICAL_40PARTS_V1_02_MQH
#define MULTIALPHA_O01_CANONICAL_40PARTS_V1_02_MQH
#include "MultiAlpha_O01_Canonical_40Parts_v1_01.mqh"
#define MA_O01_CANONICAL_40P_102_VERSION "1.02"

void MAO01LoadCanonical102(string &p[][40],string &v[][40])
{
 MAO01LoadCanonical101(p,v);

 // MANAGE: source order keeps state first, then confirmed overlap handling.
 for(int i=0;i<40;i++){p[2][i]="EMPTY";v[2][i]="";}
 string m[9]={"POSITION_COUNT","AND","AVG_PRICE","AND","LAST_PRICE","AND","MOVE_POINTS","AND","OVERLAP"};
 for(int i=0;i<9;i++)p[2][i]=m[i];
 v[2][8]="ENABLED=1;ORDER=8;PERCENT=3.0";

 // EXIT: preserve existing protection/trailing order, then confirmed O01 exit modes.
 for(int i=0;i<40;i++){p[3][i]="EMPTY";v[3][i]="";}
 string x[19]={"POSITION_COUNT","AND","AVG_PRICE","AND","MOVE_POINTS","AND","VIRTUAL_SL","OR","FIXED_TP","OR",
               "SINGLE_TRAILING","OR","BASKET_TRAILING","OR","BASKET_FIXED_TP","OR","SINGLE_MONEY_TP","OR","CLOSE_OPPOSITE"};
 for(int i=0;i<19;i++)p[3][i]=x[i];
 v[3][6]="POINTS=1500";
 v[3][8]="POINTS=110;SCOPE=SINGLE";
 v[3][10]="START=110;LOCK=60;DISTANCE=50;STEP=10";
 v[3][12]="START=100;LOCK=50;DISTANCE=50;STEP=10";
 v[3][14]="POINTS=100;EXIT_MODE=FIXED";
 v[3][16]="MONEY=15.0;TP_MODE=MONEY";
 v[3][18]="ENABLED=0;AFTER=TP_OR_SL_OR_TRAILING";
}
#endif
