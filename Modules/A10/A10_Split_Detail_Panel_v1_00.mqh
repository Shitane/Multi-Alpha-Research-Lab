//+------------------------------------------------------------------+
//| A10_Split_Detail_Panel_v1_00.mqh                                |
//| Draft-aware A10 M/X detail binding. UI only. NO broker orders.   |
//+------------------------------------------------------------------+
#ifndef A10_SPLIT_DETAIL_PANEL_V1_00_MQH
#define A10_SPLIT_DETAIL_PANEL_V1_00_MQH
#include "A10_Full_Module_v1_00.mqh"
#include "..\\O01\\O01_Runtime_Settings_v1_10.mqh"

class CA10SplitDetailPanel100
{
 string p;
 void T(const string id,const string v){if(ObjectFind(0,p+id)>=0)ObjectSetString(0,p+id,OBJPROP_TEXT,v);}
 void V(const string id,const bool on){if(ObjectFind(0,p+id)>=0)ObjectSetInteger(0,p+id,OBJPROP_TIMEFRAMES,on?OBJ_ALL_PERIODS:0);}
 void Pair(const string id,const bool on){V("L_"+id,on);V(id,on);}
 int ModeIndex(const int mode){int m=mode;if(m<0)m=0;if(m>3)m=3;return m;}
public:
 CA10SplitDetailPanel100(){p="O01CFG160_";}
 void DisplayManage(const bool a10,const SA10FullConfig100 &c,const int mode){
  if(!a10)return;int m=ModeIndex(mode);
  T("L_H_GRID","MANAGE [M]  [A10]");
  T("L_LOT","Max Positions");T("LOT",IntegerToString(c.max_positions));
  T("L_MULT","Cooldown");T("MULT",IntegerToString(c.mode[m].cooldown));
  T("L_MAXLOT","Max Spread");T("MAXLOT",DoubleToString(c.mode[m].max_spread,2));
  T("L_TOTLOT","Entry TTL sec");T("TOTLOT",IntegerToString(c.entry_ttl_seconds));
  T("L_MAXORD","Skip Opposite");T("MAXORD",c.skip_opposite?"1":"0");
  T("L_GRID","Mode #");T("GRID",IntegerToString(m+1));
  Pair("DYNORD",false);Pair("DYNPTS",false);Pair("DISTM",false);
 }
 void DisplayExit(const bool a10,const SA10FullConfig100 &c,const int mode){
  if(!a10)return;int m=ModeIndex(mode);
  T("L_H_EXIT","EXIT [X]  [A10]");
  T("L_VSL","TP bricks");T("VSL",DoubleToString(c.mode[m].tp,1));
  T("L_STS","SL bricks");T("STS",DoubleToString(c.mode[m].sl,1));
  T("L_STL","Max Hold min");T("STL",IntegerToString(c.mode[m].max_hold));
  Pair("STD",false);Pair("BTS",false);Pair("BTL",false);
 }
 void RestoreManageO01(const SO01RuntimeSettings110 &s){
  T("L_H_GRID","MANAGE / GRID / LOT  [O01]");
  T("L_LOT","Initial Lot");T("LOT",DoubleToString(s.initial_lot,2));
  T("L_MULT","Lot Mult");T("MULT",DoubleToString(s.lot_multiplier,2));
  T("L_MAXLOT","Max Lot");T("MAXLOT",DoubleToString(s.max_lot,2));
  T("L_TOTLOT","Max Side Lots");T("TOTLOT",DoubleToString(s.max_total_lots_per_side,2));
  T("L_MAXORD","Max Orders");T("MAXORD",IntegerToString(s.max_orders));
  T("L_GRID","Grid Distance");T("GRID",IntegerToString(s.fixed_distance_points));
  T("L_DYNORD","Dynamic Start #");T("DYNORD",IntegerToString(s.dynamic_start_order));
  T("L_DYNPTS","Dynamic Points");T("DYNPTS",IntegerToString(s.dynamic_start_points));
  T("L_DISTM","Distance Mult");T("DISTM",DoubleToString(s.distance_multiplier,2));
  Pair("DYNORD",true);Pair("DYNPTS",true);Pair("DISTM",true);
 }
 void RestoreExitO01(const SO01RuntimeSettings110 &s){
  T("L_H_EXIT","EXIT / TRAILING  [O01]");
  T("L_VSL","Virtual SL");T("VSL",IntegerToString(s.virtual_sl_points));
  T("L_STS","Single Start");T("STS",IntegerToString(s.single_trail_start));
  T("L_STL","Single Lock");T("STL",IntegerToString(s.single_trail_lock));
  T("L_STD","Single Dist");T("STD",IntegerToString(s.single_trail_distance));
  T("L_BTS","Basket Start");T("BTS",IntegerToString(s.basket_trail_start));
  T("L_BTL","Basket Lock");T("BTL",IntegerToString(s.basket_trail_lock));
  Pair("STD",true);Pair("BTS",true);Pair("BTL",true);
 }
};
#endif
