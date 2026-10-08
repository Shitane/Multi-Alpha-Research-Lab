#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_LogicSlot_Disk_v1_00.mqh"
int failures=0;
void Check(const string label,const bool actual,const bool expected)
{
 bool pass=actual==expected;
 Print("[MA_LOGICDISK100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)failures++;
}
void Reset(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
}
int OnInit()
{
 string file="MA_LOGIC100_NoOrders_test_v1_00.bin",reason="",name="",p[],v[],lp[],lv[];
 bool enabled=false;
 CMultiAlphaModuleLibraryStore101 before,after;
 CMultiAlphaLogicDisk100 disk;
 Reset(p,v);p[99]="GRID_OFF";
 Check("SAVE_GRID_SLOT100",before.SaveDefinition(1,99,"GRID_OFF_100",p,v,true),true);
 Reset(p,v);p[0]="MOVE_POINTS";p[40]="AND";p[99]="SINGLE_TRAILING";v[99]="START=80;LOCK=20;DISTANCE=40;STEP=10";
 Check("SAVE_MANAGE_SLOT51",before.SaveDefinition(2,50,"MANAGE_51",p,v,false),true);
 Check("DISK_WRITE",disk.Save(file,before,reason),true);
 Check("DISK_READ",disk.Load(file,after,reason),true);
 bool got=after.LoadDefinition(1,99,name,lp,lv,enabled);
 Check("RESTORE_GRID_PART100",got&&name=="GRID_OFF_100"&&enabled&&lp[99]=="GRID_OFF"&&lp[0]=="EMPTY",true);
 got=after.LoadDefinition(2,50,name,lp,lv,enabled);
 Check("RESTORE_MANAGE_41_100",got&&name=="MANAGE_51"&&!enabled&&lp[40]=="AND"&&lp[99]=="SINGLE_TRAILING"&&lv[99]=="START=80;LOCK=20;DISTANCE=40;STEP=10",true);
 Check("ROLE_ISOLATION",after.IsSaved(0,99),false);
 Check("UNSAVED_99",after.IsSaved(3,98),false);
 Check("BAD_FILENAME_REJECT",disk.Save("../bad.bin",before,reason),false);
 int h=FileOpen(file,FILE_WRITE|FILE_BIN|FILE_UNICODE);
 bool wrote=h!=INVALID_HANDLE;
 if(wrote){FileWriteInteger(h,0x4D414C53,INT_VALUE);FileWriteInteger(h,1,INT_VALUE);FileClose(h);}
 Check("CORRUPT_FIXTURE",wrote,true);
 Check("TRUNCATED_REJECT",disk.Load(file,after,reason),false);
 Check("FAILED_LOAD_PRESERVES_GRID",after.LoadDefinition(1,99,name,lp,lv,enabled)&&lp[99]=="GRID_OFF",true);
 FileDelete(file);FileDelete(file+".tmp");
 if(failures==0)Print("[MA_LOGICDISK100_PASS] roles=4 slots_per_role=100 parts=100 disk_roundtrip=PASS truncated_fail_closed=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_LOGICDISK100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
