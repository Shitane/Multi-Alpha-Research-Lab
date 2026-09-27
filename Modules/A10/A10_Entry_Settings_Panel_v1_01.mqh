//+------------------------------------------------------------------+
//| A10_Entry_Settings_Panel_v1_01.mqh                              |
//| A10 ENTRY detail editor for Multi Alpha. NO broker orders.       |
//+------------------------------------------------------------------+
#ifndef A10_ENTRY_SETTINGS_PANEL_V1_01_MQH
#define A10_ENTRY_SETTINGS_PANEL_V1_01_MQH
#include "A10_Entry_Settings_v1_00.mqh"

class CA10EntrySettingsPanel100
{
 string p; int page;
 string ModeName(){if(page==0)return"Breakout";if(page==1)return"Re-entry";if(page==2)return"Midline";return"Squeeze";}
 SA10EntryModeSettings100 Mode(const SA10EntrySettings100 &s){if(page==0)return s.breakout;if(page==1)return s.reentry;if(page==2)return s.midline;return s.squeeze;}
 void PutMode(SA10EntrySettings100 &s,const SA10EntryModeSettings100 &m){if(page==0)s.breakout=m;else if(page==1)s.reentry=m;else if(page==2)s.midline=m;else s.squeeze=m;}
 void Show(string id,bool on){if(ObjectFind(0,p+id)>=0)ObjectSetInteger(0,p+id,OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}
 void Text(string id,string v){if(ObjectFind(0,p+id)>=0)ObjectSetString(0,p+id,OBJPROP_TEXT,v);}
 bool State(string id){string s=ObjectGetString(0,p+id,OBJPROP_TEXT);StringToUpper(s);return(s=="1"||s=="ON"||s=="TRUE");}
 double D(string id){return StringToDouble(ObjectGetString(0,p+id,OBJPROP_TEXT));}
 int I(string id){return(int)StringToInteger(ObjectGetString(0,p+id,OBJPROP_TEXT));}
public:
 CA10EntrySettingsPanel100(){p="O01CFG160_";page=0;}
 void BindToO01Panel(){p="O01CFG160_";}
 void EnsureModeButton(){
  string n=p+"A10_MODE_NEXT";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,516);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,169);
  ObjectSetInteger(0,n,OBJPROP_XSIZE,72);ObjectSetInteger(0,n,OBJPROP_YSIZE,19);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);
  ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'80,92,104');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,true);ObjectSetInteger(0,n,OBJPROP_HIDDEN,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,"NEXT >");
 }
 void ShowModeButton(const bool on){EnsureModeButton();ObjectSetInteger(0,p+"A10_MODE_NEXT",OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}

 void Display(SA10EntrySettings100 &s)
 {
  ShowModeButton(true);SA10EntryModeSettings100 m=Mode(s);
  Text("L_H_ENTRY","ENTRY / FILTER  [A10]  "+ModeName());
  Text("L_NEW","Enabled");Text("NEW",m.enabled?"1":"0");
  Text("L_BUY","Opposite Skip");Text("BUY",s.skip_opposite_signals?"1":"0");
  Text("L_SELL","Mode");Text("SELL",IntegerToString(page+1));
  Text("L_RSIP","Brick Size");Text("RSIP",DoubleToString(m.brick_size,1));
  Text("L_RSIL","BB Period");Text("RSIL",IntegerToString(m.bb_period));
  Text("L_RSIU","Deviation");Text("RSIU",DoubleToString(m.deviation,1));
  Text("L_ATR1P","Entry Run");Text("ATR1P",IntegerToString(m.entry_run));
  Text("L_ATR2P",page==3?"Sq Max Width":"Reserved");Text("ATR2P",page==3?DoubleToString(m.squeeze_max_width,1):"-");
  Text("L_ATR2TF","A10 Entry");Text("ATR2TF","NO ORDERS");
  ChartRedraw();
 }
 bool Pull(SA10EntrySettings100 &s)
 {
  SA10EntryModeSettings100 m=Mode(s);
  m.enabled=State("NEW");s.skip_opposite_signals=State("BUY");
  m.brick_size=D("RSIP");m.bb_period=I("RSIL");m.deviation=D("RSIU");m.entry_run=I("ATR1P");
  if(page==3)m.squeeze_max_width=D("ATR2P");
  PutMode(s,m);
  return A10ValidateEntrySettings100(s);
 }
 bool HandleClick(const string name,SA10EntrySettings100 &s)
 {
  if(name==p+"A10_MODE_NEXT"){if(Pull(s)){page=(page+1)%4;Display(s);}ObjectSetInteger(0,name,OBJPROP_STATE,false);return true;}
  return false;
 }
 void Next(SA10EntrySettings100 &s){if(Pull(s)){page=(page+1)%4;Display(s);}}
 void RestoreO01Labels()
 {
  ShowModeButton(false);
  Text("L_H_ENTRY","ENTRY / FILTER  [O01]");
  Text("L_NEW","New Cycles");Text("L_BUY","Trade BUY");Text("L_SELL","Trade SELL");
  Text("L_RSIP","RSI Period");Text("L_RSIL","RSI Lower");Text("L_RSIU","RSI Upper");
  Text("L_ATR1P","ATR1 Period");Text("L_ATR2P","ATR2 Period");Text("L_ATR2TF","ATR2 TF");
  ChartRedraw();
 }
};
#endif
