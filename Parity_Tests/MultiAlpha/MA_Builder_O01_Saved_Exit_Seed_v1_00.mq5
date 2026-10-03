//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Exit_Seed_v1_00.mq5                        |
//| Writes generic O01 EXIT SAVE24 definition.                       |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
input string InpExitName="O01_EXIT_GENERIC_V1";
input bool InpOverwrite=true;
int OnInit()
{
 string fn="MultiAlpha_Builder_EXIT_"+InpExitName+".csv";
 if(!InpOverwrite && FileIsExist(fn,FILE_COMMON)){Print("RESULT: PASS - existing EXIT seed preserved: ",fn);return INIT_SUCCEEDED;}
 int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){Print("RESULT: FAIL - cannot write ",fn);return INIT_FAILED;}
 FileWrite(h,"MA_BUILDER_ROLE","1.16",2,24);
 string p[24],a[24];for(int i=0;i<24;i++){p[i]="EMPTY";a[i]="";}int n=0;
 p[n++]="POSITION_COUNT";p[n++]="MOVE_POINTS";
 p[n]="VIRTUAL_SL";a[n++]="POINTS=1500";
 p[n]="FIXED_TP";a[n++]="POINTS=110";
 p[n]="SINGLE_TRAIL";a[n++]="ENABLED=1;START=80;LOCK=20;DISTANCE=40;STEP=10";
 p[n++]="BASKET_TRAIL";p[n++]="CLOSE";
 for(int i=0;i<24;i++)FileWrite(h,i+1,p[i],a[i]);FileClose(h);
 Print("EXIT SAVED: ",fn);Print("SLOTS USED: ",n,"/24");
 Print("RESULT: PASS - generic O01 EXIT SAVE24 definition ready");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnTick(){}
