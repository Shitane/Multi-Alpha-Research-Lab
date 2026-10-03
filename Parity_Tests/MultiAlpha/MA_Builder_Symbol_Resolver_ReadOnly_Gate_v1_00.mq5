//+------------------------------------------------------------------+
//| MA_Builder_Symbol_Resolver_ReadOnly_Gate_v1_00.mq5              |
//| First broker/symbol validation gate for Builder demo path.       |
//| NO ORDERS.                                                       |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include "..\\..\\..\\Include\\Runtime\\MultiAlpha_Symbol_Resolver_v1_00.mqh"
input string InpLogicalSymbol="XAUUSD";
input bool InpUseCustom=false;
input string InpCustomBrokerSymbol="XAUUSD-m";
CMultiAlphaSymbolResolver100 g_r;
int OnInit()
{
 SMA_SymbolSpec100 s={};bool ok=(InpUseCustom?g_r.ResolveCustom(InpLogicalSymbol,InpCustomBrokerSymbol,s):g_r.ResolveAuto(InpLogicalSymbol,s));
 Print("MULTI ALPHA SYMBOL RESOLVER / READ-ONLY GATE v1.00");
 Print("MODE=",(InpUseCustom?"CUSTOM":"AUTO")," LOGICAL=",InpLogicalSymbol);
 if(!ok){Print("RESULT: FAIL CLOSED - ",s.reason);Print("NO ORDERS / BROKER ACTIONS ARMED=0");return INIT_FAILED;}
 Print("RESOLVED=",s.broker_symbol," POINT=",DoubleToString(s.point,10)," DIGITS=",s.digits);
 Print("TICK_SIZE=",DoubleToString(s.tick_size,10)," TICK_VALUE=",DoubleToString(s.tick_value,8));
 Print("VOLUME_MIN=",DoubleToString(s.volume_min,4)," MAX=",DoubleToString(s.volume_max,4)," STEP=",DoubleToString(s.volume_step,4)," CONTRACT=",DoubleToString(s.contract_size,2));
 Print("RESULT: PASS - logical symbol resolved and broker symbol specification validated");
 Print("NO ORDERS / BROKER ACTIONS ARMED=0");return INIT_SUCCEEDED;
}
void OnTick(){}
