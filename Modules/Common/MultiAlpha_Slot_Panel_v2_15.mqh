//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Panel_v2_15.mqh                                 |
//| SLOT selector styled to match ROUTE dropdown + 5x10 popup.       |
//| UI only. NO broker operations.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_PANEL_V2_15_MQH
#define MULTIALPHA_SLOT_PANEL_V2_15_MQH
#include <Canvas\Canvas.mqh>
class CMultiAlphaSlotPanel215
{
 string p;int m_x,m_y,m_opacity;CCanvas cv;bool ready,popup;CMultiAlphaSlotState195 *st;string m_hover;
 string PN(const int id){return p+"P"+StringFormat("%02d",id);}
 string LN(const int id){return p+"L"+StringFormat("%02d",id);}
 void LampVisual(const int id)
 {
  string n=LN(id);if(ObjectFind(0,n)<0)return;
  SMA_SlotState195 s=st.Get(id);
  ObjectSetInteger(0,n,OBJPROP_BGCOLOR,s.enabled?C'45,125,92':C'132,58,58');
  ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,s.enabled?C'90,205,150':C'210,105,105');
  ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);
  ObjectSetString(0,n,OBJPROP_TEXT,s.enabled?"ON":"OFF");
 }
 void Bg(){string n=p+"BG";if(ready){cv.Destroy();ready=false;}ready=cv.CreateBitmapLabel(0,0,n,m_x,m_y,660,78,COLOR_FORMAT_ARGB_NORMALIZE);if(!ready)return;ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);cv.Erase(ColorToARGB(C'12,20,27',(uchar)MathMax(0,MathMin(255,m_opacity))));cv.Rectangle(0,0,659,77,ColorToARGB(C'55,70,80',220));cv.Update(false);}
 void B(string id,int x,int w,string z){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,m_y+39);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,30);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,z);}
 void L(string id,int x,int y,string z){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,z);}
 void SlotVisual(const bool hover){string n=p+"SLOT";if(ObjectFind(0,n)<0)return;ObjectSetInteger(0,n,OBJPROP_BGCOLOR,hover?C'58,72,83':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,hover?C'135,155,168':C'85,95,105');}
 void SlotText(const int id){string n=p+"SLOT";ObjectSetString(0,n,OBJPROP_TEXT,StringFormat("SLOT [#%02d]",id));string a=p+"ARROW";if(ObjectFind(0,a)<0)ObjectCreate(0,a,OBJ_LABEL,0,0,0);int x=(int)ObjectGetInteger(0,n,OBJPROP_XDISTANCE),y=(int)ObjectGetInteger(0,n,OBJPROP_YDISTANCE),w=(int)ObjectGetInteger(0,n,OBJPROP_XSIZE);ObjectSetInteger(0,a,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,a,OBJPROP_XDISTANCE,x+w-16);ObjectSetInteger(0,a,OBJPROP_YDISTANCE,y+4);ObjectSetInteger(0,a,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,a,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,a,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,a,OBJPROP_HIDDEN,true);ObjectSetInteger(0,a,OBJPROP_ZORDER,35);ObjectSetString(0,a,OBJPROP_TEXT,popup?"▲":"▼");}
 void PopupItemVisual(const string n,const bool hover,const bool current){ObjectSetInteger(0,n,OBJPROP_BGCOLOR,hover?C'60,78,90':(current?C'52,91,111':C'42,52,61'));ObjectSetInteger(0,n,OBJPROP_COLOR,current?C'120,220,255':clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,hover?C'150,172,185':(current?C'90,150,175':C'85,95,105'));}
 void ClosePopup(){for(int i=1;i<=50;i++){ObjectDelete(0,PN(i));ObjectDelete(0,LN(i));}ObjectDelete(0,p+"POPBG");popup=false;m_hover="";if(st!=NULL)SlotText(st.Selected());ChartRedraw();}
 void OpenPopup(){
  ClosePopup();int bx=m_x+16,by=m_y+66,bw=76,bh=23,g=3;string bg=p+"POPBG";ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,bx-5);ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,by-5);ObjectSetInteger(0,bg,OBJPROP_XSIZE,5*bw+4*g+10);ObjectSetInteger(0,bg,OBJPROP_YSIZE,10*bh+9*g+10);ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,bg,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,bg,OBJPROP_ZORDER,90);ObjectSetInteger(0,bg,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,bg,OBJPROP_HIDDEN,true);
  int cur=st.Selected();for(int id=1;id<=50;id++){int k=id-1,col=k%5,row=k/5;int xx=bx+col*(bw+g),yy=by+row*(bh+g);string n=PN(id);ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,xx);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,yy);ObjectSetInteger(0,n,OBJPROP_XSIZE,48);ObjectSetInteger(0,n,OBJPROP_YSIZE,bh);PopupItemVisual(n,false,id==cur);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,100);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetString(0,n,OBJPROP_TEXT,StringFormat("#%02d",id));
   string l=LN(id);ObjectCreate(0,l,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,l,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,l,OBJPROP_XDISTANCE,xx+50);ObjectSetInteger(0,l,OBJPROP_YDISTANCE,yy+2);ObjectSetInteger(0,l,OBJPROP_XSIZE,24);ObjectSetInteger(0,l,OBJPROP_YSIZE,bh-4);ObjectSetInteger(0,l,OBJPROP_FONTSIZE,7);ObjectSetInteger(0,l,OBJPROP_ZORDER,105);ObjectSetInteger(0,l,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,l,OBJPROP_HIDDEN,true);LampVisual(id);}
  popup=true;SlotText(cur);ChartRedraw();
 }
 void HoverAt(const int mx,const int my){
  string sn=p+"SLOT";int x=(int)ObjectGetInteger(0,sn,OBJPROP_XDISTANCE),y=(int)ObjectGetInteger(0,sn,OBJPROP_YDISTANCE),w=(int)ObjectGetInteger(0,sn,OBJPROP_XSIZE),h=(int)ObjectGetInteger(0,sn,OBJPROP_YSIZE);bool sh=(mx>=x&&mx<x+w&&my>=y&&my<y+h);SlotVisual(sh);
  if(!popup){ChartRedraw();return;}string hit="";for(int id=1;id<=50;id++){string n=PN(id);x=(int)ObjectGetInteger(0,n,OBJPROP_XDISTANCE);y=(int)ObjectGetInteger(0,n,OBJPROP_YDISTANCE);w=(int)ObjectGetInteger(0,n,OBJPROP_XSIZE);h=(int)ObjectGetInteger(0,n,OBJPROP_YSIZE);if(mx>=x&&mx<x+w&&my>=y&&my<y+h){hit=n;break;}}
  if(hit==m_hover){ChartRedraw();return;}if(m_hover!=""){int old=(int)StringToInteger(StringSubstr(m_hover,StringLen(m_hover)-2));PopupItemVisual(m_hover,false,old==st.Selected());}m_hover=hit;if(m_hover!=""){int now=(int)StringToInteger(StringSubstr(m_hover,StringLen(m_hover)-2));PopupItemVisual(m_hover,true,now==st.Selected());}ChartRedraw();
 }
public:
 CMultiAlphaSlotPanel215(){p="MASLOT215_";ready=false;popup=false;st=NULL;m_hover="";}
 void Create(CMultiAlphaSlotState195 *state,const int x=640,const int y=36,const int opacity=150){st=state;m_x=x;m_y=y;m_opacity=opacity;Bg();L("TITLE",x+16,y+13,"MULTI ALPHA / SLOT");B("SLOT",x+16,128,"");B("ENABLE",x+154,112,"");L("SYMBOL",x+286,y+45,"");L("STATE",x+420,y+45,"");L("COUNT",x+570,y+45,"");Refresh();}
 void SetVisible(const bool on){
  // v2.15: workspace transitions are a hard UI lifecycle boundary.
  // Never carry popup/object state across EA LOGIC / EA PARTS.
  if(!on){
   ClosePopup();
   ObjectsDeleteAll(0,p);
   if(ready){cv.Destroy();ready=false;}
   popup=false;m_hover="";
   ChartRedraw();return;
  }
  // Re-enter SLOT from a clean object state.  This prevents stale chart
  // objects/internal popup state from making the SLOT selector unclickable.
  ClosePopup();
  ObjectsDeleteAll(0,p);
  if(ready){cv.Destroy();ready=false;}
  popup=false;m_hover="";
  Bg();L("TITLE",m_x+16,m_y+13,"MULTI ALPHA / SLOT");B("SLOT",m_x+16,128,"");B("ENABLE",m_x+154,112,"");L("SYMBOL",m_x+286,m_y+45,"");L("STATE",m_x+420,m_y+45,"");L("COUNT",m_x+570,m_y+45,"");Refresh();
 }
 void Refresh(){if(st==NULL)return;SMA_SlotState195 s=st.Current();SlotText(s.slot_id);ObjectSetString(0,p+"ENABLE",OBJPROP_TEXT,s.enabled?"ENABLE [ON]":"ENABLE [OFF]");ObjectSetString(0,p+"SYMBOL",OBJPROP_TEXT,s.symbol);ObjectSetString(0,p+"STATE",OBJPROP_TEXT,"STATE: "+s.state_text);ObjectSetString(0,p+"COUNT",OBJPROP_TEXT,StringFormat("#%02d/50",s.slot_id));ChartRedraw();}
 int Event(int id,string name,const long lparam=0,const double dparam=0){
  if(st==NULL)return 0;if(id==CHARTEVENT_MOUSE_MOVE){HoverAt((int)lparam,(int)dparam);return 0;}if(id!=CHARTEVENT_OBJECT_CLICK)return 0;
  if(name==p+"SLOT"){ObjectSetInteger(0,name,OBJPROP_STATE,false);if(popup)ClosePopup();else OpenPopup();return 0;}
  if(name==p+"ENABLE"){ObjectSetInteger(0,name,OBJPROP_STATE,false);bool on=st.ToggleSelected();Refresh();Print("[MA_SLOT215_ENABLE] slot=",st.Selected()," enabled=",(int)on," broker_actions_changed=0");return 2;}
  for(int n=1;n<=50;n++)if(name==LN(n)){ObjectSetInteger(0,name,OBJPROP_STATE,false);int keep=st.Selected();st.Select(n);bool on=st.ToggleSelected();st.Select(keep);LampVisual(n);if(n==keep)Refresh();Print("[MA_SLOT215_LAMP] slot=",n," enabled=",(int)on," selected_stays=",keep," broker_actions_changed=0");ChartRedraw();return 2;}
  for(int n=1;n<=50;n++)if(name==PN(n)){ObjectSetInteger(0,name,OBJPROP_STATE,false);st.Select(n);ClosePopup();Refresh();Print("[MA_SLOT215_VIEW] selected=",n," slot_local_route_loaded=1 runtime_changed=0");return 1;}return 0;
 }
 void Delete(){ClosePopup();if(ready){cv.Destroy();ready=false;}ObjectsDeleteAll(0,p);}
};
#endif
