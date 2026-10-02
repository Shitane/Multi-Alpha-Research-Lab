//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Live_Evaluator_v1_00.mqh               |
//| Generic saved Builder definition -> live context boolean gate.   |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_SAVED_LIVE_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_SAVED_LIVE_EVALUATOR_V1_00_MQH
#include "MultiAlpha_Builder_Saved_Definition_Route_v1_00.mqh"
#define MA_BUILDER_SAVED_LIVE_EVALUATOR_VERSION "1.00"

struct SMA_BuilderSavedLiveContext100
{
 double rsi;
 int buy_count;
 int sell_count;
 int position_count;
 bool cycle_new;
 bool emergency_unlocked;
 bool time_allowed;
 bool news_clear;
 bool spread_ok;
 bool filters_ok;
};

class CMultiAlphaBuilderSavedLiveEvaluator100
{
private:
 CMultiAlphaBuilderInterpreter101 m_interpreter;

 bool IsLogic(const string p) const { return p=="AND" || p=="OR"; }

 bool Operand(const string part,const string param,
              const SMA_BuilderSavedLiveContext100 &x,
              bool &value,string &reason)
 {
  value=false;
  if(part=="CYCLE_NEW"){value=x.cycle_new;return true;}
  if(part=="EMERGENCY_UNLOCKED"){value=x.emergency_unlocked;return true;}
  if(part=="TIME_ALLOWED" || part=="TIME"){value=x.time_allowed;return true;}
  if(part=="NEWS_CLEAR" || part=="NEWS"){value=x.news_clear;return true;}
  if(part=="SPREAD_OK" || part=="SPREAD"){value=x.spread_ok;return true;}
  if(part=="FILTERS_OK"){value=x.filters_ok;return true;}
  if(part=="SIDE_COUNT_ZERO"){value=(x.buy_count==0 && x.sell_count==0);return true;}
  if(part=="SIDE_COUNT"){value=(x.position_count>0);return true;}
  if(part=="POSITION_COUNT"){value=(x.position_count>0);return true;}
  if(part=="RSI_THRESHOLD")
  {
   string cond=m_interpreter.Param(param,"COND","LT");
   double level=StringToDouble(m_interpreter.Param(param,"LEVEL","30"));
   double upper=StringToDouble(m_interpreter.Param(param,"UPPER","70"));
   if(cond=="LT"){value=(x.rsi<level);return true;}
   if(cond=="GT"){value=(x.rsi>level);return true;}
   if(cond=="OUTSIDE"){value=(x.rsi<level || x.rsi>upper);return true;}
   if(cond=="BETWEEN"){value=(x.rsi>=level && x.rsi<=upper);return true;}
   reason="UNSUPPORTED RSI COND: "+cond;return false;
  }

  // Position-dependent Builder parts are valid but inactive in this first
  // live gate because the context is deliberately VIRTUAL NOT FILL.
  if(part=="AVG_PRICE" || part=="LAST_PRICE" || part=="FIXED_DIST" ||
     part=="DYNAMIC_DIST" || part=="LOT_MULT" || part=="MAX_LOT" ||
     part=="MAX_TOTAL" || part=="MAX_ORDERS" || part=="ONE/BAR" ||
     part=="TRAIL_PAUSE" || part=="MOVE_PTS" || part=="VIRTUAL_SL" ||
     part=="FIXED_TP" || part=="SINGLE_TRAIL" || part=="BASKET_TRAIL" ||
     part=="ADD BUY" || part=="ADD SELL" || part=="CLOSE" ||
     part=="SIGNAL BUY/SELL")
  { value=false; return true; }

  reason="UNSUPPORTED LIVE PART: "+part;
  return false;
 }

public:
 bool Evaluate(const SMA_BuilderSavedDefinition100 &d,
               const SMA_BuilderSavedLiveContext100 &x,
               bool &result,string &trace,string &reason)
 {
  result=false;trace="";
  if(!d.loaded || !d.valid){reason="DEFINITION NOT READY: "+d.reason;return false;}

  string parts[]; bool values[];
  ArrayResize(parts,24);ArrayResize(values,24);
  for(int i=0;i<24;i++)
  {
   parts[i]=d.part[i];
   values[i]=false;
   if(parts[i]=="" || parts[i]=="EMPTY" || IsLogic(parts[i])) continue;
   string why="";
   if(!Operand(parts[i],d.param[i],x,values[i],why))
   {reason="slot "+IntegerToString(i+1)+": "+why;return false;}
  }
  return m_interpreter.EvaluateBooleans(parts,values,result,trace,reason);
 }
};
#endif
