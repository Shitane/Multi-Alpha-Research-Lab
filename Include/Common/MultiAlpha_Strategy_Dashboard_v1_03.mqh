//+------------------------------------------------------------------+
//| MultiAlpha_Strategy_Dashboard_v1_03.mqh                         |
//| Gate LD-1: Strategy Dashboard using the exact legacy left-panel  |
//| canvas geometry/theme. Display shell only; live data starts LD-2.|
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_STRATEGY_DASHBOARD_V1_03_MQH
#define MULTIALPHA_STRATEGY_DASHBOARD_V1_03_MQH
#include "..\\O01\\MultiAlpha_Foundation_v1_40.mqh"
#include <Canvas\\Canvas.mqh>

class CMultiAlphaStrategyDashboard103
{
 private:
  CCanvas cv; bool cvReady; SMA140PanelTheme theme;
  int PX,PY,PW,PH,YOFF;
  void CanvasCreate()
  {
   string n="MASTRAT103_BG"; if(cvReady){cv.Destroy();cvReady=false;}
   cvReady=cv.CreateBitmapLabel(0,0,n,PX,PY,PW,PH,COLOR_FORMAT_ARGB_NORMALIZE);
   if(!cvReady){Print("[MA_LD1_DASHBOARD] canvas creation failed");return;}
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true); ObjectSetInteger(0,n,OBJPROP_ZORDER,1);
   uchar a=(uchar)MathMax(0,MathMin(255,theme.opacity)); cv.Erase(ColorToARGB(theme.background,a));
   uint fr=ColorToARGB(theme.border,220),sp=ColorToARGB(theme.border,155);
   cv.Rectangle(0,0,PW-1,PH-1,fr);
   // Preserve the established legacy LOGIC panel section rhythm.
   int ys[]={62,164,272,362,448}; for(int i=0;i<ArraySize(ys);i++)cv.Line(12,ys[i],PW-13,ys[i],sp);
   cv.Update(false);
  }
  void L(const string id,const int x,const int y,const string v,const color c,const int fs=8)
  {
   string n="MASTRAT103_L_"+id; if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER); ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y+YOFF);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs); ObjectSetInteger(0,n,OBJPROP_COLOR,c); ObjectSetString(0,n,OBJPROP_FONT,"Arial"); ObjectSetString(0,n,OBJPROP_TEXT,v);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
  }
  void H(const string id,const int x,const int y,const string v){L("H_"+id,x,y,v,theme.section,9);}
 public:
  CMultiAlphaStrategyDashboard103(){cvReady=false;PX=8;PY=36;PW=620;PH=570;YOFF=28;}
  void Create(const SMA140PanelTheme &appearance)
  {
   theme=appearance; CanvasCreate();
   L("TITLE",24,18,"MULTI ALPHA  /  STRATEGY DASHBOARD",theme.title,10);
   L("SUB",24,39,"NO ORDERS / VIRTUAL NOT FILL",theme.muted,8);
   L("MODE",330,39,"LD-1 DISPLAY SHELL",theme.text,8);

   H("BASIC",24,73,"STRATEGY / SLOT");
   L("SLOT",24,96,"SLOT",theme.text,8);       L("SLOTV",132,96,"--",theme.text,8);
   L("EN",220,96,"ENABLED",theme.text,8);     L("ENV",328,96,"--",theme.text,8);
   L("SYM",416,96,"SYMBOL",theme.text,8);     L("SYMV",524,96,"--",theme.text,8);
   L("MAG",24,119,"MAGIC",theme.text,8);      L("MAGV",132,119,"--",theme.text,8);

   H("MODULES",24,176,"MODULE CONFIGURATION");
   L("ENTRY",24,199,"ENTRY",theme.text,8);     L("ENTRYV",132,199,"--",theme.text,8);
   L("GRID",220,199,"GRID",theme.text,8);      L("GRIDV",328,199,"--",theme.text,8);
   L("MANAGE",416,199,"MANAGE",theme.text,8); L("MANAGEV",524,199,"--",theme.text,8);
   L("EXIT",24,222,"EXIT",theme.text,8);       L("EXITV",132,222,"--",theme.text,8);

   H("STATE",24,284,"STRATEGY STATUS");
   L("STATUS",24,307,"STATUS",theme.text,8);   L("STATUSV",132,307,"--",theme.text,8);
   L("EXEC",220,307,"EXECUTION",theme.text,8);L("EXECV",328,307,"NO ORDERS",theme.text,8);

   H("RESERVED",24,375,"STRATEGY INFORMATION");
   L("NEXT",24,398,"LD-2: SLOT / ENABLED / SYMBOL / MAGIC",theme.muted,8);
   L("NEXT2",24,421,"LD-3: ENTRY / GRID / MANAGE / EXIT",theme.muted,8);
   ChartRedraw();
  }
  void Hide()
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
   {
    string name=ObjectName(0,i,0,-1);
    if(StringFind(name,"MASTRAT103_")==0)ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,0);
   }
  }
  void Delete()
  {
   if(cvReady){cv.Destroy();cvReady=false;}
   ObjectsDeleteAll(0,"MASTRAT103_",0,-1);
  }
};
#endif
