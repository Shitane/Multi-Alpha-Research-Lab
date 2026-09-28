//+------------------------------------------------------------------+
//| A10_Full_Module_v1_01.mqh                                       |
//| Independent whole-path A10 reference module for Multi Alpha.     |
//| Uses verified whole A10 engines; does NOT call SPLIT modules.     |
//| NO BROKER ORDER OPERATIONS.                                      |
//+------------------------------------------------------------------+
#ifndef A10_FULL_MODULE_V1_01_MQH
#define A10_FULL_MODULE_V1_01_MQH
#include "A10_Bollinger_Module_v1_01.mqh"

struct SA10FullModeConfig100
  {
   bool enabled; double brick; int bb_period; double deviation;
   double squeeze_width; int entry_run; double tp; double sl;
   int max_hold; int cooldown; double max_spread;
  };

struct SA10FullConfig100
  {
   int max_positions;
   bool skip_opposite;
   int entry_ttl_seconds;
   SA10FullModeConfig100 mode[4];
  };

struct SA10FullEvent100
  {
   bool valid;
   bool is_entry;
   int mode;
   int direction;
   string reason;
   double price;
   ulong ticket;
  };

class CA10FullModule100
  {
private:
   CA10ModeEngine m_engine[4];
   SA10FullConfig100 m_cfg;
   bool m_open[4];
   int m_dir[4],m_pending_dir[4];
   double m_price[4];
   datetime m_time[4],m_pending_time[4];
   ulong m_ticket[4],m_next_ticket;
   bool m_exit_pending[4];
   string m_exit_reason[4];
   long m_ticks,m_entries,m_exits,m_entries_mode[4],m_exits_mode[4];
   bool m_ready;

   int OpenCountInternal() const {int n=0;for(int i=0;i<4;i++)if(m_open[i])n++;return n;}
   int PendingCount() const {int n=0;for(int i=0;i<4;i++)if(m_pending_dir[i]!=0)n++;return n;}
   bool AnyExit() const {for(int i=0;i<4;i++)if(m_exit_pending[i])return true;return false;}
   bool SpreadOK(const int mode,const MqlTick &t) const
     {return mode>=0&&mode<4&&m_engine[mode].Enabled()&&
             (t.ask-t.bid)<=m_engine[mode].Brick()*m_engine[mode].Spread();}

   void ClearPending(const int mode){m_pending_dir[mode]=0;m_pending_time[mode]=0;}
   void RequestExit(const int mode,const string reason)
     {if(mode<0||mode>3||!m_open[mode])return;m_exit_pending[mode]=true;m_exit_reason[mode]=reason;ClearPending(mode);}

   bool CompleteOneExit(const MqlTick &t,SA10FullEvent100 &e)
     {
      for(int mode=0;mode<4;mode++)
        {
         if(!m_exit_pending[mode])continue;
         e.valid=true;e.is_entry=false;e.mode=mode;e.direction=m_dir[mode];
         e.reason=m_exit_reason[mode];e.price=(m_dir[mode]>0?t.bid:t.ask);e.ticket=m_ticket[mode];
         m_open[mode]=false;m_dir[mode]=0;m_price[mode]=0;m_time[mode]=0;m_ticket[mode]=0;
         m_exit_pending[mode]=false;m_exit_reason[mode]="";m_engine[mode].StartCooldown();
         m_exits++;m_exits_mode[mode]++;
         return true;
        }
      return false;
     }

   void PriceExits(const MqlTick &t)
     {
      for(int mode=0;mode<4;mode++)
        {
         if(!m_open[mode]||m_exit_pending[mode])continue;
         const double px=(m_dir[mode]>0?t.bid:t.ask);
         const double move=m_dir[mode]*(px-m_price[mode]);
         const double brick=m_engine[mode].Brick();
         if(m_engine[mode].TP()*brick>0&&move>=m_engine[mode].TP()*brick){RequestExit(mode,"TP");continue;}
         if(m_engine[mode].SL()*brick>0&&move<=-m_engine[mode].SL()*brick){RequestExit(mode,"SL");continue;}
         if(m_engine[mode].Hold()>0&&m_time[mode]>0&&
            (long)(TimeCurrent()-m_time[mode])>=(long)m_engine[mode].Hold()*60)
            RequestExit(mode,"TIME");
        }
     }

   void SignalExit(const int mode,const SA10TickResult &r)
     {
      if(r.completed<=0||!m_open[mode]||m_exit_pending[mode])return;
      if(mode==A10_REENTRY&&r.bb_ready)
        {
         if((m_dir[mode]>0&&r.final_close>=r.bb_mid)||(m_dir[mode]<0&&r.final_close<=r.bb_mid))
            RequestExit(mode,"BB_MID");
        }
      else if(r.raw_signal!=0&&r.raw_signal==-m_dir[mode]) RequestExit(mode,"BB_OPPOSITE");
     }

   void Queue(const int &signals[],const MqlTick &t)
     {
      bool candidate[4]={false,false,false,false},lng=false,shrt=false;
      for(int mode=0;mode<4;mode++)
        {
         if(!m_engine[mode].Enabled()||m_engine[mode].Cooldown()>0||signals[mode]==0)continue;
         if(m_open[mode]||m_pending_dir[mode]!=0||m_exit_pending[mode]||!SpreadOK(mode,t))continue;
         candidate[mode]=true;if(signals[mode]>0)lng=true;else shrt=true;
        }
      if(m_cfg.skip_opposite&&lng&&shrt)return;
      int free_slots=m_cfg.max_positions-OpenCountInternal()-PendingCount();
      for(int mode=0;mode<4&&free_slots>0;mode++)if(candidate[mode])
        {m_pending_dir[mode]=signals[mode];m_pending_time[mode]=TimeCurrent();free_slots--;}
     }

   bool CompleteOneEntry(const MqlTick &t,SA10FullEvent100 &e)
     {
      if(AnyExit()||OpenCountInternal()>=m_cfg.max_positions)return false;
      const datetime now=TimeCurrent();
      for(int mode=0;mode<4;mode++)
        {
         const int d=m_pending_dir[mode];if(d==0)continue;
         if(m_pending_time[mode]>0&&(long)(now-m_pending_time[mode])>(long)m_cfg.entry_ttl_seconds)
           {ClearPending(mode);continue;}
         if(!m_engine[mode].Enabled()||m_engine[mode].Cooldown()>0||m_open[mode])
           {ClearPending(mode);continue;}
         if(!SpreadOK(mode,t))continue;
         m_open[mode]=true;m_dir[mode]=d;m_price[mode]=(d>0?t.ask:t.bid);m_time[mode]=now;
         m_ticket[mode]=m_next_ticket++;ClearPending(mode);m_entries++;m_entries_mode[mode]++;
         e.valid=true;e.is_entry=true;e.mode=mode;e.direction=d;e.reason="ENTRY";
         e.price=m_price[mode];e.ticket=m_ticket[mode];return true;
        }
      return false;
     }

public:
   CA10FullModule100(){m_ready=false;}
   bool Init(const SA10FullConfig100 &cfg,const double tick_size)
     {
      if(tick_size<=0||cfg.max_positions<1||cfg.max_positions>4||cfg.entry_ttl_seconds<1)return false;
      m_cfg=cfg;
      for(int i=0;i<4;i++)
        {
         const ENUM_A10_BB_MODE mode=(ENUM_A10_BB_MODE)i;
         if(!m_engine[i].Configure(cfg.mode[i].enabled,mode,tick_size,cfg.mode[i].brick,
            cfg.mode[i].bb_period,cfg.mode[i].deviation,cfg.mode[i].squeeze_width,
            cfg.mode[i].entry_run,cfg.mode[i].tp,cfg.mode[i].sl,cfg.mode[i].max_hold,
            cfg.mode[i].cooldown,cfg.mode[i].max_spread))return false;
         m_open[i]=false;m_dir[i]=0;m_price[i]=0;m_time[i]=0;m_ticket[i]=0;
         m_pending_dir[i]=0;m_pending_time[i]=0;m_exit_pending[i]=false;m_exit_reason[i]="";
         m_entries_mode[i]=0;m_exits_mode[i]=0;
        }
      m_next_ticket=1;m_ticks=0;m_entries=0;m_exits=0;m_ready=true;return true;
     }

   // Returns at most one lifecycle event per tick, preserving one-request sequencing.
   bool OnTick(const MqlTick &t,SA10FullEvent100 &e)
     {
      e.valid=false;e.is_entry=false;e.mode=-1;e.direction=0;e.reason="";e.price=0;e.ticket=0;
      if(!m_ready||t.bid<=0||t.ask<t.bid)return false;m_ticks++;

      // Whole-path order is intentionally independent from SPLIT implementation.
      if(CompleteOneExit(t,e))return true;
      PriceExits(t);if(CompleteOneExit(t,e))return true;

      SA10TickResult r[4];
      for(int i=0;i<4;i++)m_engine[i].PushPrice(t.bid,r[i]);
      for(int i=0;i<4;i++)SignalExit(i,r[i]);
      if(CompleteOneExit(t,e))return true;

      int sig[4]={r[0].signal,r[1].signal,r[2].signal,r[3].signal};
      Queue(sig,t);
      return CompleteOneEntry(t,e);
     }

   bool Ready()const{return m_ready;}
   long Ticks()const{return m_ticks;} long Entries()const{return m_entries;} long Exits()const{return m_exits;}
   int OpenCount()const{return OpenCountInternal();}
   long ModeEntries(const int m)const{return (m>=0&&m<4?m_entries_mode[m]:0);}
   long ModeExits(const int m)const{return (m>=0&&m<4?m_exits_mode[m]:0);}
  };
#endif
