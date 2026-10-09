#ifndef MA_ME_TICKET_SAVED_BRIDGE_V1_00
#define MA_ME_TICKET_SAVED_BRIDGE_V1_00
#include "MultiAlpha_ME_Runtime_Decision_v1_00.mqh"
#include "MultiAlpha_ME_Ticket_Metrics_v1_00.mqh"
// A14-45: preview-only saved-side decision plus ticket metric. No trade operations.
bool MAMETicketSavedPreview100(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slot,const string symbol,const long magic,
 const ulong ticket,const datetime now,const int metric,const int cmp,
 const double threshold,bool &preview,string &action,string &reason)
{
 preview=false;action="";
 SMA_MEReadOnlyDecision100 d;
 if(!MABuildMEReadOnlyDecision100(store,role,slot,symbol,magic,d))
 {reason="SAVED_"+d.reason;return false;}
 SMA_METicketMetrics100 m;
 if(!MAReadMETicketMetrics100(ticket,symbol,magic,now,m,reason))return false;
 bool match=false;
 if(!MAEvaluateMETicketPredicate100(m,metric,cmp,threshold,match,reason))return false;
 if(d.state==MA_ME_DECISION_NO_SIGNAL||!match)
 {reason="NO_SIGNAL";return true;}
 if(d.state!=MA_ME_DECISION_INTENT_ONLY||!d.fire)
 {reason="INVALID_DECISION";return false;}
 preview=true;action=d.action;reason="PREVIEW_ONLY_NOT_EXECUTABLE";
 return true;
}
#endif
