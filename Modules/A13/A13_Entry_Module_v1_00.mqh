//+------------------------------------------------------------------+
//| A13 Entry Module v1.00                                          |
//| Renko + Dual MA entry decision extracted from verified A13.      |
//| SAFETY: NO_ORDERS. No broker execution functions.                |
//+------------------------------------------------------------------+
#ifndef __A13_ENTRY_MODULE_V1_00_MQH__
#define __A13_ENTRY_MODULE_V1_00_MQH__

struct SA13EntryBrick { double open,close; int direction,run; };
const int A13_ENTRY_MAX_BRICKS_PER_TICK=4096;

class CA13Entry
{
 private:
  double m_tick_size,m_effective_brick,m_closes[];
  long m_size,m_close;
  int m_dir,m_run,m_fast,m_slow,m_count,m_entry_run;
  double m_min_sep;
  bool m_anchor,m_failed;
 public:
  CA13Entry(){m_tick_size=0;m_effective_brick=0;m_size=0;m_close=0;m_dir=0;m_run=0;m_fast=0;m_slow=0;m_count=0;m_entry_run=0;m_min_sep=0;m_anchor=false;m_failed=false;}
  bool Init(const double tick_size,const double requested_brick,const int fast_period,const int slow_period,const double min_sep_bricks,const int entry_run)
  {
   if(!MathIsValidNumber(tick_size)||tick_size<=0||!MathIsValidNumber(requested_brick)||requested_brick<=0)return false;
   const double ur=requested_brick/tick_size;if(!MathIsValidNumber(ur)||ur<0.5||ur>1e9)return false;
   if(fast_period<2||fast_period>100||slow_period<3||slow_period>250||fast_period>=slow_period||entry_run<1||entry_run>50||!MathIsValidNumber(min_sep_bricks)||min_sep_bricks<0)return false;
   m_tick_size=tick_size;m_size=(long)MathMax(1.0,MathRound(ur));m_effective_brick=(double)m_size*tick_size;
   m_close=0;m_dir=0;m_run=0;m_anchor=false;m_failed=false;m_fast=fast_period;m_slow=slow_period;m_count=0;m_entry_run=entry_run;m_min_sep=min_sep_bricks;
   return ArrayResize(m_closes,m_slow)==m_slow;
  }
  double EffectiveBrick(){return m_effective_brick;}
  bool Failed(){return m_failed;}

  int PushMA(const SA13EntryBrick &b)
  {
   if(m_count<m_slow){m_closes[m_count]=b.close;m_count++;}else{for(int i=1;i<m_slow;i++)m_closes[i-1]=m_closes[i];m_closes[m_slow-1]=b.close;}
   if(m_count<m_slow)return 0;
   double ss=0,fs=0;const int start=m_slow-m_fast;
   for(int i=0;i<m_slow;i++){ss+=m_closes[i];if(i>=start)fs+=m_closes[i];}
   const double fv=fs/(double)m_fast,sv=ss/(double)m_slow,sep=m_min_sep*m_effective_brick,eps=1e-9;
   if(fv>sv+sep-eps)return 1;if(fv<sv-sep+eps)return -1;return 0;
  }

  int PushBid(const double price,int &brick_count,int &final_alignment)
  {
   brick_count=0;final_alignment=0;if(m_failed)return 0;
   const long p=(long)MathRound(price/m_tick_size);
   if(!m_anchor){m_close=p;m_anchor=true;return 0;}
   const long delta=p-m_close;int dir=m_dir;long count=0;bool reversal=false;
   if(m_dir==0){if(delta>=m_size){dir=1;count=delta/m_size;}else if(delta<=-m_size){dir=-1;count=(-delta)/m_size;}}
   else if(m_dir>0){if(delta>=m_size)count=delta/m_size;else if(delta<=-2*m_size){dir=-1;reversal=true;count=(-delta)/m_size-1;}}
   else {if(delta<=-m_size)count=(-delta)/m_size;else if(delta>=2*m_size){dir=1;reversal=true;count=delta/m_size-1;}}
   if(count>A13_ENTRY_MAX_BRICKS_PER_TICK){m_failed=true;return 0;}if(count==0)return 0;
   brick_count=(int)count;int final_signal=0;
   for(int i=0;i<brick_count;i++)
   {
    const long op=m_close+((reversal&&i==0)?dir*m_size:0);m_close=op+dir*m_size;
    if(dir==m_dir)m_run++;else{m_dir=dir;m_run=1;}
    SA13EntryBrick b;b.open=op*m_tick_size;b.close=m_close*m_tick_size;b.direction=dir;b.run=m_run;
    final_alignment=PushMA(b);final_signal=0;
    if(final_alignment!=0&&b.direction==final_alignment&&b.run>=m_entry_run)final_signal=final_alignment;
   }
   return final_signal;
  }
};
#endif
