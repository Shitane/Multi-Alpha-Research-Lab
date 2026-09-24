//+------------------------------------------------------------------+
//| A11_Core_NoOrders_v1_00.mq5                                     |
//| NoOrders reproduction of ProMACross_MT5 v1.07                    |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#property description "A11 MA Cross reproduction - NO ORDERS"

input group "=== MA Settings ==="
input ENUM_MA_METHOD mode_ma=MODE_EMA;
input int period_ma_fast=100;
input int period_ma_slow=200;
input bool use_ma_filter=false;
input ENUM_MA_METHOD mode_ma_filter=MODE_SMA;
input ENUM_TIMEFRAMES timeframe_ma_filter=PERIOD_D1;
input int period_ma_filter=100;

input group "=== Risk Management ==="
input double takeProfit=0.0;
input double stopLoss=0.0;
input bool useFastMAexit=false;
input double maxLotSize=0.1;
input double minEquity=100.0;

input group "=== Trading Settings ==="
input int MagicNumber=889;

double myPoint;
datetime prevTime=0;
int hFastMA=INVALID_HANDLE,hSlowMA=INVALID_HANDLE;
double fastMA[],slowMA[];
bool v_open=false;
ENUM_POSITION_TYPE v_type=POSITION_TYPE_BUY;
double v_entry=0.0;
long g_ticks=0,g_newbars=0,g_raw=0,g_entries=0,g_exits=0;

double A11_iMAOnArray(int period,int ma_shift,ENUM_MA_METHOD ma_method,int shift)
{
 MqlRates rates[]; int copied=CopyRates(_Symbol,timeframe_ma_filter,0,period_ma_filter+1,rates);
 double array[]; ArrayResize(array,copied);
 if(copied>0) for(int i=1;i<copied;i++) array[i]=rates[i-1].close;
 ArrayReverse(array,0,WHOLE_ARRAY);
 double buf[],arr[]; int total=ArraySize(array);
 if(total<=period) return 0;
 if(shift>total-period-ma_shift) return 0;
 switch(ma_method)
 {
  case MODE_SMA:
   {
    total=ArrayCopy(arr,array,0,shift+ma_shift,period);
    if(ArrayResize(buf,total)<0) return 0;
    double sum=0; int i,pos=total-1;
    for(i=1;i<period;i++,pos--) sum+=arr[pos];
    while(pos>=0){sum+=arr[pos];buf[pos]=sum/period;sum-=arr[pos+period-1];pos--;}
    return buf[0];
   }
  case MODE_EMA:
   {
    if(ArrayResize(buf,total)<0) return 0;
    double pr=2.0/(period+1); int pos=total-2;
    while(pos>=0){if(pos==total-2) buf[pos+1]=array[pos+1];buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);pos--;}
    return buf[shift+ma_shift];
   }
  case MODE_SMMA:
   {
    if(ArrayResize(buf,total)<0) return 0;
    double sum=0; int i,k,pos=total-period;
    while(pos>=0){if(pos==total-period){for(i=0,k=pos;i<period;i++,k++){sum+=array[k];buf[k]=0;}}else sum=buf[pos+1]*(period-1)+array[pos];buf[pos]=sum/period;pos--;}
    return buf[shift+ma_shift];
   }
  case MODE_LWMA:
   {
    if(ArrayResize(buf,total)<0) return 0;
    double sum=0,lsum=0,price; int i,weight=0,pos=total-1;
    for(i=1;i<=period;i++,pos--){price=array[pos];sum+=price*i;lsum+=price;weight+=i;}
    pos++; i=pos+period;
    while(pos>=0){buf[pos]=sum/weight;if(pos==0) break;pos--;i--;price=array[pos];sum=sum-lsum+price*period;lsum-=array[i];lsum+=price;}
    return buf[shift+ma_shift];
   }
 }
 return 0;
}

bool IsNewBar()
{
 datetime t=iTime(_Symbol,PERIOD_CURRENT,0);
 if(prevTime!=t){prevTime=t;return true;}
 return false;
}

int GetSignal()
{
 double close=iClose(_Symbol,PERIOD_CURRENT,1);
 if(close>fastMA[1] && fastMA[2]<=slowMA[2] && fastMA[1]>slowMA[1] &&
    (!use_ma_filter || close>A11_iMAOnArray(period_ma_filter,0,mode_ma_filter,1))) return ORDER_TYPE_BUY;
 if(close<fastMA[1] && fastMA[2]>=slowMA[2] && fastMA[1]<slowMA[1] &&
    (!use_ma_filter || close<A11_iMAOnArray(period_ma_filter,0,mode_ma_filter,1))) return ORDER_TYPE_SELL;
 if(useFastMAexit && v_open)
 {
  if(v_type==POSITION_TYPE_BUY && close<=fastMA[1])
  {
   double p=SymbolInfoDouble(_Symbol,SYMBOL_BID); g_exits++; v_open=false;
   PrintFormat("[A11_NOORDERS_EXIT] no=%I64d reason=FAST_MA dir=BUY price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_exits,p);
  }
  else if(v_type==POSITION_TYPE_SELL && close>=fastMA[1])
  {
   double p=SymbolInfoDouble(_Symbol,SYMBOL_ASK); g_exits++; v_open=false;
   PrintFormat("[A11_NOORDERS_EXIT] no=%I64d reason=FAST_MA dir=SELL price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_exits,p);
  }
 }
 return -1;
}

void ProcessVirtual(int signal)
{
 ENUM_POSITION_TYPE want=(signal==ORDER_TYPE_BUY ? POSITION_TYPE_BUY : POSITION_TYPE_SELL);
 bool hasSame=(v_open && v_type==want);
 if(v_open && v_type!=want)
 {
  double closePrice=(v_type==POSITION_TYPE_BUY ? SymbolInfoDouble(_Symbol,SYMBOL_BID) : SymbolInfoDouble(_Symbol,SYMBOL_ASK));
  g_exits++;
  PrintFormat("[A11_NOORDERS_EXIT] no=%I64d reason=OPPOSITE dir=%s price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_exits,(v_type==POSITION_TYPE_BUY?"BUY":"SELL"),closePrice);
  v_open=false;
 }
 if(!hasSame)
 {
  double price=(signal==ORDER_TYPE_BUY ? SymbolInfoDouble(_Symbol,SYMBOL_ASK) : SymbolInfoDouble(_Symbol,SYMBOL_BID));
  v_open=true; v_type=want; v_entry=price; g_entries++;
  PrintFormat("[A11_NOORDERS_ENTRY] no=%I64d dir=%s price=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",g_entries,(signal==ORDER_TYPE_BUY?"BUY":"SELL"),price);
 }
}

int OnInit()
{
 if(period_ma_fast>=period_ma_slow || period_ma_fast<1 || period_ma_slow<1) return INIT_PARAMETERS_INCORRECT;
 if(takeProfit<0 || stopLoss<0 || maxLotSize<0.01 || minEquity<10) return INIT_PARAMETERS_INCORRECT;
 hFastMA=iMA(_Symbol,PERIOD_CURRENT,period_ma_fast,0,mode_ma,PRICE_CLOSE);
 hSlowMA=iMA(_Symbol,PERIOD_CURRENT,period_ma_slow,0,mode_ma,PRICE_CLOSE);
 if(hFastMA==INVALID_HANDLE || hSlowMA==INVALID_HANDLE) return INIT_FAILED;
 int digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
 myPoint=(StringFind(_Symbol,"XAU")>=0 || StringFind(_Symbol,"XAG")>=0)?0.1:((digits==5||digits==3)?_Point*10:_Point);
 Print("[A11_NOORDERS_START] NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}

void OnTick()
{
 g_ticks++;
 ArraySetAsSeries(fastMA,true); ArraySetAsSeries(slowMA,true);
 if(CopyBuffer(hFastMA,0,0,3,fastMA)<0) Print("CopyBuffer Fast MA error =",GetLastError());
 if(CopyBuffer(hSlowMA,0,0,3,slowMA)<0) Print("CopyBuffer SlowEMA error =",GetLastError());
 if(AccountInfoDouble(ACCOUNT_EQUITY)<minEquity) return;
 if(!IsNewBar()) return;
 g_newbars++;
 int signal=GetSignal();
 if(signal==-1) return;
 g_raw++;
 ProcessVirtual(signal);
}

void OnDeinit(const int reason)
{
 PrintFormat("[A11_NOORDERS_SUMMARY] ticks=%I64d newbars=%I64d raw=%I64d entries=%I64d exits=%I64d open=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
             g_ticks,g_newbars,g_raw,g_entries,g_exits,(int)v_open,reason);
 if(hFastMA!=INVALID_HANDLE) IndicatorRelease(hFastMA);
 if(hSlowMA!=INVALID_HANDLE) IndicatorRelease(hSlowMA);
}
//+------------------------------------------------------------------+
