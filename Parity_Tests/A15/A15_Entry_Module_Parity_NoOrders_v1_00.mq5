//+------------------------------------------------------------------+
//| A15_Entry_Module_Parity_NoOrders_v1_00.mq5                       |
//| Compares frozen v1.52-style A15 entry logic with extracted       |
//| A15_Entry_Module_v1_00.mqh. Research only. NO ORDERS.            |
//+------------------------------------------------------------------+
#property strict

#include "..\..\Include\A15_Entry_Module_v1_00.mqh"

input double InpA15BrickSize=14.0;
input int    InpA15DonchianPeriod=25;
input double InpA15BreakoutBufferBricks=0.20;
input int    InpA15EntryRunBricks=1;

const int BASE_MAX_HISTORY=512;

struct SBaseBrick
  {
   double open;
   double close;
   int    direction;
   int    run;
  };

class CBaseRenkoBuilder
  {
private:
   double m_size;
   bool   m_has_anchor;
   double m_anchor;
   double m_last_close;
   int    m_last_dir;
   int    m_run;

   void AddBrick(SBaseBrick &out[],const double open_price,
                 const double close_price,const int direction)
     {
      if(direction==m_last_dir) m_run++;
      else { m_last_dir=direction; m_run=1; }

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

   int PushPrice(const double price,SBaseBrick &out[])
     {
      ArrayResize(out,0);
      if(m_size<=0.0 || price<=0.0) return 0;
      if(!m_has_anchor)
        {
         m_anchor=price;
         m_has_anchor=true;
         return 0;
        }

      int added=0;
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
               added++; changed=true;
              }
            else if(price<=m_last_close-2.0*m_size)
              {
               const double brick_open=m_last_close-m_size;
               m_last_close-=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++; changed=true;
              }
           }
         else
           {
            if(price<=m_last_close-m_size)
              {
               const double brick_open=m_last_close;
               m_last_close-=m_size;
               AddBrick(out,brick_open,m_last_close,-1);
               added++; changed=true;
              }
            else if(price>=m_last_close+2.0*m_size)
              {
               const double brick_open=m_last_close+m_size;
               m_last_close+=2.0*m_size;
               AddBrick(out,brick_open,m_last_close,+1);
               added++; changed=true;
              }
           }
        }
      return added;
     }
  };

CBaseRenkoBuilder g_base_renko;
SBaseBrick g_base_history[];
CA15RenkoBuilder g_mod_renko;
CA15EntryModule g_mod_entry;

long g_ticks=0;
long g_bricks=0;
long g_brick_mismatch=0;
long g_signal_checks=0;
long g_signal_mismatch=0;
long g_base_signals=0;
long g_mod_signals=0;

void BasePushHistory(const SBaseBrick &brick)
  {
   int n=ArraySize(g_base_history);
   if(n>=BASE_MAX_HISTORY)
     {
      for(int i=1;i<n;i++) g_base_history[i-1]=g_base_history[i];
      n--;
      ArrayResize(g_base_history,n);
     }
   ArrayResize(g_base_history,n+1);
   g_base_history[n]=brick;
  }

bool BaseGetDonchian(const int lookback,double &upper,double &lower)
  {
   const int n=ArraySize(g_base_history);
   if(lookback<1 || n<lookback) return false;
   upper=-1.0e100; lower=1.0e100;
   const int first=n-lookback;
   for(int i=first;i<n;i++)
     {
      const double high=MathMax(g_base_history[i].open,g_base_history[i].close);
      const double low=MathMin(g_base_history[i].open,g_base_history[i].close);
      if(high>upper) upper=high;
      if(low<lower) lower=low;
     }
   return true;
  }

int BaseProcessCompletedBrick(const SBaseBrick &brick)
  {
   double upper=0.0,lower=0.0;
   int signal=0;
   if(BaseGetDonchian(InpA15DonchianPeriod,upper,lower))
     {
      const double buffer=InpA15BreakoutBufferBricks*InpA15BrickSize;
      if(brick.direction>0 && brick.run>=InpA15EntryRunBricks && brick.close>upper+buffer)
         signal=+1;
      else if(brick.direction<0 && brick.run>=InpA15EntryRunBricks && brick.close<lower-buffer)
         signal=-1;
     }
   BasePushHistory(brick); // frozen v1.52 order: append AFTER channel test
   return signal;
  }

int OnInit()
  {
   ArrayResize(g_base_history,0);
   g_base_renko.Init(InpA15BrickSize);
   g_mod_renko.Init(InpA15BrickSize);
   g_mod_entry.Init(InpA15BrickSize,InpA15DonchianPeriod,
                    InpA15BreakoutBufferBricks,InpA15EntryRunBricks);
   PrintFormat("[A15_ENTRY_MODULE_PARITY_START] brick=%.8f donchian=%d buffer=%.8f run=%d NO_ORDERS=1",
               InpA15BrickSize,InpA15DonchianPeriod,
               InpA15BreakoutBufferBricks,InpA15EntryRunBricks);
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick) || tick.bid<=0.0) return;
   g_ticks++;

   SBaseBrick base[];
   SA15Brick mod[];
   const int nb=g_base_renko.PushPrice(tick.bid,base);
   const int nm=g_mod_renko.PushPrice(tick.bid,mod);

   if(nb!=nm)
     {
      g_brick_mismatch++;
      PrintFormat("[A15_ENTRY_MODULE_BRICK_COUNT_DIFF] time_msc=%I64d baseline=%d module=%d bid=%.8f NO_ORDERS=1",
                  tick.time_msc,nb,nm,tick.bid);
     }

   const int common=MathMin(nb,nm);
   for(int i=0;i<common;i++)
     {
      g_bricks++;
      const bool brick_same=
         (base[i].open==mod[i].open &&
          base[i].close==mod[i].close &&
          base[i].direction==mod[i].direction &&
          base[i].run==mod[i].run);
      if(!brick_same)
        {
         g_brick_mismatch++;
         PrintFormat("[A15_ENTRY_MODULE_BRICK_DIFF] time_msc=%I64d index=%d base_open=%.8f mod_open=%.8f base_close=%.8f mod_close=%.8f base_dir=%d mod_dir=%d base_run=%d mod_run=%d NO_ORDERS=1",
                     tick.time_msc,i,base[i].open,mod[i].open,base[i].close,mod[i].close,
                     base[i].direction,mod[i].direction,base[i].run,mod[i].run);
        }

      const int bs=BaseProcessCompletedBrick(base[i]);
      const int ms=g_mod_entry.ProcessCompletedBrick(mod[i]);
      g_signal_checks++;
      if(bs!=0) g_base_signals++;
      if(ms!=0) g_mod_signals++;
      if(bs!=ms)
        {
         g_signal_mismatch++;
         PrintFormat("[A15_ENTRY_MODULE_SIGNAL_DIFF] time_msc=%I64d index=%d baseline=%d module=%d close=%.8f dir=%d run=%d NO_ORDERS=1",
                     tick.time_msc,i,bs,ms,mod[i].close,mod[i].direction,mod[i].run);
        }
     }
  }

void OnDeinit(const int reason)
  {
   PrintFormat("[A15_ENTRY_MODULE_PARITY_SUMMARY] ticks=%I64d bricks=%I64d brick_mismatch=%I64d signal_checks=%I64d signal_mismatch=%I64d baseline_signals=%I64d module_signals=%I64d NO_ORDERS=1",
               g_ticks,g_bricks,g_brick_mismatch,g_signal_checks,g_signal_mismatch,
               g_base_signals,g_mod_signals);
  }
