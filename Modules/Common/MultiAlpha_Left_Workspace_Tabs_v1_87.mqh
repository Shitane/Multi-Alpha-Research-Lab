//+------------------------------------------------------------------+
//| MultiAlpha_Left_Workspace_Tabs_v1_87.mqh                        |
//| UI-only LOGIC/FILTER/SAFETY view switch. NO runtime side effects.|
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_WORKSPACE_TABS_V1_87_MQH
#define MULTIALPHA_LEFT_WORKSPACE_TABS_V1_87_MQH

enum ENUM_MA_LEFT_VIEW_V187 { MA_LEFT_LOGIC_V187=0,MA_LEFT_FILTER_V187=1,MA_LEFT_SAFETY_V187=2 };

class CMultiAlphaLeftWorkspaceTabs187
{
 string m_prefix; ENUM_MA_LEFT_VIEW_V187 m_view;
 string m_logic_ids[];
 void V(const string name,const bool on){if(ObjectFind(0,name)>=0)ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void MakeButton(const string id,const int x,const string text){
  string n=m_prefix+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,12);
  ObjectSetInteger(0,n,OBJPROP_XSIZE,88);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);
  ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,60);ObjectSetString(0,n,OBJPROP_TEXT,text);
 }
 void MakeLabel(const string id,const int x,const int y,const string text,const int fs=9){
  string n=m_prefix+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,text);
 }
 void SetLogicVisible(const bool on){for(int i=0;i<ArraySize(m_logic_ids);i++)V("O01CFG160_"+m_logic_ids[i],on);}
 void ShowPage(const string page,const bool on){V(m_prefix+page+"_TITLE",on);V(m_prefix+page+"_LINE1",on);V(m_prefix+page+"_LINE2",on);V(m_prefix+page+"_LINE3",on);}
 void PaintTabs(){
  ObjectSetString(0,m_prefix+"TAB_LOGIC",OBJPROP_TEXT,(m_view==MA_LEFT_LOGIC_V187?"[ LOGIC ]":"LOGIC"));
  ObjectSetString(0,m_prefix+"TAB_FILTER",OBJPROP_TEXT,(m_view==MA_LEFT_FILTER_V187?"[ FILTER ]":"FILTER"));
  ObjectSetString(0,m_prefix+"TAB_SAFETY",OBJPROP_TEXT,(m_view==MA_LEFT_SAFETY_V187?"[ SAFETY ]":"SAFETY"));
 }
public:
 CMultiAlphaLeftWorkspaceTabs187(){m_prefix="MALEFT187_";m_view=MA_LEFT_LOGIC_V187;}
 void Create(){
  string a[]={"L_H_ENTRY","L_H_GRID","L_H_EXIT","L_H_SAFETY","L_H_TIME","L_H_PRESETSEC","L_NEW","NEW","L_BUY","BUY","L_SELL","SELL","L_RSIP","RSIP","L_RSIL","RSIL","L_RSIU","RSIU","L_ATR1P","ATR1P","L_ATR2P","ATR2P","L_ATR2TF","ATR2TF","L_LOT","LOT","L_MULT","MULT","L_MAXLOT","MAXLOT","L_TOTLOT","TOTLOT","L_MAXORD","MAXORD","L_GRID","GRID","L_DYNORD","DYNORD","L_DYNPTS","DYNPTS","L_DISTM","DISTM","L_VSL","VSL","L_STS","STS","L_STL","STL","L_STD","STD","L_BTS","BTS","L_BTL","BTL","L_WARN","WARN","L_PAUSE","PAUSE","L_CLOSE","CLOSE","L_TMODE","TMODE","L_START","START","L_END","END","L_NEWS","NEWS","L_PRESETLAB","PRESET","L_SAVEDLAB","L_SAVEDVAL","NEXT","APPLY","SAVE","LOAD","DELETE","RESET"};
  ArrayResize(m_logic_ids,ArraySize(a));for(int i=0;i<ArraySize(a);i++)m_logic_ids[i]=a[i];
  MakeButton("TAB_LOGIC",330,"[ LOGIC ]");MakeButton("TAB_FILTER",420,"FILTER");MakeButton("TAB_SAFETY",510,"SAFETY");
  MakeLabel("FILTER_TITLE",24,104,"COMMON FILTER / TRADE PERMISSION",9);
  MakeLabel("FILTER_LINE1",24,136,"UI FRAME ONLY - NOT CONNECTED",8);
  MakeLabel("FILTER_LINE2",24,162,"NEW ENTRY: NOT CONNECTED",8);
  MakeLabel("FILTER_LINE3",24,184,"ADD ENTRY: NOT CONNECTED",8);
  MakeLabel("SAFETY_TITLE",24,104,"COMMON SAFETY",9);
  MakeLabel("SAFETY_LINE1",24,136,"UI FRAME ONLY - NOT CONNECTED",8);
  MakeLabel("SAFETY_LINE2",24,162,"Existing strategy safety unchanged",8);
  MakeLabel("SAFETY_LINE3",24,184,"No runtime control from this page",8);
  Apply();
 }
 void Apply(){
  bool logic=(m_view==MA_LEFT_LOGIC_V187);SetLogicVisible(logic);
  ShowPage("FILTER",m_view==MA_LEFT_FILTER_V187);ShowPage("SAFETY",m_view==MA_LEFT_SAFETY_V187);PaintTabs();ChartRedraw();
 }
 int Event(const int id,const string name){
  if(id!=CHARTEVENT_OBJECT_CLICK)return 0;
  ENUM_MA_LEFT_VIEW_V187 nv=m_view;
  if(name==m_prefix+"TAB_LOGIC")nv=MA_LEFT_LOGIC_V187;
  else if(name==m_prefix+"TAB_FILTER")nv=MA_LEFT_FILTER_V187;
  else if(name==m_prefix+"TAB_SAFETY")nv=MA_LEFT_SAFETY_V187;
  else return 0;
  ObjectSetInteger(0,name,OBJPROP_STATE,false);m_view=nv;Apply();
  Print("[MA_LEFT187_VIEW] view=",(m_view==MA_LEFT_LOGIC_V187?"LOGIC":(m_view==MA_LEFT_FILTER_V187?"FILTER":"SAFETY"))," runtime_changed=0");
  return 1;
 }
 void Refresh(){Apply();}
 ENUM_MA_LEFT_VIEW_V187 View(){return m_view;}
 void Delete(){ObjectsDeleteAll(0,m_prefix);}
};
#endif
