#property strict
#include "../../../Include/Builder/MultiAlpha_Saved_Grid_Lamp100_v1_00.mqh"
int OnInit()
{
 CMultiAlphaModuleLibraryStore101 store;
 string reason="";
 bool ok=(MASavedGridLamp100(store,100,reason)==MA_SAVED_OFF100);
 Print("[MA_GRID_LAMP100_CASE] UNSAVED_OFF ",ok?"PASS":"FAIL");
 return INIT_SUCCEEDED;
}
void OnTick(){}
