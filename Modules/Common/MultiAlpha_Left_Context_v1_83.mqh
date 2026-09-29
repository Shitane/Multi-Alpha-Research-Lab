//+------------------------------------------------------------------+
//| MultiAlpha_Left_Context_v1_83.mqh                               |
//| Draft-aware left panel visibility helper. UI only.               |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_CONTEXT_V1_83_MQH
#define MULTIALPHA_LEFT_CONTEXT_V1_83_MQH
class CMultiAlphaLeftContext183
{
 string p;
 void V(const string id,const bool on){if(ObjectFind(0,p+id)>=0)ObjectSetInteger(0,p+id,OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}
 void T(const string id,const string s){if(ObjectFind(0,p+id)>=0)ObjectSetString(0,p+id,OBJPROP_TEXT,s);}
 void Pair(const string id,const bool on){V("L_"+id,on);V(id,on);}
public:
 CMultiAlphaLeftContext183(){p="O01CFG160_";}
 void Restore(){
  string a[]={"NEW","BUY","SELL","RSIP","RSIL","RSIU","ATR1P","ATR2P","ATR2TF","LOT","MULT","MAXLOT","TOTLOT","MAXORD","GRID","DYNORD","DYNPTS","DISTM","VSL","STS","STL","STD","BTS","BTL","WARN","PAUSE","CLOSE","TMODE","START","END","NEWS","PRESET"};
  for(int i=0;i<ArraySize(a);i++)Pair(a[i],true);
  string h[]={"ENTRY","GRID","EXIT","SAFETY","TIME","PRESETSEC"};for(int i=0;i<ArraySize(h);i++)V("L_H_"+h[i],true);
  string b[]={"NEXT","APPLY","SAVE","LOAD","DELETE","RESET","L_PRESETLAB","L_SAVEDLAB","L_SAVEDVAL"};for(int i=0;i<ArraySize(b);i++)V(b[i],true);
 }
 void Split(const string entry_name,const string manage_name,const string exit_name){
  Restore();
  string x[]={"WARN","PAUSE","CLOSE","TMODE","START","END","NEWS","PRESET"};for(int i=0;i<ArraySize(x);i++)Pair(x[i],false);
  string h[]={"SAFETY","TIME","PRESETSEC"};for(int i=0;i<ArraySize(h);i++)V("L_H_"+h[i],false);
  string b[]={"SAVE","LOAD","DELETE","RESET","L_PRESETLAB","L_SAVEDLAB","L_SAVEDVAL"};for(int i=0;i<ArraySize(b);i++)V(b[i],false);
  T("L_H_ENTRY","ENTRY [E]  ["+entry_name+"]");T("L_H_GRID","MANAGE [M]  ["+manage_name+"]");T("L_H_EXIT","EXIT [X]  ["+exit_name+"]");ChartRedraw();
 }
 void A10Full(){
  Restore();
  string x[]={"WARN","PAUSE","CLOSE","TMODE","START","END","NEWS","PRESET"};for(int i=0;i<ArraySize(x);i++)Pair(x[i],false);
  string h[]={"SAFETY","TIME","PRESETSEC"};for(int i=0;i<ArraySize(h);i++)V("L_H_"+h[i],false);
  string b[]={"NEXT","SAVE","LOAD","DELETE","RESET","L_PRESETLAB","L_SAVEDLAB","L_SAVEDVAL"};for(int i=0;i<ArraySize(b);i++)V(b[i],false);
  ChartRedraw();
 }
 void Unregistered(const string name){
  Restore();
  string a[]={"NEW","BUY","SELL","RSIP","RSIL","RSIU","ATR1P","ATR2P","ATR2TF","LOT","MULT","MAXLOT","TOTLOT","MAXORD","GRID","DYNORD","DYNPTS","DISTM","VSL","STS","STL","STD","BTS","BTL","WARN","PAUSE","CLOSE","TMODE","START","END","NEWS","PRESET"};
  for(int i=0;i<ArraySize(a);i++)Pair(a[i],false);
  string h[]={"GRID","EXIT","SAFETY","TIME","PRESETSEC"};for(int i=0;i<ArraySize(h);i++)V("L_H_"+h[i],false);
  string b[]={"NEXT","APPLY","SAVE","LOAD","DELETE","RESET","L_PRESETLAB","L_SAVEDLAB","L_SAVEDVAL"};for(int i=0;i<ArraySize(b);i++)V(b[i],false);
  V("L_H_ENTRY",true);T("L_H_ENTRY","FULL STRATEGY  ["+name+"]  NOT REGISTERED");ChartRedraw();
 }
};
#endif
