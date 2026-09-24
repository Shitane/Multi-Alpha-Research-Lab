//+------------------------------------------------------------------+
//| A15_Entry_Module_v1_00.mqh                                      |
//| Extracted from A12_Modular_v152_A15_Lifecycle_Boundary_NoOrders |
//| Research-only decision module. NO ORDER OPERATIONS.              |
//| Logic intentionally preserved; no optimization/refactoring.      |
//+------------------------------------------------------------------+
#ifndef A15_ENTRY_MODULE_V1_00_MQH
#define A15_ENTRY_MODULE_V1_00_MQH

struct SA15Brick
  {
   double open;
   double close;
   int    direction; // +1 up, -1 down
   int    run;       // consecutive bricks in current direction
  };

class CA15RenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;
   int    m_run;

   void AddBrick(SA15Brick &out[],const double open_price,
                 const double close_price,const int direction)
     {
      if(direction==m_last_dir)
         m_run++;
      else
        {
         m_last_dir=direction;
         m_run=1;
        }

      const int n=ArraySize(out);
      ArrayResize(out,n+1);
      out[n].open=NormalizeDouble(open_price,_Digits);
      out[n].close=NormalizeDouble(close_price,_Digits);
      out[n].direction=direction;
      out[n].run=m_run;
     }

public:
   void Init(const double brick_size)
     {
      m_size=brick_size;
      m_has_anchor=false;
      m_anchor=0.0;
      m_last_close=0.0;
      m_last_dir=0;
      m_run=0;
     }

   int PushPrice(const double price,SA15Brick &out[])
     {
      ArrayResize(out,0);
      if(m_size<=0.0 || price<=0.0)
         return 0;

      if(!m_has_anchor)
        {
         m_anchor=price;
         m_has_anchor=true;
         return 0;
        }

      int added=0;

      // First direction: one full brick from the starting anchor.
      if(m_last_dir==0)
        {
         while(price>=m_anchor+m_size)
           {
            const double brick_open=m_anchor;
            m_anchor+=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,+1);
            added++;
           }

         while(price<=m_anchor-m_size)
           {
            const double brick_open=m_anchor;
            m_anchor-=m_size;
            m_last_close=m_anchor;
            AddBrick(out,brick_open,m_last_close,-1);
            added++;
           }
         return added;
        }

      bool changed=true;
      while(changed)
        {
         changed=false;

         if(m_last_dir>0)
           {
            if(price>=m_last_close+m_size)
              {
               const double brick_open=m_last_close;
               m_last_close+=m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               const double brick_open=m_last_close-m_size;
               m_last_close-=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               const double brick_open=m_last_close;
               m_last_close-=m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++;
               changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               const double brick_open=m_last_close+m_size;
               m_last_close+=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++;
               changed=true;
              }
           }
        }

      return added;
     }
  };

class CA15EntryModule
  {
private:
   int m_max_history;
   SA15Brick m_history[];
   int m_donchian_period;
   double m_breakout_buffer_bricks;
   double m_brick_size;
   int m_entry_run_bricks;

   void PushHistory(const SA15Brick &brick)
     {
      int n=ArraySize(m_history);
      if(n>=m_max_history)
        {
         for(int i=1;i<n;i++) m_history[i-1]=m_history[i];
         n--;
         ArrayResize(m_history,n);
        }
      ArrayResize(m_history,n+1);
      m_history[n]=brick;
     }

   bool GetDonchian(const int lookback,double &upper,double &lower)
     {
      const int n=ArraySize(m_history);
      if(lookback<1 || n<lookback) return false;
      upper=-1.0e100; lower=1.0e100;
      const int first=n-lookback;
      for(int i=first;i<n;i++)
        {
         const double high=MathMax(m_history[i].open,m_history[i].close);
         const double low=MathMin(m_history[i].open,m_history[i].close);
         if(high>upper) upper=high;
         if(low<lower) lower=low;
        }
      return true;
     }

public:
   void Init(const double brick_size,
             const int donchian_period,
             const double breakout_buffer_bricks,
             const int entry_run_bricks)
     {
      m_brick_size=brick_size;
      m_donchian_period=donchian_period;
      m_breakout_buffer_bricks=breakout_buffer_bricks;
      m_entry_run_bricks=entry_run_bricks;
      m_max_history=512;
      ArrayResize(m_history,0);
     }

   int ProcessCompletedBrick(const SA15Brick &brick)
     {
      double upper=0.0,lower=0.0;
      int signal=0;
      if(GetDonchian(m_donchian_period,upper,lower))
        {
         const double buffer=m_breakout_buffer_bricks*m_brick_size;
         if(brick.direction>0 && brick.run>=m_entry_run_bricks && brick.close>upper+buffer)
            signal=+1;
         else if(brick.direction<0 && brick.run>=m_entry_run_bricks && brick.close<lower-buffer)
            signal=-1;
        }
      // Original v1.11/v1.52 behavior: append AFTER channel test.
      PushHistory(brick);
      return signal;
     }
  };

#endif // A15_ENTRY_MODULE_V1_00_MQH
