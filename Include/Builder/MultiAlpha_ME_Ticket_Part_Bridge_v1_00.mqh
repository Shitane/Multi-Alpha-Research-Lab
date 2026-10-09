#ifndef MA_ME_TICKET_PART_BRIDGE_V1_00
#define MA_ME_TICKET_PART_BRIDGE_V1_00
#include "MultiAlpha_ME_Ticket_Saved_Bridge_v1_00.mqh"
// A14-46 experimental read-only Parts adapter.
// TICKET_PROFIT / TICKET_AGE_SECONDS / TICKET_OPEN_PRICE are NOT yet
// registered in the canonical Builder Part Schema. Do not certify them.
bool MA46ParseTicketPart(const string part,const string param,int &metric,int &cmp,double &threshold,string &reason)
{
 metric=0;cmp=0;threshold=0;
 string p=MA101CanonicalPart(part);
 if(p=="TICKET_PROFIT")metric=MA_TICKET_METRIC_PROFIT;
 else if(p=="TICKET_AGE_SECONDS")metric=MA_TICKET_METRIC_AGE_SECONDS;
 else if(p=="TICKET_OPEN_PRICE")metric=MA_TICKET_METRIC_OPEN_PRICE;
 else{reason="UNSUPPORTED_TICKET_PART";return false;}
 string fields[];int n=StringSplit(param,';',fields);
 if(n!=2){reason="PARAM_FORMAT";return false;}
 bool hasCmp=false,hasValue=false;
 for(int i=0;i<n;i++)
 {
  int eq=StringFind(fields[i],"=");
  if(eq<=0){reason="PARAM_FORMAT";return false;}
  string key=StringSubstr(fields[i],0,eq),val=StringSubstr(fields[i],eq+1);
  if(key=="COND"&&!hasCmp)
  {
   if(val=="GE")cmp=MA_TICKET_CMP_GE;
   else if(val=="LE")cmp=MA_TICKET_CMP_LE;
   else{reason="UNSUPPORTED_COMPARISON";return false;}
   hasCmp=true;
  }
  else if(key=="VALUE"&&!hasValue)
  {
   if(val==""||StringFind(val," ")>=0){reason="BAD_THRESHOLD";return false;}
   // StringToDouble is permissive; validate characters before conversion.
   int dots=0,digits=0;
   for(int j=0;j<StringLen(val);j++)
   {
    ushort c=StringGetCharacter(val,j);
    if(c>=48&&c<=57){digits++;continue;}
    if(c==46){dots++;if(dots>1)break;continue;}
    if((c==43||c==45)&&j==0)continue;
    reason="BAD_THRESHOLD";return false;
   }
   if(digits==0||dots>1){reason="BAD_THRESHOLD";return false;}
   threshold=StringToDouble(val);
   if(!MathIsValidNumber(threshold)){reason="BAD_THRESHOLD";return false;}
   hasValue=true;
  }
  else{reason="DUPLICATE_OR_UNKNOWN_PARAM";return false;}
 }
 if(!hasCmp||!hasValue){reason="MISSING_PARAM";return false;}
 reason="PARSED_PREVIEW_ONLY";return true;
}
bool MA46SavedTicketPartPreview(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slot,const string symbol,const long magic,
 const ulong ticket,const datetime now,bool &preview,string &action,string &reason)
{
 preview=false;action="";
 string name="",parts[],params[];bool enabled=false;
 if(!store.LoadDefinition(role,slot,name,parts,params,enabled)||!enabled)
 {reason="SLOT_NOT_ENABLED_OR_SAVED";return false;}
 int count=0,metric=0,cmp=0;double threshold=0;
 for(int i=0;i<ArraySize(parts);i++)
 {
  string p=MA101CanonicalPart(parts[i]);
  if(p=="TICKET_PROFIT"||p=="TICKET_AGE_SECONDS"||p=="TICKET_OPEN_PRICE")
  {
   count++;
   if(count>1){reason="MULTIPLE_TICKET_PARTS_NOT_SUPPORTED";return false;}
   if(!MA46ParseTicketPart(p,params[i],metric,cmp,threshold,reason))return false;
  }
 }
 if(count!=1){reason="REQUIRES_ONE_TICKET_PART";return false;}
 // Ticket Part is an experimental sidecar: do not pass it to the
 // canonical saved decision grammar, which does not register it.
 string cleanP[],cleanV[];ArrayResize(cleanP,100);ArrayResize(cleanV,100);
 for(int i=0;i<100;i++){cleanP[i]=parts[i];cleanV[i]=params[i];}
 for(int i=0;i<100;i++)
 {
  string p=MA101CanonicalPart(cleanP[i]);
  if(p=="TICKET_PROFIT"||p=="TICKET_AGE_SECONDS"||p=="TICKET_OPEN_PRICE")
  {cleanP[i]="EMPTY";cleanV[i]="";}
 }
 CMultiAlphaModuleLibraryStore101 temporary;
 if(!temporary.SaveDefinition(role,slot,name,cleanP,cleanV,true))
 {reason="TEMPORARY_SAVE_FAILED";return false;}
 return MAMETicketSavedPreview100(temporary,role,slot,symbol,magic,ticket,now,
  metric,cmp,threshold,preview,action,reason);
}
#endif
