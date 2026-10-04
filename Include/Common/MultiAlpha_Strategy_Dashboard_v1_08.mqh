//+------------------------------------------------------------------+
//| MultiAlpha_Strategy_Dashboard_v1_08.mqh                         |
//| Gate LD-1: function-only dashboard shell; no custom class state. |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_STRATEGY_DASHBOARD_V1_08_MQH
#define MULTIALPHA_STRATEGY_DASHBOARD_V1_08_MQH

void MA_StrategyDashboard108_Delete()
{
 ObjectsDeleteAll(0,"MASTRAT108_",0,-1);
}
void MA_StrategyDashboard108_Box(const string id,const int x,const int y,const int w,const int h,const color bg,const color border)
{
 string n="MASTRAT108_B_"+id;
 ObjectDelete(0,n); ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
 ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
 ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,h);
 ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg); ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,border);
 ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
}
void MA_StrategyDashboard108_Label(const string id,const int x,const int y,const string value,const color c,const int fs)
{
 string n="MASTRAT108_L_"+id;
 ObjectDelete(0,n); ObjectCreate(0,n,OBJ_LABEL,0,0,0);
 ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
 ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
 ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs); ObjectSetInteger(0,n,OBJPROP_COLOR,c);
 ObjectSetString(0,n,OBJPROP_FONT,"Arial"); ObjectSetString(0,n,OBJPROP_TEXT,value);
 ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false); ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
}
void MA_StrategyDashboard108_Rule(const string id,const int y)
{
 MA_StrategyDashboard108_Box("R_"+id,20,86+y,596,1,clrDimGray,clrDimGray);
}
void MA_StrategyDashboard108_Create()
{
 MA_StrategyDashboard108_Delete();
 MA_StrategyDashboard108_Box("BG",8,86,620,520,clrBlack,clrDimGray);
 MA_StrategyDashboard108_Rule("1",62); MA_StrategyDashboard108_Rule("2",164);
 MA_StrategyDashboard108_Rule("3",272); MA_StrategyDashboard108_Rule("4",362); MA_StrategyDashboard108_Rule("5",448);
 MA_StrategyDashboard108_Label("TITLE",24,96,"MULTI ALPHA  /  STRATEGY DASHBOARD",clrWhite,10);
 MA_StrategyDashboard108_Label("SUB",24,117,"NO ORDERS / VIRTUAL NOT FILL",clrSilver,8);
 MA_StrategyDashboard108_Label("MODE",330,117,"LD-1 DISPLAY SHELL",clrWhite,8);
 MA_StrategyDashboard108_Label("HB",24,151,"STRATEGY / SLOT",clrAqua,9);
 MA_StrategyDashboard108_Label("SLOT",24,174,"SLOT",clrWhite,8); MA_StrategyDashboard108_Label("SLOTV",132,174,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("EN",220,174,"ENABLED",clrWhite,8); MA_StrategyDashboard108_Label("ENV",328,174,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("SYM",416,174,"SYMBOL",clrWhite,8); MA_StrategyDashboard108_Label("SYMV",524,174,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("MAG",24,197,"MAGIC",clrWhite,8); MA_StrategyDashboard108_Label("MAGV",132,197,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("HM",24,254,"MODULE CONFIGURATION",clrAqua,9);
 MA_StrategyDashboard108_Label("ENTRY",24,277,"ENTRY",clrWhite,8); MA_StrategyDashboard108_Label("ENTRYV",132,277,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("GRID",220,277,"GRID",clrWhite,8); MA_StrategyDashboard108_Label("GRIDV",328,277,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("MANAGE",416,277,"MANAGE",clrWhite,8); MA_StrategyDashboard108_Label("MANAGEV",524,277,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("EXIT",24,300,"EXIT",clrWhite,8); MA_StrategyDashboard108_Label("EXITV",132,300,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("HS",24,362,"STRATEGY STATUS",clrAqua,9);
 MA_StrategyDashboard108_Label("STATUS",24,385,"STATUS",clrWhite,8); MA_StrategyDashboard108_Label("STATUSV",132,385,"--",clrWhite,8);
 MA_StrategyDashboard108_Label("EXEC",220,385,"EXECUTION",clrWhite,8); MA_StrategyDashboard108_Label("EXECV",328,385,"NO ORDERS",clrWhite,8);
 MA_StrategyDashboard108_Label("HI",24,453,"STRATEGY INFORMATION",clrAqua,9);
 MA_StrategyDashboard108_Label("NEXT",24,476,"LD-2: SLOT / ENABLED / SYMBOL / MAGIC",clrSilver,8);
 MA_StrategyDashboard108_Label("NEXT2",24,499,"LD-3: ENTRY / GRID / MANAGE / EXIT",clrSilver,8);
 ChartRedraw();
}
void MA_StrategyDashboard108_Hide()
{
 int total=ObjectsTotal(0,0,-1);
 for(int i=total-1;i>=0;i--)
 {
  string name=ObjectName(0,i,0,-1);
  if(StringFind(name,"MASTRAT108_")==0)ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,0);
 }
}
#endif
