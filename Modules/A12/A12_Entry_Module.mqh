// A12 Entry Module - research-only, no trading operations.
// Renko builder and Wilder ADX definitions below are copied verbatim
// from A12_Step12_Original_TradingDecision_Audit(3).mq5 lines 29-276.
#ifndef A12_ENTRY_MODULE_MQH
#define A12_ENTRY_MODULE_MQH

struct SRenkoBrick
  {
   double open;
   double close;
   int    direction; // +1 up, -1 down
   int    run;       // consecutive bricks in current direction
  };

//+------------------------------------------------------------------+
//| Classic fixed-size Renko builder, two-brick reversal             |
//+------------------------------------------------------------------+
const int MAX_BRICKS_PER_TICK=4096;
class CRenkoBuilder
  {
private:
   double m_tick_size;
   long   m_size,m_close;
   int    m_dir,m_run;
   bool   m_anchor;
public:
   void Init(const double tick_size,const long size)
     {
      m_tick_size=tick_size;
      m_size=size;
      m_close=0;
      m_dir=0;
      m_run=0;
      m_anchor=false;
     }

   int PushPrice(const double price,SRenkoBrick &out[])
     {
      ArrayResize(out,0);
      const long p=(long)MathRound(price/m_tick_size);
      if(!m_anchor)
        {
         m_close=p;
         m_anchor=true;
         return 0;
        }

      const long delta=p-m_close;
      int dir=m_dir;
      long count=0;
      bool reversal=false;

      if(m_dir==0)
        {
         if(delta>=m_size) { dir=1; count=delta/m_size; }
         else if(delta<=-m_size) { dir=-1; count=(-delta)/m_size; }
        }
      else if(m_dir>0)
        {
         if(delta>=m_size) count=delta/m_size;
         else if(delta<=-2*m_size)
           {
            dir=-1;
            reversal=true;
            count=(-delta)/m_size-1;
           }
        }
      else
        {
         if(delta<=-m_size) count=(-delta)/m_size;
         else if(delta>=2*m_size)
           {
            dir=1;
            reversal=true;
            count=delta/m_size-1;
           }
        }

      if(count>MAX_BRICKS_PER_TICK) return -1;
      if(count==0) return 0;
      if(ArrayResize(out,(int)count)!=(int)count) return -1;

      for(int i=0;i<(int)count;i++)
        {
         const long open=m_close+((reversal && i==0) ? dir*m_size : 0);
         m_close=open+dir*m_size;
         if(dir==m_dir) m_run++;
         else
           {
            m_dir=dir;
            m_run=1;
           }

         out[i].open=open*m_tick_size;
         out[i].close=m_close*m_tick_size;
         out[i].direction=dir;
         out[i].run=m_run;
        }
      return (int)count;
     }
  };

//+------------------------------------------------------------------+
//| Wilder ADX calculated only from completed synthetic Renko OHLC   |
//+------------------------------------------------------------------+
class CRenkoADX
  {
private:
   int    m_period;
   int    m_tr_count;
   int    m_dx_count;
   bool   m_have_prev;
   bool   m_ready;
   double m_prev_high;
   double m_prev_low;
   double m_prev_close;
   double m_sm_tr;
   double m_sm_plus_dm;
   double m_sm_minus_dm;
   double m_dx_sum;
   double m_adx;
   double m_plus_di;
   double m_minus_di;

   double Max3(const double a,const double b,const double c)
     {
      return MathMax(a,MathMax(b,c));
     }

   double ComputeDX(void)
     {
      if(m_sm_tr<=1.0e-12)
        {
         m_plus_di=0.0;
         m_minus_di=0.0;
         return 0.0;
        }

      m_plus_di=100.0*m_sm_plus_dm/m_sm_tr;
      m_minus_di=100.0*m_sm_minus_dm/m_sm_tr;
      const double total=m_plus_di+m_minus_di;
      if(total<=1.0e-12) return 0.0;
      return 100.0*MathAbs(m_plus_di-m_minus_di)/total;
     }

public:
   void Init(const int period)
     {
      m_period=period;
      m_tr_count=0;
      m_dx_count=0;
      m_have_prev=false;
      m_ready=false;
      m_prev_high=0.0;
      m_prev_low=0.0;
      m_prev_close=0.0;
      m_sm_tr=0.0;
      m_sm_plus_dm=0.0;
      m_sm_minus_dm=0.0;
      m_dx_sum=0.0;
      m_adx=0.0;
      m_plus_di=0.0;
      m_minus_di=0.0;
     }

   void Push(const SRenkoBrick &brick)
     {
      const double high=MathMax(brick.open,brick.close);
      const double low=MathMin(brick.open,brick.close);
      const double close=brick.close;

      if(!m_have_prev)
        {
         m_prev_high=high;
         m_prev_low=low;
         m_prev_close=close;
         m_have_prev=true;
         return;
        }

      const double tr=Max3(high-low,MathAbs(high-m_prev_close),MathAbs(low-m_prev_close));
      const double up_move=high-m_prev_high;
      const double down_move=m_prev_low-low;
      const double plus_dm=(up_move>down_move && up_move>0.0 ? up_move : 0.0);
      const double minus_dm=(down_move>up_move && down_move>0.0 ? down_move : 0.0);

      m_prev_high=high;
      m_prev_low=low;
      m_prev_close=close;

      if(m_tr_count<m_period)
        {
         m_sm_tr+=tr;
         m_sm_plus_dm+=plus_dm;
         m_sm_minus_dm+=minus_dm;
         m_tr_count++;

         if(m_tr_count==m_period)
           {
            const double dx=ComputeDX();
            m_dx_sum=dx;
            m_dx_count=1;
            if(m_period==1)
              {
               m_adx=dx;
               m_ready=true;
              }
           }
         return;
        }

      m_sm_tr=m_sm_tr-m_sm_tr/(double)m_period+tr;
      m_sm_plus_dm=m_sm_plus_dm-m_sm_plus_dm/(double)m_period+plus_dm;
      m_sm_minus_dm=m_sm_minus_dm-m_sm_minus_dm/(double)m_period+minus_dm;
      const double dx=ComputeDX();

      if(!m_ready)
        {
         m_dx_sum+=dx;
         m_dx_count++;
         if(m_dx_count>=m_period)
           {
            m_adx=m_dx_sum/(double)m_period;
            m_ready=true;
           }
         return;
        }

      m_adx=((double)(m_period-1)*m_adx+dx)/(double)m_period;
     }

   bool Ready(void) const { return m_ready; }
   double ADX(void) const { return m_adx; }
   double PlusDI(void) const { return m_plus_di; }
   double MinusDI(void) const { return m_minus_di; }

   int Direction(const double adx_threshold,const double min_di_separation) const
     {
      if(!m_ready || m_adx<adx_threshold) return 0;
      if(MathAbs(m_plus_di-m_minus_di)<min_di_separation) return 0;
      if(m_plus_di>m_minus_di) return 1;
      if(m_minus_di>m_plus_di) return -1;
      return 0;
     }

   int RawDirection(void) const
     {
      if(!m_ready) return 0;
      if(m_plus_di>m_minus_di) return 1;
      if(m_minus_di>m_plus_di) return -1;
      return 0;
     }
  };

// Original ProcessCompletedBrick entry predicate, with dependencies injected.
int A12_ProcessCompletedBrick(CRenkoADX &adx,const SRenkoBrick &brick,
                             const double adx_threshold,const double min_di_separation,
                             const int entry_run_bricks,int &raw_direction)
  {
   adx.Push(brick);
   raw_direction=adx.RawDirection();
   const int direction=adx.Direction(adx_threshold,min_di_separation);
   if(direction==0) return 0;
   if(brick.direction!=direction) return 0;
   if(brick.run<entry_run_bricks) return 0;
   return direction;
  }
#endif // A12_ENTRY_MODULE_MQH
