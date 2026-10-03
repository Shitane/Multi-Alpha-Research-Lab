//+------------------------------------------------------------------+
//| MultiAlpha_Right_Workspace_Tabs_v1_04.mqh                       |
//| SLOT-only right workspace selector. Builder/EA PARTS are owned by left LOGIC.         |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_RIGHT_WORKSPACE_TABS_V1_04_MQH
#define MULTIALPHA_RIGHT_WORKSPACE_TABS_V1_04_MQH

enum ENUM_MA_RIGHT_VIEW_V104 { MA_RIGHT_SLOT_V104=0 };

class CMultiAlphaRightWorkspaceTabs104
{
 string p; ENUM_MA_RIGHT_VIEW_V104 view;
 void Btn(string id,int x,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,30);ObjectSetInteger(0,n,OBJPROP_XSIZE,88);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,160);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Style(string id,bool active){string n=p+id;if(ObjectFind(0,n)<0)return;ObjectSetInteger(0,n,OBJPROP_BGCOLOR,active?C'52,86,104':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,active?C'118,166,188':C'85,95,105');}
 void Paint(){Style("TAB_SLOT",true);ChartRedraw();}
public:
 CMultiAlphaRightWorkspaceTabs104(){p="MARIGHT104_";view=MA_RIGHT_SLOT_V104;}
 void Create(){Btn("TAB_SLOT",656,"SLOT");Paint();}
 int Event(const int id,const string name){if(id!=CHARTEVENT_OBJECT_CLICK||name!=p+"TAB_SLOT")return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);view=MA_RIGHT_SLOT_V104;Paint();return 1;}
 void Select(const int v){view=MA_RIGHT_SLOT_V104;Paint();}
 ENUM_MA_RIGHT_VIEW_V104 View()const{return view;} bool SlotVisible()const{return true;} bool LogicVisible()const{return false;} bool PartsVisible()const{return false;}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
