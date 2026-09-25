//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_20.mqh                                   |
//| Labeled runtime panel. APPLY/SAVE/LOAD/REFRESH. NO ORDERS.       |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_20_MQH
#define O01_SETTINGS_PANEL_V1_20_MQH
#include "O01_Runtime_Settings_v1_10.mqh"
class CO01SettingsPanel120{
 string p;CO01SettingsStore110 st;
 void L(string id,int x,int y,string v){string n=p+"L_"+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y+3);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 void E(string id,int x,int y,string v){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,72);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 void F(string id,int x,int y,string lab,string v){L(id,x,y,lab);E(id,x+116,y,v);}
 void B(string id,int x,int y,string v){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,92);ObjectSetInteger(0,n,OBJPROP_YSIZE,23);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 string G(string id){return ObjectGetString(0,p+id,OBJPROP_TEXT);}double D(string id){return StringToDouble(G(id));}int I(string id){return(int)StringToInteger(G(id));}
public:
 void Create(const SO01RuntimeSettings110&s){p="O01CFG120_";st.SetFile("O01_GSG_RSI30_Settings_v1_10.csv");
  L("TITLE",10,8,"O01 GSG RSI30 - Runtime Settings v1.20   NO ORDERS");
  F("RSIP",10,30,"RSI Period",(string)s.rsi_period);F("RSIL",210,30,"RSI Lower",DoubleToString(s.rsi_lower,1));F("RSIU",410,30,"RSI Upper",DoubleToString(s.rsi_upper,1));
  F("LOT",10,55,"Initial Lot",DoubleToString(s.initial_lot,2));F("MULT",210,55,"Lot Multiplier",DoubleToString(s.lot_multiplier,2));F("MAXLOT",410,55,"Max Lot",DoubleToString(s.max_lot,2));
  F("MAXORD",10,80,"Max Orders",(string)s.max_orders);F("GRID",210,80,"Grid Distance",(string)s.fixed_distance_points);F("DYNORD",410,80,"Dynamic Start #",(string)s.dynamic_start_order);
  F("DYNPTS",10,105,"Dynamic Points",(string)s.dynamic_start_points);F("DISTM",210,105,"Distance Mult",DoubleToString(s.distance_multiplier,2));F("VSL",410,105,"Virtual SL",(string)s.virtual_sl_points);
  F("STS",10,130,"Single Trail Start",(string)s.single_trail_start);F("STL",210,130,"Single Trail Lock",(string)s.single_trail_lock);F("STD",410,130,"Single Trail Dist",(string)s.single_trail_distance);
  F("BTS",10,155,"Basket Trail Start",(string)s.basket_trail_start);F("BTL",210,155,"Basket Trail Lock",(string)s.basket_trail_lock);F("BTD",410,155,"Basket Trail Dist",(string)s.basket_trail_distance);
  F("WARN",10,180,"Warning DD %",(string)s.warning_dd);F("PAUSE",210,180,"Grid Pause DD %",(string)s.pause_grid_dd);F("CLOSE",410,180,"Emergency DD %",(string)s.emergency_close_dd);
  F("START",10,205,"Trade Start",StringFormat("%02d:%02d",s.start_hour,s.start_minute));F("END",210,205,"Trade End",StringFormat("%02d:%02d",s.end_hour,s.end_minute));
  B("APPLY",10,238,"APPLY");B("SAVE",107,238,"SAVE");B("LOAD",204,238,"LOAD");B("RESET",301,238,"REFRESH");ChartRedraw();
 }
 void Delete(){ObjectsDeleteAll(0,p);}
 bool Pull(SO01RuntimeSettings110&s){
  s.rsi_period=I("RSIP");s.rsi_lower=D("RSIL");s.rsi_upper=D("RSIU");s.initial_lot=D("LOT");s.lot_multiplier=D("MULT");s.max_lot=D("MAXLOT");s.max_orders=I("MAXORD");
  s.fixed_distance_points=I("GRID");s.dynamic_start_order=I("DYNORD");s.dynamic_start_points=I("DYNPTS");s.distance_multiplier=D("DISTM");s.virtual_sl_points=I("VSL");
  s.single_trail_start=I("STS");s.single_trail_lock=I("STL");s.single_trail_distance=I("STD");s.basket_trail_start=I("BTS");s.basket_trail_lock=I("BTL");s.basket_trail_distance=I("BTD");
  s.warning_dd=I("WARN");s.pause_grid_dd=I("PAUSE");s.emergency_close_dd=I("CLOSE");string a=G("START"),b=G("END");
  s.start_hour=(int)StringToInteger(StringSubstr(a,0,2));s.start_minute=(int)StringToInteger(StringSubstr(a,3,2));s.end_hour=(int)StringToInteger(StringSubstr(b,0,2));s.end_minute=(int)StringToInteger(StringSubstr(b,3,2));
  return s.rsi_period>0&&s.rsi_lower>=0&&s.rsi_upper<=100&&s.rsi_lower<s.rsi_upper&&s.initial_lot>0&&s.lot_multiplier>=1&&s.max_lot>=s.initial_lot&&s.max_orders>0&&s.fixed_distance_points>0&&s.dynamic_start_order>0&&s.dynamic_start_points>0&&s.distance_multiplier>=1&&s.virtual_sl_points>=0&&s.warning_dd>=0&&s.pause_grid_dd>=s.warning_dd&&s.emergency_close_dd>=s.pause_grid_dd&&s.start_hour>=0&&s.start_hour<24&&s.end_hour>=0&&s.end_hour<24&&s.start_minute>=0&&s.start_minute<60&&s.end_minute>=0&&s.end_minute<60;
 }
 int Event(int id,string name,SO01RuntimeSettings110&s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name==p+"APPLY")return Pull(s)?1:-1;if(name==p+"SAVE"){if(!Pull(s))return-1;return st.Save(s)?2:-2;}if(name==p+"LOAD"){if(!st.Load(s))return-3;Delete();Create(s);return 3;}if(name==p+"RESET"){Delete();Create(s);return 4;}return 0;}
};
#endif
