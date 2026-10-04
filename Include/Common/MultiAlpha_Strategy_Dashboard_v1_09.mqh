//+------------------------------------------------------------------+
//| MultiAlpha_Strategy_Dashboard_v1_09.mqh                         |
//| Gate LD-1: function-only dashboard shell; no custom class state. |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_STRATEGY_DASHBOARD_V1_09_MQH
#define MULTIALPHA_STRATEGY_DASHBOARD_V1_09_MQH

void MA_StrategyDashboard109_Delete()
{
 ObjectsDeleteAll(0,"MASTRAT109_",0,-1);
}
void MA_StrategyDashboard109_Box(const string id,const int x,const int y,const int w,const int h,const color bg,const color border)
{
 string n="MASTRAT109_B_"+id;
 ObjectDelete(0,n); ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
 ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
 ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
 ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,border);
 ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
}
void MA_StrategyDashboard109_Label(const string id,const int x,const int y,const string value,const color c,const int fs)
{
 string n="MASTRAT109_L_"+id;
 ObjectDelete(0,n); ObjectCreate(0,n,OBJ_LABEL,0,0,0);
 ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
 ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs); ObjectSetInteger(0,n,OBJPROP_COLOR,c);
 ObjectSetString(0,n,OBJPROP_FONT,"Arial"); ObjectSetString(0,n,OBJPROP_TEXT,value);
 ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
}
void MA_StrategyDashboard109_Rule(const string id,const int y)
{
 MA_StrategyDashboard109_Box("R_"+id,20,146+y,596,1,clrDimGray,clrDimGray);
}
void MA_StrategyDashboard109_Create()
{
 MA_StrategyDashboard109_Delete();
 MA_StrategyDashboard109_Box("BG",8,146,620,460,clrBlack,clrDimGray);
 MA_StrategyDashboard109_Rule("1",62); MA_StrategyDashboard109_Rule("2",164);
 MA_StrategyDashboard109_Rule("3",272); MA_StrategyDashboard109_Rule("4",362); MA_StrategyDashboard109_Rule("5",448);
 MA_StrategyDashboard109_Label("TITLE",24,156,"MULTI ALPHA  /  STRATEGY DASHBOARD",clrWhite,10);
 MA_StrategyDashboard109_Label("SUB",24,177,"NO ORDERS / VIRTUAL NOT FILL",clrSilver,8);
 MA_StrategyDashboard109_Label("MODE",330,177,"LD-1 DISPLAY SHELL",clrWhite,8);
 MA_StrategyDashboard109_Label("HB",24,211,"STRATEGY / SLOT",clrAqua,9);
 MA_StrategyDashboard109_Label("SLOT",24,234,"SLOT",clrWhite,8); MA_StrategyDashboard109_Label("SLOTV",132,234,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("EN",280,234,"ENABLED",clrWhite,8); MA_StrategyDashboard109_Label("ENV",328,234,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("SYM",416,234,"SYMBOL",clrWhite,8); MA_StrategyDashboard109_Label("SYMV",524,234,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("MAG",24,257,"MAGIC",clrWhite,8); MA_StrategyDashboard109_Label("MAGV",132,257,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("HM",24,314,"MODULE CONFIGURATION",clrAqua,9);
 MA_StrategyDashboard109_Label("ENTRY",24,337,"ENTRY",clrWhite,8); MA_StrategyDashboard109_Label("ENTRYV",132,337,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("GRID",280,337,"GRID",clrWhite,8); MA_StrategyDashboard109_Label("GRIDV",328,337,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("MANAGE",416,337,"MANAGE",clrWhite,8); MA_StrategyDashboard109_Label("MANAGEV",524,337,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("EXIT",24,360,"EXIT",clrWhite,8); MA_StrategyDashboard109_Label("EXITV",132,360,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("HS",24,422,"STRATEGY STATUS",clrAqua,9);
 MA_StrategyDashboard109_Label("STATUS",24,445,"STATUS",clrWhite,8); MA_StrategyDashboard109_Label("STATUSV",132,445,"--",clrWhite,8);
 MA_StrategyDashboard109_Label("EXEC",280,445,"EXECUTION",clrWhite,8); MA_StrategyDashboard109_Label("EXECV",328,445,"NO ORDERS",clrWhite,8);
 MA_StrategyDashboard109_Label("HI",24,513,"STRATEGY INFORMATION",clrAqua,9);
 MA_StrategyDashboard109_Label("NEXT",24,536,"LD-2: SLOT / ENABLED / SYMBOL / MAGIC",clrSilver,8);
 MA_StrategyDashboard109_Label("NEXT2",24,559,"LD-3: ENTRY / GRID / MANAGE / EXIT",clrSilver,8);
 ChartRedraw();
}
void MA_StrategyDashboard109_Hide()
{
 int total=ObjectsTotal(0,0,-1);
 for(int i=total-1;i>=0;i--)
 {
  string name=ObjectName(0,i,0,-1);
  if(StringFind(name,"MASTRAT109_")==0)ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,0);
 }
}
#endif
