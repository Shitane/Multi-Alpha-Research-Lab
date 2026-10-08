#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Logic_Lamp_v1_01.mqh"
int failed=0;
void Check(const string name,const int got,const int expected)
{
 bool pass=got==expected;
 Print("[MA_LAMP2I_CASE] ",name," ",pass?"PASS":"FAIL"," actual=",got," expected=",expected);
 if(!pass)failed++;
}
int OnInit()
{
 string p[],v[],reason="";
 ArrayResize(p,40);ArrayResize(v,40);
 for(int i=0;i<40;i++){p[i]="EMPTY";v[i]="";}
 Check("UNSAVED_OFF",(int)MA101RoleLamp(1,false,p,v,reason),(int)MA_LAMP_OFF101);
 Check("SAVED_EMPTY_RED",(int)MA101RoleLamp(1,true,p,v,reason),(int)MA_LAMP_RED101);
 p[0]="GRID_OFF";
 Check("GRID_OFF_ORANGE",(int)MA101RoleLamp(1,true,p,v,reason),(int)MA_LAMP_ORANGE101);
 Check("EA_ALL_VALID_GRID_OFF_ORANGE",(int)MA101EASlotLamp(MA_LAMP_GREEN101,MA_LAMP_ORANGE101,MA_LAMP_GREEN101,MA_LAMP_GREEN101),(int)MA_LAMP_ORANGE101);
 Check("EA_ALL_VALID_GRID_ON_GREEN",(int)MA101EASlotLamp(MA_LAMP_GREEN101,MA_LAMP_GREEN101,MA_LAMP_GREEN101,MA_LAMP_GREEN101),(int)MA_LAMP_GREEN101);
 Check("EA_INVALID_EXIT_RED",(int)MA101EASlotLamp(MA_LAMP_GREEN101,MA_LAMP_ORANGE101,MA_LAMP_GREEN101,MA_LAMP_RED101),(int)MA_LAMP_RED101);
 p[1]="ADD_BUY";
 Check("GRID_OFF_CONFLICT_RED",(int)MA101RoleLamp(1,true,p,v,reason),(int)MA_LAMP_RED101);
 p[0]="GRID_ON";p[1]="EMPTY";
 Check("GRID_ON_ONLY_RED",(int)MA101RoleLamp(1,true,p,v,reason),(int)MA_LAMP_RED101);
 if(failed==0)Print("[MA_LAMP2I_PASS] modes=PASS aggregate=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_LAMP2I_FAIL] failed=",failed);
 return INIT_SUCCEEDED;
}
void OnTick(){}
