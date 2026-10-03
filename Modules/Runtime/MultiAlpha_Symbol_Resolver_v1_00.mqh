//+------------------------------------------------------------------+
//| MultiAlpha_Symbol_Resolver_v1_00.mqh                             |
//| Logical symbol -> broker symbol resolver. Read-only / fail closed.|
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SYMBOL_RESOLVER_V1_00_MQH
#define MULTIALPHA_SYMBOL_RESOLVER_V1_00_MQH
#define MA_SYMBOL_RESOLVER_VERSION "1.00"

struct SMA_SymbolSpec100
{
 string logical_symbol,broker_symbol;
 double point,tick_size,tick_value,volume_min,volume_max,volume_step,contract_size;
 int digits;
 bool selected,valid;
 string reason;
};

class CMultiAlphaSymbolResolver100
{
private:
 bool Snapshot(const string logical,const string broker,SMA_SymbolSpec100 &o)
 {
  o.logical_symbol=logical;o.broker_symbol=broker;o.selected=false;o.valid=false;o.reason="";
  if(!SymbolSelect(broker,true)){o.reason="SYMBOL SELECT FAILED: "+broker;return false;}
  o.selected=true;
  o.point=SymbolInfoDouble(broker,SYMBOL_POINT);
  o.digits=(int)SymbolInfoInteger(broker,SYMBOL_DIGITS);
  o.tick_size=SymbolInfoDouble(broker,SYMBOL_TRADE_TICK_SIZE);
  o.tick_value=SymbolInfoDouble(broker,SYMBOL_TRADE_TICK_VALUE);
  o.volume_min=SymbolInfoDouble(broker,SYMBOL_VOLUME_MIN);
  o.volume_max=SymbolInfoDouble(broker,SYMBOL_VOLUME_MAX);
  o.volume_step=SymbolInfoDouble(broker,SYMBOL_VOLUME_STEP);
  o.contract_size=SymbolInfoDouble(broker,SYMBOL_TRADE_CONTRACT_SIZE);
  if(o.point<=0||o.tick_size<=0||o.volume_min<=0||o.volume_max<o.volume_min||o.volume_step<=0)
   {o.reason="INVALID SYMBOL SPEC";return false;}
  o.valid=true;o.reason="READY";return true;
 }
 bool Candidate(const string logical,const string broker) const
 {
  int n=StringLen(logical),m=StringLen(broker);if(n==0||m<n)return false;
  return StringFind(broker,logical)>=0;
 }
public:
 bool ResolveCustom(const string logical,const string broker,SMA_SymbolSpec100 &o)
 {
  if(logical==""||broker==""){o.valid=false;o.reason="EMPTY SYMBOL";return false;}
  return Snapshot(logical,broker,o);
 }
 bool ResolveAuto(const string logical,SMA_SymbolSpec100 &o)
 {
  if(logical==""){o.valid=false;o.reason="EMPTY LOGICAL SYMBOL";return false;}
  // Exact broker symbol always wins.
  if(SymbolExist(logical,false))return Snapshot(logical,logical,o);
  string match="";int matches=0,total=SymbolsTotal(false);
  for(int i=0;i<total;i++){string s=SymbolName(i,false);if(Candidate(logical,s)){match=s;matches++;}}
  if(matches==0)
  {
   total=SymbolsTotal(true);
   for(int i=0;i<total;i++){string s=SymbolName(i,true);if(Candidate(logical,s)){match=s;matches++;}}
  }
  if(matches==0){o.logical_symbol=logical;o.valid=false;o.reason="NO SYMBOL MATCH";return false;}
  if(matches>1){o.logical_symbol=logical;o.valid=false;o.reason="AMBIGUOUS SYMBOL MATCH ("+IntegerToString(matches)+")";return false;}
  return Snapshot(logical,match,o);
 }
};
#endif
