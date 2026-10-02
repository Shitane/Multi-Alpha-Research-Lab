//+------------------------------------------------------------------+
//| MultiAlpha_Left_Slot_Badge_v1_99.mqh                            |
//| SLOT-local context positioned as a dedicated third header line.  |
//| UI only. NO broker operations.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_SLOT_BADGE_V1_99_MQH
#define MULTIALPHA_LEFT_SLOT_BADGE_V1_99_MQH
class CMultiAlphaLeftSlotBadge199
{
 string p;
public:
 CMultiAlphaLeftSlotBadge199(){p="MALEFTSLOT199_";}
 void Create(const int slot){
  string n=p+"BADGE";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
  // O01 panel body starts at chart y=58. Its title/sub line move with the body.
  // Keep SLOT context on its own dedicated third line below them.
  ObjectSetInteger(0,n,OBJPROP_XDISTANCE,24);
  ObjectSetInteger(0,n,OBJPROP_YDISTANCE,113);
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
