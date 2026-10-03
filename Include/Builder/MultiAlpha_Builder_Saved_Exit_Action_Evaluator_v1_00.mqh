//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Exit_Action_Evaluator_v1_00.mqh        |
//| Generic persisted EXIT definition -> O01-compatible decision.    |
//| Decision/state only. NO ORDERS / VIRTUAL NOT FILL.               |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_SAVED_EXIT_ACTION_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_SAVED_EXIT_ACTION_EVALUATOR_V1_00_MQH
#include "MultiAlpha_Builder_Saved_Definition_Route_v1_00.mqh"
#include "..\\O01\\O01_GSG_RSI30_Exit_Module_v1_00.mqh"
#define MA_BUILDER_SAVED_EXIT_ACTION_EVALUATOR_VERSION "1.00"
class CMultiAlphaBuilderSavedExitActionEvaluator100
{
private:
 CMultiAlphaBuilderInterpreter101 m_i;
 int IntNum(const string p,const string key,const int defv){return (int)StringToInteger(m_i.Param(p,key,IntegerToString(defv)));}
 bool BoolNum(const string p,const string key,const bool defv){return (StringToInteger(m_i.Param(p,key,(defv?"1":"0")))!=0);}
public:
 bool Evaluate(const SMA_BuilderSavedDefinition100 &d,const bool is_buy,const int count,const double move_pts,
               SO01TrailState &t,ENUM_O01_EXIT_DECISION &out,string &trace,string &reason)
 {
  out=O01_EXIT_NONE;trace="";
  if(!d.loaded){reason="DEFINITION NOT LOADED";return false;}
  SO01ExitConfig c={}; bool have_vsl=false,have_tp=false,have_single=false,have_basket=false,have_action=false;
  for(int i=0;i<24;i++)
  {
   string part=d.part[i],p=d.param[i];
   if(part==""||part=="EMPTY"||part=="AND"||part=="OR"||part=="POSITION_COUNT"||part=="MOVE_POINTS")continue;
   if(part=="VIRTUAL_SL"){c.sl_points=IntNum(p,"POINTS",1500);have_vsl=true;continue;}
   if(part=="FIXED_TP"){c.tp_points=IntNum(p,"POINTS",110);have_tp=true;continue;}
   if(part=="SINGLE_TRAIL"){c.trailing=BoolNum(p,"ENABLED",true);c.trail_start=IntNum(p,"START",80);c.trail_lock=IntNum(p,"LOCK",20);c.trail_distance=IntNum(p,"DISTANCE",40);c.trail_step=IntNum(p,"STEP",10);have_single=true;continue;}
   if(part=="BASKET_TRAIL"){have_basket=true;continue;}
   if(part=="CLOSE"||part=="CLOSE SIDE"){have_action=true;continue;}
   reason="UNSUPPORTED EXIT PART: "+part;return false;
  }
  if(!have_vsl||!have_tp||!have_single||!have_basket||!have_action){reason="EXIT REQUIRED PARTS MISSING";return false;}
  CO01ExitModule ref; out=ref.Evaluate(is_buy,count,move_pts,c,t);
  trace="EXIT decision="+IntegerToString((int)out);reason="VALID";return true;
 }
};
#endif
