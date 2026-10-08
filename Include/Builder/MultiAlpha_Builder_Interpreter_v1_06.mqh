#ifndef MULTIALPHA_BUILDER_INTERPRETER_V1_06_MQH
#define MULTIALPHA_BUILDER_INTERPRETER_V1_06_MQH
#include "MultiAlpha_Capacity_v1_00.mqh"
#include "MultiAlpha_Builder_Interpreter_v1_02.mqh"
// Ordered 100-Part ENTRY branches. No broker actions.
class CMultiAlphaBuilderInterpreter106
{
 CMultiAlphaBuilderInterpreter102 m_base;
 bool Empty(const string p){return p==""||p=="EMPTY";}
 bool Action(const string p){return p=="BUY"||p=="SELL"||p=="SIGNAL BUY"||p=="SIGNAL SELL";}
 int ActionValue(const string p){return (p=="BUY"||p=="SIGNAL BUY")?1:-1;}
public:
 bool BuildEntryBranchMap(const string &parts[],int &branch_of_slot[],int &branch_action[],int &branch_count,string &reason)
 {
  branch_count=0;ArrayResize(branch_of_slot,0);ArrayResize(branch_action,0);
  if(ArraySize(parts)!=MA_CAP_PARTS_PER_LOGIC){reason="PART_COUNT_100_REQUIRED";return false;}
  ArrayResize(branch_of_slot,MA_CAP_PARTS_PER_LOGIC);
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)branch_of_slot[i]=-1;
  int actions[];ArrayResize(actions,MA_CAP_PARTS_PER_LOGIC);
  bool have_condition=false,have_action=false,need_new=false;int current=0;
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
  {
   string p=parts[i];if(Empty(p))continue;
   if(p=="AND")
   {
    if(!have_condition||have_action){reason="slot "+IntegerToString(i+1)+": misplaced AND";return false;}
    continue;
   }
   if(p=="OR")
   {
    if(!have_action){reason="slot "+IntegerToString(i+1)+": OR requires completed action branch";return false;}
    branch_count++;current=branch_count;
    if(current>=MA_CAP_PARTS_PER_LOGIC){reason="BRANCH_OVERFLOW";return false;}
    have_condition=false;have_action=false;need_new=false;continue;
   }
   if(Action(p))
   {
    if(!have_condition||have_action){reason="slot "+IntegerToString(i+1)+": action without condition or duplicate action";return false;}
    actions[current]=ActionValue(p);have_action=true;need_new=true;continue;
   }
   if(need_new){reason="slot "+IntegerToString(i+1)+": OR required after action";return false;}
   branch_of_slot[i]=current;have_condition=true;
  }
  if(!have_action){reason="definition must end with BUY/SELL action";return false;}
  branch_count++;
  ArrayResize(branch_action,branch_count);
  for(int b=0;b<branch_count;b++)branch_action[b]=actions[b];
  reason="VALID";return true;
 }
 bool EvaluateEntry100(const string &parts[],const bool &condition_values[],
                       bool &outBuy,bool &outSell,string &trace,string &reason)
 {
  outBuy=false;outSell=false;trace="";
  if(ArraySize(condition_values)!=MA_CAP_PARTS_PER_LOGIC){reason="CONDITION_VALUE_SIZE";return false;}
  int map[],act[],bc=0;
  if(!BuildEntryBranchMap(parts,map,act,bc,reason))return false;
  bool result=false,branch[];string base_trace="";
  if(!m_base.EvaluateAndBranches(condition_values,map,bc,result,branch,base_trace,reason))return false;
  for(int b=0;b<bc;b++)if(branch[b])
  {
   if(act[b]==1)outBuy=true;
   if(act[b]==-1)outSell=true;
  }
  trace=base_trace+" BUY="+(outBuy?"TRUE":"FALSE")+" SELL="+(outSell?"TRUE":"FALSE");
  reason="VALID";return true;
 }
};
#endif
