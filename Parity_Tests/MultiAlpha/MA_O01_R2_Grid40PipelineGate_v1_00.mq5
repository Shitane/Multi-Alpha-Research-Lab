//+------------------------------------------------------------------+
//| MA_O01_R2_Grid40PipelineGate_v1_00.mq5                          |
//| P1-B: canonical GRID 40 Parts -> ordered runtime decision.       |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#property strict
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_01.mqh>
#include <Builder\MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh>

bool Run(CMultiAlphaBuilderGridInterpreter100 &z,string &p[],string &v[],int side,int failSlot,bool eb,bool es,string expectedStop)
{
 bool g[];ArrayResize(g,40);for(int i=0;i<40;i++)g[i]=true;
 if(failSlot>=0)g[failSlot]=false;
 bool b=false,s=false;string stop="",why="";
 bool parsed=z.Evaluate(p,v,g,side,b,s,stop,why);
 bool pass=parsed&&b==eb&&s==es&&stop==expectedStop;
 Print("[O01_R2_GRID40_CASE] side=",(side==1?"BUY":"SELL")," failSlot=",failSlot+1,
       " addBuy=",(int)b," addSell=",(int)s," stop=",stop," reason=",why," result=",(pass?"PASS":"FAIL"));
 return pass;
}
int OnInit()
{
 string allP[4][40],allV[4][40];MAO01LoadCanonical101(allP,allV);
 string p[],v[];ArrayResize(p,40);ArrayResize(v,40);
 for(int i=0;i<40;i++){p[i]=allP[1][i];v[i]=allV[1][i];}
 CMultiAlphaBuilderGridInterpreter100 z;string why="";
 bool ok=z.ValidatePlan(p,v,why);
 Print("[O01_R2_GRID40_PLAN] used=33 order=ManageSide result=",(ok?"PASS":"FAIL")," reason=",why);

 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,-1,true,false,"-");
 ok&=Run(z,p,v,MA_GRID_SIDE_SELL100,-1,false,true,"-");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,4,false,false,"DD_BELOW");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,6,false,false,"TRAILING_PAUSE");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,8,false,false,"GRID_TIME_ALLOWED");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,10,false,false,"GRID_NEWS_CLEAR");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,12,false,false,"SPREAD_OK");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,14,false,false,"ONE_ORDER_PER_BAR");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,22,false,false,"DISTANCE_REACHED");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,26,false,false,"MAX_LOT");
 ok&=Run(z,p,v,MA_GRID_SIDE_BUY100,28,false,false,"MAX_TOTAL_LOT");

 Print("[O01_R2_GRID40_GATE] seed=",MA_O01_CANONICAL_40P_101_VERSION,
       " interpreter=",MA_BUILDER_GRID_INTERPRETER_100_VERSION,
       " source=O01_MANAGESIDE result=",(ok?"PASS":"FAIL"),
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
