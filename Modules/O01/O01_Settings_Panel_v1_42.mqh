//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_42.mqh                                    |
//| STEP 4: compile-safe fixed-layout panel body.                                 |
//| Trading settings/behavior remain compatible with v1.33.          |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_42_MQH
#define O01_SETTINGS_PANEL_V1_42_MQH
#include "O01_Runtime_Settings_v1_10.mqh"
#include "MultiAlpha_Foundation_v1_40.mqh"
#include <Canvas\Canvas.mqh>

class CO01SettingsPanel141{
 string p; CO01SettingsStore110 st; CCanvas cv; bool cvReady;
 SMA140PanelTheme theme; SMA140StrategyIdentity identity;
 color C_EDIT_BG,C_BUTTON;
 int PX,PY,PW,PH;
 int X1,X2,X3,LW,EW,RH;
 void CanvasCreate(){
  string n=p+"BG";if(cvReady){cv.Destroy();cvReady=false;}
  cvReady=cv.CreateBitmapLabel(0,0,n,PX,PY,PW,PH,COLOR_FORMAT_ARGB_NORMALIZE);
  if(!cvReady){Print("O01 v1.41 panel canvas creation failed");return;}
  ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,1);
  uchar a=(uchar)MathMax(0,MathMin(255,theme.opacity));cv.Erase(ColorToARGB(theme.background,a));
  uint fr=ColorToARGB(theme.border,220),sp=ColorToARGB(theme.border,155);
  cv.Rectangle(0,0,PW-1,PH-1,fr);
  int ys[]={62,164,272,362,448};for(int i=0;i<ArraySize(ys);i++)cv.Line(12,ys[i],PW-13,ys[i],sp);
  cv.Line(310,362,310,448,sp);cv.Update(false);
 }
 void L(string id,int x,int y,string v,color c,int fs=8){
  string n=p+"L_"+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_COLOR,c);ObjectSetString(0,n,OBJPROP_FONT,"Arial");ObjectSetString(0,n,OBJPROP_TEXT,v);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
 }
 void E(string id,int x,int y,string v,int w=64){
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,19);
  ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C_EDIT_BG);ObjectSetInteger(0,n,OBJPROP_COLOR,theme.text);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,theme.border);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,theme.font_size);ObjectSetInteger(0,n,OBJPROP_ALIGN,ALIGN_CENTER);ObjectSetInteger(0,n,OBJPROP_READONLY,false);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);ObjectSetInteger(0,n,OBJPROP_BACK,false);ObjectSetString(0,n,OBJPROP_TEXT,v);
 }
 void F(string id,int col,int y,string lab,string v,int lw=100,int ew=64){L(id,col,y+2,lab,theme.text,theme.font_size);E(id,col+lw,y,v,ew);}
 void H(string id,int x,int y,string v){L("H_"+id,x,y,v,theme.section,9);}
 void B(string id,int x,int y,int w,string v){
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,25);
  ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C_BUTTON);ObjectSetInteger(0,n,OBJPROP_COLOR,theme.text);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,theme.border);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,theme.font_size);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,false);ObjectSetInteger(0,n,OBJPROP_BACK,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,30);ObjectSetString(0,n,OBJPROP_TEXT,v);
 }
 string G(string id){return ObjectGetString(0,p+id,OBJPROP_TEXT);} double D(string id){return StringToDouble(G(id));} int I(string id){return(int)StringToInteger(G(id));}
 void NormalizeEdit(string name){
  string id=name;
  if(StringFind(id,p)==0)id=StringSubstr(id,StringLen(p));
  string v=ObjectGetString(0,name,OBJPROP_TEXT);
  if(id=="RSIL"||id=="RSIU"||id=="A1MIN"||id=="A1MAX"||id=="A2MIN"||id=="A2MAX")
   ObjectSetString(0,name,OBJPROP_TEXT,DoubleToString(StringToDouble(v),1));
  else if(id=="LOT"||id=="MULT"||id=="MAXLOT"||id=="TOTLOT"||id=="DISTM")
   ObjectSetString(0,name,OBJPROP_TEXT,DoubleToString(StringToDouble(v),2));
  else if(id=="RSIP"||id=="ATR1P"||id=="ATR2P"||id=="ATR2TF"||id=="MAXORD"||id=="GRID"||id=="DYNORD"||id=="DYNPTS"||id=="VSL"||id=="STS"||id=="STL"||id=="STD"||id=="STSTEP"||id=="BTS"||id=="BTL"||id=="BTD"||id=="BTSTEP"||id=="WARN"||id=="PAUSE"||id=="CLOSE")
   ObjectSetString(0,name,OBJPROP_TEXT,IntegerToString((int)StringToInteger(v)));
 }
 string TF(int m){if(m==0)return"AUTO_GMT";if(m==1)return"SERVER_TIME";return"CUSTOM_GMT";}
 int TM(string s){StringToUpper(s);if(s=="SERVER_TIME"||s=="1")return 1;if(s=="CUSTOM_GMT"||s=="2")return 2;return 0;}
 string OnOff(bool v){return v?"1":"0";} bool Bool(string id){string s=G(id);StringToUpper(s);return(s=="1"||s=="ON"||s=="TRUE"||s=="YES");}
 void Draw(const SO01RuntimeSettings110&s){
  CanvasCreate();
  L("TITLE",24,18,"MULTI ALPHA  /  O01 RUNTIME",theme.title,10);
  L("INSTANCE",250,18,StringFormat("Strategy #%d  %s  E:%s M:%s X:%s",identity.instance_id,identity.symbol,identity.entry_module,identity.manage_module,identity.exit_module),theme.text,8);
  L("SUB",24,39,"Fixed Layout  |  Appearance Theme  |  NO ORDERS / VIRTUAL NOT FILL",theme.muted,8);
  H("ENTRY",X1,73,"ENTRY / FILTER");
  F("NEW",X1,94,"New Cycles",OnOff(s.new_cycles));F("BUY",X2,94,"Trade BUY",OnOff(s.trade_buy));F("SELL",X3,94,"Trade SELL",OnOff(s.trade_sell));
  F("RSIP",X1,117,"RSI Period",(string)s.rsi_period);F("RSIL",X2,117,"RSI Lower",DoubleToString(s.rsi_lower,1));F("RSIU",X3,117,"RSI Upper",DoubleToString(s.rsi_upper,1));
  F("ATR1P",X1,140,"ATR1 Period",(string)s.atr1_period);F("ATR2P",X2,140,"ATR2 Period",(string)s.atr2_period);F("ATR2TF",X3,140,"ATR2 TF",(string)s.atr2_timeframe);
  H("GRID",X1,176,"MANAGE / GRID / LOT");
  F("LOT",X1,197,"Initial Lot",DoubleToString(s.initial_lot,2));F("MULT",X2,197,"Lot Mult",DoubleToString(s.lot_multiplier,2));F("MAXLOT",X3,197,"Max Lot",DoubleToString(s.max_lot,2));
  F("TOTLOT",X1,220,"Max Side Lots",DoubleToString(s.max_total_lots_per_side,2));F("MAXORD",X2,220,"Max Orders",(string)s.max_orders);F("GRID",X3,220,"Grid Distance",(string)s.fixed_distance_points);
  F("DYNORD",X1,243,"Dynamic Start #",(string)s.dynamic_start_order);F("DYNPTS",X2,243,"Dynamic Points",(string)s.dynamic_start_points);F("DISTM",X3,243,"Distance Mult",DoubleToString(s.distance_multiplier,2));
  H("EXIT",X1,284,"EXIT / TRAILING");
  F("VSL",X1,305,"Virtual SL",(string)s.virtual_sl_points);F("STS",X2,305,"Single Start",(string)s.single_trail_start);F("STL",X3,305,"Single Lock",(string)s.single_trail_lock);
  F("STD",X1,328,"Single Dist",(string)s.single_trail_distance);F("BTS",X2,328,"Basket Start",(string)s.basket_trail_start);F("BTL",X3,328,"Basket Lock",(string)s.basket_trail_lock);
  H("SAFETY",X1,375,"SAFETY / DD");H("TIME",326,375,"TIME / NEWS");
  F("WARN",X1,397,"Warning DD %",(string)s.warning_dd,96,48);F("PAUSE",166,397,"Grid Pause %",(string)s.pause_grid_dd,88,44);
  F("CLOSE",X1,420,"Emergency %",(string)s.emergency_close_dd,96,48);
  F("TMODE",326,397,"Time Mode",TF(s.time_mode),74,88);F("START",492,397,"Start",StringFormat("%02d:%02d",s.start_hour,s.start_minute),42,58);
  F("END",326,420,"End",StringFormat("%02d:%02d",s.end_hour,s.end_minute),74,88);F("NEWS",492,420,"News",OnOff(s.use_news_filter),42,58);
  // Compatibility state remains off-screen until advanced settings page is implemented.
  E("A1MIN",-300,20,DoubleToString(s.atr1_min_points,1));E("A1MAX",-300,42,DoubleToString(s.atr1_max_points,1));E("A2MIN",-300,64,DoubleToString(s.atr2_min_points,1));E("A2MAX",-300,86,DoubleToString(s.atr2_max_points,1));
  E("ONEBAR",-300,108,OnOff(s.one_order_per_bar));E("GRIDOUT",-300,130,OnOff(s.allow_grid_outside_time));E("PGTR",-300,152,OnOff(s.pause_grid_while_trailing));E("STSTEP",-300,174,(string)s.single_trail_step);E("BTD",-300,196,(string)s.basket_trail_distance);E("BTSTEP",-300,218,(string)s.basket_trail_step);E("NEWSMO",-300,240,OnOff(s.news_manage_only));
  B("APPLY",24,472,137,"APPLY");B("SAVE",171,472,137,"SAVE");B("LOAD",318,472,137,"LOAD");B("RESET",465,472,137,"REFRESH");ChartRedraw();
 }
public:
 void Create(const SO01RuntimeSettings110&s,const SMA140StrategyIdentity &strategy_cfg,const SMA140PanelTheme &appearance){
  p="O01CFG141_";cvReady=false;PX=8;PY=8;PW=620;PH=522;X1=24;X2=220;X3=416;LW=100;EW=64;RH=23;identity=strategy_cfg;theme=appearance;st.SetFile("O01_GSG_RSI30_Settings_v1_10.csv");C_EDIT_BG=C'24,31,38';C_BUTTON=C'42,52,61';Draw(s);
 }
 void Delete(){if(cvReady){cv.Destroy();cvReady=false;}ObjectsDeleteAll(0,p);}
 bool Pull(SO01RuntimeSettings110&s){
  s.new_cycles=Bool("NEW");s.trade_buy=Bool("BUY");s.trade_sell=Bool("SELL");s.rsi_period=I("RSIP");s.rsi_lower=D("RSIL");s.rsi_upper=D("RSIU");
  s.atr1_period=I("ATR1P");s.atr2_period=I("ATR2P");s.atr2_timeframe=I("ATR2TF");s.atr1_min_points=D("A1MIN");s.atr1_max_points=D("A1MAX");s.atr2_min_points=D("A2MIN");s.atr2_max_points=D("A2MAX");
  s.initial_lot=D("LOT");s.lot_multiplier=D("MULT");s.max_lot=D("MAXLOT");s.max_total_lots_per_side=D("TOTLOT");s.max_orders=I("MAXORD");s.fixed_distance_points=I("GRID");s.dynamic_start_order=I("DYNORD");s.dynamic_start_points=I("DYNPTS");s.distance_multiplier=D("DISTM");
  s.one_order_per_bar=Bool("ONEBAR");s.allow_grid_outside_time=Bool("GRIDOUT");s.pause_grid_while_trailing=Bool("PGTR");s.virtual_sl_points=I("VSL");s.single_trail_start=I("STS");s.single_trail_lock=I("STL");s.single_trail_distance=I("STD");s.single_trail_step=I("STSTEP");
  s.basket_trail_start=I("BTS");s.basket_trail_lock=I("BTL");s.basket_trail_distance=I("BTD");s.basket_trail_step=I("BTSTEP");s.warning_dd=I("WARN");s.pause_grid_dd=I("PAUSE");s.emergency_close_dd=I("CLOSE");s.time_mode=TM(G("TMODE"));
  string a=G("START"),b=G("END");if(StringLen(a)!=5||StringSubstr(a,2,1)!=":"||StringLen(b)!=5||StringSubstr(b,2,1)!=":")return false;
  s.start_hour=(int)StringToInteger(StringSubstr(a,0,2));s.start_minute=(int)StringToInteger(StringSubstr(a,3,2));s.end_hour=(int)StringToInteger(StringSubstr(b,0,2));s.end_minute=(int)StringToInteger(StringSubstr(b,3,2));s.use_news_filter=Bool("NEWS");s.news_manage_only=Bool("NEWSMO");
  return s.rsi_period>0&&s.rsi_lower>=0&&s.rsi_upper<=100&&s.rsi_lower<s.rsi_upper&&s.atr1_period>0&&s.atr2_period>0&&s.atr1_min_points>=0&&s.atr1_max_points>=s.atr1_min_points&&s.atr2_min_points>=0&&s.atr2_max_points>=s.atr2_min_points&&s.initial_lot>0&&s.lot_multiplier>=1&&s.max_lot>=s.initial_lot&&s.max_total_lots_per_side>=0&&s.max_orders>0&&s.fixed_distance_points>0&&s.dynamic_start_order>0&&s.dynamic_start_points>0&&s.distance_multiplier>=1&&s.virtual_sl_points>=0&&s.warning_dd>=0&&s.pause_grid_dd>=s.warning_dd&&s.emergency_close_dd>=s.pause_grid_dd&&s.start_hour>=0&&s.start_hour<24&&s.end_hour>=0&&s.end_hour<24&&s.start_minute>=0&&s.start_minute<60&&s.end_minute>=0&&s.end_minute<60;
 }
 int PollButtons(SO01RuntimeSettings110 &s){
  string n=p+"APPLY";
  if(ObjectFind(0,n)>=0 && (bool)ObjectGetInteger(0,n,OBJPROP_STATE)){ObjectSetInteger(0,n,OBJPROP_STATE,false);ChartRedraw();Print("[O01_PANEL_POLL] APPLY");return Pull(s)?1:-1;}
  n=p+"SAVE";
  if(ObjectFind(0,n)>=0 && (bool)ObjectGetInteger(0,n,OBJPROP_STATE)){ObjectSetInteger(0,n,OBJPROP_STATE,false);ChartRedraw();Print("[O01_PANEL_POLL] SAVE");if(!Pull(s))return -1;return st.Save(s)?2:-2;}
  n=p+"LOAD";
  if(ObjectFind(0,n)>=0 && (bool)ObjectGetInteger(0,n,OBJPROP_STATE)){ObjectSetInteger(0,n,OBJPROP_STATE,false);ChartRedraw();Print("[O01_PANEL_POLL] LOAD");if(!st.Load(s))return -3;Delete();Create(s,identity,theme);return 3;}
  n=p+"RESET";
  if(ObjectFind(0,n)>=0 && (bool)ObjectGetInteger(0,n,OBJPROP_STATE)){ObjectSetInteger(0,n,OBJPROP_STATE,false);ChartRedraw();Print("[O01_PANEL_POLL] RESET");SO01RuntimeSettings110 disk=s;if(st.Load(disk))s=disk;Delete();Create(s,identity,theme);return 4;}
  return 0;
 }
 int Event(int id,string name,SO01RuntimeSettings110&s){if(id==CHARTEVENT_OBJECT_ENDEDIT&&StringFind(name,p)==0&&ObjectGetInteger(0,name,OBJPROP_TYPE)==OBJ_EDIT){NormalizeEdit(name);ChartRedraw();return 0;}if(id!=CHARTEVENT_OBJECT_CLICK)return 0;Print("[O01_PANEL_CLICK] name=",name);if(StringFind(name,p)!=0)return 0;if(name==p+"APPLY"){ObjectSetInteger(0,name,OBJPROP_STATE,false);ChartRedraw();return Pull(s)?1:-1;}if(name==p+"SAVE"){ObjectSetInteger(0,name,OBJPROP_STATE,false);ChartRedraw();if(!Pull(s))return-1;return st.Save(s)?2:-2;}if(name==p+"LOAD"){ObjectSetInteger(0,name,OBJPROP_STATE,false);ChartRedraw();if(!st.Load(s))return-3;Delete();Create(s,identity,theme);return 3;}
if(name==p+"RESET"){ObjectSetInteger(0,name,OBJPROP_STATE,false);ChartRedraw();
 SO01RuntimeSettings110 disk=s;
 if(st.Load(disk)){s=disk;Delete();Create(s,identity,theme);return 4;}
 Delete();Create(s,identity,theme);return 4;
}return 0;}
 void RefreshIdentity(const SMA140StrategyIdentity &strategy_cfg,const SMA140PanelTheme &appearance){
  identity=strategy_cfg;theme=appearance;CanvasCreate();
  L("TITLE",24,18,"MULTI ALPHA  /  O01 RUNTIME",theme.title,10);
  L("INSTANCE",250,18,StringFormat("Strategy #%d  %s  E:%s M:%s X:%s",identity.instance_id,identity.symbol,identity.entry_module,identity.manage_module,identity.exit_module),theme.text,8);
  L("SUB",24,39,"Fixed Layout  |  Appearance Theme  |  NO ORDERS / VIRTUAL NOT FILL",theme.muted,8);
  ChartRedraw();
 }
};
// Backward-compatible host name used by the current local v1.40 main-line EA.
class CO01SettingsPanel140 : public CO01SettingsPanel141 {};
#endif
