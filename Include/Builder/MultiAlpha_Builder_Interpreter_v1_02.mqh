//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Interpreter_v1_02.mqh                         |
//| P0-2: grouped branch evaluator for ordered Builder definitions.  |
//| Flat v1_01 semantics are retained for legacy data only.          |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_INTERPRETER_V1_02_MQH
#define MULTIALPHA_BUILDER_INTERPRETER_V1_02_MQH
#define MA_BUILDER_INTERPRETER_VERSION "1.02"

class CMultiAlphaBuilderInterpreter102
{
 bool IsLogic(const string p){return p=="AND"||p=="OR";}
 bool IsOperand(const string p){return p!=""&&p!="EMPTY"&&!IsLogic(p);}
public:
 bool Validate(const string &parts[],const string &params[],string &reason)
 {
  int n=ArraySize(parts),used=0;bool expect_operand=true;
  for(int i=0;i<n;i++){string p=parts[i];if(p==""||p=="EMPTY")continue;used++;
   if(expect_operand){if(IsLogic(p)){reason="slot "+IntegerToString(i+1)+": expected condition/part, got "+p;return false;}expect_operand=false;}
   else{if(!IsLogic(p)){reason="slot "+IntegerToString(i+1)+": expected AND/OR, got "+p;return false;}expect_operand=true;}}
  if(used==0){reason="definition is empty";return false;}
  if(expect_operand){reason="definition ends with AND/OR";return false;}
  reason="VALID";return true;
 }
 string Expression(const string &parts[],const string &params[])
 {
  string out="";for(int i=0;i<ArraySize(parts);i++){string p=parts[i];if(p==""||p=="EMPTY")continue;if(out!="")out+=" ";out+=p;if(i<ArraySize(params)&&params[i]!="")out+="("+params[i]+")";}return out;
 }
 string Param(const string par,const string key,const string def="")
 {
  string a[];int n=StringSplit(par,';',a);for(int i=0;i<n;i++){int q=StringFind(a[i],"=");if(q>0&&StringSubstr(a[i],0,q)==key)return StringSubstr(a[i],q+1);}return def;
 }
 // Legacy flat evaluator. Do not use this to encode BUY/SELL branches.
 bool EvaluateBooleans(const string &parts[],const bool &values[],bool &result,string &trace,string &reason)
 {
  string dummy[];ArrayResize(dummy,ArraySize(parts));if(!Validate(parts,dummy,reason))return false;
  bool have=false,acc=false;string op="";trace="";
  for(int i=0;i<ArraySize(parts);i++){string p=parts[i];if(p==""||p=="EMPTY")continue;if(IsLogic(p)){op=p;trace+=" "+p+" ";continue;}
   bool v=(i<ArraySize(values)?values[i]:false);trace+=p+"="+(v?"TRUE":"FALSE");
   if(!have){acc=v;have=true;}else if(op=="AND")acc=acc&&v;else if(op=="OR")acc=acc||v;else{reason="missing operator before slot "+IntegerToString(i+1);return false;}}
  result=acc;reason="VALID";trace+=" => "+(result?"TRUE":"FALSE");return true;
 }
 // Canonical P0-2 primitive: each branch is an AND group; branch outputs are OR.
 bool EvaluateAndBranches(const bool &values[],const int &branch_of_slot[],const int branch_count,
                          bool &result,bool &branch_result[],string &trace,string &reason)
 {
  result=false;trace="";
  if(branch_count<1){reason="BRANCH COUNT";return false;}
  if(ArraySize(values)!=ArraySize(branch_of_slot)){reason="BRANCH MAP SIZE";return false;}
  ArrayResize(branch_result,branch_count);int used[];ArrayResize(used,branch_count);
  for(int b=0;b<branch_count;b++){branch_result[b]=true;used[b]=0;}
  for(int i=0;i<ArraySize(values);i++)
  {
   int b=branch_of_slot[i];if(b<0)continue;
   if(b>=branch_count){reason="BRANCH RANGE slot "+IntegerToString(i+1);return false;}
   branch_result[b]=branch_result[b]&&values[i];used[b]++;
  }
  for(int b=0;b<branch_count;b++)
  {
   if(used[b]==0){reason="EMPTY BRANCH "+IntegerToString(b);return false;}
   if(b>0)trace+=" OR ";
   trace+="B"+IntegerToString(b)+"="+(branch_result[b]?"TRUE":"FALSE");
   result=result||branch_result[b];
  }
  reason="VALID";trace+=" => "+(result?"TRUE":"FALSE");return true;
 }
};
#endif
