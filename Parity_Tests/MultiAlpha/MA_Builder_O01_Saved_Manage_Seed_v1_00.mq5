//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Manage_Seed_v1_00.mq5                      |
//| Writes generic O01 MANAGE SAVE24 definition.                     |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
input string InpManageName="O01_MANAGE_GENERIC_V1";
input bool InpOverwrite=false;
int OnInit()
{
 string fn="MultiAlpha_Builder_MANAGE_"+InpManageName+".csv";
 if(!InpOverwrite && FileIsExist(fn,FILE_COMMON)){Print("RESULT: PASS - existing MANAGE seed preserved: ",fn);return INIT_SUCCEEDED;}
 int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){Print("RESULT: FAIL - cannot write ",fn);return INIT_FAILED;}
 FileWrite(h,"MA_BUILDER_ROLE","1.16",1,24);
 string p[24],a[24];for(int i=0;i<24;i++){p[i]="EMPTY";a[i]="";}int n=0;
 p[n++]="POSITION_COUNT";p[n++]="AND";p[n]="MAX_ORDERS";a[n++]="VALUE=5";p[n++]="AND";
 p[n]="TRAIL_PAUSE";a[n++]="ENABLED=1";p[n++]="AND";p[n]="TIME";a[n++]="ALLOW_OUTSIDE=0";p[n++]="AND";
 p[n++]="NEWS";p[n++]="AND";p[n++]="SPREAD";p[n++]="AND";p[n]="ONE/BAR";a[n++]="ENABLED=1";p[n++]="AND";
 p[n]="FIXED_DIST";a[n++]="POINTS=100";p[n++]="AND";p[n]="DYNAMIC_DIST";a[n++]="START_ORDER=3;START_POINTS=150;MULT=1.5";p[n++]="AND";
 p[n]="LOT_MULT";a[n++]="MULT=2.0";p[n++]="AND";p[n]="MAX_LOT";a[n++]="VALUE=0.50";p[n++]="AND";
 p[n]="MAX_TOTAL";a[n++]="VALUE=1.0";p[n++]="AND";p[n++]="ADD BUY/SELL";
 for(int i=0;i<24;i++)FileWrite(h,i+1,p[i],a[i]);FileClose(h);
 Print("MANAGE SAVED: ",fn);Print("RESULT: PASS - generic O01 MANAGE SAVE24 definition ready");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnTick(){}
