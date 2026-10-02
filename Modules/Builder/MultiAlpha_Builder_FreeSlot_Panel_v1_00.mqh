//+------------------------------------------------------------------+
//| MultiAlpha_Builder_FreeSlot_Panel_v1_00.mqh                     |
//| LB-01 general-purpose empty-slot construction board. UI only.    |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_00_MQH
#define MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_00_MQH
#define MA_BUILDER_FREE_SLOT_PANEL_VERSION "1.00"
#define MA_BUILDER_UI_SLOT_COUNT 8

class CMultiAlphaBuilderFreeSlotPanel100
{
 string p;
 string slot[MA_BUILDER_UI_SLOT_COUNT];
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'24,39,49');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,390);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
public:
 CMultiAlphaBuilderFreeSlotPanel100(){p="MAFREESLOT100_";for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++)slot[i]="EMPTY";}
 void LoadO01EntryExample(){string a[8]={"CYCLE_NEW","AND","TIME_ALLOWED","AND","FILTERS_OK","AND","RSI_THRESHOLD","SIGNAL BUY/SELL"};for(int i=0;i<8;i++)slot[i]=a[i];}
 void ClearSlots(){for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++)slot[i]="EMPTY";}
 void Show(){Delete();Box();Lab("TITLE",656,70,"EA LOGIC / FREE-SLOT BUILDER",10);Lab("SUB",656,92,"Definition: BUILDER_E01   Role: ENTRY   NO ORDERS",8);Lab("HELP",656,112,"Click a slot to select/replace a reusable part. AND / OR are placeable parts.",8);
  int y=145;for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++){string no=(i<9?"0":"")+IntegerToString(i+1);Lab("N"+IntegerToString(i),656,y+4,no,8);Btn("S"+IntegerToString(i),686,y,360,slot[i]);Btn("E"+IntegerToString(i),1055,y,90,(slot[i]=="EMPTY"?"ADD":"EDIT"));y+=30;}
  Btn("CLEAR",656,400,100,"CLEAR");Btn("EXAMPLE",765,400,150,"LOAD O01 ENTRY");Lab("FOOT",930,405,"Foundation first / O01 is parity target",8);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 bool OnChartEvent(const int id,const string sparam){if(id!=CHARTEVENT_OBJECT_CLICK)return false;if(sparam==p+"CLEAR"){ClearSlots();Show();return true;}if(sparam==p+"EXAMPLE"){LoadO01EntryExample();Show();return true;}return (StringFind(sparam,p+"S")==0||StringFind(sparam,p+"E")==0);}
};
#endif
