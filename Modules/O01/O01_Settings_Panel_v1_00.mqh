//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_00.mqh                                   |
//| Prototype edit/save/load panel. No order functions.              |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_00_MQH
#define O01_SETTINGS_PANEL_V1_00_MQH
#include "O01_Runtime_Settings_v1_00.mqh"

class CO01SettingsPanel
  {
   string p; CO01SettingsStore store;
   void Btn(string id,int x,int y,int w,string txt)
     { string n=p+id; if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_BUTTON,0,0,0);
       ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y); ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,22); ObjectSetString(0,n,OBJPROP_TEXT,txt); }
   void Edit(string id,int x,int y,int w,string txt)
     { string n=p+id; if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_EDIT,0,0,0);
       ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x); ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y); ObjectSetInteger(0,n,OBJPROP_XSIZE,w); ObjectSetInteger(0,n,OBJPROP_YSIZE,20); ObjectSetString(0,n,OBJPROP_TEXT,txt); }
public:
   void Create(const SO01RuntimeSettings &s)
     {
      p="O01CFG_"; store.SetFile("O01_GSG_RSI30_Settings.csv");
      Edit("RSIL",10,20,70,DoubleToString(s.rsi_lower,1)); Edit("RSIU",85,20,70,DoubleToString(s.rsi_upper,1));
      Edit("LOT",160,20,70,DoubleToString(s.initial_lot,2)); Edit("MULT",235,20,70,DoubleToString(s.lot_multiplier,2));
      Edit("GRID",310,20,70,IntegerToString(s.fixed_distance_points)); Edit("MAXLOT",385,20,70,DoubleToString(s.max_lot,2));
      Edit("WARN",10,45,70,IntegerToString(s.warning_dd)); Edit("PAUSE",85,45,70,IntegerToString(s.pause_grid_dd)); Edit("CLOSE",160,45,70,IntegerToString(s.emergency_close_dd));
      Edit("START",235,45,70,StringFormat("%02d:%02d",s.start_hour,s.start_minute)); Edit("END",310,45,70,StringFormat("%02d:%02d",s.end_hour,s.end_minute));
      Btn("APPLY",10,72,90,"APPLY"); Btn("SAVE",105,72,90,"SAVE"); Btn("LOAD",200,72,90,"LOAD");
     }
   void Delete() { ObjectsDeleteAll(0,p); }
   bool Pull(SO01RuntimeSettings &s)
     {
      s.rsi_lower=StringToDouble(ObjectGetString(0,p+"RSIL",OBJPROP_TEXT)); s.rsi_upper=StringToDouble(ObjectGetString(0,p+"RSIU",OBJPROP_TEXT));
      s.initial_lot=StringToDouble(ObjectGetString(0,p+"LOT",OBJPROP_TEXT)); s.lot_multiplier=StringToDouble(ObjectGetString(0,p+"MULT",OBJPROP_TEXT));
      s.fixed_distance_points=(int)StringToInteger(ObjectGetString(0,p+"GRID",OBJPROP_TEXT)); s.max_lot=StringToDouble(ObjectGetString(0,p+"MAXLOT",OBJPROP_TEXT));
      s.warning_dd=(int)StringToInteger(ObjectGetString(0,p+"WARN",OBJPROP_TEXT)); s.pause_grid_dd=(int)StringToInteger(ObjectGetString(0,p+"PAUSE",OBJPROP_TEXT)); s.emergency_close_dd=(int)StringToInteger(ObjectGetString(0,p+"CLOSE",OBJPROP_TEXT));
      string a=ObjectGetString(0,p+"START",OBJPROP_TEXT),b=ObjectGetString(0,p+"END",OBJPROP_TEXT);
      s.start_hour=(int)StringToInteger(StringSubstr(a,0,2)); s.start_minute=(int)StringToInteger(StringSubstr(a,3,2));
      s.end_hour=(int)StringToInteger(StringSubstr(b,0,2)); s.end_minute=(int)StringToInteger(StringSubstr(b,3,2));
      return s.rsi_lower>=0 && s.rsi_upper<=100 && s.rsi_lower<s.rsi_upper && s.initial_lot>0 && s.lot_multiplier>=1 && s.max_lot>=s.initial_lot && s.warning_dd>=0 && s.pause_grid_dd>=s.warning_dd && s.emergency_close_dd>=s.pause_grid_dd;
     }
   int Event(const int id,const string name,SO01RuntimeSettings &s)
     {
      if(id!=CHARTEVENT_OBJECT_CLICK) return 0;
      if(name==p+"APPLY") return Pull(s)?1:-1;
      if(name==p+"SAVE") { if(!Pull(s))return -1; return store.Save(s)?2:-2; }
      if(name==p+"LOAD") { if(!store.Load(s))return -3; Delete(); Create(s); return 3; }
      return 0;
     }
  };
#endif
