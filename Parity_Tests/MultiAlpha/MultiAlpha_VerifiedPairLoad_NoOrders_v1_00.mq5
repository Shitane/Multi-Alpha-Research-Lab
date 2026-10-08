#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Verified_Pair_Load_v1_00.mqh"
int failures=0;
void Check(const string name,const bool actual,const bool expected)
{
 bool pass=actual==expected;
 Print("[MA_VERIFIED_LOAD_CASE] ",name," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
int OnInit()
{
 string ef="MA_VLoad_EA.tsv",lf="MA_VLoad_Logic.bin",mf="MA_VLoad_Manifest.tsv",why="";
 CMultiAlphaEASlotStore100 sourceEA,destEA;
 CMultiAlphaModuleLibraryStore101 sourceLogic,destLogic;
 CMultiAlphaEASlotDisk100 ed;CMultiAlphaLogicDisk100 ld;
 CMultiAlphaSnapshotManifest100 manifest;
 CMultiAlphaVerifiedPairLoad100 loader;
 int refs[4]={1,51,60,100};
 string parts[],values[];
 ArrayResize(parts,100);ArrayResize(values,100);
 for(int i=0;i<100;i++){parts[i]="EMPTY";values[i]="";}
 parts[99]="GRID_OFF";
 Check("SOURCE_EA",sourceEA.Save(100,"SOURCE",refs,true),true);
 Check("SOURCE_GRID",sourceLogic.SaveDefinition(1,99,"NO_GRID",parts,values,true),true);
 Check("DISK_EA",ed.Save(ef,sourceEA,why),true);
 Check("DISK_LOGIC",ld.Save(lf,sourceLogic,why),true);
 Check("MANIFEST",manifest.Write(mf,"GEN1",ef,lf,why),true);
 Check("DEST_SENTINEL",destEA.Save(100,"SENTINEL",refs,false),true);
 Check("WRONG_GEN_REJECT",loader.Load(mf,"GEN2",ef,lf,destEA,destLogic,why),false);
 string name="";int loaded[];bool enabled=false;
 Check("WRONG_GEN_PRESERVES",destEA.Load(100,name,loaded,enabled)&&name=="SENTINEL"&&!enabled,true);
 Check("VALID_LOAD",loader.Load(mf,"GEN1",ef,lf,destEA,destLogic,why),true);
 Check("VALID_EA_REPLACED",destEA.Load(100,name,loaded,enabled)&&name=="SOURCE"&&enabled,true);
 string ln="",lp[],lv[];bool le=false;
 Check("VALID_GRID_RESTORED",destLogic.LoadDefinition(1,99,ln,lp,lv,le)&&le&&lp[99]=="GRID_OFF",true);
 // Overwrite only EA file without updating manifest. Both destinations must remain unchanged.
 Check("SOURCE_EA_CHANGE",sourceEA.Save(100,"CHANGED",refs,true),true);
 Check("STALE_DISK_WRITE",ed.Save(ef,sourceEA,why),true);
 Check("STALE_REJECT",loader.Load(mf,"GEN1",ef,lf,destEA,destLogic,why),false);
 Check("STALE_PRESERVES_BOTH",destEA.Load(100,name,loaded,enabled)&&name=="SOURCE"&&destLogic.LoadDefinition(1,99,ln,lp,lv,le)&&lp[99]=="GRID_OFF",true);
 FileDelete(mf);
 Check("MISSING_MANIFEST_REJECT",loader.Load(mf,"GEN1",ef,lf,destEA,destLogic,why),false);
 Check("MISSING_PRESERVES",destEA.Load(100,name,loaded,enabled)&&name=="SOURCE",true);
 FileDelete(ef);FileDelete(lf);FileDelete(ef+".tmp");FileDelete(lf+".tmp");FileDelete(mf+".tmp");
 if(failures==0)Print("[MA_VERIFIED_LOAD_PASS] verify_before_load=PASS reject_preserves_destinations=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_VERIFIED_LOAD_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
