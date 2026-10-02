//+------------------------------------------------------------------+
//| MultiAlpha_Builder_FreeSlot_Panel_v1_05.mqh                     |
//| Free-slot board with per-slot part + parameter persistence.       |
//| UI only. NO ORDERS / VIRTUAL NOT FILL.                           |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_05_MQH
#define MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_05_MQH
#define MA_BUILDER_FREE_SLOT_PANEL_VERSION "1.05"
#define MA_BUILDER_UI_SLOT_COUNT 8
class CMultiAlphaBuilderFreeSlotPanel105{
 string p,slot[MA_BUILDER_UI_SLOT_COUNT],params[MA_BUILDER_UI_SLOT_COUNT]; int selected;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,int state=0){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);color bg=(state==2?C'32,135,160':(state==1?C'30,82,98':C'24,39,49'));ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,390);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
 int ParseSlot(string s){for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++)if(s==p+"S"+IntegerToString(i)||s==p+"E"+IntegerToString(i))return i;return -1;}
public:
 CMultiAlphaBuilderFreeSlotPanel105(){p="MAFREESLOT105_";selected=-1;for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++){slot[i]="EMPTY";params[i]="";}}
 int Selected(){return selected;} string SelectedPart(){return selected>=0?slot[selected]:"NONE";} string SelectedParams(){return selected>=0?params[selected]:"";}
 bool PutSelected(string part,string par){if(selected<0||selected>=MA_BUILDER_UI_SLOT_COUNT)return false;slot[selected]=part;params[selected]=par;return true;}
 void ClearSlots(){for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++){slot[i]="EMPTY";params[i]="";}selected=-1;}
 void LoadO01EntryExample(){string a[8]={"CYCLE_NEW","AND","TIME_ALLOWED","AND","FILTERS_OK","AND","RSI_THRESHOLD","SIGNAL BUY/SELL"};for(int i=0;i<8;i++){slot[i]=a[i];params[i]="";}params[6]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL=30";selected=-1;}
 void Show(){Delete();Box();Lab("TITLE",656,70,"EA LOGIC / FREE-SLOT BUILDER",10);Lab("SUB",656,92,"Definition: BUILDER_E01   Role: ENTRY   NO ORDERS",8);Lab("HELP",656,112,"ADD/EDIT -> EA PARTS -> configure -> APPLY. Each slot keeps its own settings.",8);int y=145;for(int i=0;i<MA_BUILDER_UI_SLOT_COUNT;i++){string no=(i<9?"0":"")+IntegerToString(i+1);Lab("N"+IntegerToString(i),656,y+4,(i==selected?"> ":"  ")+no,8);string shown=slot[i];if(params[i]!="")shown+="  {"+params[i]+"}";int slot_state=(i==selected?2:(slot[i]!="EMPTY"?1:0));Btn("S"+IntegerToString(i),686,y,360,shown,slot_state);Btn("E"+IntegerToString(i),1055,y,90,(slot[i]=="EMPTY"?"ADD":"EDIT"),slot_state);y+=30;}Btn("CLEAR",656,400,100,"CLEAR",0);Btn("EXAMPLE",765,400,150,"LOAD O01 ENTRY",0);Lab("FOOT",930,405,"AND / OR remain independent placeable parts",8);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 int OnChartEvent(const int id,const string sparam){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(sparam==p+"CLEAR"){ClearSlots();Show();return 1;}if(sparam==p+"EXAMPLE"){LoadO01EntryExample();Show();return 1;}int i=ParseSlot(sparam);if(i>=0){selected=i;Show();return 2;}return 0;}
};
#endif
