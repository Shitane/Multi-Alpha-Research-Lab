//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Parts_Picker_v1_00.mqh                       |
//| EA PARTS picker for selected free slot. AND/OR are placeable.    |
//| UI only. NO ORDERS.                                              |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PARTS_PICKER_V1_00_MQH
#define MULTIALPHA_BUILDER_PARTS_PICKER_V1_00_MQH
class CMultiAlphaBuilderPartsPicker100{
 string p; int selected_slot; string chosen;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,24);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'24,39,49');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,390);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
public:
 CMultiAlphaBuilderPartsPicker100(){p="MAPICK100_";selected_slot=-1;chosen="";}
 void SetSlot(int i){selected_slot=i;} string Chosen(){return chosen;} void ClearChosen(){chosen="";}
 void Show(){Delete();Box();Lab("TITLE",656,70,"EA PARTS / PART PICKER",10);Lab("SEL",656,94,"Target slot: "+(selected_slot>=0?IntegerToString(selected_slot+1):"NONE")+"   Choose a reusable part",8);
  Lab("IND",656,126,"INDICATOR / CONDITION",9);Btn("RSI",656,148,120,"RSI");Btn("MA",786,148,120,"MA");Btn("ATR",916,148,120,"ATR");
  Lab("LOG",656,190,"LOGIC",9);Btn("AND",656,212,120,"AND");Btn("OR",786,212,120,"OR");
  Lab("STATE",656,254,"STATE / FILTER",9);Btn("TIME",656,276,120,"TIME");Btn("FILTERS",786,276,120,"FILTERS_OK");Btn("COUNT",916,276,120,"SIDE_COUNT_ZERO");
  Lab("ACT",656,318,"ACTION",9);Btn("BUY",656,340,120,"SIGNAL BUY");Btn("SELL",786,340,120,"SIGNAL SELL");Btn("CLEAR",916,340,120,"EMPTY");
  Lab("NOTE",656,382,"AND and OR are independent placeable composition parts.",8);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 bool OnChartEvent(const int id,const string s){if(id!=CHARTEVENT_OBJECT_CLICK)return false;
  if(s==p+"RSI")chosen="RSI_THRESHOLD";else if(s==p+"MA")chosen="MA";else if(s==p+"ATR")chosen="ATR";else if(s==p+"AND")chosen="AND";else if(s==p+"OR")chosen="OR";else if(s==p+"TIME")chosen="TIME_ALLOWED";else if(s==p+"FILTERS")chosen="FILTERS_OK";else if(s==p+"COUNT")chosen="SIDE_COUNT_ZERO";else if(s==p+"BUY")chosen="SIGNAL BUY";else if(s==p+"SELL")chosen="SIGNAL SELL";else if(s==p+"CLEAR")chosen="EMPTY";else return false;return true;}
};
#endif
