// A11 Entry Module v1.00 - source-faithful signal extraction, research-only, NO ORDERS.
#ifndef A11_ENTRY_MODULE_V1_00_MQH
#define A11_ENTRY_MODULE_V1_00_MQH

class CA11Entry
{
private:
 int m_fast_handle,m_slow_handle;
 datetime m_prev_time;
 double m_fast[],m_slow[];
 ENUM_TIMEFRAMES m_filter_tf;
 int m_filter_period;
 ENUM_MA_METHOD m_filter_method;
 bool m_use_filter;

 double MAOnArray(const int period,const int ma_shift,const ENUM_MA_METHOD method,const int shift)
 {
  MqlRates rates[]; int copied=CopyRates(_Symbol,m_filter_tf,0,m_filter_period+1,rates);
  double array[]; ArrayResize(array,copied);
  if(copied>0) for(int i=1;i<copied;i++) array[i]=rates[i-1].close;
  ArrayReverse(array,0,WHOLE_ARRAY);
  double buf[],arr[]; int total=ArraySize(array);
  if(total<=period) return 0;
  if(shift>total-period-ma_shift) return 0;
  switch(method)
  {
   case MODE_SMA:
   {
    total=ArrayCopy(arr,array,0,shift+ma_shift,period); if(ArrayResize(buf,total)<0) return 0;
    double sum=0; int i,pos=total-1; for(i=1;i<period;i++,pos--) sum+=arr[pos];
    while(pos>=0){sum+=arr[pos];buf[pos]=sum/period;sum-=arr[pos+period-1];pos--;} return buf[0];
   }
   case MODE_EMA:
   {
    if(ArrayResize(buf,total)<0) return 0; double pr=2.0/(period+1); int pos=total-2;
    while(pos>=0){if(pos==total-2) buf[pos+1]=array[pos+1];buf[pos]=array[pos]*pr+buf[pos+1]*(1-pr);pos--;}
    return buf[shift+ma_shift];
   }
   case MODE_SMMA:
   {
    if(ArrayResize(buf,total)<0) return 0; double sum=0; int i,k,pos=total-period;
    while(pos>=0){if(pos==total-period){for(i=0,k=pos;i<period;i++,k++){sum+=array[k];buf[k]=0;}}else sum=buf[pos+1]*(period-1)+array[pos];buf[pos]=sum/period;pos--;}
    return buf[shift+ma_shift];
   }
   case MODE_LWMA:
   {
    if(ArrayResize(buf,total)<0) return 0; double sum=0,lsum=0,price; int i,weight=0,pos=total-1;
    for(i=1;i<=period;i++,pos--){price=array[pos];sum+=price*i;lsum+=price;weight+=i;} pos++; i=pos+period;
    while(pos>=0){buf[pos]=sum/weight;if(pos==0) break;pos--;i--;price=array[pos];sum=sum-lsum+price*period;lsum-=array[i];lsum+=price;}
    return buf[shift+ma_shift];
   }
  }
  return 0;
 }

public:
 CA11Entry(){m_fast_handle=INVALID_HANDLE;m_slow_handle=INVALID_HANDLE;m_prev_time=0;}
 bool Init(const int fast_period,const int slow_period,const ENUM_MA_METHOD method,
           const bool use_filter,const ENUM_MA_METHOD filter_method,
           const ENUM_TIMEFRAMES filter_tf,const int filter_period)
 {
  m_use_filter=use_filter;m_filter_method=filter_method;m_filter_tf=filter_tf;m_filter_period=filter_period;m_prev_time=0;
  m_fast_handle=iMA(_Symbol,PERIOD_CURRENT,fast_period,0,method,PRICE_CLOSE);
  m_slow_handle=iMA(_Symbol,PERIOD_CURRENT,slow_period,0,method,PRICE_CLOSE);
  return(m_fast_handle!=INVALID_HANDLE && m_slow_handle!=INVALID_HANDLE);
 }
 void Release(){if(m_fast_handle!=INVALID_HANDLE) IndicatorRelease(m_fast_handle);if(m_slow_handle!=INVALID_HANDLE) IndicatorRelease(m_slow_handle);}
 bool Prepare()
 {
  ArraySetAsSeries(m_fast,true);ArraySetAsSeries(m_slow,true);
  if(CopyBuffer(m_fast_handle,0,0,3,m_fast)<0) return false;
  if(CopyBuffer(m_slow_handle,0,0,3,m_slow)<0) return false;
  return true;
 }
 bool IsNewBar()
 {
  datetime t=iTime(_Symbol,PERIOD_CURRENT,0); if(m_prev_time!=t){m_prev_time=t;return true;} return false;
 }
 int Signal()
 {
  double close=iClose(_Symbol,PERIOD_CURRENT,1);
  if(close>m_fast[1] && m_fast[2]<=m_slow[2] && m_fast[1]>m_slow[1] &&
     (!m_use_filter || close>MAOnArray(m_filter_period,0,m_filter_method,1))) return ORDER_TYPE_BUY;
  if(close<m_fast[1] && m_fast[2]>=m_slow[2] && m_fast[1]<m_slow[1] &&
     (!m_use_filter || close<MAOnArray(m_filter_period,0,m_filter_method,1))) return ORDER_TYPE_SELL;
  return -1;
 }
 double FastClosed() const {return m_fast[1];}
 double ClosedPrice() const {return iClose(_Symbol,PERIOD_CURRENT,1);}
};
#endif
