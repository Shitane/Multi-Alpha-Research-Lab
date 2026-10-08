#ifndef MULTIALPHA_SNAPSHOT_MANIFEST_V1_00_MQH
#define MULTIALPHA_SNAPSHOT_MANIFEST_V1_00_MQH
// Companion manifest binds two completed snapshot files to a common generation.
// Non-cryptographic Adler32 detects accidental bit flips; not malicious tampering.
// Save EA/LOGIC snapshots FIRST, then WriteManifest LAST. Verify BEFORE loading.
class CMultiAlphaSnapshotManifest100
{
 bool Good(const string s)const
 {return s!=""&&StringFind(s,"..")<0&&StringFind(s,"/")<0&&StringFind(s,"\\")<0;}
 bool Fingerprint(const string filename,long &bytes,ulong &sum)
 {
  int h=FileOpen(filename,FILE_READ|FILE_BIN);
  if(h==INVALID_HANDLE)return false;
  bytes=FileSize(h);
  if(bytes<=0){FileClose(h);return false;}
  ulong a=1,b=0;
  for(long i=0;i<bytes;i++)
  {
   int x=FileReadInteger(h,CHAR_VALUE)&255;
   a=(a+(ulong)x)%65521;
   b=(b+a)%65521;
  }
  FileClose(h);
  sum=b*65536+a;
  return true;
 }
public:
 bool Write(const string manifest,const string generation,
            const string eaFile,const string logicFile,string &reason)
 {
  if(!Good(manifest)||!Good(eaFile)||!Good(logicFile)||generation==""||
     StringFind(generation,"\t")>=0||StringFind(generation,"\n")>=0)
  {reason="BAD_INPUT";return false;}
  long es=0,ls=0;ulong ec=0,lc=0;
  if(!Fingerprint(eaFile,es,ec)||!Fingerprint(logicFile,ls,lc))
  {reason="SNAPSHOT_MISSING";return false;}
  string tmp=manifest+".tmp";
  int h=FileOpen(tmp,FILE_WRITE|FILE_CSV|FILE_ANSI,'\t');
  if(h==INVALID_HANDLE){reason="MANIFEST_WRITE_FAILED";return false;}
  FileWrite(h,"MA_PAIR_MANIFEST","1",generation);
  FileWrite(h,eaFile,(string)es,(string)ec);
  FileWrite(h,logicFile,(string)ls,(string)lc);
  FileFlush(h);FileClose(h);
  if(!FileMove(tmp,0,manifest,FILE_REWRITE))
  {reason="MANIFEST_RENAME_FAILED";return false;}
  reason="MANIFEST_WRITTEN";return true;
 }
 bool Verify(const string manifest,const string expectedGeneration,
             const string eaFile,const string logicFile,string &reason)
 {
  if(!Good(manifest)||!Good(eaFile)||!Good(logicFile)||expectedGeneration=="")
  {reason="BAD_INPUT";return false;}
  int h=FileOpen(manifest,FILE_READ|FILE_CSV|FILE_ANSI,'\t');
  if(h==INVALID_HANDLE){reason="MANIFEST_MISSING";return false;}
  string magic=FileReadString(h),version=FileReadString(h),generation=FileReadString(h);
  string efile=FileReadString(h),esize=FileReadString(h),ecrc=FileReadString(h);
  string lfile=FileReadString(h),lsize=FileReadString(h),lcrc=FileReadString(h);
  bool extra=!FileIsEnding(h);
  FileClose(h);
  if(extra||magic!="MA_PAIR_MANIFEST"||version!="1"||
     generation!=expectedGeneration||efile!=eaFile||lfile!=logicFile)
  {reason="MANIFEST_INVALID_OR_GENERATION_MISMATCH";return false;}
  long es=0,ls=0;ulong ec=0,lc=0;
  if(!Fingerprint(eaFile,es,ec)||!Fingerprint(logicFile,ls,lc))
  {reason="SNAPSHOT_MISSING";return false;}
  if(esize!=(string)es||ecrc!=(string)ec||lsize!=(string)ls||lcrc!=(string)lc)
  {reason="SNAPSHOT_FINGERPRINT_MISMATCH";return false;}
  reason="PAIR_VERIFIED";return true;
 }
};
#endif
