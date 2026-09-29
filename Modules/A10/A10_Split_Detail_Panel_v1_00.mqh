//+------------------------------------------------------------------+
//| A10_Split_Detail_Panel_v1_00.mqh                                |
//| Draft-aware A10 M/X detail binding for the common left panel.    |
//| UI/config only. NO broker orders.                                |
//+------------------------------------------------------------------+
#ifndef A10_SPLIT_DETAIL_PANEL_V1_00_MQH
#define A10_SPLIT_DETAIL_PANEL_V1_00_MQH
#include "A10_Full_Module_v1_00.mqh"

class CA10SplitDetailPanel100
{
 string p;
 void T(const string id,const string v){if(ObjectFind(0,p+id)>=0)ObjectSetString(0,p+id,OBJPROP_TEXT,v);}
 void V(const string id,const bool on){if(ObjectFind(0,p+id)>=0)ObjectSetInteger(0,p+id,OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}
 void Pair(const string id,const bool on){V("L_"+id,on);V(id,on);}
public:
 CA10SplitDetailPanel100(){p="O01CFG160_";}

 void DisplayManage(const bool a10,const SA10FullConfig100 &c,const int mode)
 {
  if(!a10)return; int m=MathMax(0,MathMin(3,mode));
  T("L_H_GRID","MANAGE [M]  [A10]");
  // A10 M is lifecycle/queue management, NOT grid/averaging.
  T("L_LOT","Max Positions"); T("LOT",IntegerToString(c.max_positions));
  T("L_MULT","Cooldown");     T("MULT",IntegerToString(c.mode[m].cooldown));
  T("L_MAXLOT","Max Spread"); T("MAXLOT",DoubleToString(c.mode[m].max_spread,2));
  T("L_TOTLOT","Entry TTL sec");T("TOTLOT",IntegerToString(c.entry_ttl_seconds));
  T("L_MAXORD","Skip Opposite");T("MAXORD",c.skip_opposite?"1":"0");
  T("L_GRID","Mode #");       T("GRID",IntegerToString(m+1));
  Pair("DYNORD",false);Pair("DYNPTS",false);Pair("DISTM",false);
 }

 void DisplayExit(const bool a10,const SA10FullConfig100 &c,const int mode)
 {
  if(!a10)return; int m=MathMax(0,MathMin(3,mode));
  T("L_H_EXIT","EXIT [X]  [A10]");
  T("L_VSL","TP bricks");     T("VSL",DoubleToString(c.mode[m].tp,1));
  T("L_STS","SL bricks");     T("STS",DoubleToString(c.mode[m].sl,1));
  T("L_STL","Max Hold min");  T("STL",IntegerToString(c.mode[m].max_hold));
  // O01 trailing fields are not A10 EXIT settings.
  Pair("STD",false);Pair("BTS",false);Pair("BTL",false);
 }

 void RestoreManageO01()
 {
  T("L_H_GRID","MANAGE / GRID / LOT  [O01]");
  T("L_LOT","Initial Lot");T("L_MULT","Lot Mult");T("L_MAXLOT","Max Lot");
  T("L_TOTLOT","Max Side Lots");T("L_MAXORD","Max Orders");T("L_GRID","Grid Distance");
  Pair("DYNORD",true);Pair("DYNPTS",true);Pair("DISTM",true);
 }
 void RestoreExitO01()
 {
  T("L_H_EXIT","EXIT / TRAILING  [O01]");
  T("L_VSL","Virtual SL");T("L_STS","Single Start");T("L_STL","Single Lock");
  T("L_STD","Single Dist");T("L_BTS","Basket Start");T("L_BTL","Basket Lock");
  Pair("STD",true);Pair("BTS",true);Pair("BTL",true);
 }
};
#endif
