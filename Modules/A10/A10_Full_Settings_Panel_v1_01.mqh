//+------------------------------------------------------------------+
//| A10_Full_Settings_Panel_v1_01.mqh                               |
//| A10 FULL detail editor bound to the common left panel.           |
//| UI/config only. NO broker orders.                                |
//+------------------------------------------------------------------+
#ifndef A10_FULL_SETTINGS_PANEL_V1_01_MQH
#define A10_FULL_SETTINGS_PANEL_V1_01_MQH
#include "A10_Full_Module_v1_01.mqh"

class CA10FullSettingsPanel101
{
 string p; int page;
 string ModeName(){if(page==0)return"Breakout";if(page==1)return"Re-entry";if(page==2)return"Midline";return"Squeeze";}
 void Text(string id,string v){if(ObjectFind(0,p+id)>=0)ObjectSetString(0,p+id,OBJPROP_TEXT,v);}
 void Show(string id,bool on){if(ObjectFind(0,p+id)>=0)ObjectSetInteger(0,p+id,OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}
 string G(string id){return ObjectGetString(0,p+id,OBJPROP_TEXT);}
 bool State(string id){string s=G(id);StringToUpper(s);return(s=="1"||s=="ON"||s=="TRUE"||s=="YES");}
 double D(string id){return StringToDouble(G(id));}
 int I(string id){return(int)StringToInteger(G(id));}
 void EnsureModeButton(){
  string n=p+"A10_FULL_MODE_NEXT";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,516);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,169);
  ObjectSetInteger(0,n,OBJPROP_XSIZE,72);ObjectSetInteger(0,n,OBJPROP_YSIZE,19);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);
  ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'80,92,104');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,"NEXT >");
 }
 void ModeButton(bool on){EnsureModeButton();ObjectSetInteger(0,p+"A10_FULL_MODE_NEXT",OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}
public:
 CA10FullSettingsPanel101(){p="O01CFG160_";page=0;}
 void Display(SA10FullConfig100 &s){
  ModeButton(true);SA10FullModeConfig100 m=s.mode[page];
  Text("L_H_ENTRY","FULL STRATEGY  [A10]  "+ModeName());
  Text("L_NEW","Enabled");Text("NEW",m.enabled?"1":"0");
  Text("L_BUY","Max Positions");Text("BUY",IntegerToString(s.max_positions));
  Text("L_SELL","Skip Opposite");Text("SELL",s.skip_opposite?"1":"0");
  Text("L_RSIP","Brick Size");Text("RSIP",DoubleToString(m.brick,1));
  Text("L_RSIL","BB Period");Text("RSIL",IntegerToString(m.bb_period));
  Text("L_RSIU","Deviation");Text("RSIU",DoubleToString(m.deviation,1));
  Text("L_ATR1P","Entry Run");Text("ATR1P",IntegerToString(m.entry_run));
  Show("L_ATR2P",true);Show("ATR2P",true);Text("L_ATR2P","Sq Width");Text("ATR2P",DoubleToString(m.squeeze_width,1));
  Text("L_ATR2TF","Entry TTL sec");Text("ATR2TF",IntegerToString(s.entry_ttl_seconds));
  Text("L_H_GRID","A10 MODE / POSITION");
  Text("L_LOT","TP bricks");Text("LOT",DoubleToString(m.tp,1));
  Text("L_MULT","SL bricks");Text("MULT",DoubleToString(m.sl,1));
  Text("L_MAXLOT","Max Hold min");Text("MAXLOT",IntegerToString(m.max_hold));
  Text("L_TOTLOT","Cooldown");Text("TOTLOT",IntegerToString(m.cooldown));
  Text("L_MAXORD","Max Spread");Text("MAXORD",DoubleToString(m.max_spread,2));
  Text("L_GRID","Mode #");Text("GRID",IntegerToString(page+1));
  Text("L_H_EXIT","A10 FULL EXIT  [TP / SL / TIME / BB]");
  Text("L_VSL","TP");Text("VSL",DoubleToString(m.tp,1));
  Text("L_STS","SL");Text("STS",DoubleToString(m.sl,1));
  Text("L_STL","Hold");Text("STL",IntegerToString(m.max_hold));
  ChartRedraw();
 }
 bool Pull(SA10FullConfig100 &s){
  SA10FullModeConfig100 m=s.mode[page];
  m.enabled=State("NEW");s.max_positions=I("BUY");s.skip_opposite=State("SELL");
  m.brick=D("RSIP");m.bb_period=I("RSIL");m.deviation=D("RSIU");m.entry_run=I("ATR1P");m.squeeze_width=D("ATR2P");s.entry_ttl_seconds=I("ATR2TF");
  m.tp=D("LOT");m.sl=D("MULT");m.max_hold=I("MAXLOT");m.cooldown=I("TOTLOT");m.max_spread=D("MAXORD");
  if(s.max_positions<1||s.max_positions>4||s.entry_ttl_seconds<1||m.brick<=0||m.bb_period<1||m.deviation<=0||m.entry_run<1||m.tp<0||m.sl<0||m.max_hold<0||m.cooldown<0||m.max_spread<0)return false;
  s.mode[page]=m;return true;
 }
 bool HandleClick(const string name,SA10FullConfig100 &s){
  if(name==p+"A10_FULL_MODE_NEXT"){if(Pull(s)){page=(page+1)%4;Display(s);}ObjectSetInteger(0,name,OBJPROP_STATE,false);ObjectSetInteger(0,name,OBJPROP_SELECTED,false);return true;}return false;
 }
 void Hide(){ModeButton(false);}
};
#endif
