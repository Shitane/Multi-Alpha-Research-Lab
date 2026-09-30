//+------------------------------------------------------------------+
//| MultiAlpha_Left_Slot_Badge_v1_97.mqh                            |
//| Clear SLOT-local context line below the left runtime status.      |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_SLOT_BADGE_V1_97_MQH
#define MULTIALPHA_LEFT_SLOT_BADGE_V1_97_MQH
class CMultiAlphaLeftSlotBadge197
{
 string p;
public:
 CMultiAlphaLeftSlotBadge197(){p="MALEFTSLOT197_";}
 void Create(const int slot){string n=p+"BADGE";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,24);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,70);ObjectSetInteger(0,n,OBJPROP_COLOR,C'118,190,220');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,9);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);ObjectSetInteger(0,n,OBJPROP_ZORDER,12);Set(slot);}
 void Set(const int slot){string n=p+"BADGE";if(ObjectFind(0,n)>=0)ObjectSetString(0,n,OBJPROP_TEXT,StringFormat("VIEWING SLOT # %02d  /  SLOT-LOCAL SETTINGS",slot));ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
