//+------------------------------------------------------------------+
//| MultiAlpha_Slot_Header_v1_88.mqh                                |
//| Stage-1 multi-slot UI scaffold. NO runtime routing side effects. |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_HEADER_V1_88_MQH
#define MULTIALPHA_SLOT_HEADER_V1_88_MQH
class CMultiAlphaSlotHeader188
{
 string p; int selected;
 void Btn(const string id,int x,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,64);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_SELECTED,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,70);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Lab(const string id,int x,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,69);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 string SlotText(){return StringFormat("SLOT [ #%02d ]",selected);}
public:
 CMultiAlphaSlotHeader188(){p="MASLOT188_";selected=1;}
 void Create(const string symbol){Btn("SLOT",330,104,SlotText());Btn("ENABLE",438,104,"ENABLE [ON]");Lab("SYMBOL",550,symbol);Lab("STATE",650,"STATE: READY");Lab("COUNT",760,"#01 / 50");ChartRedraw();}
 int Event(const int id,const string name){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(name!=p+"SLOT"&&name!=p+"ENABLE")return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);
  if(name==p+"SLOT"){selected++;if(selected>50)selected=1;ObjectSetString(0,p+"SLOT",OBJPROP_TEXT,SlotText());ObjectSetString(0,p+"COUNT",OBJPROP_TEXT,StringFormat("#%02d / 50",selected));Print("[MA_SLOT188_VIEW] selected=",selected," runtime_changed=0 scaffold=1");}
  else Print("[MA_SLOT188_ENABLE] stage1_scaffold=1 action_ignored=1 runtime_changed=0");
  ChartRedraw();return 1;}
 void SetState(const string s){if(ObjectFind(0,p+"STATE")>=0)ObjectSetString(0,p+"STATE",OBJPROP_TEXT,"STATE: "+s);}
 int Selected(){return selected;}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
