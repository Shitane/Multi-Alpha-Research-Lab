#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_EASlot_Disk_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_LogicSlot_Disk_v1_00.mqh"
#include "../../../Include/Builder/MultiAlpha_Saved_Ref_Gate_v1_00.mqh"
int failures=0;
void Check(const string label,const bool actual,const bool expected)
{
 bool pass=actual==expected;
 Print("[MA_RESTORE_REF_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
void Parts(string &p[],string &v[],const string marker)
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[99]=marker;
}
int OnInit()
{
 string ef="MA_RestoreRef_EA_NoOrders_v1_00.tsv";
 string lf="MA_RestoreRef_Logic_NoOrders_v1_00.bin";
 string reason="",p[],v[],name="",outp[],outv[];
 bool enabled=false;
 int refs[4]={1,51,60,100};
 CMultiAlphaEASlotStore100 eaSrc,eaRestored;
 CMultiAlphaModuleLibraryStore101 logicSrc,logicRestored;
 CMultiAlphaEASlotDisk100 eaDisk;
 CMultiAlphaLogicDisk100 logicDisk;
 CMultiAlphaSavedRefGate100 gate;
 Check("EA100_SOURCE_SAVE",eaSrc.Save(100,"EA100",refs,true),true);
 for(int role=0;role<4;role++)
 {
  Parts(p,v,role==1?"GRID_OFF":"ROLE_TEST_MARKER");
  Check("ROLE_SOURCE_SAVE_"+IntegerToString(role),
        logicSrc.SaveDefinition(role,refs[role]-1,"ROLE"+IntegerToString(role),p,v,true),true);
 }
 Check("EA_DISK_SAVE",eaDisk.Save(ef,eaSrc,reason),true);
 Check("LOGIC_DISK_SAVE",logicDisk.Save(lf,logicSrc,reason),true);
 Check("EA_DISK_RESTORE",eaDisk.Load(ef,eaRestored,reason),true);
 Check("LOGIC_DISK_RESTORE",logicDisk.Load(lf,logicRestored,reason),true);
 Check("RESTORED_FOUR_REFS",gate.Resolve(100,eaRestored,logicRestored,reason),true);
 Check("RESTORED_STRUCTURAL_ONLY",reason=="REFERENCES_RESOLVED_SEMANTICS_UNPROVEN",true);
 bool got=logicRestored.LoadDefinition(1,50,name,outp,outv,enabled);
 Check("GRID_OFF_PART100_PRESERVED",got&&enabled&&outp[99]=="GRID_OFF",true);
 Check("GRID_OFF_NOT_UNSAVED",logicRestored.IsSaved(1,50),true);
 Check("GRID_OFF_NOT_GENERIC_OFF",logicRestored.IsEnabled(1,50),true);
 Check("REMOVE_REFERENCED_EXIT",logicRestored.ClearSlot(3,99),true);
 Check("MISSING_EXIT_REJECT",gate.Resolve(100,eaRestored,logicRestored,reason),false);
 Check("MISSING_EXIT_REASON",reason=="ROLE_3_UNSAVED",true);
 Parts(p,v,"ROLE_TEST_MARKER");
 Check("RESTORE_EXIT_MEMORY",logicRestored.SaveDefinition(3,99,"EXIT",p,v,true),true);
 Check("DISABLE_MANAGE",logicRestored.SaveDefinition(2,59,"MANAGE",p,v,false),true);
 Check("DISABLED_MANAGE_REJECT",gate.Resolve(100,eaRestored,logicRestored,reason),false);
 Check("DISABLED_MANAGE_REASON",reason=="ROLE_2_OFF",true);
 Check("RE_ENABLE_MANAGE",logicRestored.SaveDefinition(2,59,"MANAGE",p,v,true),true);
 Check("EA_DISABLE",eaRestored.Save(100,"EA100",refs,false),true);
 Check("EA_OFF_REJECT",gate.Resolve(100,eaRestored,logicRestored,reason),false);
 Check("EA_OFF_REASON",reason=="EA_OFF",true);
 FileDelete(ef);FileDelete(ef+".tmp");
 FileDelete(lf);FileDelete(lf+".tmp");
 if(failures==0)
  Print("[MA_RESTORE_REF_PASS] cross_file_refs=PASS grid_off_storage=PASS semantics_proven=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_RESTORE_REF_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
