//+------------------------------------------------------------------+
//| MultiAlpha_Strategy_Dashboard_v1_04.mqh                         |
//| Gate LD-1: legacy LOGIC geometry/theme, no CCanvas dependency.   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_STRATEGY_DASHBOARD_V1_04_MQH
#define MULTIALPHA_STRATEGY_DASHBOARD_V1_04_MQH
#include "..\\O01\\MultiAlpha_Foundation_v1_40.mqh"

class CMultiAlphaStrategyDashboard104
{
 private:
  SMA140PanelTheme m_theme;
  int m_yoff;
  void Background()
  {
   string n="MASTRAT104_BG";
   ObjectDelete(0,n); ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,8); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,36);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,620); ObjectSetInteger(0,n,OBJPROP_YSIZE,570);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,m_theme.background);
   ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,m_theme.border);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,n,OBJPROP_ZORDER,1);
  }
  void Rule(const string id,const int y)
  {
   string n="MASTRAT104_R_"+id;
   ObjectDelete(0,n); ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,20); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,36+y);
   ObjectSetInteger(0,n,OBJPROP_XSIZE,596); ObjectSetInteger(0,n,OBJPROP_YSIZE,1);
   ObjectSetInteger(0,n,OBJPROP_BGCOLOR,m_theme.border); ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,m_theme.border);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
  }
  void L(const string id,const int x,const int y,const string v,const color c,const int fs=8)
  {
   string n="MASTRAT104_L_"+id;
   ObjectDelete(0,n); ObjectCreate(0,n,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
   ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y+m_yoff);
   ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs); ObjectSetInteger(0,n,OBJPROP_COLOR,c);
   ObjectSetString(0,n,OBJPROP_FONT,"Arial"); ObjectSetString(0,n,OBJPROP_TEXT,v);
   ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
  }
  void H(const string id,const int x,const int y,const string v){L("H_"+id,x,y,v,m_theme.section,9);}
 public:
  CMultiAlphaStrategyDashboard104(){m_yoff=28;}
  void Create(const SMA140PanelTheme &appearance)
  {
   m_theme=appearance; Delete(); Background();
   Rule("1",62); Rule("2",164); Rule("3",272); Rule("4",362); Rule("5",448);
   L("TITLE",24,18,"MULTI ALPHA  /  STRATEGY DASHBOARD",m_theme.title,10);
   L("SUB",24,39,"NO ORDERS / VIRTUAL NOT FILL",m_theme.muted,8);
   L("MODE",330,39,"LD-1 DISPLAY SHELL",m_theme.text,8);
   H("BASIC",24,73,"STRATEGY / SLOT");
   L("SLOT",24,96,"SLOT",m_theme.text,8);       L("SLOTV",132,96,"--",m_theme.text,8);
   L("EN",220,96,"ENABLED",m_theme.text,8);     L("ENV",328,96,"--",m_theme.text,8);
   L("SYM",416,96,"SYMBOL",m_theme.text,8);     L("SYMV",524,96,"--",m_theme.text,8);
   L("MAG",24,119,"MAGIC",m_theme.text,8);      L("MAGV",132,119,"--",m_theme.text,8);
   H("MODULES",24,176,"MODULE CONFIGURATION");
   L("ENTRY",24,199,"ENTRY",m_theme.text,8);     L("ENTRYV",132,199,"--",m_theme.text,8);
   L("GRID",220,199,"GRID",m_theme.text,8);      L("GRIDV",328,199,"--",m_theme.text,8);
   L("MANAGE",416,199,"MANAGE",m_theme.text,8); L("MANAGEV",524,199,"--",m_theme.text,8);
   L("EXIT",24,222,"EXIT",m_theme.text,8);       L("EXITV",132,222,"--",m_theme.text,8);
   H("STATE",24,284,"STRATEGY STATUS");
   L("STATUS",24,307,"STATUS",m_theme.text,8);   L("STATUSV",132,307,"--",m_theme.text,8);
   L("EXEC",220,307,"EXECUTION",m_theme.text,8);L("EXECV",328,307,"NO ORDERS",m_theme.text,8);
   H("INFO",24,375,"STRATEGY INFORMATION");
   L("NEXT",24,398,"LD-2: SLOT / ENABLED / SYMBOL / MAGIC",m_theme.muted,8);
   L("NEXT2",24,421,"LD-3: ENTRY / GRID / MANAGE / EXIT",m_theme.muted,8);
   ChartRedraw();
  }
  void Hide()
  {
   int total=ObjectsTotal(0,0,-1);
   for(int i=total-1;i>=0;i--)
   {
    string name=ObjectName(0,i,0,-1);
    if(StringFind(name,"MASTRAT104_")==0)ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,0);
   }
  }
  void Delete(){ObjectsDeleteAll(0,"MASTRAT104_",0,-1);}
};
#endif
