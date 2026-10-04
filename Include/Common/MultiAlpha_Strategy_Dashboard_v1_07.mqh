//+------------------------------------------------------------------+
//| MultiAlpha_Strategy_Dashboard_v1_07.mqh                         |
//| Gate LD-1: function-only dashboard shell; no custom class state. |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_STRATEGY_DASHBOARD_V1_07_MQH
#define MULTIALPHA_STRATEGY_DASHBOARD_V1_07_MQH

void MA_StrategyDashboard107_Delete()
{
 ObjectsDeleteAll(0,"MASTRAT107_",0,-1);
}
void MA_StrategyDashboard107_Box(const string id,const int x,const int y,const int w,const int h,const color bg,const color border)
{
 string n="MASTRAT107_B_"+id;
 ObjectDelete(0,n); ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
 ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
 ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
 ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,border);
 ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
}
void MA_StrategyDashboard107_Label(const string id,const int x,const int y,const string value,const color c,const int fs)
{
 string n="MASTRAT107_L_"+id;
 ObjectDelete(0,n); ObjectCreate(0,n,OBJ_LABEL,0,0,0);
 ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
 ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs); ObjectSetInteger(0,n,OBJPROP_COLOR,c);
 ObjectSetString(0,n,OBJPROP_FONT,"Arial"); ObjectSetString(0,n,OBJPROP_TEXT,value);
 ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
}
void MA_StrategyDashboard107_Rule(const string id,const int y)
{
 MA_StrategyDashboard107_Box("R_"+id,20,36+y,596,1,clrDimGray,clrDimGray);
}
void MA_StrategyDashboard107_Create()
{
 MA_StrategyDashboard107_Delete();
 MA_StrategyDashboard107_Box("BG",8,36,620,570,clrBlack,clrDimGray);
 MA_StrategyDashboard107_Rule("1",62); MA_StrategyDashboard107_Rule("2",164);
 MA_StrategyDashboard107_Rule("3",272); MA_StrategyDashboard107_Rule("4",362); MA_StrategyDashboard107_Rule("5",448);
 MA_StrategyDashboard107_Label("TITLE",24,46,"MULTI ALPHA  /  STRATEGY DASHBOARD",clrWhite,10);
 MA_StrategyDashboard107_Label("SUB",24,67,"NO ORDERS / VIRTUAL NOT FILL",clrSilver,8);
 MA_StrategyDashboard107_Label("MODE",330,67,"LD-1 DISPLAY SHELL",clrWhite,8);
 MA_StrategyDashboard107_Label("HB",24,101,"STRATEGY / SLOT",clrAqua,9);
 MA_StrategyDashboard107_Label("SLOT",24,124,"SLOT",clrWhite,8); MA_StrategyDashboard107_Label("SLOTV",132,124,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("EN",220,124,"ENABLED",clrWhite,8); MA_StrategyDashboard107_Label("ENV",328,124,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("SYM",416,124,"SYMBOL",clrWhite,8); MA_StrategyDashboard107_Label("SYMV",524,124,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("MAG",24,147,"MAGIC",clrWhite,8); MA_StrategyDashboard107_Label("MAGV",132,147,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("HM",24,204,"MODULE CONFIGURATION",clrAqua,9);
 MA_StrategyDashboard107_Label("ENTRY",24,227,"ENTRY",clrWhite,8); MA_StrategyDashboard107_Label("ENTRYV",132,227,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("GRID",220,227,"GRID",clrWhite,8); MA_StrategyDashboard107_Label("GRIDV",328,227,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("MANAGE",416,227,"MANAGE",clrWhite,8); MA_StrategyDashboard107_Label("MANAGEV",524,227,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("EXIT",24,250,"EXIT",clrWhite,8); MA_StrategyDashboard107_Label("EXITV",132,250,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("HS",24,312,"STRATEGY STATUS",clrAqua,9);
 MA_StrategyDashboard107_Label("STATUS",24,335,"STATUS",clrWhite,8); MA_StrategyDashboard107_Label("STATUSV",132,335,"--",clrWhite,8);
 MA_StrategyDashboard107_Label("EXEC",220,335,"EXECUTION",clrWhite,8); MA_StrategyDashboard107_Label("EXECV",328,335,"NO ORDERS",clrWhite,8);
 MA_StrategyDashboard107_Label("HI",24,403,"STRATEGY INFORMATION",clrAqua,9);
 MA_StrategyDashboard107_Label("NEXT",24,426,"LD-2: SLOT / ENABLED / SYMBOL / MAGIC",clrSilver,8);
 MA_StrategyDashboard107_Label("NEXT2",24,449,"LD-3: ENTRY / GRID / MANAGE / EXIT",clrSilver,8);
 ChartRedraw();
}
void MA_StrategyDashboard107_Hide()
{
 int total=ObjectsTotal(0,0,-1);
 for(int i=total-1;i>=0;i--)
 {
  string name=ObjectName(0,i,0,-1);
  if(StringFind(name,"MASTRAT107_")==0)ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,0);
 }
}
#endif
