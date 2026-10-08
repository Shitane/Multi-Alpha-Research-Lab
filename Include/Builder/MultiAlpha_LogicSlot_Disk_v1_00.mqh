#ifndef MULTIALPHA_LOGIC_DISK_V1_00_MQH
#define MULTIALPHA_LOGIC_DISK_V1_00_MQH
#include "MultiAlpha_Module_Library_Store_v1_01.mqh"
// Versioned binary full snapshot, MQL5 terminal sandbox. In-memory stage on load.
// No semantic Interpreter validation; not a runnable certification.
class CMultiAlphaLogicDisk100
{
 bool GoodName(const string s)const
 {return s!=""&&StringFind(s,"..")<0&&StringFind(s,"/")<0&&StringFind(s,"\\")<0;}
 void PutString(const int h,const string s)
 {
  int n=StringLen(s);FileWriteInteger(h,n,INT_VALUE);
  if(n>0)FileWriteString(h,s,n);
 }
 bool GetString(const int h,string &s)
 {
  if(FileIsEnding(h))return false;
  int n=FileReadInteger(h,INT_VALUE);
  if(n<0||n>4096||FileTell(h)+(long)n*2>FileSize(h))return false;
  s=n>0?FileReadString(h,n):"";
  return StringLen(s)==n;
 }
public:
 bool Save(const string filename,CMultiAlphaModuleLibraryStore101 &store,string &reason)
 {
  if(!GoodName(filename)){reason="BAD_FILENAME";return false;}
  string tmp=filename+".tmp";
  int h=FileOpen(tmp,FILE_WRITE|FILE_BIN|FILE_UNICODE);
  if(h==INVALID_HANDLE){reason="OPEN_WRITE_FAILED";return false;}
  FileWriteInteger(h,0x4D414C53,INT_VALUE);
  FileWriteInteger(h,1,INT_VALUE);
  FileWriteInteger(h,MA_CAP_LOGIC_ROLES,INT_VALUE);
  FileWriteInteger(h,MA_CAP_LOGIC_SLOTS_PER_ROLE,INT_VALUE);
  FileWriteInteger(h,MA_CAP_PARTS_PER_LOGIC,INT_VALUE);
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)
   for(int s=0;s<MA_CAP_LOGIC_SLOTS_PER_ROLE;s++)
   {
    string name="",p[],v[];bool enabled=false;
    bool saved=store.LoadDefinition(r,s,name,p,v,enabled);
    FileWriteInteger(h,(int)saved,INT_VALUE);
    FileWriteInteger(h,(int)enabled,INT_VALUE);
    if(!saved)continue;
    PutString(h,name);
    for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
    {PutString(h,p[i]);PutString(h,v[i]);}
   }
  FileFlush(h);FileClose(h);
  if(!FileMove(tmp,0,filename,FILE_REWRITE)){reason="RENAME_FAILED";return false;}
  reason="SAVED";return true;
 }
 bool Load(const string filename,CMultiAlphaModuleLibraryStore101 &store,string &reason)
 {
  if(!GoodName(filename)){reason="BAD_FILENAME";return false;}
  int h=FileOpen(filename,FILE_READ|FILE_BIN|FILE_UNICODE);
  if(h==INVALID_HANDLE){reason="OPEN_READ_FAILED";return false;}
  bool ok=true;
  if(FileSize(h)<20)ok=false;
  if(ok)
  {
   int magic=FileReadInteger(h,INT_VALUE),version=FileReadInteger(h,INT_VALUE);
   int roles=FileReadInteger(h,INT_VALUE),slots=FileReadInteger(h,INT_VALUE),parts=FileReadInteger(h,INT_VALUE);
   if(magic!=0x4D414C53||version!=1||roles!=MA_CAP_LOGIC_ROLES||slots!=MA_CAP_LOGIC_SLOTS_PER_ROLE||parts!=MA_CAP_PARTS_PER_LOGIC)ok=false;
  }
  CMultiAlphaModuleLibraryStore101 staged;
  for(int r=0;r<MA_CAP_LOGIC_ROLES&&ok;r++)
   for(int s=0;s<MA_CAP_LOGIC_SLOTS_PER_ROLE&&ok;s++)
   {
    if(FileTell(h)+8>FileSize(h)){ok=false;break;}
    int saved=FileReadInteger(h,INT_VALUE),enabled=FileReadInteger(h,INT_VALUE);
    if((saved!=0&&saved!=1)||(enabled!=0&&enabled!=1)||(saved==0&&enabled!=0)){ok=false;break;}
    if(saved==0)continue;
    string name="",p[],v[];
    ArrayResize(p,MA_CAP_PARTS_PER_LOGIC);ArrayResize(v,MA_CAP_PARTS_PER_LOGIC);
    if(!GetString(h,name)){ok=false;break;}
    for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
    {
     if(!GetString(h,p[i])||!GetString(h,v[i])){ok=false;break;}
    }
    if(ok&&!staged.SaveDefinition(r,s,name,p,v,enabled==1))ok=false;
   }
  if(ok&&FileTell(h)!=FileSize(h))ok=false;
  FileClose(h);
  if(!ok){reason="INVALID_OR_TRUNCATED";return false;}
  // Commit only after complete validation.
  store.ClearAll();
  for(int r=0;r<MA_CAP_LOGIC_ROLES;r++)
   for(int s=0;s<MA_CAP_LOGIC_SLOTS_PER_ROLE;s++)
   {
    string name="",p[],v[];bool enabled=false;
    if(staged.LoadDefinition(r,s,name,p,v,enabled))
     store.SaveDefinition(r,s,name,p,v,enabled);
   }
  reason="LOADED";return true;
 }
};
#endif
