#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_Grid_Lamp100_v1_00.mqh"
int failures=0;
void Check(string n,bool ok)
{
 Print("[MA_GRID_LAMP100_CASE] ",n," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
int OnInit()
{
 CMultiAlphaEASlotStore100 ea;
 CMultiAlphaModuleLibraryStore101 logic;
 string why="",p[],v[];
 int refs[4]={1,100,1,1};
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 Check("UNSAVED_OFF",MASavedGridLamp100(logic,100,why)==MA_SAVED_OFF100);
 Check("INVALID_REF_RED",MASavedGridLamp100(logic,101,why)==MA_SAVED_RED100);
 p[99]="GRID_OFF";
 Check("SAVE_GRID_OFF",logic.SaveDefinition(1,99,"NO_GRID",p,v,true));
 Check("GRID_ORANGE",MASavedGridLamp100(logic,100,why)==MA_SAVED_ORANGE100);
 Check("EA_UNSAVED",MASavedEASlotGridPreview100(ea,logic,100,why)==MA_SAVED_OFF100);
 Check("EA_SAVE",ea.Save(100,"EA100",refs,true));
 Check("EA_PREVIEW_ORANGE",MASavedEASlotGridPreview100(ea,logic,100,why)==MA_SAVED_ORANGE100);
 Check("NOT_RUNNABLE",!MASavedEASlotRunnableCertified100(ea,logic,100,why));
 p[0]="GRID_ON";
 Check("SAVE_CONFLICT",logic.SaveDefinition(1,99,"BAD",p,v,true));
 Check("CONFLICT_RED",MASavedGridLamp100(logic,100,why)==MA_SAVED_RED100);
 Check("EA_CONFLICT_RED",MASavedEASlotGridPreview100(ea,logic,100,why)==MA_SAVED_RED100);
 p[0]="EMPTY";
 Check("SAVE_DISABLED",logic.SaveDefinition(1,99,"DISABLED",p,v,false));
 Check("DISABLED_RED",MASavedGridLamp100(logic,100,why)==MA_SAVED_RED100);
 Check("EA_OFF_SAVE",ea.Save(100,"OFF",refs,false));
 Check("EA_OFF_LAMP",MASavedEASlotGridPreview100(ea,logic,100,why)==MA_SAVED_OFF100);
 if(failures==0)Print("[MA_GRID_LAMP100_PASS] cases=15 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_GRID_LAMP100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
