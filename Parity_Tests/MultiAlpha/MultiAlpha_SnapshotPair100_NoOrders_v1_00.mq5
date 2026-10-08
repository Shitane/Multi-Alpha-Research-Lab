#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_EASlot_Disk_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_LogicSlot_Disk_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_Snapshot_Manifest_v1_00.mqh"
int failures=0;
void Check(const string name,const bool actual,const bool expected)
{
 bool pass=actual==expected;
 Print("[MA_PAIR100_CASE] ",name," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
int OnInit()
{
 string ef="MA_Pair100_EA_test.tsv",lf="MA_Pair100_Logic_test.bin",mf="MA_Pair100_manifest.tsv",reason="";
 CMultiAlphaEASlotStore100 ea;
 CMultiAlphaModuleLibraryStore101 logic;
 CMultiAlphaEASlotDisk100 ed;
 CMultiAlphaLogicDisk100 ld;
 CMultiAlphaSnapshotManifest100 gate;
 int refs[4]={1,51,60,100};
 string p[],v[];
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[99]="GRID_OFF";
 Check("EA_SETUP",ea.Save(100,"EA100",refs,true),true);
 Check("LOGIC_SETUP",logic.SaveDefinition(1,50,"GRID",p,v,true),true);
 Check("EA_SNAPSHOT_WRITE",ed.Save(ef,ea,reason),true);
 Check("LOGIC_SNAPSHOT_WRITE",ld.Save(lf,logic,reason),true);
 Check("MANIFEST_WRITE_G1",gate.Write(mf,"G1",ef,lf,reason),true);
 Check("PAIR_G1_VALID",gate.Verify(mf,"G1",ef,lf,reason),true);
 Check("WRONG_GENERATION_REJECT",gate.Verify(mf,"G2",ef,lf,reason),false);
 // Same-length overwrite simulates a stale/cross-generation EA snapshot.
 Check("EA_CHANGE",ea.Save(100,"EA101",refs,true),true);
 Check("EA_REWRITE",ed.Save(ef,ea,reason),true);
 Check("STALE_EA_REJECT",gate.Verify(mf,"G1",ef,lf,reason),false);
 Check("MANIFEST_WRITE_G2",gate.Write(mf,"G2",ef,lf,reason),true);
 Check("PAIR_G2_VALID",gate.Verify(mf,"G2",ef,lf,reason),true);
 int h=FileOpen(lf,FILE_READ|FILE_WRITE|FILE_BIN);
 bool mutated=h!=INVALID_HANDLE;
 if(mutated)
 {
  FileSeek(h,0,SEEK_SET);
  int old=FileReadInteger(h,CHAR_VALUE)&255;
  FileSeek(h,0,SEEK_SET);
  FileWriteInteger(h,(old^1),CHAR_VALUE);
  FileClose(h);
 }
 Check("BITFLIP_FIXTURE",mutated,true);
 Check("BITFLIP_REJECT",gate.Verify(mf,"G2",ef,lf,reason),false);
 FileDelete(mf);
 Check("MISSING_MANIFEST_REJECT",gate.Verify(mf,"G2",ef,lf,reason),false);
 FileDelete(ef);FileDelete(ef+".tmp");
 FileDelete(lf);FileDelete(lf+".tmp");
 FileDelete(mf+".tmp");
 if(failures==0)Print("[MA_PAIR100_PASS] generation_gate=PASS bitflip_detection=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_PAIR100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
