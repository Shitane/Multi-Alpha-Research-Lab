//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_10.mqh                                   |
//| Expanded editable O01 research panel. NO ORDERS.                 |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_10_MQH
#define O01_SETTINGS_PANEL_V1_10_MQH
#include "O01_Runtime_Settings_v1_10.mqh"
class CO01SettingsPanel110{
 string p;CO01SettingsStore110 st;
 void E(string id,int x,int y,string v){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,74);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 void B(string id,int x,int y,string v){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,88);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetString(0,n,OBJPROP_TEXT,v);}
 string G(string id){return ObjectGetString(0,p+id,OBJPROP_TEXT);} double D(string id){return StringToDouble(G(id));} int I(string id){return(int)StringToInteger(G(id));}
public:
 void Create(const SO01RuntimeSettings110&s){p="O01CFG110_";st.SetFile("O01_GSG_RSI30_Settings_v1_10.csv");
  E("RSIP",10,20,(string)s.rsi_period);E("RSIL",89,20,DoubleToString(s.rsi_lower,1));E("RSIU",168,20,DoubleToString(s.rsi_upper,1));
  E("LOT",247,20,DoubleToString(s.initial_lot,2));E("MULT",326,20,DoubleToString(s.lot_multiplier,2));E("MAXLOT",405,20,DoubleToString(s.max_lot,2));E("MAXORD",484,20,(string)s.max_orders);
  E("GRID",10,45,(string)s.fixed_distance_points);E("DYNORD",89,45,(string)s.dynamic_start_order);E("DYNPTS",168,45,(string)s.dynamic_start_points);E("DISTM",247,45,DoubleToString(s.distance_multiplier,2));
  E("VSL",326,45,(string)s.virtual_sl_points);E("STS",405,45,(string)s.single_trail_start);E("STL",484,45,(string)s.single_trail_lock);
  E("BTS",10,70,(string)s.basket_trail_start);E("BTL",89,70,(string)s.basket_trail_lock);E("WARN",168,70,(string)s.warning_dd);E("PAUSE",247,70,(string)s.pause_grid_dd);E("CLOSE",326,70,(string)s.emergency_close_dd);
  E("START",405,70,StringFormat("%02d:%02d",s.start_hour,s.start_minute));E("END",484,70,StringFormat("%02d:%02d",s.end_hour,s.end_minute));
  B("APPLY",10,98,"APPLY");B("SAVE",103,98,"SAVE");B("LOAD",196,98,"LOAD");B("RESET",289,98,"REFRESH");
 }
 void Delete(){ObjectsDeleteAll(0,p);}
 bool Pull(SO01RuntimeSettings110&s){
  s.rsi_period=I("RSIP");s.rsi_lower=D("RSIL");s.rsi_upper=D("RSIU");s.initial_lot=D("LOT");s.lot_multiplier=D("MULT");s.max_lot=D("MAXLOT");s.max_orders=I("MAXORD");
  s.fixed_distance_points=I("GRID");s.dynamic_start_order=I("DYNORD");s.dynamic_start_points=I("DYNPTS");s.distance_multiplier=D("DISTM");s.virtual_sl_points=I("VSL");s.single_trail_start=I("STS");s.single_trail_lock=I("STL");s.basket_trail_start=I("BTS");s.basket_trail_lock=I("BTL");s.warning_dd=I("WARN");s.pause_grid_dd=I("PAUSE");s.emergency_close_dd=I("CLOSE");
  string a=G("START"),b=G("END");s.start_hour=(int)StringToInteger(StringSubstr(a,0,2));s.start_minute=(int)StringToInteger(StringSubstr(a,3,2));s.end_hour=(int)StringToInteger(StringSubstr(b,0,2));s.end_minute=(int)StringToInteger(StringSubstr(b,3,2));
  return s.rsi_period>0&&s.rsi_lower>=0&&s.rsi_upper<=100&&s.rsi_lower<s.rsi_upper&&s.initial_lot>0&&s.lot_multiplier>=1&&s.max_lot>=s.initial_lot&&s.max_orders>0&&s.fixed_distance_points>0&&s.dynamic_start_order>0&&s.dynamic_start_points>0&&s.distance_multiplier>=1&&s.virtual_sl_points>=0&&s.warning_dd>=0&&s.pause_grid_dd>=s.warning_dd&&s.emergency_close_dd>=s.pause_grid_dd&&s.start_hour>=0&&s.start_hour<24&&s.end_hour>=0&&s.end_hour<24&&s.start_minute>=0&&s.start_minute<60&&s.end_minute>=0&&s.end_minute<60;
 }
 int Event(int id,string name,SO01RuntimeSettings110&s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name==p+"APPLY")return Pull(s)?1:-1;if(name==p+"SAVE"){if(!Pull(s))return-1;return st.Save(s)?2:-2;}if(name==p+"LOAD"){if(!st.Load(s))return-3;Delete();Create(s);return 3;}if(name==p+"RESET"){Delete();Create(s);return 4;}return 0;}
};
#endif
