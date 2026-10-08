// B-P0-2H headless LOGIC SLOT validity test. NO ORDERS.
#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Logic_Validity_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_Module_Library_Store_v1_00.mqh"
int g_failed=0;
void Verify100(const string label,const bool actual,const bool expected)
{
 bool pass=(actual==expected);
 Print("[MA_VALID100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(actual?1:0)," expected=",(expected?1:0));
 if(!pass)g_failed++;
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore100 store;
 string parts[],params[],reason="",name="";
 bool enabled=false;
 ArrayResize(parts,40);ArrayResize(params,40);
 for(int i=0;i<40;i++){parts[i]="EMPTY";params[i]="";}
 Verify100("UNSAVED_OFF",MAValidityState100(1,false,parts,params,reason)==MA_LOGIC_EMPTY100,true);
 Verify100("SAVED_EMPTY_INVALID",MAValidityState100(1,true,parts,params,reason)==MA_LOGIC_INVALID100,true);
 parts[0]="GRID_OFF";
 Verify100("GRID_OFF_VALID",MAValidityState100(1,true,parts,params,reason)==MA_LOGIC_VALID100,true);
 Verify100("STORE_GRID_OFF",store.SaveDefinition(1,0,"No Grid",parts,params,false),true);
 string readparts[],readparams[];
 bool loaded=store.LoadDefinition(1,0,name,readparts,readparams,enabled);
 Verify100("LOAD_GRID_OFF",loaded&&name=="No Grid"&&readparts[0]=="GRID_OFF"&&!enabled,true);
 Verify100("RELOADED_GRID_OFF_VALID",MAValidityState100(1,loaded,readparts,readparams,reason)==MA_LOGIC_VALID100,true);
 parts[0]="GRID_ON";
 Verify100("GRID_ON_ALONE_INVALID",MAValidityState100(1,true,parts,params,reason)==MA_LOGIC_INVALID100,true);
 Verify100("EA_FOUR_VALID",MAValidityEASlot100(true,true,true,true),true);
 Verify100("EA_ONE_INVALID",MAValidityEASlot100(true,true,false,true),false);
 bool ea_enabled=false;
 Verify100("EA_DISABLED_BUT_VALID",!ea_enabled&&MAValidityEASlot100(true,true,true,true),true);
 if(g_failed==0)Print("[MA_VALID100_PASS] grid_off=PASS states=PASS memory_roundtrip=PASS aggregate=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_VALID100_FAIL] failed=",g_failed," NO_ORDERS=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
