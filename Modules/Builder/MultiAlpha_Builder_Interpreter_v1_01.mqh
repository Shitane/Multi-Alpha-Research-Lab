//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Interpreter_v1_01.mqh                         |
//| Parse/validate/evaluate ordered Builder expressions.              |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_INTERPRETER_V1_01_MQH
#define MULTIALPHA_BUILDER_INTERPRETER_V1_01_MQH
#define MA_BUILDER_INTERPRETER_VERSION "1.01"
class CMultiAlphaBuilderInterpreter101{
 bool IsLogic(const string p){return p=="AND"||p=="OR";}
 bool IsOperand(const string p){return p!=""&&p!="EMPTY"&&!IsLogic(p);}
public:
 bool Validate(const string &parts[],const string &params[],string &reason){
  int n=ArraySize(parts),used=0;bool expect_operand=true;
  for(int i=0;i<n;i++){string p=parts[i];if(p==""||p=="EMPTY")continue;used++;
   if(expect_operand){if(IsLogic(p)){reason="slot "+IntegerToString(i+1)+": expected condition/part, got "+p;return false;}expect_operand=false;}
   else{if(!IsLogic(p)){reason="slot "+IntegerToString(i+1)+": expected AND/OR, got "+p;return false;}expect_operand=true;}}
  if(used==0){reason="definition is empty";return false;}if(expect_operand){reason="definition ends with AND/OR";return false;}reason="VALID";return true;}
 string Expression(const string &parts[],const string &params[]){string out="";for(int i=0;i<ArraySize(parts);i++){string p=parts[i];if(p==""||p=="EMPTY")continue;if(out!="")out+=" ";out+=p;if(i<ArraySize(params)&&params[i]!="")out+="("+params[i]+")";}return out;}
 string Param(const string par,const string key,const string def=""){string a[];int n=StringSplit(par,';',a);for(int i=0;i<n;i++){int q=StringFind(a[i],"=");if(q>0&&StringSubstr(a[i],0,q)==key)return StringSubstr(a[i],q+1);}return def;}
 bool EvaluateBooleans(const string &parts[],const bool &values[],bool &result,string &trace,string &reason){
  string dummy[];ArrayResize(dummy,ArraySize(parts));if(!Validate(parts,dummy,reason))return false;
  bool have=false,acc=false;string op="";trace="";
  for(int i=0;i<ArraySize(parts);i++){string p=parts[i];if(p==""||p=="EMPTY")continue;if(IsLogic(p)){op=p;trace+=" "+p+" ";continue;}
   bool v=(i<ArraySize(values)?values[i]:false);trace+=p+"="+(v?"TRUE":"FALSE");
   if(!have){acc=v;have=true;}else if(op=="AND")acc=acc&&v;else if(op=="OR")acc=acc||v;else{reason="missing operator before slot "+IntegerToString(i+1);return false;}}
  result=acc;reason="VALID";trace+=" => "+(result?"TRUE":"FALSE");return true;}
};
#endif
