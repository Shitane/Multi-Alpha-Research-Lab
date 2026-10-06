//+------------------------------------------------------------------+
//| MA_O01_R2_LiveMXGate_v1_00.mq5                                 |
//| P2-C: canonical O01 MANAGE/EXIT -> live broker/runtime gate.     |
//| Decision/state observation only. NO ORDERS / VIRTUAL NOT FILL.   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_02.mqh>
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_03.mqh>

input int InpTargetSamples=20;

int g_samples=0,g_manageValid=0,g_exitValid=0;
bool g_done=false;

bool FinitePrice(const double x){return MathIsValidNumber(x) && x>0.0;}

bool ValidateRole(const int role,int &used,string &reason)
{
 string p[4][40],v[4][40];MAO01LoadCanonical102(p,v);
 used=0;
 for(int i=0;i<40;i++)
 {
  if(p[role][i]=="" || p[role][i]=="EMPTY")continue;
  used++;
  if(!MA103ValidatePart(role,p[role][i],v[role][i],reason))
  {
   reason=MA101RoleName(role)+" slot="+IntegerToString(i+1)+" part="+p[role][i]+" "+reason;
   return false;
  }
 }
 int expected=(role==MA_BUILDER_ROLE_MANAGE101 ? 9 : 19);
 if(used!=expected){reason="USED COUNT "+IntegerToString(used)+" EXPECTED "+IntegerToString(expected);return false;}
 reason="VALID";return true;
}

void Sample()
{
 if(g_done)return;
 MqlTick tick;if(!SymbolInfoTick(_Symbol,tick))return;
 bool marketOK=FinitePrice(tick.bid)&&FinitePrice(tick.ask)&&tick.ask>=tick.bid&&_Point>0.0;
 int mu=0,xu=0;string mw="",xw="";
 bool manageOK=ValidateRole(MA_BUILDER_ROLE_MANAGE101,mu,mw);
 bool exitOK=ValidateRole(MA_BUILDER_ROLE_EXIT101,xu,xw);
 bool pass=marketOK&&manageOK&&exitOK;

 g_samples++;
 if(manageOK)g_manageValid++;
 if(exitOK)g_exitValid++;

 Print("[O01_R2_LIVE_MX_SAMPLE] n=",g_samples,
       " bid=",DoubleToString(tick.bid,_Digits)," ask=",DoubleToString(tick.ask,_Digits),
       " spreadPts=",DoubleToString((tick.ask-tick.bid)/_Point,1),
       " marketOK=",(int)marketOK,
       " manageUsed=",mu," manageValid=",(int)manageOK," manageReason=",mw,
       " exitUsed=",xu," exitValid=",(int)exitOK," exitReason=",xw,
       " result=",(pass?"PASS":"FAIL"));

 if(!pass || g_samples>=InpTargetSamples)
 {
  g_done=true;
  Print("[O01_R2_LIVE_MX_GATE] canonical=1.02 schema=1.03 samples=",g_samples,
        " manageValid=",g_manageValid," exitValid=",g_exitValid,
        " result=",(pass?"PASS":"FAIL"),
        " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 }
}

int OnInit()
{
 int mu=0,xu=0;string mw="",xw="";
 bool m=ValidateRole(MA_BUILDER_ROLE_MANAGE101,mu,mw);
 bool x=ValidateRole(MA_BUILDER_ROLE_EXIT101,xu,xw);
 Print("[O01_R2_LIVE_MX_START] symbol=",_Symbol," tf=",EnumToString(_Period),
       " target=",InpTargetSamples,
       " manageUsed=",mu," manage=",(m?"VALID":"INVALID")," manageReason=",mw,
       " exitUsed=",xu," exit=",(x?"VALID":"INVALID")," exitReason=",xw,
       " NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 if(!m||!x)return INIT_FAILED;
 EventSetTimer(1);return INIT_SUCCEEDED;
}
void OnDeinit(const int reason){EventKillTimer();}
void OnTimer(){Sample();}
void OnTick(){Sample();}
