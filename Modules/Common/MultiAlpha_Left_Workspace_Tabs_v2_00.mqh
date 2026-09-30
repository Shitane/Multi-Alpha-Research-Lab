//+------------------------------------------------------------------+
//| MultiAlpha_Left_Workspace_Tabs_v2_00.mqh                        |
//| LOGIC/FILTER tabs with external FILTER workspace ownership.          |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_WORKSPACE_TABS_V1_93_MQH
#define MULTIALPHA_LEFT_WORKSPACE_TABS_V1_93_MQH
enum ENUM_MA_LEFT_VIEW_V200 { MA_LEFT_LOGIC_V200=0,MA_LEFT_FILTER_V200=1 };
class CMultiAlphaLeftWorkspaceTabs200
{
 string p; ENUM_MA_LEFT_VIEW_V200 view; string ids[];
 void V(string n,bool on){if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Btn(string id,int x,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,22);ObjectSetInteger(0,n,OBJPROP_XSIZE,88);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,60);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Lab(string id,int x,int y,string s,int fs=9){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Logic(bool on){for(int i=0;i<ArraySize(ids);i++)V("O01CFG160_"+ids[i],on);}
 void Page(string s,bool on){V(p+s+"_TITLE",on);V(p+s+"_LINE1",on);V(p+s+"_LINE2",on);V(p+s+"_LINE3",on);}
 void Style(string id,bool active){string n=p+id;if(ObjectFind(0,n)<0)return;ObjectSetInteger(0,n,OBJPROP_BGCOLOR,active?C'52,86,104':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,active?C'118,166,188':C'85,95,105');}
 void Paint(){Style("TAB_LOGIC",view==MA_LEFT_LOGIC_V200);Style("TAB_FILTER",view==MA_LEFT_FILTER_V200);}
public:
 CMultiAlphaLeftWorkspaceTabs200(){p="MALEFT200_";view=MA_LEFT_LOGIC_V200;}
 void Create(){string a[]={"L_H_ENTRY","L_H_GRID","L_H_EXIT","L_H_SAFETY","L_H_TIME","L_H_PRESETSEC","L_NEW","NEW","L_BUY","BUY","L_SELL","SELL","L_RSIP","RSIP","L_RSIL","RSIL","L_RSIU","RSIU","L_ATR1P","ATR1P","L_ATR2P","ATR2P","L_ATR2TF","ATR2TF","L_LOT","LOT","L_MULT","MULT","L_MAXLOT","MAXLOT","L_TOTLOT","TOTLOT","L_MAXORD","MAXORD","L_GRID","GRID","L_DYNORD","DYNORD","L_DYNPTS","DYNPTS","L_DISTM","DISTM","L_VSL","VSL","L_STS","STS","L_STL","STL","L_STD","STD","L_BTS","BTS","L_BTL","BTL","L_WARN","WARN","L_PAUSE","PAUSE","L_CLOSE","CLOSE","L_TMODE","TMODE","L_START","START","L_END","END","L_NEWS","NEWS","L_PRESETLAB","PRESET","L_SAVEDLAB","L_SAVEDVAL","NEXT","APPLY","SAVE","LOAD","DELETE","RESET"};ArrayResize(ids,ArraySize(a));for(int i=0;i<ArraySize(a);i++)ids[i]=a[i];Btn("TAB_LOGIC",420,"LOGIC");Btn("TAB_FILTER",510,"FILTER");Apply();}
 void Apply(){Logic(view==MA_LEFT_LOGIC_V200);Paint();ChartRedraw();}
 int Event(int id,string name){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;ENUM_MA_LEFT_VIEW_V200 nv=view;if(name==p+"TAB_LOGIC")nv=MA_LEFT_LOGIC_V200;else if(name==p+"TAB_FILTER")nv=MA_LEFT_FILTER_V200;else return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);view=nv;Apply();Print("[MA_LEFT200_VIEW] view=",(view==MA_LEFT_LOGIC_V200?"LOGIC":"FILTER")," runtime_changed=0");return 1;}
 ENUM_MA_LEFT_VIEW_V200 View()const{return view;} bool FilterVisible()const{return view==MA_LEFT_FILTER_V200;} void Refresh(){Apply();} void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
