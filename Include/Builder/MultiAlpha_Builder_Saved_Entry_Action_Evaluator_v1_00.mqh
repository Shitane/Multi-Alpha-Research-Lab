//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Entry_Action_Evaluator_v1_00.mqh       |
//| Generic saved ENTRY definition -> BUY/SELL/NONE decision.        |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_SAVED_ENTRY_ACTION_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_SAVED_ENTRY_ACTION_EVALUATOR_V1_00_MQH
#include "MultiAlpha_Builder_Saved_Definition_Route_v1_00.mqh"
#define MA_BUILDER_SAVED_ENTRY_ACTION_EVALUATOR_VERSION "1.00"

enum ENUM_MA_BUILDER_ENTRY_ACTION100
{
 MA_BUILDER_ENTRY_NONE100=0,
 MA_BUILDER_ENTRY_BUY100=1,
 MA_BUILDER_ENTRY_SELL100=2
};

struct SMA_BuilderSavedEntryContext100
{
 double rsi;
 int buy_count;
 int sell_count;
 bool cycle_new;
 bool emergency_unlocked;
 bool time_allowed;
 bool news_clear;
 bool spread_ok;
 bool filters_ok;
};

class CMultiAlphaBuilderSavedEntryActionEvaluator100
{
private:
 CMultiAlphaBuilderInterpreter101 m_i;

 bool Cond(const string part,const string param,const SMA_BuilderSavedEntryContext100 &x,bool &v,string &why)
 {
  v=false;
  if(part=="CYCLE_NEW"){v=x.cycle_new;return true;}
  if(part=="EMERGENCY_UNLOCKED"){v=x.emergency_unlocked;return true;}
  if(part=="TIME_ALLOWED"||part=="TIME"){v=x.time_allowed;return true;}
  if(part=="NEWS_CLEAR"||part=="NEWS"){v=x.news_clear;return true;}
  if(part=="SPREAD_OK"||part=="SPREAD"){v=x.spread_ok;return true;}
  if(part=="FILTERS_OK"){v=x.filters_ok;return true;}
  if(part=="BUY_SIDE_ZERO"){v=(x.buy_count==0);return true;}
  if(part=="SELL_SIDE_ZERO"){v=(x.sell_count==0);return true;}
  if(part=="SIDE_COUNT_ZERO"){v=(x.buy_count==0&&x.sell_count==0);return true;}
  if(part=="RSI_THRESHOLD")
  {
   string c=m_i.Param(param,"COND","LT");
   double level=StringToDouble(m_i.Param(param,"LEVEL","30"));
   if(c=="LT"){v=x.rsi<level;return true;}
   if(c=="GT"){v=x.rsi>level;return true;}
   why="UNSUPPORTED RSI COND: "+c;return false;
  }
  why="UNSUPPORTED ENTRY CONDITION: "+part;return false;
 }

 bool EvalClause(const SMA_BuilderSavedDefinition100 &d,const int from,const int to,
                 const SMA_BuilderSavedEntryContext100 &x,bool &result,string &why)
 {
  result=true; bool have=false; string op="AND";
  for(int k=from;k<=to;k++)
  {
   string p=d.part[k]; if(p==""||p=="EMPTY")continue;
   if(p=="AND"||p=="OR"){op=p;continue;}
   if(p=="SIGNAL BUY"||p=="SIGNAL SELL"||p=="SIGNAL BUY/SELL")continue;
   bool v=false;if(!Cond(p,d.param[k],x,v,why))return false;
   if(!have){result=v;have=true;} else if(op=="AND")result=result&&v; else result=result||v;
  }
  if(!have){why="EMPTY ENTRY CLAUSE";return false;}return true;
 }

public:
 bool Evaluate(const SMA_BuilderSavedDefinition100 &d,const SMA_BuilderSavedEntryContext100 &x,
               ENUM_MA_BUILDER_ENTRY_ACTION100 &action,string &trace,string &reason)
 {
  action=MA_BUILDER_ENTRY_NONE100;trace="";
  if(!d.loaded){reason="DEFINITION NOT LOADED";return false;}
  // Action-oriented generic grammar: each SIGNAL terminates its preceding clause.
  int start=0;bool saw_action=false;
  for(int i=0;i<24;i++)
  {
   string p=d.part[i]; if(p!="SIGNAL BUY"&&p!="SIGNAL SELL")continue;
   saw_action=true;bool pass=false;string why="";
   if(!EvalClause(d,start,i-1,x,pass,why)){reason="slot "+IntegerToString(i+1)+": "+why;return false;}
   trace+=(trace==""?"":" | ")+p+"="+(pass?"TRUE":"FALSE");
   if(pass){action=(p=="SIGNAL BUY"?MA_BUILDER_ENTRY_BUY100:MA_BUILDER_ENTRY_SELL100);reason="VALID";return true;}
   start=i+1;
   // Optional OR immediately after an action separates action clauses.
   if(start<24&&d.part[start]=="OR")start++;
  }
  if(!saw_action){reason="ENTRY ACTION (SIGNAL BUY/SELL) REQUIRED";return false;}
  reason="VALID";return true;
 }
};
#endif
