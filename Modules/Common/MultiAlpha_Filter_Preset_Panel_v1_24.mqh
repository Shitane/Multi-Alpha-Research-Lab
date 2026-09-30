//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Preset_Panel_v1_24.mqh                        |
//| FILTER preset controls constrained to LEFT workspace.             |
//| UI only. NO broker operations.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_FILTER_PRESET_PANEL_V1_24_MQH
#define MULTIALPHA_FILTER_PRESET_PANEL_V1_24_MQH
class CMultiAlphaFilterPresetPanel124
{
 string p;bool shown;
 void Vis(string id,bool on){string n=p+id;if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Lab(string id,int x,int y,string s,int fs=8,color c=clrWhite){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,c);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,71);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,75);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Ed(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'35,45,53');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_ZORDER,76);ObjectSetString(0,n,OBJPROP_TEXT,s);}
public:
 CMultiAlphaFilterPresetPanel124(){p="MAFPRESET124_";shown=false;}
 // Keep this row well left of the workspace divider (~x=980 in current host).
 // Right edge is x=938, leaving a visible safety margin.
 void Create(){Lab("PRE",400,106,"PRESET",8,C'118,190,220');Ed("EDIT",448,101,108,"");Btn("SAVE",564,101,54,"SAVE");Btn("LOAD",626,101,54,"LOAD");Lab("STATUS",400,124,"READY",8,C'170,190,200');Hide();}
 void Show(){shown=true;string a[]={"PRE","EDIT","SAVE","LOAD","STATUS"};for(int i=0;i<ArraySize(a);i++)Vis(a[i],true);ChartRedraw();}
 void Hide(){shown=false;string a[]={"PRE","EDIT","SAVE","LOAD","STATUS"};for(int i=0;i<ArraySize(a);i++)Vis(a[i],false);ChartRedraw();}
 string Name()const{return ObjectGetString(0,p+"EDIT",OBJPROP_TEXT);}
 void Status(string s,bool ok=true){if(ObjectFind(0,p+"STATUS")<0)return;ObjectSetString(0,p+"STATUS",OBJPROP_TEXT,s);ObjectSetInteger(0,p+"STATUS",OBJPROP_COLOR,ok?C'170,210,185':C'235,150,145');ChartRedraw();}
 int Event(int id,string name){if(!shown||id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name==p+"SAVE"){ObjectSetInteger(0,name,OBJPROP_STATE,false);return 1;}if(name==p+"LOAD"){ObjectSetInteger(0,name,OBJPROP_STATE,false);return 2;}return 0;}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
