//+------------------------------------------------------------------+
//| MultiAlpha_Route_Selector_Panel_v1_82.mqh                       |
//| Registry-backed route selector. NO ORDERS. No fallback.          |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_ROUTE_SELECTOR_PANEL_V1_82_MQH
#define MULTI_ALPHA_ROUTE_SELECTOR_PANEL_V1_82_MQH
#include "MultiAlpha_Route_Controller_v1_75.mqh"
#include <Canvas\Canvas.mqh>

class CMultiAlphaRouteSelectorPanel182
  {
private:
 string m_prefix; SMA_ModuleSelection150 m_draft; CMultiAlphaRouteController175 *m_controller;
 int m_x,m_y,m_opacity; CCanvas m_cv; bool m_cv_ready; string m_menu; string m_hover;
 string LogicText(const ENUM_MA_LOGIC_ID_V150 id){return MA150LogicName(id);}
 void Background(const int x,const int y){string n=m_prefix+"BG";if(m_cv_ready){m_cv.Destroy();m_cv_ready=false;}m_cv_ready=m_cv.CreateBitmapLabel(0,0,n,x,y,660,158,COLOR_FORMAT_ARGB_NORMALIZE);if(!m_cv_ready){Print("[MA_ROUTE175] canvas background creation failed");return;}ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);m_cv.Erase(ColorToARGB(C'12,20,27',(uchar)MathMax(0,MathMin(255,m_opacity))));m_cv.Rectangle(0,0,659,157,ColorToARGB(C'55,70,80',220));m_cv.Update(false);}
 void Label(const string id,const int x,const int y,const string text){string n=m_prefix+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetString(0,n,OBJPROP_TEXT,text);}
 void Button(const string id,const int x,const int y,const int w,const string text){string n=m_prefix+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,30);ObjectSetString(0,n,OBJPROP_TEXT,text);}
 void DropdownVisual(const string id,const bool hover=false){string n=m_prefix+id;if(ObjectFind(0,n)<0)return;ObjectSetInteger(0,n,OBJPROP_BGCOLOR,hover?C'58,72,83':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,hover?C'135,155,168':C'85,95,105');}
 void DropdownText(const string id,const string text){
  string n=m_prefix+id;if(ObjectFind(0,n)<0)return;
  int w=(int)ObjectGetInteger(0,n,OBJPROP_XSIZE);
  int approx_chars=(int)MathMax(1,(w-16)/7);
  int spaces=(int)MathMax(1,approx_chars-StringLen(text)-1);
  string pad="";for(int i=0;i<spaces;i++)pad+=" ";
  ObjectSetString(0,n,OBJPROP_TEXT,text+pad+(m_menu==id?"▲":"▼"));
 }
 bool IsDropdown(const string id){return(id=="STRUCTURE"||id=="FULL"||id=="ENTRY"||id=="MANAGE"||id=="EXIT");}
 void HoverAt(const int mx,const int my){string hit="";string ids[5]={"STRUCTURE","FULL","ENTRY","MANAGE","EXIT"};for(int i=0;i<5;i++){string n=m_prefix+ids[i];if(ObjectFind(0,n)<0)continue;int x=(int)ObjectGetInteger(0,n,OBJPROP_XDISTANCE),y=(int)ObjectGetInteger(0,n,OBJPROP_YDISTANCE),w=(int)ObjectGetInteger(0,n,OBJPROP_XSIZE),h=(int)ObjectGetInteger(0,n,OBJPROP_YSIZE);if(mx>=x&&mx<x+w&&my>=y&&my<y+h){hit=ids[i];break;}}if(hit==m_hover)return;if(m_hover!="")DropdownVisual(m_hover,false);m_hover=hit;if(m_hover!="")DropdownVisual(m_hover,true);ChartRedraw();}
 void Release(const string id){string n=m_prefix+id;ObjectSetInteger(0,n,OBJPROP_STATE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);}
 void MenuClear(){for(int i=ObjectsTotal(0)-1;i>=0;i--){string n=ObjectName(0,i);if(StringFind(n,m_prefix+"DD_")==0)ObjectDelete(0,n);}m_menu="";Refresh();}
 void MenuItem(const string key,const int row,const string text){string n=m_prefix+"DD_"+m_menu+"_"+key;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);int x=m_x+121,y=m_y+66;if(m_menu=="ENTRY"){x=m_x+346;y=m_y+66;}else if(m_menu=="MANAGE"){x=m_x+346;y=m_y+96;}else if(m_menu=="EXIT"){x=m_x+545;y=m_y+66;}ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y+row*23);ObjectSetInteger(0,n,OBJPROP_XSIZE,(m_menu=="EXIT"?99:100));ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'30,42,50');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'100,115,125');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,80);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,text);}
 void OpenMenu(const string which){MenuClear();m_menu=which;if(which=="STRUCTURE"){MenuItem("FULL",0,"FULL");MenuItem("SPLIT",1,"SPLIT");return;}ENUM_MA_MODULE_CAPABILITY_V175 cap=MA_CAP_FULL_V175;if(which=="ENTRY")cap=MA_CAP_ENTRY_V175;else if(which=="MANAGE")cap=MA_CAP_MANAGE_V175;else if(which=="EXIT")cap=MA_CAP_EXIT_V175;int row=0;if(MA175IsRegistered(MA_LOGIC_O01_V150,cap))MenuItem("O01",row++,"O01");if(MA175IsRegistered(MA_LOGIC_A10_V150,cap))MenuItem("A10",row++,"A10");}
 ENUM_MA_LOGIC_ID_V150 MenuLogic(const string key){if(key=="A10")return MA_LOGIC_A10_V150;return MA_LOGIC_O01_V150;}
 void Refresh(){DropdownText("STRUCTURE",MA150StructureName(m_draft.structure));DropdownText("FULL",LogicText(m_draft.full_module));DropdownText("ENTRY",LogicText(m_draft.entry_module));DropdownText("MANAGE",LogicText(m_draft.manage_module));DropdownText("EXIT",LogicText(m_draft.exit_module));if(m_controller!=NULL){SMA_ModuleSelection150 a=m_controller.Active();string s=(a.structure==MA_STRUCTURE_FULL_V150?"ACTIVE: FULL  "+LogicText(a.full_module):"ACTIVE: SPLIT  E:"+LogicText(a.entry_module)+"  M:"+LogicText(a.manage_module)+"  X:"+LogicText(a.exit_module));ObjectSetString(0,m_prefix+"ACTIVE",OBJPROP_TEXT,s);}ChartRedraw();}
public:
 void Create(CMultiAlphaRouteController175 *controller,const SMA_ModuleSelection150 &initial,const int x=20,const int y=20,const int opacity=150){m_prefix="MA_ROUTE175_";m_controller=controller;m_draft=initial;m_x=x;m_y=y;m_opacity=opacity;m_cv_ready=false;m_menu="";m_hover="";Background(x,y);Label("TITLE",x+16,y+14,"MULTI ALPHA / ROUTE");Label("LS",x+16,y+48,"Structure");Button("STRUCTURE",x+121,y+42,100,"");Label("LF",x+16,y+78,"Full Module");Button("FULL",x+121,y+72,100,"");Label("LE",x+241,y+48,"Entry Module");Button("ENTRY",x+346,y+42,100,"");Label("LM",x+241,y+78,"Manage Module");Button("MANAGE",x+346,y+72,100,"");Label("LX",x+466,y+48,"Exit Module");Button("EXIT",x+545,y+42,99,"");Button("APPLY",x+16,y+108,100,"APPLY");Button("REVERT",x+126,y+108,100,"REVERT");Label("ACTIVE",x+241,y+113,"");Label("STATUS",x+16,y+139,"READY");Refresh();}
 void Delete(){MenuClear();if(m_cv_ready){m_cv.Destroy();m_cv_ready=false;}ObjectsDeleteAll(0,m_prefix);}
 SMA_ModuleSelection150 Draft(){return m_draft;}
 bool DraftChangedFromActive(){if(m_controller==NULL)return false;SMA_ModuleSelection150 a=m_controller.Active();return(m_draft.structure!=a.structure||m_draft.full_module!=a.full_module||m_draft.entry_module!=a.entry_module||m_draft.manage_module!=a.manage_module||m_draft.exit_module!=a.exit_module);}
 bool DraftFullRegistered(){return MA175IsRegistered(m_draft.full_module,MA_CAP_FULL_V175);}
 bool DraftEntryRegistered(){return MA175IsRegistered(m_draft.entry_module,MA_CAP_ENTRY_V175);}
 bool DraftManageRegistered(){return MA175IsRegistered(m_draft.manage_module,MA_CAP_MANAGE_V175);}
 bool DraftExitRegistered(){return MA175IsRegistered(m_draft.exit_module,MA_CAP_EXIT_V175);}
 string DraftSummary(){return MA150StructureName(m_draft.structure)+" F:"+LogicText(m_draft.full_module)+" E:"+LogicText(m_draft.entry_module)+" M:"+LogicText(m_draft.manage_module)+" X:"+LogicText(m_draft.exit_module);}
 void SetDraft(const SMA_ModuleSelection150 &s){m_draft=s;Refresh();}
 int Event(const int id,const string &name,const SMA_RouteState150 &state,string &reason,const long mouse_x=0,const double mouse_y=0){reason="";if(id==CHARTEVENT_MOUSE_MOVE){HoverAt((int)mouse_x,(int)mouse_y);return 0;}if(id!=CHARTEVENT_OBJECT_CLICK||StringFind(name,m_prefix)!=0)return 0;
 if(StringFind(name,m_prefix+"DD_")==0){string tail=StringSubstr(name,StringLen(m_prefix+"DD_"));int p=StringFind(tail,"_");string which=StringSubstr(tail,0,p),key=StringSubstr(tail,p+1);if(which=="STRUCTURE")m_draft.structure=(key=="SPLIT"?MA_STRUCTURE_SPLIT_V150:MA_STRUCTURE_FULL_V150);else if(which=="FULL")m_draft.full_module=MenuLogic(key);else if(which=="ENTRY")m_draft.entry_module=MenuLogic(key);else if(which=="MANAGE")m_draft.manage_module=MenuLogic(key);else if(which=="EXIT")m_draft.exit_module=MenuLogic(key);MenuClear();Refresh();return 1;}
 if(name==m_prefix+"STRUCTURE"){Release("STRUCTURE");if(m_menu=="STRUCTURE")MenuClear();else OpenMenu("STRUCTURE");Refresh();return 0;}
 if(name==m_prefix+"FULL"){Release("FULL");if(m_menu=="FULL")MenuClear();else OpenMenu("FULL");Refresh();return 0;}
 if(name==m_prefix+"ENTRY"){Release("ENTRY");if(m_menu=="ENTRY")MenuClear();else OpenMenu("ENTRY");Refresh();return 0;}
 if(name==m_prefix+"MANAGE"){Release("MANAGE");if(m_menu=="MANAGE")MenuClear();else OpenMenu("MANAGE");Refresh();return 0;}
 if(name==m_prefix+"EXIT"){Release("EXIT");if(m_menu=="EXIT")MenuClear();else OpenMenu("EXIT");Refresh();return 0;}
 if(name==m_prefix+"REVERT"){Release("REVERT");MenuClear();if(m_controller!=NULL)m_draft=m_controller.Active();reason="draft reverted to active route";ObjectSetString(0,m_prefix+"STATUS",OBJPROP_TEXT,"REVERTED");Refresh();return 2;}
 if(name==m_prefix+"APPLY"){Release("APPLY");MenuClear();if(m_controller==NULL){reason="route controller is not connected";return -1;}bool ok=m_controller.Request(m_draft,state,reason);ObjectSetString(0,m_prefix+"STATUS",OBJPROP_TEXT,(ok?"ACCEPT: ":"REJECT: ")+reason);if(!ok)m_draft=m_controller.Active();Refresh();return ok?3:-3;}return 0;}
  };
#endif
