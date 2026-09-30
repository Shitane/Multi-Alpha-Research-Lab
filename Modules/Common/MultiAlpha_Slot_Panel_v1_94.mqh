//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Panel_v1_94.mqh                                 |
//| SLOT #01-#50 selector bound to slot-state scaffold.              |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_PANEL_V1_94_MQH
#define MULTIALPHA_SLOT_PANEL_V1_94_MQH
#include <Canvas\Canvas.mqh>
class CMultiAlphaSlotPanel194
{
 string p;int m_x,m_y,m_opacity;CCanvas cv;bool ready;CMultiAlphaSlotState194 *st;
 void Bg(){string n=p+"BG";if(ready){cv.Destroy();ready=false;}ready=cv.CreateBitmapLabel(0,0,n,m_x,m_y,660,78,COLOR_FORMAT_ARGB_NORMALIZE);if(!ready)return;ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);cv.Erase(ColorToARGB(C'12,20,27',(uchar)MathMax(0,MathMin(255,m_opacity))));cv.Rectangle(0,0,659,77,ColorToARGB(C'55,70,80',220));cv.Update(false);}
 void B(string id,int x,int w,string z){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,m_y+39);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,30);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,z);}
 void L(string id,int x,int y,string z){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,z);}
 string SlotText(int id){return StringFormat("SLOT [ #%02d ]  ▼",id);}
public:
 CMultiAlphaSlotPanel194(){p="MASLOT194_";ready=false;st=NULL;}
 void Create(CMultiAlphaSlotState194 *state,const int x=640,const int y=36,const int opacity=150){st=state;m_x=x;m_y=y;m_opacity=opacity;Bg();L("TITLE",x+16,y+13,"MULTI ALPHA / SLOT");B("SLOT",x+16,128,"");B("ENABLE",x+154,112,"");L("SYMBOL",x+286,y+45,"");L("STATE",x+420,y+45,"");L("COUNT",x+570,y+45,"");Refresh();}
 void Refresh(){if(st==NULL)return;SMA_SlotState194 s=st.Current();ObjectSetString(0,p+"SLOT",OBJPROP_TEXT,SlotText(s.slot_id));ObjectSetString(0,p+"ENABLE",OBJPROP_TEXT,s.enabled?"ENABLE [ON]":"ENABLE [OFF]");ObjectSetString(0,p+"SYMBOL",OBJPROP_TEXT,s.symbol);ObjectSetString(0,p+"STATE",OBJPROP_TEXT,"STATE: "+s.state_text);ObjectSetString(0,p+"COUNT",OBJPROP_TEXT,StringFormat("#%02d/50",s.slot_id));ChartRedraw();}
 int Event(int id,string name){if(id!=CHARTEVENT_OBJECT_CLICK||st==NULL)return 0;if(name==p+"SLOT"){ObjectSetInteger(0,name,OBJPROP_STATE,false);int n=st.Selected()+1;if(n>MA_SLOT_COUNT_V194)n=1;st.Select(n);Refresh();Print("[MA_SLOT194_VIEW] selected=",n," runtime_changed=0");return 1;}if(name==p+"ENABLE"){ObjectSetInteger(0,name,OBJPROP_STATE,false);bool on=st.ToggleSelected();Refresh();Print("[MA_SLOT194_ENABLE] slot=",st.Selected()," enabled=",(int)on," broker_actions_changed=0");return 2;}return 0;}
 void Delete(){if(ready){cv.Destroy();ready=false;}ObjectsDeleteAll(0,p);}
};
#endif
