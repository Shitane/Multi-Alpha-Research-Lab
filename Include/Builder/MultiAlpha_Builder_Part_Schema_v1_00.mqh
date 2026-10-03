//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Part_Schema_v1_00.mqh                        |
//| Canonical generic Logic Builder part IDs / parameter validation. |
//| Strategy-neutral. NO ORDERS.                                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PART_SCHEMA_V1_00_MQH
#define MULTIALPHA_BUILDER_PART_SCHEMA_V1_00_MQH
#define MA_BUILDER_PART_SCHEMA_VERSION "1.00"

enum ENUM_MA_BUILDER_ROLE100
{
 MA_BUILDER_ROLE_ENTRY100=0,
 MA_BUILDER_ROLE_MANAGE100=1,
 MA_BUILDER_ROLE_EXIT100=2
};

string MA100Param(const string params,const string key,const string def="")
{
 string a[]; int n=StringSplit(params,';',a);
 for(int i=0;i<n;i++)
 {
  int q=StringFind(a[i],"=");
  if(q>0 && StringSubstr(a[i],0,q)==key) return StringSubstr(a[i],q+1);
 }
 return def;
}
bool MA100HasParam(const string params,const string key){return MA100Param(params,key,"__MA_MISSING__")!="__MA_MISSING__";}
bool MA100IsBoolText(const string v){return v=="0"||v=="1"||v=="true"||v=="false"||v=="TRUE"||v=="FALSE";}
bool MA100PositiveInt(const string v){return (int)StringToInteger(v)>0;}
bool MA100NonNegative(const string v){return StringToDouble(v)>=0.0;}
bool MA100Positive(const string v){return StringToDouble(v)>0.0;}

string MA100CanonicalPart(string id)
{
 // Migration aliases only. New saves must use the returned canonical ID.
 if(id=="ATR") return "ATR_RANGE";
 if(id=="SIDE_COUNT_ZERO") return "SIDE_COUNT";
 if(id=="FIXED_DIST") return "FIXED_DISTANCE";
 if(id=="DYNAMIC_DIST") return "DYNAMIC_DISTANCE";
 if(id=="LOT_MULT") return "LOT_MULTIPLIER";
 if(id=="MAX_TOTAL") return "MAX_TOTAL_LOT";
 if(id=="ONE/BAR") return "ONE_ORDER_PER_BAR";
 if(id=="TRAIL_PAUSE") return "TRAILING_PAUSE";
 if(id=="SIGNAL BUY") return "BUY";
 if(id=="SIGNAL SELL") return "SELL";
 if(id=="ADD BUY") return "ADD_BUY";
 if(id=="ADD SELL") return "ADD_SELL";
 if(id=="CLOSE"||id=="CLOSE SIDE") return "CLOSE_SIDE";
 return id;
}

string MA100NormalizeParams(const string id,const string params)
{
 string p=id;
 if(p=="SINGLE_TRAILING"||p=="BASKET_TRAILING")
 {
  string dist=MA100Param(params,"DISTANCE",MA100Param(params,"DIST","50"));
  return "START="+MA100Param(params,"START","0")+
         ";LOCK="+MA100Param(params,"LOCK","0")+
         ";DISTANCE="+dist+
         ";STEP="+MA100Param(params,"STEP","0");
 }
 if(p=="ATR_RANGE")
  return "TF="+MA100Param(params,"TF","CURRENT")+
         ";PERIOD="+MA100Param(params,"PERIOD","15")+
         ";MIN_POINTS="+MA100Param(params,"MIN_POINTS",MA100Param(params,"MIN","0"))+
         ";MAX_POINTS="+MA100Param(params,"MAX_POINTS",MA100Param(params,"MAX","10000"));
 if(p=="MAX_ORDERS") return "COUNT="+MA100Param(params,"COUNT",MA100Param(params,"VALUE","10"));
 if(p=="MAX_LOT") return "LOT="+MA100Param(params,"LOT",MA100Param(params,"VALUE","5.00"));
 if(p=="MAX_TOTAL_LOT") return "LOT="+MA100Param(params,"LOT",MA100Param(params,"VALUE","1.20"));
 if(p=="SIDE_COUNT")
  return "SIDE="+MA100Param(params,"SIDE","CURRENT")+
         ";COND="+MA100Param(params,"COND","EQ")+
         ";VALUE="+MA100Param(params,"VALUE","0");
 return params;
}

bool MA100PartAllowed(const int role,const string raw)
{
 string p=MA100CanonicalPart(raw);
 if(p=="EMPTY"||p=="AND"||p=="OR") return true;
 if(role==MA_BUILDER_ROLE_ENTRY100)
  return p=="CYCLE_NEW"||p=="FILTERS_OK"||p=="SIDE_COUNT"||p=="RSI_THRESHOLD"||p=="ATR_RANGE"||p=="MA"||p=="BUY"||p=="SELL";
 if(role==MA_BUILDER_ROLE_MANAGE100)
  return p=="FILTERS_OK"||p=="SIDE_COUNT"||p=="POSITION_COUNT"||p=="AVG_PRICE"||p=="LAST_PRICE"||
         p=="INITIAL_LOT"||p=="MAX_ORDERS"||p=="ONE_ORDER_PER_BAR"||p=="TRAILING_PAUSE"||
         p=="FIXED_DISTANCE"||p=="DYNAMIC_DISTANCE"||p=="LOT_MULTIPLIER"||p=="MAX_LOT"||
         p=="MAX_TOTAL_LOT"||p=="ADD_BUY"||p=="ADD_SELL";
 if(role==MA_BUILDER_ROLE_EXIT100)
  return p=="SIDE_COUNT"||p=="POSITION_COUNT"||p=="AVG_PRICE"||p=="MOVE_POINTS"||p=="VIRTUAL_SL"||
         p=="FIXED_TP"||p=="SINGLE_TRAILING"||p=="BASKET_TRAILING"||p=="CLOSE_SIDE";
 return false;
}

bool MA100ValidatePart(const int role,const string raw,const string raw_params,string &reason)
{
 string p=MA100CanonicalPart(raw),v=MA100NormalizeParams(p,raw_params);
 if(!MA100PartAllowed(role,p)){reason="PART NOT ALLOWED FOR ROLE: "+p;return false;}
 if(p=="EMPTY"||p=="AND"||p=="OR"||p=="CYCLE_NEW"||p=="FILTERS_OK"||p=="AVG_PRICE"||p=="LAST_PRICE"||p=="MOVE_POINTS"||p=="BUY"||p=="SELL"||p=="ADD_BUY"||p=="ADD_SELL"||p=="CLOSE_SIDE"){reason="OK";return true;}
 if(p=="SIDE_COUNT")
 {
  string side=MA100Param(v,"SIDE",""),cond=MA100Param(v,"COND",""),val=MA100Param(v,"VALUE","");
  if(!(side=="BUY"||side=="SELL"||side=="CURRENT")){reason="SIDE_COUNT SIDE";return false;}
  if(!(cond=="EQ"||cond=="GT"||cond=="GE"||cond=="LT"||cond=="LE")){reason="SIDE_COUNT COND";return false;}
  if(StringToInteger(val)<0){reason="SIDE_COUNT VALUE";return false;}
 }
 else if(p=="RSI_THRESHOLD")
 {
  if(!MA100PositiveInt(MA100Param(v,"PERIOD","0"))){reason="RSI PERIOD";return false;}
  string c=MA100Param(v,"COND","");
  if(!(c=="LT"||c=="GT"||c=="LE"||c=="GE")){reason="RSI COND";return false;}
  double level=StringToDouble(MA100Param(v,"LEVEL","-1"));
  if(level<0.0||level>100.0){reason="RSI LEVEL";return false;}
 }
 else if(p=="ATR_RANGE")
 {
  if(!MA100PositiveInt(MA100Param(v,"PERIOD","0"))){reason="ATR PERIOD";return false;}
  double mn=StringToDouble(MA100Param(v,"MIN_POINTS","-1")),mx=StringToDouble(MA100Param(v,"MAX_POINTS","-1"));
  if(mn<0.0||mx<mn){reason="ATR RANGE";return false;}
 }
 else if(p=="INITIAL_LOT"||p=="MAX_LOT"||p=="MAX_TOTAL_LOT")
 {
  if(!MA100Positive(MA100Param(v,"LOT","0"))){reason=p+" LOT";return false;}
 }
 else if(p=="MAX_ORDERS")
 {
  if(!MA100PositiveInt(MA100Param(v,"COUNT","0"))){reason="MAX_ORDERS COUNT";return false;}
 }
 else if(p=="ONE_ORDER_PER_BAR"||p=="TRAILING_PAUSE")
 {
  if(!MA100IsBoolText(MA100Param(v,"ENABLED",""))){reason=p+" ENABLED";return false;}
 }
 else if(p=="FIXED_DISTANCE"||p=="VIRTUAL_SL"||p=="FIXED_TP")
 {
  if(!MA100NonNegative(MA100Param(v,"POINTS","-1"))){reason=p+" POINTS";return false;}
 }
 else if(p=="DYNAMIC_DISTANCE")
 {
  if(!MA100PositiveInt(MA100Param(v,"START_ORDER","0"))||!MA100NonNegative(MA100Param(v,"START_POINTS","-1"))||!MA100Positive(MA100Param(v,"MULT","0"))){reason="DYNAMIC_DISTANCE PARAMS";return false;}
 }
 else if(p=="LOT_MULTIPLIER")
 {
  if(!MA100Positive(MA100Param(v,"MULT","0"))){reason="LOT_MULTIPLIER MULT";return false;}
 }
 else if(p=="SINGLE_TRAILING"||p=="BASKET_TRAILING")
 {
  if(!MA100NonNegative(MA100Param(v,"START","-1"))||!MA100NonNegative(MA100Param(v,"LOCK","-1"))||!MA100NonNegative(MA100Param(v,"DISTANCE","-1"))||!MA100NonNegative(MA100Param(v,"STEP","-1"))){reason=p+" PARAMS";return false;}
 }
 reason="OK";return true;
}
#endif
