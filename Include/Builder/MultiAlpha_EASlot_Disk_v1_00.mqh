#ifndef MULTIALPHA_EASLOT_DISK_V1_00_MQH
#define MULTIALPHA_EASLOT_DISK_V1_00_MQH
#include "MultiAlpha_EA_Slot_Store_v1_00.mqh"
// Separate EA SLOT file only. Does not persist LOGIC definitions or FILTER.
// File sandbox: terminal-local MQL5/Files, not FILE_COMMON.
// Two-phase read: validate complete snapshot before replacing destination store.
class CMultiAlphaEASlotDisk100
{
 bool WriteSnapshot(const string path,CMultiAlphaEASlotStore100 &store)
 {
  int h=FileOpen(path,FILE_WRITE|FILE_CSV|FILE_ANSI,'\t');
  if(h==INVALID_HANDLE)return false;
  FileWrite(h,"MA_EASLOT100","1",MA_CAP_EA_SLOTS);
  for(int id=1;id<=MA_CAP_EA_SLOTS;id++)
  {
   string name="";int refs[];bool enabled=false;
   if(store.Load(id,name,refs,enabled))
    FileWrite(h,id,1,(int)enabled,name,refs[0],refs[1],refs[2],refs[3]);
   else FileWrite(h,id,0,0,"",0,0,0,0);
  }
  FileFlush(h);
  FileClose(h);
  return true;
 }
public:
 bool Save(const string filename,CMultiAlphaEASlotStore100 &store,string &reason)
 {
  if(filename==""||StringFind(filename,"..")>=0||StringFind(filename,"/")>=0||StringFind(filename,"\\")>=0)
  {reason="BAD_FILENAME";return false;}
  string temp=filename+".tmp";
  if(!WriteSnapshot(temp,store)){reason="WRITE_FAILED";return false;}
  // Rename within terminal sandbox only after writing complete temporary snapshot.
  if(!FileMove(temp,0,filename,FILE_REWRITE))
  {reason="RENAME_FAILED";return false;}
  reason="SAVED";return true;
 }
 bool Load(const string filename,CMultiAlphaEASlotStore100 &store,string &reason)
 {
  if(filename==""||StringFind(filename,"..")>=0||StringFind(filename,"/")>=0||StringFind(filename,"\\")>=0)
  {reason="BAD_FILENAME";return false;}
  int h=FileOpen(filename,FILE_READ|FILE_CSV|FILE_ANSI,'\t');
  if(h==INVALID_HANDLE){reason="OPEN_FAILED";return false;}
  CMultiAlphaEASlotStore100 staged;
  string magic=FileReadString(h),version=FileReadString(h);
  int count=(int)FileReadNumber(h);
  if(magic!="MA_EASLOT100"||version!="1"||count!=MA_CAP_EA_SLOTS)
  {FileClose(h);reason="HEADER_INVALID";return false;}
  for(int id=1;id<=MA_CAP_EA_SLOTS;id++)
  {
   if(FileIsEnding(h)){FileClose(h);reason="TRUNCATED";return false;}
   int row=(int)FileReadNumber(h),saved=(int)FileReadNumber(h),enabled=(int)FileReadNumber(h);
   string name=FileReadString(h);
   int refs[];ArrayResize(refs,4);
   for(int r=0;r<4;r++)refs[r]=(int)FileReadNumber(h);
   if(row!=id||(saved!=0&&saved!=1)||(enabled!=0&&enabled!=1))
   {FileClose(h);reason="ROW_INVALID";return false;}
   if(saved==0)
   {
    if(enabled!=0||name!=""||refs[0]!=0||refs[1]!=0||refs[2]!=0||refs[3]!=0)
    {FileClose(h);reason="UNSAVED_ROW_INVALID";return false;}
   }
   else if(!staged.Save(id,name,refs,enabled==1))
   {FileClose(h);reason="REF_INVALID";return false;}
  }
  bool trailing=!FileIsEnding(h);
  FileClose(h);
  if(trailing){reason="TRAILING_DATA";return false;}
  // Only replace after the entire file passed validation.
  store.ClearAll();
  for(int id=1;id<=MA_CAP_EA_SLOTS;id++)
  {
   string name="";int refs[];bool enabled=false;
   if(staged.Load(id,name,refs,enabled))store.Save(id,name,refs,enabled);
  }
  reason="LOADED";return true;
 }
};
#endif
