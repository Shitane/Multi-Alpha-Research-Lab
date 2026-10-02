//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Saved_Definition_Route_v1_00.mqh             |
//| Generic saved ENTRY/MANAGE/EXIT definition loader + route gate. |
//| NO ORDERS / VIRTUAL NOT FILL.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_SAVED_DEFINITION_ROUTE_V1_00_MQH
#define MULTIALPHA_BUILDER_SAVED_DEFINITION_ROUTE_V1_00_MQH
#include "MultiAlpha_Builder_Interpreter_v1_01.mqh"
#define MA_BUILDER_SAVED_DEFINITION_ROUTE_VERSION "1.00"
#define MA_BUILDER_SAVED_ROUTE_NO_ORDERS 1

struct SMA_BuilderSavedDefinition100
{
 int role;
 string name;
 string part[24];
 string param[24];
 bool loaded;
 bool valid;
 string reason;
 string expression;
};

class CMultiAlphaBuilderSavedDefinitionRoute100
{
private:
 CMultiAlphaBuilderInterpreter101 m_interpreter;

 string Prefix(const int role) const
 {
  return "MultiAlpha_Builder_"+(role==0?"ENTRY_":role==1?"MANAGE_":"EXIT_");
 }

 void Clear(SMA_BuilderSavedDefinition100 &d,const int role,const string name)
 {
  d.role=role;d.name=name;d.loaded=false;d.valid=false;d.reason="";d.expression="";
  for(int i=0;i<24;i++){d.part[i]="EMPTY";d.param[i]="";}
 }

 bool LoadOne(const int role,const string name,SMA_BuilderSavedDefinition100 &d)
 {
  Clear(d,role,name);
  if(name==""){d.reason="NAME REQUIRED";return false;}
  string fn=Prefix(role)+name+".csv";
  int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');
  if(h==INVALID_HANDLE){d.reason="NOT FOUND: "+fn;return false;}
  string sig=FileReadString(h),ver=FileReadString(h);
  int file_role=(int)FileReadNumber(h),count=(int)FileReadNumber(h);
  if(sig!="MA_BUILDER_ROLE"||file_role!=role||count!=24)
  {FileClose(h);d.reason="INVALID ROLE FILE: "+fn;return false;}
  for(int i=0;i<count&&!FileIsEnding(h);i++)
  {
   int no=(int)FileReadNumber(h);
   string pt=FileReadString(h),pa=FileReadString(h);
   if(no<1||no>24){FileClose(h);d.reason="INVALID SLOT NUMBER";return false;}
   d.part[no-1]=pt;d.param[no-1]=pa;
  }
  FileClose(h);
  d.loaded=true;
  string p[],v[];ArrayResize(p,24);ArrayResize(v,24);
  for(int i=0;i<24;i++){p[i]=d.part[i];v[i]=d.param[i];}
  d.valid=m_interpreter.Validate(p,v,d.reason);
  d.expression=m_interpreter.Expression(p,v);
  return d.valid;
 }

public:
 bool LoadRoute(const string entry_name,const string manage_name,const string exit_name,
                SMA_BuilderSavedDefinition100 &entry,
                SMA_BuilderSavedDefinition100 &manage,
                SMA_BuilderSavedDefinition100 &exit,
                string &reason)
 {
  bool e=LoadOne(0,entry_name,entry);
  bool m=LoadOne(1,manage_name,manage);
  bool x=LoadOne(2,exit_name,exit);
  if(!e){reason="ENTRY: "+entry.reason;return false;}
  if(!m){reason="MANAGE: "+manage.reason;return false;}
  if(!x){reason="EXIT: "+exit.reason;return false;}
  reason="READY";
  return true;
 }
};
#endif
