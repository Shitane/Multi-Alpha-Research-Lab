// MultiAlpha_O01_Canonical_40Parts_v1_00.mqh
#ifndef MULTIALPHA_O01_CANONICAL_40PARTS_V1_00_MQH
#define MULTIALPHA_O01_CANONICAL_40PARTS_V1_00_MQH
#define MA_O01_CANONICAL_40P_VERSION "1.00"
#define MA_O01_CANONICAL_ROLE_COUNT 4
#define MA_O01_CANONICAL_SLOTS 40

void MAO01Clear100(string &p[][40],string &v[][40])
{for(int r=0;r<4;r++)for(int i=0;i<40;i++){p[r][i]="EMPTY";v[r][i]="";}}
void MAO01Put100(string &p[][40],string &v[][40],int r,int i,string x,string y="")
{p[r][i]=x;v[r][i]=y;}

void MAO01LoadCanonical100(string &p[][40],string &v[][40])
{
 MAO01Clear100(p,v); int i=0;
 // ENTRY
 string e[39]={"CYCLE_NEW","AND","EMERGENCY_UNLOCKED","AND","TIME_ALLOWED","AND","NEWS_CLEAR","AND","SPREAD_OK","AND",
 "ATR_RANGE","AND","ATR_RANGE","AND","SIDE_COUNT","AND","RSI_THRESHOLD","AND","BUY","OR",
 "CYCLE_NEW","AND","EMERGENCY_UNLOCKED","AND","TIME_ALLOWED","AND","NEWS_CLEAR","AND","SPREAD_OK","AND",
 "ATR_RANGE","AND","ATR_RANGE","AND","SIDE_COUNT","AND","RSI_THRESHOLD","AND","SELL"};
 for(i=0;i<39;i++)p[0][i]=e[i];
 v[0][10]="TF=CURRENT;PERIOD=15;MIN_POINTS=0;MAX_POINTS=10000";
 v[0][12]="TF=CONFIGURED_2;PERIOD=15;MIN_POINTS=0;MAX_POINTS=10000";
 v[0][14]="SIDE=BUY;COND=EQ;VALUE=0";v[0][16]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL=30";
 v[0][30]="TF=CURRENT;PERIOD=15;MIN_POINTS=0;MAX_POINTS=10000";
 v[0][32]="TF=CONFIGURED_2;PERIOD=15;MIN_POINTS=0;MAX_POINTS=10000";
 v[0][34]="SIDE=SELL;COND=EQ;VALUE=0";v[0][36]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=GT;LEVEL=70";

 // GRID: mechanics currently expressible without inventing missing semantics.
 string g[19]={"SIDE_COUNT","AND","MAX_ORDERS","AND","TRAILING_PAUSE","AND","ONE_ORDER_PER_BAR","AND","LAST_PRICE","AND",
 "FIXED_DISTANCE","AND","DYNAMIC_DISTANCE","AND","LOT_MULTIPLIER","AND","MAX_LOT","AND","MAX_TOTAL_LOT"};
 for(i=0;i<19;i++)p[1][i]=g[i];
 v[1][0]="SIDE=CURRENT;COND=GT;VALUE=0";v[1][2]="COUNT=10";v[1][4]="ENABLED=1";v[1][6]="ENABLED=1";
 v[1][10]="POINTS=200";v[1][12]="START_ORDER=3;START_POINTS=300;MULT=1.20";v[1][14]="MULT=1.50";
 v[1][16]="LOT=5.00";v[1][18]="LOT=1.20";

 // MANAGE: position state. Overlap is deliberately deferred until a real generic Part exists.
 string m[7]={"POSITION_COUNT","AND","AVG_PRICE","AND","LAST_PRICE","AND","MOVE_POINTS"};
 for(i=0;i<7;i++)p[2][i]=m[i];

 // EXIT: protection/profit-exit mechanics currently expressible.
 string x[13]={"POSITION_COUNT","AND","AVG_PRICE","AND","MOVE_POINTS","AND","VIRTUAL_SL","OR","FIXED_TP","OR","SINGLE_TRAILING","OR","BASKET_TRAILING"};
 for(i=0;i<13;i++)p[3][i]=x[i];
 v[3][6]="POINTS=1500";v[3][8]="POINTS=110;SCOPE=SINGLE";
 v[3][10]="START=110;LOCK=60;DISTANCE=50;STEP=10";
 v[3][12]="START=100;LOCK=50;DISTANCE=50;STEP=10";
}
#endif
