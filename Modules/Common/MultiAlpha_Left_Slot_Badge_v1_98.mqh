//+------------------------------------------------------------------+
//| MultiAlpha_Left_Slot_Badge_v1_98.mqh                            |
//| SLOT-local context positioned as a dedicated third header line.  |
//| UI only. NO broker operations.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_SLOT_BADGE_V1_98_MQH
#define MULTIALPHA_LEFT_SLOT_BADGE_V1_98_MQH
class CMultiAlphaLeftSlotBadge198
{
 string p;
public:
 CMultiAlphaLeftSlotBadge198(){p="MALEFTSLOT198_";}
 void Create(const int slot){
  string n=p+"BADGE";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
  // O01 panel body starts at chart y=36. Its title/sub line are y=54/75.
  // Keep SLOT context on its own line immediately below them.
  ObjectSetInteger(0,n,OBJPROP_XDISTANCE,24);
  ObjectSetInteger(0,n,OBJPROP_YDISTANCE,91);
  ObjectSetInteger(0,n,OBJPROP_COLOR,C'118,190,220');
  ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);
  ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
  ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
  ObjectSetInteger(0,n,OBJPROP_ZORDER,12);
  Set(slot);
 }
 void Set(const int slot){
  string n=p+"BADGE";
  if(ObjectFind(0,n)>=0)ObjectSetString(0,n,OBJPROP_TEXT,StringFormat("VIEWING SLOT #%02d  /  SLOT-LOCAL SETTINGS",slot));
  ChartRedraw();
 }
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
