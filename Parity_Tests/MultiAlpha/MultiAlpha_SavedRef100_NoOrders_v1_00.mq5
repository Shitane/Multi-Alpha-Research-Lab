#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_Saved_Ref_Gate_v1_00.mqh"
int fails=0;
void Check(const string label,const bool actual,const bool expected)
{
 bool pass=(actual==expected);
 Print("[MA_REF100_CASE] ",label," ",pass?"PASS":"FAIL"," actual=",(int)actual," expected=",(int)expected);
 if(!pass)fails++;
}
void MakeParts(string &p[],string &v[])
{
 ArrayResize(p,100);ArrayResize(v,100);
 for(int i=0;i<100;i++){p[i]="EMPTY";v[i]="";}
 p[99]="SAVED_TEST_MARKER";
}
int OnInit()
{
 CMultiAlphaEASlotStore100 ea;
 CMultiAlphaModuleLibraryStore101 logic;
 CMultiAlphaSavedRefGate100 gate;
 string reason="",p[],v[];
 int refs[4]={1,51,60,100};
 MakeParts(p,v);
 Check("UNSAVED_EA_REJECT",gate.Resolve(100,ea,logic,reason),false);
 Check("SAVE_EA100",ea.Save(100,"EA100",refs,true),true);
 Check("UNSAVED_ROLE_REJECT",gate.Resolve(100,ea,logic,reason),false);
 for(int role=0;role<4;role++)
  Check("SAVE_ROLE_"+IntegerToString(role),logic.SaveDefinition(role,refs[role]-1,"ROLE",p,v,true),true);
 Check("FOUR_REFS_RESOLVE",gate.Resolve(100,ea,logic,reason),true);
 Check("RESOLVE_NOT_SEMANTIC_CERTIFICATION",reason=="REFERENCES_RESOLVED_SEMANTICS_UNPROVEN",true);
 Check("ROLE_3_INDEX99",logic.IsSaved(3,99),true);
 Check("ROLE_3_INDEX100_REJECT",logic.IsSaved(3,100),false);
 Check("DISABLE_REFERENCED_ROLE",logic.SaveDefinition(3,99,"OFF",p,v,false),true);
 Check("ROLE_OFF_REJECT",gate.Resolve(100,ea,logic,reason),false);
 Check("RE_ENABLE_ROLE",logic.SaveDefinition(3,99,"ON",p,v,true),true);
 Check("EA_OFF_SAVE",ea.Save(100,"EA100",refs,false),true);
 Check("EA_OFF_REJECT",gate.Resolve(100,ea,logic,reason),false);
 Check("INVALID_EA0_REJECT",gate.Resolve(0,ea,logic,reason),false);
 Check("INVALID_EA101_REJECT",gate.Resolve(101,ea,logic,reason),false);
 if(fails==0)Print("[MA_REF100_PASS] structural_refs=PASS semantics_proven=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_REF100_FAIL] count=",fails);
 return INIT_SUCCEEDED;
}
void OnTick(){}
