#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Builder_Interpreter_v1_05.mqh"
#include "../../../Include/Builder/MultiAlpha_Builder_Interpreter_v1_06.mqh"
int failures=0;
void Check(const string label,const bool got,const bool expected)
{
 bool pass=got==expected;
 Print("[MA_ENTRY100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)got," expected=",(int)expected);
 if(!pass)failures++;
}
void Reset(string &p[],bool &v[],const int n)
{
 ArrayResize(p,n);ArrayResize(v,n);
 for(int i=0;i<n;i++){p[i]="EMPTY";v[i]=false;}
}
int OnInit()
{
 CMultiAlphaBuilderInterpreter105 oldI;
 CMultiAlphaBuilderInterpreter106 newI;
 string p40[],p100[],reason="",trace="";bool v40[],v100[],buy=false,sell=false;
 Reset(p40,v40,40);Reset(p100,v100,100);
 p40[0]="RSI";p40[1]="AND";p40[2]="ATR";p40[3]="BUY";p40[4]="OR";p40[5]="RSI";p40[6]="SELL";
 for(int i=0;i<40;i++){p100[i]=p40[i];v100[i]=v40[i];}
 v40[0]=true;v40[2]=true;v40[5]=false;
 for(int i=0;i<40;i++)v100[i]=v40[i];
 bool ob=false,os=false,nb=false,ns=false;string ot="",nt="",orr="",nrr="";
 bool oldOK=oldI.EvaluateEntry40(p40,v40,ob,os,ot,orr);
 bool newOK=newI.EvaluateEntry100(p100,v100,nb,ns,nt,nrr);
 Check("LEGACY_40_EVALUATES",oldOK,true);
 Check("EXTENDED_100_EVALUATES",newOK,true);
 Check("LEGACY_40_TO_100_PARITY",oldOK&&newOK&&ob==nb&&os==ns&&ot==nt,true);
 v40[0]=false;v40[5]=true;
 for(int i=0;i<40;i++)v100[i]=v40[i];
 oldOK=oldI.EvaluateEntry40(p40,v40,ob,os,ot,orr);
 newOK=newI.EvaluateEntry100(p100,v100,nb,ns,nt,nrr);
 Check("SELL_BRANCH_PARITY",oldOK&&newOK&&ob==nb&&os==ns&&ot==nt,true);
 Reset(p100,v100,100);
 p100[97]="RSI";p100[98]="AND";p100[99]="BUY";v100[97]=true;
 Check("PART_100_ACTION",newI.EvaluateEntry100(p100,v100,buy,sell,trace,reason)&&buy&&!sell,true);
 Reset(p100,v100,100);
 p100[98]="RSI";p100[99]="SELL";v100[98]=true;
 Check("PART_100_SELL",newI.EvaluateEntry100(p100,v100,buy,sell,trace,reason)&&!buy&&sell,true);
 Reset(p100,v100,100);
 p100[38]="RSI";p100[39]="BUY";p100[40]="OR";p100[41]="ATR";p100[42]="SELL";v100[38]=true;v100[41]=true;
 Check("CROSS_40_41_BOUNDARY",newI.EvaluateEntry100(p100,v100,buy,sell,trace,reason)&&buy&&sell,true);
 Reset(p100,v100,100);
 p100[98]="RSI";p100[99]="OR";
 Check("TRAILING_OR_REJECT",newI.EvaluateEntry100(p100,v100,buy,sell,trace,reason),false);
 Reset(p100,v100,100);
 p100[99]="BUY";
 Check("ACTION_ONLY_REJECT",newI.EvaluateEntry100(p100,v100,buy,sell,trace,reason),false);
 string shortP[];bool shortV[];Reset(shortP,shortV,40);
 Check("SHORT_40_REJECT",newI.EvaluateEntry100(shortP,shortV,buy,sell,trace,reason),false);
 if(failures==0)Print("[MA_ENTRY100_PASS] legacy_parity=PASS part100=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ENTRY100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
