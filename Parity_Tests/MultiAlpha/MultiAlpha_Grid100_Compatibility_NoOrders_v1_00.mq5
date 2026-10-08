#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Grid100_Compatibility_Gate_v1_00.mqh"
int failures=0;
void Check(const string name,const bool actual,const bool expected)
{
 bool pass=actual==expected;
 Print("[MA_GRID100_CASE] ",name," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
void Reset(string &p[],string &v[],bool &g[])
{
 ArrayResize(p,100);ArrayResize(v,100);ArrayResize(g,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";g[i]=true;}
}
int OnInit()
{
 CMultiAlphaGrid100Gate interpreter;
 string p[],v[],reason="",stop="";bool g[],buy=false,sell=false;
 Reset(p,v,g);p[99]="GRID_OFF";
 Check("GRID_OFF_AT_PART100",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_OFF,true);
 Check("GRID_OFF_NO_ADD",interpreter.Evaluate(p,v,g,1,buy,sell,stop,reason)&&!buy&&!sell&&reason=="GRID_OFF_NO_ADDITIONS",true);
 Check("GRID_OFF_SELL_NO_ADD",interpreter.Evaluate(p,v,g,-1,buy,sell,stop,reason)&&!buy&&!sell,true);
 p[0]="ADD_BUY";
 Check("GRID_OFF_CONFLICT",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_INVALID,true);
 Reset(p,v,g);p[39]="GRID_OFF";p[40]="GRID_OFF";
 Check("GRID_OFF_DUPLICATE",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_INVALID,true);
 Reset(p,v,g);p[40]="ADD_BUY";
 Check("UNPROVEN_PART41_REJECT",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_INVALID,true);
 Reset(p,v,g);p[99]="GRID_OFF";v[99]="ENABLED=0";
 Check("GRID_OFF_PARAMS_REJECT",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_INVALID,true);
 Reset(p,v,g);v[99]="GHOST=1";
 Check("EMPTY_PARAMS_REJECT",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_INVALID,true);
 Reset(p,v,g);
 Check("EMPTY_GRID_REJECT",(int)interpreter.Validate(p,v,reason)==(int)MA_GRID100_INVALID,true);
 string shortP[],shortV[];ArrayResize(shortP,40);ArrayResize(shortV,40);
 Check("SHORT_40_REJECT",(int)interpreter.Validate(shortP,shortV,reason)==(int)MA_GRID100_INVALID,true);
 if(failures==0)Print("[MA_GRID100_PASS] grid_off=PASS fail_closed=PASS LEGACY_O01_RUNTIME_PARITY_PROVEN=0 GENERIC_GRID_RUNTIME_PROVEN=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_GRID100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
