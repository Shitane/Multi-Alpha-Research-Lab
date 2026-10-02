//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Parts_Picker_v1_01.mqh                       |
//| Part selection + parameter editor + APPLY. UI only / NO ORDERS.  |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PARTS_PICKER_V1_01_MQH
#define MULTIALPHA_BUILDER_PARTS_PICKER_V1_01_MQH
class CMultiAlphaBuilderPartsPicker101{
 string p; int selected_slot; string chosen,loaded_params;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,bool active=false){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,24);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,active?C'34,105,125':C'24,39,49');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Edit(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'20,31,40');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'65,90,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,45);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,420);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
 string Val(string key,string def){string a[];int n=StringSplit(loaded_params,';',a);for(int i=0;i<n;i++){int q=StringFind(a[i],"=");if(q>0&&StringSubstr(a[i],0,q)==key)return StringSubstr(a[i],q+1);}return def;}
 string Txt(string id,string def){string n=p+id;return ObjectFind(0,n)>=0?ObjectGetString(0,n,OBJPROP_TEXT):def;}
 bool Active(string id){return chosen==id;}
 void DrawParams(){Lab("CFG",656,304,"PART SETTINGS",9);
  if(chosen=="RSI_THRESHOLD"){Lab("L1",656,330,"TF",8);Edit("P1",700,326,80,Val("TF","CURRENT"));Lab("L2",790,330,"Period",8);Edit("P2",840,326,60,Val("PERIOD","8"));Lab("L3",910,330,"Price",8);Edit("P3",955,326,80,Val("PRICE","CLOSE"));Lab("L4",656,360,"Cond",8);Edit("P4",700,356,80,Val("COND","LT"));Lab("L5",790,360,"Level",8);Edit("P5",840,356,80,Val("LEVEL","30"));}
  else if(chosen=="MA"){Lab("L1",656,330,"TF",8);Edit("P1",700,326,80,Val("TF","CURRENT"));Lab("L2",790,330,"Period",8);Edit("P2",840,326,60,Val("PERIOD","20"));Lab("L3",910,330,"Method",8);Edit("P3",965,326,80,Val("METHOD","SMA"));Lab("L4",656,360,"Price",8);Edit("P4",700,356,80,Val("PRICE","CLOSE"));}
  else if(chosen=="ATR"){Lab("L1",656,330,"TF",8);Edit("P1",700,326,80,Val("TF","CURRENT"));Lab("L2",790,330,"Period",8);Edit("P2",840,326,60,Val("PERIOD","15"));Lab("L3",910,330,"Multiplier",8);Edit("P3",975,326,70,Val("MULT","2.0"));}
  else Lab("NOP",656,330,"This part has no numeric parameters in LB-01.",8);
  Btn("APPLY",656,400,120,"APPLY",true);Btn("CANCEL",786,400,120,"CANCEL");}
public:
 CMultiAlphaBuilderPartsPicker101(){p="MAPICK101_";selected_slot=-1;chosen="";loaded_params="";}
 void SetSlot(int i,string part,string par){selected_slot=i;chosen=(part=="EMPTY"?"":part);loaded_params=par;}
 string Chosen(){return chosen==""?"EMPTY":chosen;}
 string Parameters(){if(chosen=="RSI_THRESHOLD")return "TF="+Txt("P1","CURRENT")+";PERIOD="+Txt("P2","8")+";PRICE="+Txt("P3","CLOSE")+";COND="+Txt("P4","LT")+";LEVEL="+Txt("P5","30");if(chosen=="MA")return "TF="+Txt("P1","CURRENT")+";PERIOD="+Txt("P2","20")+";METHOD="+Txt("P3","SMA")+";PRICE="+Txt("P4","CLOSE");if(chosen=="ATR")return "TF="+Txt("P1","CURRENT")+";PERIOD="+Txt("P2","15")+";MULT="+Txt("P3","2.0");return "";}
 void Show(){Delete();Box();Lab("TITLE",656,70,"EA PARTS / PART PICKER",10);Lab("SEL",656,94,"Target slot: "+(selected_slot>=0?IntegerToString(selected_slot+1):"NONE")+"   Active: "+(chosen==""?"NONE":chosen),8);
  Lab("IND",656,122,"INDICATOR / CONDITION",9);Btn("RSI",656,142,110,"RSI",Active("RSI_THRESHOLD"));Btn("MA",776,142,110,"MA",Active("MA"));Btn("ATR",896,142,110,"ATR",Active("ATR"));
  Lab("LOG",656,178,"LOGIC",9);Btn("AND",656,198,110,"AND",Active("AND"));Btn("OR",776,198,110,"OR",Active("OR"));
  Lab("STATE",656,234,"STATE / FILTER",9);Btn("TIME",656,254,110,"TIME",Active("TIME_ALLOWED"));Btn("FILTERS",776,254,110,"FILTERS",Active("FILTERS_OK"));Btn("COUNT",896,254,130,"SIDE COUNT",Active("SIDE_COUNT_ZERO"));Btn("EMPTY",1036,254,100,"EMPTY",Active("EMPTY"));
  DrawParams();ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 int OnChartEvent(const int id,const string s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;string next="";
  if(s==p+"RSI")next="RSI_THRESHOLD";else if(s==p+"MA")next="MA";else if(s==p+"ATR")next="ATR";else if(s==p+"AND")next="AND";else if(s==p+"OR")next="OR";else if(s==p+"TIME")next="TIME_ALLOWED";else if(s==p+"FILTERS")next="FILTERS_OK";else if(s==p+"COUNT")next="SIDE_COUNT_ZERO";else if(s==p+"EMPTY")next="EMPTY";
  else if(s==p+"APPLY")return 2;else if(s==p+"CANCEL")return 3;else return 0;
  if(next!=chosen){chosen=next;loaded_params="";}Show();return 1;}
};
#endif
