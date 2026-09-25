//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_32.mqh                                   |
//| Semi-transparent dark runtime panel, white-first typography.     |
//| APPLY/SAVE/LOAD/REFRESH. NO ORDERS.                              |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_32_MQH
#define O01_SETTINGS_PANEL_V1_32_MQH
#include "O01_Runtime_Settings_v1_10.mqh"

class CO01SettingsPanel132{
 string p; CO01SettingsStore110 st;
 color C_TEXT,C_MUTED,C_HEAD,C_ACCENT,C_EDIT_BG,C_BORDER,C_BUTTON;
 void Base(string id,int x,int y,int w,int h,color bg,uchar alpha=185){
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,h);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,ColorToARGB(bg,alpha));
  ObjectSetInteger(0,n,OBJPROP_BORDER_TYPE,BORDER_FLAT);ObjectSetInteger(0,n,OBJPROP_COLOR,C_BORDER);ObjectSetInteger(0,n,OBJPROP_BACK,false);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
 }
 void L(string id,int x,int y,string v,color c=clrNONE,int fs=8){
  string n=p+"L_"+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
  ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);
  ObjectSetInteger(0,n,OBJPROP_COLOR,c==clrNONE?C_TEXT:c);ObjectSetString(0,n,OBJPROP_FONT,"Arial");ObjectSetString(0,n,OBJPROP_TEXT,v);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
 }
 void E(string id,int x,int y,string v,int w=64){
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
  ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,19);
  ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C_EDIT_BG);ObjectSetInteger(0,n,OBJPROP_COLOR,C_TEXT);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C_BORDER);
  ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ALIGN,ALIGN_CENTER);ObjectSetString(0,n,OBJPROP_TEXT,v);
 }
 void F(string id,int x,int y,string lab,string v,int lw=104,int ew=64){L(id,x,y+2,lab,C_TEXT,8);E(id,x+lw,y,v,ew);}
 void H(string id,int x,int y,string v){L("H_"+id,x,y,v,C_HEAD,9);}
 void B(string id,int x,int y,int w,string v){
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
  ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,25);
  ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C_BUTTON);ObjectSetInteger(0,n,OBJPROP_COLOR,C_TEXT);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C_BORDER);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetString(0,n,OBJPROP_TEXT,v);
 }
 string G(string id){return ObjectGetString(0,p+id,OBJPROP_TEXT);} double D(string id){return StringToDouble(G(id));} int I(string id){return(int)StringToInteger(G(id));}
 string TF(int m){if(m==0)return"AUTO_GMT";if(m==1)return"SERVER_TIME";return"CUSTOM_GMT";}
 int TM(string s){StringToUpper(s);if(s=="SERVER_TIME"||s=="1")return 1;if(s=="CUSTOM_GMT"||s=="2")return 2;return 0;}
 string OnOff(bool v){return v?"1":"0";} bool Bool(string id){string s=G(id);StringToUpper(s);return(s=="1"||s=="ON"||s=="TRUE"||s=="YES");}
public:
 void Create(const SO01RuntimeSettings110&s){
  p="O01CFG132_";st.SetFile("O01_GSG_RSI30_Settings_v1_10.csv");
  C_TEXT=clrWhite;C_MUTED=C'175,185,195';C_HEAD=C'70,200,235';C_ACCENT=C'235,200,70';C_EDIT_BG=C'24,31,38';C_BORDER=C'70,85,95';C_BUTTON=C'42,52,61';
  Base("BG",6,18,610,480,C'8,14,20',205);
  L("TITLE",18,27,"O01 GOLD SESSION GUARD - RUNTIME PANEL v1.32",C_ACCENT,10);
  L("SAFE",405,28,"NO ORDERS / VIRTUAL NOT FILL",C_HEAD,8);
  L("SUB",18,47,"Settings / Research Panel",C_MUTED,8);
  Base("ENTRYBOX",14,66,590,102,C'12,21,28',170);H("ENTRY",24,73,"ENTRY / FILTER");
  F("NEW",24,93,"New Cycles",OnOff(s.new_cycles));F("BUY",214,93,"Trade BUY",OnOff(s.trade_buy));F("SELL",404,93,"Trade SELL",OnOff(s.trade_sell));
  F("RSIP",24,116,"RSI Period",(string)s.rsi_period);F("RSIL",214,116,"RSI Lower",DoubleToString(s.rsi_lower,1));F("RSIU",404,116,"RSI Upper",DoubleToString(s.rsi_upper,1));
  F("ATR1P",24,139,"ATR1 Period",(string)s.atr1_period);F("ATR2P",214,139,"ATR2 Period",(string)s.atr2_period);F("ATR2TF",404,139,"ATR2 TF",(string)s.atr2_timeframe);
  Base("GRIDBOX",14,174,590,101,C'12,21,28',170);H("GRID",24,181,"GRID / LOT");
  F("LOT",24,201,"Initial Lot",DoubleToString(s.initial_lot,2));F("MULT",214,201,"Lot Mult",DoubleToString(s.lot_multiplier,2));F("MAXLOT",404,201,"Max Lot",DoubleToString(s.max_lot,2));
  F("TOTLOT",24,224,"Max Side Lots",DoubleToString(s.max_total_lots_per_side,2));F("MAXORD",214,224,"Max Orders",(string)s.max_orders);F("GRID",404,224,"Grid Distance",(string)s.fixed_distance_points);
  F("DYNORD",24,247,"Dynamic Start #",(string)s.dynamic_start_order);F("DYNPTS",214,247,"Dynamic Points",(string)s.dynamic_start_points);F("DISTM",404,247,"Distance Mult",DoubleToString(s.distance_multiplier,2));
  Base("EXITBOX",14,281,590,83,C'12,21,28',170);H("EXIT",24,288,"EXIT / TRAILING");
  F("VSL",24,308,"Virtual SL",(string)s.virtual_sl_points);F("STS",214,308,"Single Start",(string)s.single_trail_start);F("STL",404,308,"Single Lock",(string)s.single_trail_lock);
  F("STD",24,331,"Single Dist",(string)s.single_trail_distance);F("BTS",214,331,"Basket Start",(string)s.basket_trail_start);F("BTL",404,331,"Basket Lock",(string)s.basket_trail_lock);
  Base("SAFETYBOX",14,370,292,75,C'12,21,28',170);H("SAFETY",24,377,"SAFETY / DD");
  F("WARN",24,397,"Warning DD %",(string)s.warning_dd,102,52);F("PAUSE",168,397,"Grid Pause %",(string)s.pause_grid_dd,92,38);
  F("CLOSE",24,420,"Emergency %",(string)s.emergency_close_dd,102,52);
  Base("TIMEBOX",312,370,292,75,C'12,21,28',170);H("TIME",322,377,"TIME / NEWS");
  F("TMODE",322,397,"Time Mode",TF(s.time_mode),76,90);F("START",490,397,"Start",StringFormat("%02d:%02d",s.start_hour,s.start_minute),42,58);
  F("END",322,420,"End",StringFormat("%02d:%02d",s.end_hour,s.end_minute),76,90);F("NEWS",490,420,"News",OnOff(s.use_news_filter),42,58);
  // Hidden-but-editable advanced fields are retained below the visible panel for compatibility.
  E("A1MIN",-200,20,DoubleToString(s.atr1_min_points,1));E("A1MAX",-200,42,DoubleToString(s.atr1_max_points,1));E("A2MIN",-200,64,DoubleToString(s.atr2_min_points,1));E("A2MAX",-200,86,DoubleToString(s.atr2_max_points,1));
  E("ONEBAR",-200,108,OnOff(s.one_order_per_bar));E("GRIDOUT",-200,130,OnOff(s.allow_grid_outside_time));E("PGTR",-200,152,OnOff(s.pause_grid_while_trailing));
  E("STSTEP",-200,174,(string)s.single_trail_step);E("BTD",-200,196,(string)s.basket_trail_distance);E("BTSTEP",-200,218,(string)s.basket_trail_step);E("NEWSMO",-200,240,OnOff(s.news_manage_only));
  B("APPLY",18,456,137,"APPLY");B("SAVE",165,456,137,"SAVE");B("LOAD",312,456,137,"LOAD");B("RESET",459,456,137,"REFRESH");ChartRedraw();
 }
 void Delete(){ObjectsDeleteAll(0,p);}
 bool Pull(SO01RuntimeSettings110&s){
  s.new_cycles=Bool("NEW");s.trade_buy=Bool("BUY");s.trade_sell=Bool("SELL");s.rsi_period=I("RSIP");s.rsi_lower=D("RSIL");s.rsi_upper=D("RSIU");
  s.atr1_period=I("ATR1P");s.atr2_period=I("ATR2P");s.atr2_timeframe=I("ATR2TF");s.atr1_min_points=D("A1MIN");s.atr1_max_points=D("A1MAX");s.atr2_min_points=D("A2MIN");s.atr2_max_points=D("A2MAX");
  s.initial_lot=D("LOT");s.lot_multiplier=D("MULT");s.max_lot=D("MAXLOT");s.max_total_lots_per_side=D("TOTLOT");s.max_orders=I("MAXORD");s.fixed_distance_points=I("GRID");
  s.dynamic_start_order=I("DYNORD");s.dynamic_start_points=I("DYNPTS");s.distance_multiplier=D("DISTM");s.one_order_per_bar=Bool("ONEBAR");s.allow_grid_outside_time=Bool("GRIDOUT");s.pause_grid_while_trailing=Bool("PGTR");
  s.virtual_sl_points=I("VSL");s.single_trail_start=I("STS");s.single_trail_lock=I("STL");s.single_trail_distance=I("STD");s.single_trail_step=I("STSTEP");
  s.basket_trail_start=I("BTS");s.basket_trail_lock=I("BTL");s.basket_trail_distance=I("BTD");s.basket_trail_step=I("BTSTEP");
  s.warning_dd=I("WARN");s.pause_grid_dd=I("PAUSE");s.emergency_close_dd=I("CLOSE");s.time_mode=TM(G("TMODE"));
  string a=G("START"),b=G("END");if(StringLen(a)!=5||StringSubstr(a,2,1)!=":"||StringLen(b)!=5||StringSubstr(b,2,1)!=":")return false;
  s.start_hour=(int)StringToInteger(StringSubstr(a,0,2));s.start_minute=(int)StringToInteger(StringSubstr(a,3,2));s.end_hour=(int)StringToInteger(StringSubstr(b,0,2));s.end_minute=(int)StringToInteger(StringSubstr(b,3,2));
  s.use_news_filter=Bool("NEWS");s.news_manage_only=Bool("NEWSMO");
  return s.rsi_period>0&&s.rsi_lower>=0&&s.rsi_upper<=100&&s.rsi_lower<s.rsi_upper&&s.atr1_period>0&&s.atr2_period>0&&s.atr1_min_points>=0&&s.atr1_max_points>=s.atr1_min_points&&s.atr2_min_points>=0&&s.atr2_max_points>=s.atr2_min_points&&s.initial_lot>0&&s.lot_multiplier>=1&&s.max_lot>=s.initial_lot&&s.max_total_lots_per_side>=0&&s.max_orders>0&&s.fixed_distance_points>0&&s.dynamic_start_order>0&&s.dynamic_start_points>0&&s.distance_multiplier>=1&&s.virtual_sl_points>=0&&s.warning_dd>=0&&s.pause_grid_dd>=s.warning_dd&&s.emergency_close_dd>=s.pause_grid_dd&&s.start_hour>=0&&s.start_hour<24&&s.end_hour>=0&&s.end_hour<24&&s.start_minute>=0&&s.start_minute<60&&s.end_minute>=0&&s.end_minute<60;
 }
 int Event(int id,string name,SO01RuntimeSettings110&s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name==p+"APPLY")return Pull(s)?1:-1;if(name==p+"SAVE"){if(!Pull(s))return-1;return st.Save(s)?2:-2;}if(name==p+"LOAD"){if(!st.Load(s))return-3;Delete();Create(s);return 3;}if(name==p+"RESET"){Delete();Create(s);return 4;}return 0;}
};
#endif
