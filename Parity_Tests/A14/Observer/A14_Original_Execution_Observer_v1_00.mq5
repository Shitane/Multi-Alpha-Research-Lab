//+------------------------------------------------------------------+
//| A14 Original Execution Parity Observer v1.00                    |
//| Attach to the SAME tester run as the original A14 only if your  |
//| test workflow supports it. Otherwise use original tester log.    |
//| This observer NEVER sends orders.                                |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

input ulong InpObservedMagic=26091043;

ulong g_last_entry_deal=0;
ulong g_last_exit_deal=0;
long  g_entries=0;
long  g_exits=0;

void ScanDeals()
{
 if(!HistorySelect(0,TimeCurrent())) return;
 const int total=HistoryDealsTotal();
 for(int i=0;i<total;i++)
 {
  const ulong ticket=HistoryDealGetTicket(i);
  if(ticket==0) continue;
  if((ulong)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpObservedMagic) continue;
  if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;

  const ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
  const ENUM_DEAL_TYPE type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE);
  const double price=HistoryDealGetDouble(ticket,DEAL_PRICE);
  const datetime when=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);

  if(entry==DEAL_ENTRY_IN && ticket>g_last_entry_deal)
  {
   g_last_entry_deal=ticket; g_entries++;
   PrintFormat("[A14_ORIGINAL_ENTRY] no=%I64d deal=%I64u dir=%s price=%.8f time=%s",
     g_entries,ticket,(type==DEAL_TYPE_BUY?"BUY":"SELL"),price,
     TimeToString(when,TIME_DATE|TIME_SECONDS));
  }
  else if((entry==DEAL_ENTRY_OUT || entry==DEAL_ENTRY_OUT_BY) && ticket>g_last_exit_deal)
  {
   g_last_exit_deal=ticket; g_exits++;
   PrintFormat("[A14_ORIGINAL_EXIT] no=%I64d deal=%I64u side=%s price=%.8f time=%s",
     g_exits,ticket,(type==DEAL_TYPE_BUY?"BUY":"SELL"),price,
     TimeToString(when,TIME_DATE|TIME_SECONDS));
  }
 }
}

int OnInit()
{
 PrintFormat("[A14_ORIGINAL_OBSERVER_START] magic=%I64u symbol=%s NO_ORDERS=1",InpObservedMagic,_Symbol);
 return INIT_SUCCEEDED;
}
void OnTick(){ScanDeals();}
void OnDeinit(const int reason)
{
 ScanDeals();
 PrintFormat("[A14_ORIGINAL_OBSERVER_SUMMARY] entries=%I64d exits=%I64d reason=%d NO_ORDERS=1",
             g_entries,g_exits,reason);
}
//+------------------------------------------------------------------+
