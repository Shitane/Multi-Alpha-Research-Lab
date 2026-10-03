//+------------------------------------------------------------------+
//| MA_Builder_O01_Saved_Entry_Seed_v1_00.mq5                       |
//| Writes corrected generic O01 ENTRY SAVE24 definition.            |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
input string InpEntryName="O01_ENTRY_GENERIC_V1";
input bool InpOverwrite=false;

int OnInit()
{
 string fn="MultiAlpha_Builder_ENTRY_"+InpEntryName+".csv";
 if(!InpOverwrite && FileIsExist(fn,FILE_COMMON))
 {Print("RESULT: PASS - existing ENTRY seed preserved: ",fn);return INIT_SUCCEEDED;}
 int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');
 if(h==INVALID_HANDLE){Print("RESULT: FAIL - cannot write ",fn);return INIT_FAILED;}
 FileWrite(h,"MA_BUILDER_ROLE","1.16",0,24);
 string p[24],a[24];for(int i=0;i<24;i++){p[i]="EMPTY";a[i]="";}
 int n=0;
 p[n++]="CYCLE_NEW";p[n++]="AND";p[n++]="TIME_ALLOWED";p[n++]="AND";p[n++]="FILTERS_OK";p[n++]="AND";
 p[n++]="BUY_SIDE_ZERO";p[n++]="AND";p[n]="RSI_THRESHOLD";a[n++]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL=30";p[n++]="AND";p[n++]="SIGNAL BUY";
 p[n++]="OR";
 p[n++]="CYCLE_NEW";p[n++]="AND";p[n++]="TIME_ALLOWED";p[n++]="AND";p[n++]="FILTERS_OK";p[n++]="AND";
 p[n++]="SELL_SIDE_ZERO";p[n++]="AND";p[n]="RSI_THRESHOLD";a[n++]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=GT;LEVEL=70";p[n++]="AND";p[n++]="SIGNAL SELL";
 for(int i=0;i<24;i++)FileWrite(h,i+1,p[i],a[i]);FileClose(h);
 Print("ENTRY SAVED: ",fn);
 Print("RESULT: PASS - generic O01 ENTRY SAVE24 definition ready");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 return INIT_SUCCEEDED;
}
void OnTick(){}
