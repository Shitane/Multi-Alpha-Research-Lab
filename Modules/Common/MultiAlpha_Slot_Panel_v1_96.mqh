//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Panel_v1_96.mqh                                 |
//| Compact SLOT panel + 5x10 popup selector for slots #01-#50.      |
//| UI only. NO broker operations.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_PANEL_V1_96_MQH
#define MULTIALPHA_SLOT_PANEL_V1_96_MQH
#include <Canvas\Canvas.mqh>
class CMultiAlphaSlotPanel196
{
 string p;int m_x,m_y,m_opacity;CCanvas cv;bool ready,popup;CMultiAlphaSlotState195 *st;
 string PN(const int id){return p+"P"+StringFormat("%02d",id);}
 void Bg(){string n=p+"BG";if(ready){cv.Destroy();ready=false;}ready=cv.CreateBitmapLabel(0,0,n,m_x,m_y,660,78,COLOR_FORMAT_ARGB_NORMALIZE);if(!ready)return;ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);cv.Erase(ColorToARGB(C'12,20,27',(uchar)MathMax(0,MathMin(255,m_opacity))));cv.Rectangle(0,0,659,77,ColorToARGB(C'55,70,80',220));cv.Update(false);}
 void B(string id,int x,int w,string z){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,m_y+39);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,30);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,z);}
 void L(string id,int x,int y,string z){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,z);}
 string SlotText(int id){return StringFormat("SLOT [ #%02d ]  ▼",id);}
 void ClosePopup(){for(int i=1;i<=50;i++)ObjectDelete(0,PN(i));ObjectDelete(0,p+"POPBG");popup=false;ChartRedraw();}
 void OpenPopup()
 {
  ClosePopup();
  // 5 columns x 10 rows. Compact overlay appears below SLOT button.
  int bx=m_x+16,by=m_y+66,bw=54,bh=23,g=3;
  string bg=p+"POPBG";ObjectCreate(0,bg,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,bg,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,bg,OBJPROP_XDISTANCE,bx-5);ObjectSetInteger(0,bg,OBJPROP_YDISTANCE,by-5);ObjectSetInteger(0,bg,OBJPROP_XSIZE,5*bw+4*g+10);ObjectSetInteger(0,bg,OBJPROP_YSIZE,10*bh+9*g+10);ObjectSetInteger(0,bg,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,bg,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,bg,OBJPROP_ZORDER,90);ObjectSetInteger(0,bg,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,bg,OBJPROP_HIDDEN,true);
  int cur=st.Selected();
  for(int id=1;id<=50;id++)
  {
   int k=id-1,col=k%5,row=k/5;string n=PN(id);
   ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,bx+col*(bw+g));ObjectSetInteger(0,n,OBJPROP_YDISTANCE,by+row*(bh+g));ObjectSetInteger(0,n,OBJPROP_XSIZE,bw);ObjectSetInteger(0,n,OBJPROP_YSIZE,bh);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,id==cur?C'52,91,111':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,id==cur?C'120,220,255':clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,id==cur?C'90,150,175':C'85,95,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,100);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetString(0,n,OBJPROP_TEXT,StringFormat("#%02d",id));
  }
  popup=true;ChartRedraw();
 }
public:
 CMultiAlphaSlotPanel196(){p="MASLOT196_";ready=false;popup=false;st=NULL;}
 void Create(CMultiAlphaSlotState195 *state,const int x=640,const int y=36,const int opacity=150){st=state;m_x=x;m_y=y;m_opacity=opacity;Bg();L("TITLE",x+16,y+13,"MULTI ALPHA / SLOT");B("SLOT",x+16,128,"");B("ENABLE",x+154,112,"");L("SYMBOL",x+286,y+45,"");L("STATE",x+420,y+45,"");L("COUNT",x+570,y+45,"");Refresh();}
 void Refresh(){if(st==NULL)return;SMA_SlotState195 s=st.Current();ObjectSetString(0,p+"SLOT",OBJPROP_TEXT,SlotText(s.slot_id));ObjectSetString(0,p+"ENABLE",OBJPROP_TEXT,s.enabled?"ENABLE [ON]":"ENABLE [OFF]");ObjectSetString(0,p+"SYMBOL",OBJPROP_TEXT,s.symbol);ObjectSetString(0,p+"STATE",OBJPROP_TEXT,"STATE: "+s.state_text);ObjectSetString(0,p+"COUNT",OBJPROP_TEXT,StringFormat("#%02d/50",s.slot_id));ChartRedraw();}
 int Event(int id,string name)
 {
  if(id!=CHARTEVENT_OBJECT_CLICK||st==NULL)return 0;
  if(name==p+"SLOT"){ObjectSetInteger(0,name,OBJPROP_STATE,false);if(popup)ClosePopup();else OpenPopup();return 0;}
  if(name==p+"ENABLE"){ObjectSetInteger(0,name,OBJPROP_STATE,false);bool on=st.ToggleSelected();Refresh();Print("[MA_SLOT196_ENABLE] slot=",st.Selected()," enabled=",(int)on," broker_actions_changed=0");return 2;}
  for(int n=1;n<=50;n++)if(name==PN(n))
  {
   ObjectSetInteger(0,name,OBJPROP_STATE,false);st.Select(n);ClosePopup();Refresh();Print("[MA_SLOT196_VIEW] selected=",n," slot_local_route_loaded=1 runtime_changed=0");return 1;
  }
  return 0;
 }
 void Delete(){ClosePopup();if(ready){cv.Destroy();ready=false;}ObjectsDeleteAll(0,p);}
};
#endif
