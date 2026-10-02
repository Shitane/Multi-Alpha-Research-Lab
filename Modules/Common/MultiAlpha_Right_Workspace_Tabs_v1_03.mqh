//+------------------------------------------------------------------+
//| MultiAlpha_Right_Workspace_Tabs_v1_03.mqh                       |
//| SLOT / EA LOGIC / EA PARTS workspace selector. UI only.         |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_RIGHT_WORKSPACE_TABS_V1_03_MQH
#define MULTIALPHA_RIGHT_WORKSPACE_TABS_V1_03_MQH

enum ENUM_MA_RIGHT_VIEW_V103 { MA_RIGHT_SLOT_V103=0, MA_RIGHT_LOGIC_V103=1, MA_RIGHT_PARTS_V103=2 };

class CMultiAlphaRightWorkspaceTabs103
{
 string p; ENUM_MA_RIGHT_VIEW_V103 view;
 void Btn(string id,int x,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,30);ObjectSetInteger(0,n,OBJPROP_XSIZE,88);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,160);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Style(string id,bool active){string n=p+id;if(ObjectFind(0,n)<0)return;ObjectSetInteger(0,n,OBJPROP_BGCOLOR,active?C'52,86,104':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,active?C'118,166,188':C'85,95,105');}
 void Paint(){Style("TAB_SLOT",view==MA_RIGHT_SLOT_V103);Style("TAB_LOGIC",view==MA_RIGHT_LOGIC_V103);Style("TAB_PARTS",view==MA_RIGHT_PARTS_V103);ChartRedraw();}
public:
 CMultiAlphaRightWorkspaceTabs103(){p="MARIGHT103_";view=MA_RIGHT_SLOT_V103;}
 void Create(){Btn("TAB_SLOT",656,"SLOT");Btn("TAB_LOGIC",746,"EA LOGIC");Btn("TAB_PARTS",836,"EA PARTS");Paint();}
 int Event(const int id,const string name){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;ENUM_MA_RIGHT_VIEW_V103 nv=view;if(name==p+"TAB_SLOT")nv=MA_RIGHT_SLOT_V103;else if(name==p+"TAB_LOGIC")nv=MA_RIGHT_LOGIC_V103;else if(name==p+"TAB_PARTS")nv=MA_RIGHT_PARTS_V103;else return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);view=nv;Paint();Print("[MA_RIGHT103_VIEW] view=",(view==MA_RIGHT_SLOT_V103?"SLOT":(view==MA_RIGHT_LOGIC_V103?"EA_LOGIC":"EA_PARTS"))," runtime_changed=0 NO_ORDERS=1");return 1;}
 void Select(const int v){if(v<0||v>2)return;view=(ENUM_MA_RIGHT_VIEW_V103)v;Paint();}
 ENUM_MA_RIGHT_VIEW_V103 View()const{return view;} bool SlotVisible()const{return view==MA_RIGHT_SLOT_V103;} bool LogicVisible()const{return view==MA_RIGHT_LOGIC_V103;} bool PartsVisible()const{return view==MA_RIGHT_PARTS_V103;}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
