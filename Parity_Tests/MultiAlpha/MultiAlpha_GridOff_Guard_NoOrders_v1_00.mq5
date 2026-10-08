#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Logic_Validity_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_Grid_Off_Gate_v1_00.mqh"
int failed=0;
void TestGate(const string name,const bool got,const bool want){bool ok=got==want;Print("[MA_GRIDOFF2I_CASE] ",name," ",ok?"PASS":"FAIL");if(!ok)failed++;}
int OnInit()
{
 string p[],v[],reason="";ArrayResize(p,40);ArrayResize(v,40);
 for(int i=0;i<40;i++){p[i]="EMPTY";v[i]="";}
 p[0]="GRID_OFF";
 bool valid=MAValidityRole100(1,true,p,v,reason);
 TestGate("GRID_OFF_VALID",valid,true);
 TestGate("GRID_OFF_DENIES_ADD",MAGridDecisionGuard100(valid,p,true,reason),false);
 TestGate("GRID_OFF_DENIES_NO_SIGNAL",MAGridDecisionGuard100(valid,p,false,reason),false);
 p[0]="GRID_ON";
 bool onvalid=MAValidityRole100(1,true,p,v,reason);
 TestGate("GRID_ON_ONLY_INVALID",onvalid,false);
 TestGate("INVALID_DENIES_ADD",MAGridDecisionGuard100(onvalid,p,true,reason),false);
 TestGate("NO_SIGNAL_DENIED",MAGridDecisionGuard100(true,p,false,reason),false);
 TestGate("VALID_SIGNAL_ALLOWED",MAGridDecisionGuard100(true,p,true,reason),true);
 TestGate("EA_FOUR_ROLES_VALID",MAValidityEASlot100(true,true,true,true),true);
 TestGate("EA_MISSING_MANAGE",MAValidityEASlot100(true,true,false,true),false);
 if(failed==0)Print("[MA_GRIDOFF2I_PASS] guard=PASS aggregate=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_GRIDOFF2I_FAIL] count=",failed);
 return INIT_SUCCEEDED;
}
void OnTick(){}
