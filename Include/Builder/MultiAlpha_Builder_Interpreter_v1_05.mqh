//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Interpreter_v1_03.mqh                         |
//| O01-R2 P0-2B: ordered 40 Parts -> explicit action branches.      |
//| Branch grammar: AND inside a branch, OR between branches.        |
//| BUY/SELL terminates ENTRY branch. NO ORDERS.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_INTERPRETER_V1_05_MQH
#define MULTIALPHA_BUILDER_INTERPRETER_V1_05_MQH
#include "MultiAlpha_Builder_Interpreter_v1_02.mqh"
#define MA_BUILDER_INTERPRETER_103_VERSION "1.03"
#define MA_BUILDER_INTERPRETER_103_SLOTS 40

enum ENUM_MA_BUILDER_BRANCH_ACTION103
{
 MA_BRANCH_ACTION_NONE103=0,
 MA_BRANCH_ACTION_BUY103=1,
 MA_BRANCH_ACTION_SELL103=-1
};

class CMultiAlphaBuilderInterpreter105
{
 CMultiAlphaBuilderInterpreter102 m_base;
 bool IsEmpty(const string p){return p==""||p=="EMPTY";}
 bool IsAction(const string p){return p=="BUY"||p=="SELL"||p=="SIGNAL BUY"||p=="SIGNAL SELL";}
 int ActionOf(const string p){return (p=="BUY"||p=="SIGNAL BUY")?MA_BRANCH_ACTION_BUY103:(p=="SELL"||p=="SIGNAL SELL")?MA_BRANCH_ACTION_SELL103:MA_BRANCH_ACTION_NONE103;}
public:
 // Converts an ordered 40-Part ENTRY definition into branch IDs for CONDITION slots.
 // AND remains inside the current branch. OR closes the previous action branch.
 bool BuildEntryBranchMap(const string &parts[],int &branch_of_slot[],int &branch_action[],int &branch_count,string &reason)
 {
  int n=ArraySize(parts);ArrayResize(branch_of_slot,n);for(int i=0;i<n;i++)branch_of_slot[i]=-1;
  int actions_tmp[];ArrayResize(actions_tmp,MA_BUILDER_INTERPRETER_103_SLOTS);
  branch_count=0;bool have_condition=false,have_action=false,need_new=false;int current=0;
  for(int i=0;i<n;i++)
  {
   string p=parts[i];if(IsEmpty(p))continue;
   if(p=="AND")
   {
    if(!have_condition||have_action){reason="slot "+IntegerToString(i+1)+": misplaced AND";return false;}
    continue;
   }
   if(p=="OR")
   {
    if(!have_action){reason="slot "+IntegerToString(i+1)+": OR requires completed action branch";return false;}
    branch_count++;current=branch_count;have_condition=false;have_action=false;need_new=false;continue;
   }
   if(IsAction(p))
   {
    if(!have_condition||have_action){reason="slot "+IntegerToString(i+1)+": action without condition or duplicate action";return false;}
    actions_tmp[current]=ActionOf(p);have_action=true;need_new=true;continue;
   }
   if(need_new){reason="slot "+IntegerToString(i+1)+": OR required after action";return false;}
   branch_of_slot[i]=current;have_condition=true;
  }
  if(!have_action){reason="definition must end with BUY/SELL action";return false;}
  branch_count++;
  ArrayResize(branch_action,branch_count);for(int b=0;b<branch_count;b++)branch_action[b]=actions_tmp[b];
  reason="VALID";return true;
 }

 bool EvaluateEntry40(const string &parts[],const bool &condition_values[],
                      bool &outBuy,bool &outSell,string &trace,string &reason)
 {
  outBuy=false;outSell=false;int map[],act[],bc=0;
  if(!BuildEntryBranchMap(parts,map,act,bc,reason))return false;
  if(ArraySize(condition_values)!=ArraySize(parts)){reason="CONDITION VALUE SIZE";return false;}
  bool vals[];int maps[];ArrayResize(vals,ArraySize(parts));ArrayResize(maps,ArraySize(parts));
  for(int i=0;i<ArraySize(parts);i++){vals[i]=condition_values[i];maps[i]=map[i];}
  bool any=false,br[];string base_trace="";
  if(!m_base.EvaluateAndBranches(vals,maps,bc,any,br,base_trace,reason))return false;
  for(int b=0;b<bc;b++)if(br[b]){if(act[b]==MA_BRANCH_ACTION_BUY103)outBuy=true;if(act[b]==MA_BRANCH_ACTION_SELL103)outSell=true;}
  trace=base_trace+" BUY="+(outBuy?"TRUE":"FALSE")+" SELL="+(outSell?"TRUE":"FALSE");
  reason="VALID";return true;
 }
};
#endif
