//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Panel_v1_89.mqh                                 |
//| Standalone translucent SLOT panel. UI scaffold only.             |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_PANEL_V1_89_MQH
#define MULTIALPHA_SLOT_PANEL_V1_89_MQH
#include <Canvas\Canvas.mqh>
class CMultiAlphaSlotPanel189
{
 string p;int selected,m_x,m_y,m_opacity;CCanvas cv;bool ready;
 void Bg(){string n=p+"BG";if(ready){cv.Destroy();ready=false;}ready=cv.CreateBitmapLabel(0,0,n,m_x,m_y,660,78,COLOR_FORMAT_ARGB_NORMALIZE);if(!ready)return;ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);cv.Erase(ColorToARGB(C'12,20,27',(uchar)MathMax(0,MathMin(255,m_opacity))));cv.Rectangle(0,0,659,77,ColorToARGB(C'55,70,80',220));cv.Update(false);}
 void B(const string id,int x,int w,const string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,m_y+39);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_ZORDER,30);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void L(const string id,int x,int y,const string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 string ST(){return StringFormat("SLOT [ #%02d ]  ▼",selected);}
public:
 CMultiAlphaSlotPanel189(){p="MASLOT189_";selected=1;ready=false;}
 void Create(const string symbol,const int x=640,const int y=20,const int opacity=150){m_x=x;m_y=y;m_opacity=opacity;Bg();L("TITLE",x+16,y+13,"MULTI ALPHA / SLOT");B("SLOT",x+16,128,ST());B("ENABLE",x+154,112,"ENABLE [ON]");L("SYMBOL",x+286,y+45,symbol);L("STATE",x+420,y+45,"STATE: READY");L("COUNT",x+570,y+45,"#01/50");ChartRedraw();}
 int Event(const int id,const string name){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name!=p+"SLOT"&&name!=p+"ENABLE")return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);if(name==p+"SLOT"){selected++;if(selected>50)selected=1;ObjectSetString(0,p+"SLOT",OBJPROP_TEXT,ST());ObjectSetString(0,p+"COUNT",OBJPROP_TEXT,StringFormat("#%02d/50",selected));Print("[MA_SLOT189_VIEW] selected=",selected," runtime_changed=0 scaffold=1");}else Print("[MA_SLOT189_ENABLE] scaffold=1 action_ignored=1 runtime_changed=0");ChartRedraw();return 1;}
 int Selected(){return selected;}
 void Delete(){if(ready){cv.Destroy();ready=false;}ObjectsDeleteAll(0,p);}
};
#endif
