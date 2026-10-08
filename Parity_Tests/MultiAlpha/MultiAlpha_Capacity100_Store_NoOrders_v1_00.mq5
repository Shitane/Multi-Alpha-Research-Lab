#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Module_Library_Store_v1_01.mqh"
int failures=0;
void Check(const string label,const bool actual,const bool expected)
{
 bool pass=(actual==expected);
 Print("[MA_CAP100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string p[],v[],name="",outP[],outV[];bool enabled=false;
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[0]="FIRST";p[39]="FORTIETH";p[40]="FORTY_FIRST";p[99]="HUNDREDTH";v[99]="TEST=100";
 Check("SAVE_SLOT_100",store.SaveDefinition(3,99,"EXIT100",p,v,true),true);
 Check("LOAD_SLOT_100",store.LoadDefinition(3,99,name,outP,outV,enabled),true);
 Check("PART_BOUNDARIES",ArraySize(outP)==100&&outP[0]=="FIRST"&&outP[39]=="FORTIETH"&&outP[40]=="FORTY_FIRST"&&outP[99]=="HUNDREDTH"&&outV[99]=="TEST=100",true);
 Check("META_PRESERVED",name=="EXIT100"&&enabled,true);
 Check("ROLE_ISOLATED",store.IsSaved(2,99),false);
 Check("SLOT_101_REJECTED",store.SaveDefinition(3,100,"BAD",p,v,true),false);
 Check("SLOT_ZERO_INDEX_VALID",store.SaveDefinition(0,0,"ENTRY1",p,v,false),true);
 Check("WRONG_ROLE_REJECTED",store.SaveDefinition(4,0,"BAD",p,v,true),false);
 string oldP[],oldV[];ArrayResize(oldP,40);ArrayResize(oldV,40);
 for(int i=0;i<40;i++){oldP[i]="EMPTY";oldV[i]="";}
 oldP[0]="RSI_THRESHOLD";oldP[39]="BUY";oldV[0]="PERIOD=8;COND=LT;LEVEL=30";
 Check("IMPORT_40",store.ImportLegacy40(0,50,"LEGACY51",oldP,oldV,false),true);
 Check("LOAD_IMPORT",store.LoadDefinition(0,50,name,outP,outV,enabled),true);
 bool preserved=(name=="LEGACY51"&&!enabled&&outP[0]=="RSI_THRESHOLD"&&outP[39]=="BUY"&&outV[0]==oldV[0]);
 for(int i=40;i<100;i++)if(outP[i]!="EMPTY"||outV[i]!="")preserved=false;
 Check("LEGACY_40_PLUS_EMPTY_60",preserved,true);
 Check("ROLE_SLOT_INDEPENDENT",store.IsSaved(3,50),false);
 Check("REJECT_40_DIRECT_SAVE",store.SaveDefinition(1,0,"SHORT",oldP,oldV,true),false);
 if(failures==0)Print("[MA_CAP100_PASS] role_slots=100 parts=100 legacy_import=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_CAP100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
