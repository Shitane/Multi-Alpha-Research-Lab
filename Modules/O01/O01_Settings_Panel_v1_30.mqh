//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_30.mqh                                   |
//| Expanded runtime panel. APPLY/SAVE/LOAD/REFRESH. NO ORDERS.      |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_30_MQH
#define O01_SETTINGS_PANEL_V1_30_MQH
#include "O01_Runtime_Settings_v1_10.mqh"

class CO01SettingsPanel130{
 string p; CO01SettingsStore110 st;
 void L(string id,int x,int y,string v){string n=p+"L_"+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y+3);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 void E(string id,int x,int y,string v){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,70);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 void F(string id,int x,int y,string lab,string v){L(id,x,y,lab);E(id,x+112,y,v);}
 void B(string id,int x,int y,string v){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,92);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 string G(string id){return ObjectGetString(0,p+id,OBJPROP_TEXT);} double D(string id){return StringToDouble(G(id));} int I(string id){return(int)StringToInteger(G(id));}
 string TF(int m){if(m==0)return"AUTO_GMT";if(m==1)return"SERVER_TIME";return"CUSTOM_GMT";}
 int TM(string s){StringToUpper(s);if(s=="SERVER_TIME"||s=="1")return 1;if(s=="CUSTOM_GMT"||s=="2")return 2;return 0;}
 string OnOff(bool v){return v?"1":"0";} bool Bool(string id){string s=G(id);StringToUpper(s);return(s=="1"||s=="ON"||s=="TRUE"||s=="YES");}
public:
 void Create(const SO01RuntimeSettings110&s){p="O01CFG130_";st.SetFile("O01_GSG_RSI30_Settings_v1_10.csv");
  L("TITLE",10,8,"O01 GSG RSI30 - Runtime Settings v1.30   NO ORDERS");
  F("NEW",10,30,"New Cycles",OnOff(s.new_cycles));F("BUY",205,30,"Trade BUY",OnOff(s.trade_buy));F("SELL",400,30,"Trade SELL",OnOff(s.trade_sell));
  F("RSIP",10,55,"RSI Period",(string)s.rsi_period);F("RSIL",205,55,"RSI Lower",DoubleToString(s.rsi_lower,1));F("RSIU",400,55,"RSI Upper",DoubleToString(s.rsi_upper,1));
  F("ATR1P",10,80,"ATR1 Period",(string)s.atr1_period);F("ATR2P",205,80,"ATR2 Period",(string)s.atr2_period);F("ATR2TF",400,80,"ATR2 TF",(string)s.atr2_timeframe);
  F("A1MIN",10,105,"ATR1 Min",DoubleToString(s.atr1_min_points,1));F("A1MAX",205,105,"ATR1 Max",DoubleToString(s.atr1_max_points,1));F("A2MIN",400,105,"ATR2 Min",DoubleToString(s.atr2_min_points,1));
  F("A2MAX",10,130,"ATR2 Max",DoubleToString(s.atr2_max_points,1));F("LOT",205,130,"Initial Lot",DoubleToString(s.initial_lot,2));F("MULT",400,130,"Lot Mult",DoubleToString(s.lot_multiplier,2));
  F("MAXLOT",10,155,"Max Lot",DoubleToString(s.max_lot,2));F("TOTLOT",205,155,"Max Side Lots",DoubleToString(s.max_total_lots_per_side,2));F("MAXORD",400,155,"Max Orders",(string)s.max_orders);
  F("GRID",10,180,"Grid Distance",(string)s.fixed_distance_points);F("DYNORD",205,180,"Dynamic Start #",(string)s.dynamic_start_order);F("DYNPTS",400,180,"Dynamic Points",(string)s.dynamic_start_points);
  F("DISTM",10,205,"Distance Mult",DoubleToString(s.distance_multiplier,2));F("ONEBAR",205,205,"One/Bar",OnOff(s.one_order_per_bar));F("GRIDOUT",400,205,"Grid Out Time",OnOff(s.allow_grid_outside_time));
  F("PGTR",10,230,"Pause Grid Trail",OnOff(s.pause_grid_while_trailing));F("VSL",205,230,"Virtual SL",(string)s.virtual_sl_points);
  F("STS",10,255,"Single Start",(string)s.single_trail_start);F("STL",205,255,"Single Lock",(string)s.single_trail_lock);F("STD",400,255,"Single Dist",(string)s.single_trail_distance);
  F("STSTEP",10,280,"Single Step",(string)s.single_trail_step);F("BTS",205,280,"Basket Start",(string)s.basket_trail_start);F("BTL",400,280,"Basket Lock",(string)s.basket_trail_lock);
  F("BTD",10,305,"Basket Dist",(string)s.basket_trail_distance);F("BTSTEP",205,305,"Basket Step",(string)s.basket_trail_step);
  F("WARN",10,330,"Warning DD %",(string)s.warning_dd);F("PAUSE",205,330,"Grid Pause DD %",(string)s.pause_grid_dd);F("CLOSE",400,330,"Emergency DD %",(string)s.emergency_close_dd);
  F("TMODE",10,355,"Time Mode",TF(s.time_mode));F("START",205,355,"Trade Start",StringFormat("%02d:%02d",s.start_hour,s.start_minute));F("END",400,355,"Trade End",StringFormat("%02d:%02d",s.end_hour,s.end_minute));
  F("NEWS",10,380,"News Filter",OnOff(s.use_news_filter));F("NEWSMO",205,380,"News ManageOnly",OnOff(s.news_manage_only));
  B("APPLY",10,414,"APPLY");B("SAVE",107,414,"SAVE");B("LOAD",204,414,"LOAD");B("RESET",301,414,"REFRESH");ChartRedraw();
 }
 void Delete(){ObjectsDeleteAll(0,p);}
 bool Pull(SO01RuntimeSettings110&s){
  s.new_cycles=Bool("NEW");s.trade_buy=Bool("BUY");s.trade_sell=Bool("SELL");
  s.rsi_period=I("RSIP");s.rsi_lower=D("RSIL");s.rsi_upper=D("RSIU");s.atr1_period=I("ATR1P");s.atr2_period=I("ATR2P");s.atr2_timeframe=I("ATR2TF");
  s.atr1_min_points=D("A1MIN");s.atr1_max_points=D("A1MAX");s.atr2_min_points=D("A2MIN");s.atr2_max_points=D("A2MAX");
  s.initial_lot=D("LOT");s.lot_multiplier=D("MULT");s.max_lot=D("MAXLOT");s.max_total_lots_per_side=D("TOTLOT");s.max_orders=I("MAXORD");
  s.fixed_distance_points=I("GRID");s.dynamic_start_order=I("DYNORD");s.dynamic_start_points=I("DYNPTS");s.distance_multiplier=D("DISTM");
  s.one_order_per_bar=Bool("ONEBAR");s.allow_grid_outside_time=Bool("GRIDOUT");s.pause_grid_while_trailing=Bool("PGTR");
  s.virtual_sl_points=I("VSL");s.single_trail_start=I("STS");s.single_trail_lock=I("STL");s.single_trail_distance=I("STD");s.single_trail_step=I("STSTEP");
  s.basket_trail_start=I("BTS");s.basket_trail_lock=I("BTL");s.basket_trail_distance=I("BTD");s.basket_trail_step=I("BTSTEP");
  s.warning_dd=I("WARN");s.pause_grid_dd=I("PAUSE");s.emergency_close_dd=I("CLOSE");s.time_mode=TM(G("TMODE"));
  string a=G("START"),b=G("END");if(StringLen(a)!=5||StringSubstr(a,2,1)!=":"||StringLen(b)!=5||StringSubstr(b,2,1)!=":")return false;
  s.start_hour=(int)StringToInteger(StringSubstr(a,0,2));s.start_minute=(int)StringToInteger(StringSubstr(a,3,2));s.end_hour=(int)StringToInteger(StringSubstr(b,0,2));s.end_minute=(int)StringToInteger(StringSubstr(b,3,2));
  s.use_news_filter=Bool("NEWS");s.news_manage_only=Bool("NEWSMO");
  return s.rsi_period>0&&s.rsi_lower>=0&&s.rsi_upper<=100&&s.rsi_lower<s.rsi_upper&&s.atr1_period>0&&s.atr2_period>0&&s.atr1_min_points>=0&&s.atr1_max_points>=s.atr1_min_points&&s.atr2_min_points>=0&&s.atr2_max_points>=s.atr2_min_points&&s.initial_lot>0&&s.lot_multiplier>=1&&s.max_lot>=s.initial_lot&&s.max_total_lots_per_side>=0&&s.max_orders>0&&s.fixed_distance_points>0&&s.dynamic_start_order>0&&s.dynamic_start_points>0&&s.distance_multiplier>=1&&s.virtual_sl_points>=0&&s.single_trail_start>=0&&s.single_trail_lock>=0&&s.single_trail_distance>=0&&s.single_trail_step>=0&&s.basket_trail_start>=0&&s.basket_trail_lock>=0&&s.basket_trail_distance>=0&&s.basket_trail_step>=0&&s.warning_dd>=0&&s.pause_grid_dd>=s.warning_dd&&s.emergency_close_dd>=s.pause_grid_dd&&s.start_hour>=0&&s.start_hour<24&&s.end_hour>=0&&s.end_hour<24&&s.start_minute>=0&&s.start_minute<60&&s.end_minute>=0&&s.end_minute<60;
 }
 int Event(int id,string name,SO01RuntimeSettings110&s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name==p+"APPLY")return Pull(s)?1:-1;if(name==p+"SAVE"){if(!Pull(s))return-1;return st.Save(s)?2:-2;}if(name==p+"LOAD"){if(!st.Load(s))return-3;Delete();Create(s);return 3;}if(name==p+"RESET"){Delete();Create(s);return 4;}return 0;}
};
#endif
