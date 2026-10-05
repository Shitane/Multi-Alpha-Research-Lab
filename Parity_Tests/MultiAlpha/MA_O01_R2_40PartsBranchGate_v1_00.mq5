//+------------------------------------------------------------------+
//| MA_O01_R2_40PartsBranchGate_v1_00.mq5                           |
//| Actual O01 ENTRY seed -> 40 Parts -> branch map/evaluation.      |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#property strict
#include <Builder\\MultiAlpha_Builder_Interpreter_v1_03.mqh>

void Seed(string &p[])
{
 ArrayResize(p,40);for(int i=0;i<40;i++)p[i]="EMPTY";
 string x[19]={"CYCLE_NEW","AND","FILTERS_OK","AND","SIDE_COUNT","AND","RSI_THRESHOLD","AND","BUY","OR",
               "CYCLE_NEW","AND","FILTERS_OK","AND","SIDE_COUNT","AND","RSI_THRESHOLD","AND","SELL"};
 for(int i=0;i<19;i++)p[i]=x[i];
}
bool Run(CMultiAlphaBuilderInterpreter103 &z,string &p[],bool common,bool buyZero,bool buyRsi,bool sellZero,bool sellRsi,bool eb,bool es)
{
 bool v[];ArrayResize(v,40);for(int i=0;i<40;i++)v[i]=false;
 // BUY branch condition slots: 1,3,5,7 in human numbering.
 v[0]=common;v[2]=common;v[4]=buyZero;v[6]=buyRsi;
 // SELL branch condition slots: 11,13,15,17.
 v[10]=common;v[12]=common;v[14]=sellZero;v[16]=sellRsi;
 bool b=false,s=false;string tr="",why="";
 bool ok=z.EvaluateEntry40(p,v,b,s,tr,why);
 bool pass=ok&&b==eb&&s==es;
 Print("[O01_R2_40P_BRANCH_CASE] trace=",tr," expectBuy=",(int)eb," expectSell=",(int)es," result=",(pass?"PASS":"FAIL")," reason=",why);
 return pass;
}
int OnInit()
{
 CMultiAlphaBuilderInterpreter103 z;string p[];Seed(p);int map[],act[],bc=0;string why="";
 bool structure=z.BuildEntryBranchMap(p,map,act,bc,why);
 bool shape=structure&&bc==2&&ArraySize(act)==2&&act[0]==MA_BRANCH_ACTION_BUY103&&act[1]==MA_BRANCH_ACTION_SELL103;
 Print("[O01_R2_40P_BRANCH_MAP] branches=",bc," action0=",(ArraySize(act)>0?act[0]:0)," action1=",(ArraySize(act)>1?act[1]:0)," result=",(shape?"PASS":"FAIL")," reason=",why);
 bool ok=shape;
 ok&=Run(z,p,true,true,true,true,false,true,false);
 ok&=Run(z,p,true,true,false,true,true,false,true);
 ok&=Run(z,p,true,true,true,true,true,true,true);
 ok&=Run(z,p,false,true,true,true,true,false,false);
 ok&=Run(z,p,true,false,true,false,true,false,false);
 Print("[O01_R2_40P_BRANCH_GATE] interpreter=",MA_BUILDER_INTERPRETER_103_VERSION,
       " source=REF_O01_GENERIC_ENTRY_40P result=",(ok?"PASS":"FAIL")," NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
