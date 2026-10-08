#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_EA_Slot_Store_v1_00.mqh"
int failures=0;
void Check(const string name,const bool got,const bool expected)
{
 bool pass=got==expected;
 Print("[MA_EASLOT100_CASE] ",name," ",pass?"PASS":"FAIL"," actual=",(int)got," expected=",(int)expected);
 if(!pass)failures++;
}
void SetRefs(int &refs[],const int a,const int b,const int c,const int d)
{
 ArrayResize(refs,4);refs[0]=a;refs[1]=b;refs[2]=c;refs[3]=d;
}
int OnInit()
{
 CMultiAlphaEASlotStore100 store;
 int refs[],loaded[];string name="";bool enabled=false;
 SetRefs(refs,1,50,51,100);
 Check("SAVE_SLOT_100",store.Save(100,"EA100",refs,true),true);
 Check("LOAD_SLOT_100",store.Load(100,name,loaded,enabled),true);
 Check("FOUR_REFS_INDEPENDENT",ArraySize(loaded)==4&&loaded[0]==1&&loaded[1]==50&&loaded[2]==51&&loaded[3]==100,true);
 Check("NAME_ENABLED_ROUNDTRIP",name=="EA100"&&enabled,true);
 Check("UNSAVED_99_OFF",store.IsSaved(99),false);
 Check("SLOT_0_REJECT",store.Save(0,"BAD",refs,true),false);
 Check("SLOT_101_REJECT",store.Save(101,"BAD",refs,true),false);
 int boundaries[6]={1,50,51,60,61,100};
 bool all=true;
 for(int i=0;i<6;i++)
 {
  int id=boundaries[i];SetRefs(refs,id,100,1,50);
  if(!store.Save(id,"EA"+IntegerToString(id),refs,(id%2)==0))all=false;
  if(!store.Load(id,name,loaded,enabled)||name!="EA"+IntegerToString(id)||loaded[0]!=id||loaded[1]!=100||loaded[2]!=1||loaded[3]!=50||enabled!=((id%2)==0))all=false;
 }
 Check("BOUNDARIES_1_50_51_60_61_100",all,true);
 SetRefs(refs,1,2,3,0);
 Check("REF_0_REJECT",store.Save(2,"BAD",refs,true),false);
 SetRefs(refs,1,2,3,101);
 Check("REF_101_REJECT",store.Save(2,"BAD",refs,true),false);
 ArrayResize(refs,3);
 Check("REF_COUNT_REJECT",store.Save(2,"BAD",refs,true),false);
 SetRefs(refs,4,3,2,1);
 Check("SAVE_DISABLED",store.Save(2,"DISABLED",refs,false),true);
 Check("DISABLED_NOT_ENABLED",store.IsSaved(2)&&!store.IsEnabled(2),true);
 Check("CLEAR_100",store.Clear(100)&&!store.IsSaved(100),true);
 Check("INVALID_SAVE_ATOMIC",!store.Save(0,"BAD",refs,true)&&store.IsSaved(2),true);
 if(failures==0)Print("[MA_EASLOT100_PASS] ea_slots=100 refs=4 boundaries=PASS NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_EASLOT100_FAIL] count=",failures);
 return INIT_SUCCEEDED;
}
void OnTick(){}
