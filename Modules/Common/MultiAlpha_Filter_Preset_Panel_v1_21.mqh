//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Preset_Panel_v1_21.mqh                        |
//| FILTER workspace named preset controls. UI only.                 |
//| NO broker operations.                                            |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_FILTER_PRESET_PANEL_V1_21_MQH
#define MULTIALPHA_FILTER_PRESET_PANEL_V1_21_MQH
class CMultiAlphaFilterPresetPanel121
{
 string p; bool shown;
 void Vis(string id,bool on){string n=p+id;if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Lab(string id,int x,int y,string s,int fs=8,color c=clrWhite){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,c);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,71);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,75);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Ed(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'35,45,53');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_ZORDER,76);ObjectSetString(0,n,OBJPROP_TEXT,s);}
public:
 CMultiAlphaFilterPresetPanel121(){p="MAFPRESET121_";shown=false;}
 void Create(){Lab("TITLE",400,105,"FILTER PRESET",9,C'118,190,220');Lab("NAME",400,124,"NAME");Ed("EDIT",442,120,150,"");Btn("SAVE",600,120,62,"SAVE");Btn("LOAD",668,120,62,"LOAD");Lab("STATUS",400,146,"READY",8,C'170,190,200');Hide();}
 void Show(){shown=true;string ids[]={"TITLE","NAME","EDIT","SAVE","LOAD","STATUS"};for(int i=0;i<ArraySize(ids);i++)Vis(ids[i],true);ChartRedraw();}
 void Hide(){shown=false;string ids[]={"TITLE","NAME","EDIT","SAVE","LOAD","STATUS"};for(int i=0;i<ArraySize(ids);i++)Vis(ids[i],false);ChartRedraw();}
 string Name()const{return ObjectGetString(0,p+"EDIT",OBJPROP_TEXT);}
 void Status(const string s,const bool ok=true){if(ObjectFind(0,p+"STATUS")<0)return;ObjectSetString(0,p+"STATUS",OBJPROP_TEXT,s);ObjectSetInteger(0,p+"STATUS",OBJPROP_COLOR,ok?C'170,210,185':C'235,150,145');ChartRedraw();}
 int Event(const int id,const string name){if(!shown||id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name==p+"SAVE"){ObjectSetInteger(0,name,OBJPROP_STATE,false);return 1;}if(name==p+"LOAD"){ObjectSetInteger(0,name,OBJPROP_STATE,false);return 2;}return 0;}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
