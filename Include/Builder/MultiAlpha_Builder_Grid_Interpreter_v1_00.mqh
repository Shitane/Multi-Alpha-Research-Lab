//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh                   |
//| P1-B: ordered GRID 40 Parts pipeline evaluator.                  |
//| Mirrors O01 ManageSide(type) guard order; never sends orders.    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_GRID_INTERPRETER_V1_00_MQH
#define MULTIALPHA_BUILDER_GRID_INTERPRETER_V1_00_MQH
#include "MultiAlpha_Builder_Part_Schema_v1_02.mqh"
#define MA_BUILDER_GRID_INTERPRETER_100_VERSION "1.00"

enum ENUM_MA_GRID_SIDE100 { MA_GRID_SIDE_BUY100=1, MA_GRID_SIDE_SELL100=-1 };

class CMultiAlphaBuilderGridInterpreter100
{
 bool Empty(string p){return p==""||p=="EMPTY";}
public:
 bool ValidatePlan(const string &p[],const string &v[],string &reason)
 {
  if(ArraySize(p)!=40||ArraySize(v)!=40){reason="GRID requires 40 slots";return false;}
  string expected[33]={
   "SIDE_COUNT","AND","MAX_ORDERS","AND","DD_BELOW","AND","TRAILING_PAUSE","AND",
   "GRID_TIME_ALLOWED","AND","GRID_NEWS_CLEAR","AND","SPREAD_OK","AND","ONE_ORDER_PER_BAR","AND",
   "LAST_PRICE","AND","FIXED_DISTANCE","AND","DYNAMIC_DISTANCE","AND","DISTANCE_REACHED","AND",
   "LOT_MULTIPLIER","AND","MAX_LOT","AND","MAX_TOTAL_LOT","AND","ADD_BUY","OR","ADD_SELL"
  };
  for(int i=0;i<33;i++)
  {
   if(p[i]!=expected[i]){reason="slot "+IntegerToString(i+1)+": expected "+expected[i]+" got "+p[i];return false;}
   if(p[i]!="AND"&&p[i]!="OR")
   {
    string why="";
    if(!MA102ValidatePart(MA_BUILDER_ROLE_GRID101,p[i],v[i],why)){reason="slot "+IntegerToString(i+1)+": "+why;return false;}
   }
  }
  for(int i=33;i<40;i++)if(!Empty(p[i])){reason="slot "+IntegerToString(i+1)+": expected EMPTY";return false;}
  reason="VALID";return true;
 }

 // gate[] is indexed by 40-Part slot. Computation/config Parts are present in
 // the plan but do not become boolean guards; their resulting checks are
 // represented by the corresponding runtime guard slots (e.g. DISTANCE_REACHED).
 bool Evaluate(const string &p[],const string &v[],const bool &gate[],const int side,
               bool &addBuy,bool &addSell,string &stopAt,string &reason)
 {
  addBuy=false;addSell=false;stopAt="-";
  if(ArraySize(gate)!=40){reason="GRID GATE SIZE";return false;}
  if(side!=MA_GRID_SIDE_BUY100&&side!=MA_GRID_SIDE_SELL100){reason="GRID SIDE";return false;}
  if(!ValidatePlan(p,v,reason))return false;

  int guards[10]={0,2,4,6,8,10,12,14,16,22};
  for(int k=0;k<10;k++)
  {
   int i=guards[k];
   if(!gate[i]){stopAt=p[i];reason="BLOCKED";return true;}
  }
  // Max-lot and max-total-lot are evaluated after lot calculation in O01.
  if(!gate[26]){stopAt="MAX_LOT";reason="BLOCKED";return true;}
  if(!gate[28]){stopAt="MAX_TOTAL_LOT";reason="BLOCKED";return true;}

  if(side==MA_GRID_SIDE_BUY100)addBuy=true;else addSell=true;
  reason="ALLOW";return true;
 }
};
#endif
