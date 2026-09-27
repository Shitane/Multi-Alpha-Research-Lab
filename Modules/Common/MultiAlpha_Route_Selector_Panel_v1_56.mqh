//+------------------------------------------------------------------+
//| MultiAlpha_Route_Selector_Panel_v1_56.mqh                       |
//| Gate-3B basic route selector UI. NO ORDERS. No fallback.         |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_ROUTE_SELECTOR_PANEL_V1_56_MQH
#define MULTI_ALPHA_ROUTE_SELECTOR_PANEL_V1_56_MQH
#include "MultiAlpha_Route_Controller_v1_51.mqh"

class CMultiAlphaRouteSelectorPanel156
  {
private:
   string m_prefix;
   SMA_ModuleSelection150 m_draft;
   CMultiAlphaRouteController151 *m_controller;
   int m_x,m_y;

   string LogicText(const ENUM_MA_LOGIC_ID_V150 id){return MA150LogicName(id);}
   ENUM_MA_LOGIC_ID_V150 NextLogic(const ENUM_MA_LOGIC_ID_V150 id)
     {
      if(id==MA_LOGIC_O01_V150) return MA_LOGIC_A10_V150;
      if(id==MA_LOGIC_A10_V150) return MA_LOGIC_A11_V150;
      if(id==MA_LOGIC_A11_V150) return MA_LOGIC_A12_V150;
      if(id==MA_LOGIC_A12_V150) return MA_LOGIC_A13_V150;
      if(id==MA_LOGIC_A13_V150) return MA_LOGIC_A14_V150;
      if(id==MA_LOGIC_A14_V150) return MA_LOGIC_A15_V150;
      return MA_LOGIC_O01_V150;
     }
   void Background(const int x,const int y)
     {
      string n=m_prefix+"BG"; if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
      ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER); ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,n,OBJPROP_XSIZE,660); ObjectSetInteger(0,n,OBJPROP_YSIZE,158);
      ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27'); ObjectSetInteger(0,n,OBJPROP_COLOR,C'55,70,80');
      ObjectSetInteger(0,n,OBJPROP_BACK,false); ObjectSetInteger(0,n,OBJPROP_ZORDER,20);
     }
   void Label(const string id,const int x,const int y,const string text)
     {
      string n=m_prefix+id;
      if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);
      ObjectSetString(0,n,OBJPROP_TEXT,text);
     }
   void Button(const string id,const int x,const int y,const int w,const string text)
     {
      string n=m_prefix+id;
      if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,23);
      ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61'); ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);
      ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105'); ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,n,OBJPROP_ZORDER,30); ObjectSetString(0,n,OBJPROP_TEXT,text);
     }
   void Release(const string id){string n=m_prefix+id;ObjectSetInteger(0,n,OBJPROP_STATE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);}
   void Refresh()
     {
      ObjectSetString(0,m_prefix+"STRUCTURE",OBJPROP_TEXT,MA150StructureName(m_draft.structure));
      ObjectSetString(0,m_prefix+"FULL",OBJPROP_TEXT,LogicText(m_draft.full_module));
      ObjectSetString(0,m_prefix+"ENTRY",OBJPROP_TEXT,LogicText(m_draft.entry_module));
      ObjectSetString(0,m_prefix+"MANAGE",OBJPROP_TEXT,LogicText(m_draft.manage_module));
      ObjectSetString(0,m_prefix+"EXIT",OBJPROP_TEXT,LogicText(m_draft.exit_module));
      if(m_controller!=NULL)
        {
         SMA_ModuleSelection150 a=m_controller.Active();
         ObjectSetString(0,m_prefix+"ACTIVE",OBJPROP_TEXT,
           "ACTIVE: "+MA150StructureName(a.structure)+"  F:"+LogicText(a.full_module)+
           "  E:"+LogicText(a.entry_module)+"  M:"+LogicText(a.manage_module)+"  X:"+LogicText(a.exit_module));
        }
      ChartRedraw();
     }
public:
   void Create(CMultiAlphaRouteController151 *controller,const SMA_ModuleSelection150 &initial,const int x=20,const int y=20)
     {
      m_prefix="MA_ROUTE156_"; m_controller=controller; m_draft=initial; m_x=x; m_y=y;
      Background(x-8,y-8);
      Label("TITLE",x,y,"MULTI ALPHA / ROUTE");
      Label("LS",x,y+34,"Structure"); Button("STRUCTURE",x+105,y+28,100,"");
      Label("LF",x,y+64,"Full Module"); Button("FULL",x+105,y+58,100,"");
      Label("LE",x+225,y+34,"Entry Module"); Button("ENTRY",x+330,y+28,100,"");
      Label("LM",x+225,y+64,"Manage Module"); Button("MANAGE",x+330,y+58,100,"");
      Label("LX",x+450,y+34,"Exit Module"); Button("EXIT",x+545,y+28,100,"");
      Button("APPLY",x,y+96,100,"APPLY");
      Button("REVERT",x+110,y+96,100,"REVERT");
      Label("ACTIVE",x+225,y+101,"");
      Label("STATUS",x,y+132,"READY");
      Refresh();
     }
   void Delete(){ObjectsDeleteAll(0,m_prefix);}
   SMA_ModuleSelection150 Draft(){return m_draft;}
   bool DraftChangedFromActive()
     {
      if(m_controller==NULL) return false;
      SMA_ModuleSelection150 a=m_controller.Active();
      return (m_draft.structure!=a.structure ||
              m_draft.full_module!=a.full_module ||
              m_draft.entry_module!=a.entry_module ||
              m_draft.manage_module!=a.manage_module ||
              m_draft.exit_module!=a.exit_module);
     }
   bool DraftEntryRegistered(){return (m_draft.entry_module==MA_LOGIC_O01_V150);}
   bool DraftManageRegistered(){return (m_draft.manage_module==MA_LOGIC_O01_V150);}
   bool DraftExitRegistered(){return (m_draft.exit_module==MA_LOGIC_O01_V150);}
   string DraftSummary(){return MA150StructureName(m_draft.structure)+" F:"+LogicText(m_draft.full_module)+" E:"+LogicText(m_draft.entry_module)+" M:"+LogicText(m_draft.manage_module)+" X:"+LogicText(m_draft.exit_module);}
   void SetDraft(const SMA_ModuleSelection150 &s){m_draft=s;Refresh();}
   int Event(const int id,const string &name,const SMA_RouteState150 &state,string &reason)
     {
      reason="";
      if(id!=CHARTEVENT_OBJECT_CLICK || StringFind(name,m_prefix)!=0) return 0;
      if(name==m_prefix+"STRUCTURE"){Release("STRUCTURE");m_draft.structure=(m_draft.structure==MA_STRUCTURE_FULL_V150?MA_STRUCTURE_SPLIT_V150:MA_STRUCTURE_FULL_V150);Refresh();return 1;}
      if(name==m_prefix+"FULL"){Release("FULL");m_draft.full_module=NextLogic(m_draft.full_module);Refresh();return 1;}
      if(name==m_prefix+"ENTRY"){Release("ENTRY");m_draft.entry_module=NextLogic(m_draft.entry_module);Refresh();return 1;}
      if(name==m_prefix+"MANAGE"){Release("MANAGE");m_draft.manage_module=NextLogic(m_draft.manage_module);Refresh();return 1;}
      if(name==m_prefix+"EXIT"){Release("EXIT");m_draft.exit_module=NextLogic(m_draft.exit_module);Refresh();return 1;}
      if(name==m_prefix+"REVERT")
        {
         Release("REVERT"); if(m_controller!=NULL)m_draft=m_controller.Active(); reason="draft reverted to active route";
         ObjectSetString(0,m_prefix+"STATUS",OBJPROP_TEXT,"REVERTED");Refresh();return 2;
        }
      if(name==m_prefix+"APPLY")
        {
         Release("APPLY"); if(m_controller==NULL){reason="route controller is not connected";return -1;}
         bool ok=m_controller.Request(m_draft,state,reason);
         ObjectSetString(0,m_prefix+"STATUS",OBJPROP_TEXT,(ok?"ACCEPT: ":"REJECT: ")+reason);
         if(!ok)m_draft=m_controller.Active();
         Refresh();
         return ok?3:-3;
        }
      return 0;
     }
  };
#endif
