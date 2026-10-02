//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Part_Registry_v1_00.mqh                      |
//| LB-01 reusable part catalogue, seeded from verified O01 logic.   |
//| Metadata only. NO ORDERS / VIRTUAL NOT FILL.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_PART_REGISTRY_V1_00_MQH
#define MULTIALPHA_BUILDER_PART_REGISTRY_V1_00_MQH

#define MA_BUILDER_PART_REGISTRY_VERSION "1.00"
#define MA_BUILDER_PART_MAX 32

enum ENUM_MA_BUILDER_PART_KIND100
{
 MA_PART_CONDITION100=0,
 MA_PART_STATE100=1,
 MA_PART_ACTION100=2
};

struct SMA_BuilderPartInfo100
{
 string id;
 string version;
 string label;
 ENUM_MA_BUILDER_PART_KIND100 kind;
 string parameter_schema;
};

class CMultiAlphaBuilderPartRegistry100
{
private:
 SMA_BuilderPartInfo100 m_parts[MA_BUILDER_PART_MAX];
 int m_count;

 void Add(string id,string version,string label,ENUM_MA_BUILDER_PART_KIND100 kind,string schema)
 {
  if(m_count>=MA_BUILDER_PART_MAX)return;
  m_parts[m_count].id=id;
  m_parts[m_count].version=version;
  m_parts[m_count].label=label;
  m_parts[m_count].kind=kind;
  m_parts[m_count].parameter_schema=schema;
  m_count++;
 }

public:
 CMultiAlphaBuilderPartRegistry100(){m_count=0;}

 void BuildO01Seed()
 {
  m_count=0;
  // O01 initial-entry gates.
  Add("CYCLE_NEW","1.00","New cycles enabled",MA_PART_CONDITION100,"enabled:bool");
  Add("EMERGENCY_UNLOCKED","1.00","Emergency lock is OFF",MA_PART_CONDITION100,"");
  Add("TIME_ALLOWED","1.00","Trade time allowed",MA_PART_CONDITION100,"");
  Add("NEWS_CLEAR","1.00","News is not blocking",MA_PART_CONDITION100,"");
  Add("SPREAD_OK","1.00","Spread filter OK",MA_PART_CONDITION100,"");
  Add("FILTERS_OK","1.00","Common filters OK",MA_PART_CONDITION100,"");
  Add("SIDE_COUNT_ZERO","1.00","Selected side position count = 0",MA_PART_STATE100,"side:BUY|SELL");
  Add("RSI_THRESHOLD","1.00","RSI threshold",MA_PART_CONDITION100,"side:BUY|SELL;period:int;level:double;compare:LT|GT");

  // O01 exit / trailing state.
  Add("POSITION_COUNT","1.00","Position count",MA_PART_STATE100,"compare:GT|GE|EQ;value:int");
  Add("MOVE_POINTS","1.00","Move points",MA_PART_STATE100,"compare:LE|GE;value:double");
  Add("TRAIL_STATE","1.00","Trailing state machine",MA_PART_STATE100,"start:int;lock:int;distance:int;step:int");

  // Role outputs/actions. These are decisions only in LB-01.
  Add("SIGNAL_BUY","1.00","BUY signal",MA_PART_ACTION100,"");
  Add("SIGNAL_SELL","1.00","SELL signal",MA_PART_ACTION100,"");
  Add("EXIT_VIRTUAL_SL","1.00","Virtual SL decision",MA_PART_ACTION100,"points:int");
  Add("EXIT_FIXED_TP","1.00","Fixed TP decision",MA_PART_ACTION100,"points:int");
  Add("EXIT_TRAILING","1.00","Trailing exit decision",MA_PART_ACTION100,"mode:SINGLE|BASKET");
 }

 int Count() const { return m_count; }

 bool Get(const int index,SMA_BuilderPartInfo100 &out) const
 {
  if(index<0 || index>=m_count)return false;
  out=m_parts[index];
  return true;
 }

 bool Find(const string id,SMA_BuilderPartInfo100 &out) const
 {
  for(int i=0;i<m_count;i++)
   if(m_parts[i].id==id){out=m_parts[i];return true;}
  return false;
 }
};

#endif
