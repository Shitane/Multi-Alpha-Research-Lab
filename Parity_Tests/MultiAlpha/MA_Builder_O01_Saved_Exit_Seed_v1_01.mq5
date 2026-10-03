//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Exit_Seed_v1_01.mq5                        |
//| Writes two generic O01 EXIT SAVE24 definitions: trail ON/OFF.    |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.01"
input string InpTrailOnName="O01_EXIT_GENERIC_V1";
input string InpTrailOffName="O01_EXIT_FIXEDTP_GENERIC_V1";
input bool InpOverwrite=true;
bool SaveExit(const string name,const bool trailing)
{
 string fn="MultiAlpha_Builder_EXIT_"+name+".csv";
 if(!InpOverwrite && FileIsExist(fn,FILE_COMMON)){Print("EXIT PRESERVED: ",fn);return true;}
 int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){Print("RESULT: FAIL - cannot write ",fn);return false;}
 FileWrite(h,"MA_BUILDER_ROLE","1.16",2,24);
 string p[24],a[24];for(int i=0;i<24;i++){p[i]="EMPTY";a[i]="";}int n=0;
 p[n++]="POSITION_COUNT";p[n++]="MOVE_POINTS";
 p[n]="VIRTUAL_SL";a[n++]="POINTS=1500";
 p[n]="FIXED_TP";a[n++]="POINTS=110";
 p[n]="SINGLE_TRAIL";a[n++]=(trailing?"ENABLED=1;START=80;LOCK=20;DISTANCE=40;STEP=10":"ENABLED=0;START=80;LOCK=20;DISTANCE=40;STEP=10");
 p[n++]="BASKET_TRAIL";p[n++]="CLOSE";
 for(int i=0;i<24;i++)FileWrite(h,i+1,p[i],a[i]);FileClose(h);
 Print("EXIT SAVED: ",fn," TRAILING=",(trailing?"ON":"OFF")," SLOTS USED=",n,"/24");return true;
}
int OnInit()
{
 bool a=SaveExit(InpTrailOnName,true),b=SaveExit(InpTrailOffName,false);
 if(!a||!b){Print("RESULT: FAIL - EXIT seed write error");return INIT_FAILED;}
 Print("RESULT: PASS - O01 EXIT SAVE24 trail ON/OFF definitions ready");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnTick(){}
