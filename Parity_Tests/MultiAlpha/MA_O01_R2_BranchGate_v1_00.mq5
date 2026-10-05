//+------------------------------------------------------------------+
//| MA_O01_R2_BranchGate_v1_00.mq5                                  |
//| P0-2 gate: (BUY conditions) OR (SELL conditions). NO ORDERS.     |
//+------------------------------------------------------------------+
#property strict
#include <Builder\\MultiAlpha_Builder_Interpreter_v1_02.mqh>

bool Case(CMultiAlphaBuilderInterpreter102 &x,const bool common,const bool buy0,const bool buyRsi,
          const bool sell0,const bool sellRsi,const bool expectBuy,const bool expectSell)
{
 bool v[6]={common,buy0,buyRsi,common,sell0,sellRsi};
 int b[6]={0,0,0,1,1,1};
 bool any=false,br[];string tr="",why="";
 bool ok=x.EvaluateAndBranches(v,b,2,any,br,tr,why);
 bool pass=ok&&ArraySize(br)==2&&br[0]==expectBuy&&br[1]==expectSell&&any==(expectBuy||expectSell);
 Print("[O01_R2_BRANCH_CASE] common=",(int)common," buy0=",(int)buy0," buyRsi=",(int)buyRsi,
       " sell0=",(int)sell0," sellRsi=",(int)sellRsi," trace=",tr," result=",(pass?"PASS":"FAIL"));
 return pass;
}
int OnInit()
{
 CMultiAlphaBuilderInterpreter102 x;bool ok=true;
 ok&=Case(x,true,true,true,true,false,true,false);   // BUY only
 ok&=Case(x,true,true,false,true,true,false,true);   // SELL only
 ok&=Case(x,true,true,true,true,true,true,true);     // both branches independently true
 ok&=Case(x,false,true,true,true,true,false,false);  // common gate blocks both
 ok&=Case(x,true,false,true,false,true,false,false); // side-count blocks both
 Print("[O01_R2_BRANCH_GATE] version=",MA_BUILDER_INTERPRETER_VERSION,
       " semantics=(BUY_AND_GROUP) OR (SELL_AND_GROUP) result=",(ok?"PASS":"FAIL")," NO_ORDERS=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
