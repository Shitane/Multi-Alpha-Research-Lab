#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_EASlot_Disk_v1_00.mqh"
int failures=0;
void Check(const string label,const bool got,const bool expected)
{
 bool pass=got==expected;
 Print("[MA_DISK100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)got," expected=",(int)expected);
 if(!pass)failures++;
}
void Refs(int &a[],int x,int y,int z,int w)
{
 ArrayResize(a,4);a[0]=x;a[1]=y;a[2]=z;a[3]=w;
}
int OnInit()
{
 string file="MA_EASLOT100_NoOrders_test_v1_00.tsv",reason="",name="";
 CMultiAlphaEASlotStore100 before,after;
 CMultiAlphaEASlotDisk100 disk;
 int refs[],out[];bool enabled=false;
 Refs(refs,1,50,51,100);
 Check("SAVE_SLOT100_MEMORY",before.Save(100,"EA100",refs,true),true);
 Refs(refs,60,61,99,1);
 Check("SAVE_SLOT51_MEMORY",before.Save(51,"EA51",refs,false),true);
 Check("DISK_WRITE",disk.Save(file,before,reason),true);
 Check("DISK_READ",disk.Load(file,after,reason),true);
 Check("RESTORE_100",after.Load(100,name,out,enabled)&&name=="EA100"&&enabled&&out[0]==1&&out[1]==50&&out[2]==51&&out[3]==100,true);
 Check("RESTORE_51",after.Load(51,name,out,enabled)&&name=="EA51"&&!enabled&&out[0]==60&&out[1]==61&&out[2]==99&&out[3]==1,true);
 Check("UNSAVED_99",after.IsSaved(99),false);
 Check("INVALID_FILENAME_REJECT",disk.Save("../invalid.tsv",before,reason),false);
 // Truncated/corrupt input must leave an existing destination unchanged.
 int h=FileOpen(file,FILE_WRITE|FILE_CSV|FILE_ANSI,'\t');
 bool wrote=(h!=INVALID_HANDLE);
 if(wrote){FileWrite(h,"MA_EASLOT100","1",100);FileWrite(h,1,1,1,"BAD",1,2,3,4);FileClose(h);}
 Check("CORRUPT_FIXTURE_WRITE",wrote,true);
 Check("TRUNCATED_REJECT",disk.Load(file,after,reason),false);
 Check("FAILED_LOAD_PRESERVES_100",after.Load(100,name,out,enabled)&&name=="EA100"&&enabled,true);
 FileDelete(file);
 FileDelete(file+".tmp");
 if(failures==0)Print("[MA_DISK100_PASS] disk_roundtrip=PASS corrupt_fail_closed=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_DISK100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
