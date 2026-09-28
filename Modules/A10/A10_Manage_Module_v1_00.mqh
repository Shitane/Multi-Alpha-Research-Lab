//+------------------------------------------------------------------+
//| A10_Manage_Module_v1_00.mqh                                     |
//| Source-faithful A10 lifecycle/queue coordinator.                 |
//| Research-only. NO BROKER ORDER OPERATIONS.                       |
//+------------------------------------------------------------------+
#ifndef A10_MANAGE_MODULE_V1_00_MQH
#define A10_MANAGE_MODULE_V1_00_MQH

#define A10_MANAGE_MODE_COUNT 4

struct SA10ManageModeConfig100
  {
   bool   enabled;
   int    cooldown_bricks;
   double max_spread_fraction;
   double effective_brick;
  };

struct SA10ManagePosition100
  {
   bool     open;
   int      direction;
   double   open_price;
   datetime open_time;
   ulong    ticket;
  };

struct SA10ManageEntryRequest100
  {
   bool     request;
   int      mode;
   int      direction;
   datetime queued_time;
  };

class CA10ManageModule100
  {
private:
   SA10ManageModeConfig100 m_cfg[A10_MANAGE_MODE_COUNT];
   SA10ManagePosition100   m_pos[A10_MANAGE_MODE_COUNT];
   int      m_pending_dir[A10_MANAGE_MODE_COUNT];
   datetime m_pending_time[A10_MANAGE_MODE_COUNT];
   bool     m_exit_pending[A10_MANAGE_MODE_COUNT];
   int      m_cooldown[A10_MANAGE_MODE_COUNT];
   int      m_max_positions;
   bool     m_skip_opposite;
   int      m_entry_ttl_seconds;
   bool     m_transition_pending;
   bool     m_ready;

   bool ValidMode(const int mode) const
     {
      return (mode>=0 && mode<A10_MANAGE_MODE_COUNT);
     }

public:
   CA10ManageModule100()
     {
      m_ready=false;
      m_transition_pending=false;
      m_max_positions=4;
      m_skip_opposite=true;
      m_entry_ttl_seconds=120;
     }

   bool Init(const int max_positions,const bool skip_opposite_signals,
             const int entry_ttl_seconds=120)
     {
      if(max_positions<1 || max_positions>A10_MANAGE_MODE_COUNT ||
         entry_ttl_seconds<1)
         return false;

      m_max_positions=max_positions;
      m_skip_opposite=skip_opposite_signals;
      m_entry_ttl_seconds=entry_ttl_seconds;
      m_transition_pending=false;

      for(int i=0;i<A10_MANAGE_MODE_COUNT;i++)
        {
         m_cfg[i].enabled=false;
         m_cfg[i].cooldown_bricks=0;
         m_cfg[i].max_spread_fraction=0.0;
         m_cfg[i].effective_brick=0.0;

         m_pos[i].open=false;
         m_pos[i].direction=0;
         m_pos[i].open_price=0.0;
         m_pos[i].open_time=0;
         m_pos[i].ticket=0;

         m_pending_dir[i]=0;
         m_pending_time[i]=0;
         m_exit_pending[i]=false;
         m_cooldown[i]=0;
        }

      m_ready=true;
      return true;
     }

   bool ConfigureMode(const int mode,const bool enabled,
                      const int cooldown_bricks,
                      const double max_spread_fraction,
                      const double effective_brick)
     {
      if(!m_ready || !ValidMode(mode) || cooldown_bricks<0)
         return false;
      if(enabled &&
         (!MathIsValidNumber(max_spread_fraction) || max_spread_fraction<=0.0 ||
          !MathIsValidNumber(effective_brick) || effective_brick<=0.0))
         return false;

      m_cfg[mode].enabled=enabled;
      m_cfg[mode].cooldown_bricks=cooldown_bricks;
      m_cfg[mode].max_spread_fraction=max_spread_fraction;
      m_cfg[mode].effective_brick=effective_brick;
      return true;
     }

   bool Ready() const { return m_ready; }
   bool TransitionPending() const { return m_transition_pending; }
   void SetTransitionPending(const bool value) { m_transition_pending=value; }

   bool ModeEnabled(const int mode) const
     {
      return (ValidMode(mode) && m_cfg[mode].enabled);
     }

   bool ModeOpen(const int mode) const
     {
      return (ValidMode(mode) && m_pos[mode].open);
     }

   bool ExitPending(const int mode) const
     {
      return (ValidMode(mode) && m_exit_pending[mode]);
     }

   bool AnyExitPending() const
     {
      for(int i=0;i<A10_MANAGE_MODE_COUNT;i++)
         if(m_exit_pending[i]) return true;
      return false;
     }

   int OpenCount() const
     {
      int n=0;
      for(int i=0;i<A10_MANAGE_MODE_COUNT;i++)
         if(m_pos[i].open) n++;
      return n;
     }

   int PendingEntryCount() const
     {
      int n=0;
      for(int i=0;i<A10_MANAGE_MODE_COUNT;i++)
         if(m_pending_dir[i]!=0) n++;
      return n;
     }

   int CooldownLeft(const int mode) const
     {
      return (ValidMode(mode) ? m_cooldown[mode] : 0);
     }

   void OnCompletedBricks(const int mode,const int completed)
     {
      if(!ValidMode(mode) || completed<=0 || m_cooldown[mode]<=0) return;
      m_cooldown[mode]-=completed;
      if(m_cooldown[mode]<0) m_cooldown[mode]=0;
     }

   bool SpreadAcceptable(const int mode,const MqlTick &tick) const
     {
      if(!ValidMode(mode) || !m_cfg[mode].enabled) return false;
      if(tick.bid<=0.0 || tick.ask<=0.0 || tick.ask<tick.bid) return false;
      const double limit=m_cfg[mode].effective_brick*m_cfg[mode].max_spread_fraction;
      return (limit>0.0 && (tick.ask-tick.bid)<=limit);
     }

   void ClearPendingEntry(const int mode)
     {
      if(!ValidMode(mode)) return;
      m_pending_dir[mode]=0;
      m_pending_time[mode]=0;
     }

   void MarkExitPending(const int mode)
     {
      if(!ValidMode(mode)) return;
      m_exit_pending[mode]=true;
      ClearPendingEntry(mode);
     }

   void ConfirmExit(const int mode)
     {
      if(!ValidMode(mode)) return;
      m_pos[mode].open=false;
      m_pos[mode].direction=0;
      m_pos[mode].open_price=0.0;
      m_pos[mode].open_time=0;
      m_pos[mode].ticket=0;
      m_exit_pending[mode]=false;
      m_cooldown[mode]=m_cfg[mode].cooldown_bricks;
      m_transition_pending=false;
     }

   void RejectExit(const int mode)
     {
      if(!ValidMode(mode)) return;
      m_transition_pending=false;
     }

   void ConfirmEntry(const int mode,const int direction,
                     const double open_price,const datetime open_time,
                     const ulong ticket)
     {
      if(!ValidMode(mode) || (direction!=1 && direction!=-1)) return;
      m_pos[mode].open=true;
      m_pos[mode].direction=direction;
      m_pos[mode].open_price=open_price;
      m_pos[mode].open_time=open_time;
      m_pos[mode].ticket=ticket;
      ClearPendingEntry(mode);
      m_transition_pending=false;
     }

   void RejectEntry(const int mode)
     {
      if(!ValidMode(mode)) return;
      m_transition_pending=false;
     }

   bool PositionSnapshot(const int mode,SA10ManagePosition100 &out) const
     {
      if(!ValidMode(mode)) return false;
      out=m_pos[mode];
      return out.open;
     }

   // Source-faithful queue gate. The caller supplies the four newest
   // per-mode entry signals and the same market tick seen by all modes.
   void QueueSignals(const int &signals[],const MqlTick &tick,const datetime now)
     {
      if(!m_ready || ArraySize(signals)<A10_MANAGE_MODE_COUNT) return;

      bool candidate[A10_MANAGE_MODE_COUNT]={false,false,false,false};
      bool long_signal=false,short_signal=false;

      for(int mode=0;mode<A10_MANAGE_MODE_COUNT;mode++)
        {
         if(!m_cfg[mode].enabled || m_cooldown[mode]>0 || signals[mode]==0) continue;
         if(m_pos[mode].open || m_pending_dir[mode]!=0 || m_exit_pending[mode]) continue;
         if(!SpreadAcceptable(mode,tick)) continue;

         candidate[mode]=true;
         if(signals[mode]>0) long_signal=true;
         if(signals[mode]<0) short_signal=true;
        }

      if(m_skip_opposite && long_signal && short_signal)
         return;

      int free_slots=m_max_positions-OpenCount()-PendingEntryCount();
      if(free_slots<=0) return;

      // Original deterministic priority.
      for(int mode=0;mode<A10_MANAGE_MODE_COUNT && free_slots>0;mode++)
        {
         if(!candidate[mode]) continue;
         m_pending_dir[mode]=signals[mode];
         m_pending_time[mode]=now;
         free_slots--;
        }
     }

   bool NextEntryRequest(const MqlTick &tick,const datetime now,
                         SA10ManageEntryRequest100 &out)
     {
      out.request=false;
      out.mode=-1;
      out.direction=0;
      out.queued_time=0;

      if(!m_ready || m_transition_pending || AnyExitPending()) return false;
      if(OpenCount()>=m_max_positions) return false;

      for(int mode=0;mode<A10_MANAGE_MODE_COUNT;mode++)
        {
         const int direction=m_pending_dir[mode];
         if(direction==0) continue;

         if(m_pending_time[mode]>0 &&
            (long)(now-m_pending_time[mode])>(long)m_entry_ttl_seconds)
           {
            ClearPendingEntry(mode);
            continue;
           }

         if(!m_cfg[mode].enabled || m_cooldown[mode]>0 || m_pos[mode].open)
           {
            ClearPendingEntry(mode);
            continue;
           }

         if(!SpreadAcceptable(mode,tick))
            continue;

         out.request=true;
         out.mode=mode;
         out.direction=direction;
         out.queued_time=m_pending_time[mode];
         m_transition_pending=true;
         return true; // one execution request per tick
        }

      return false;
     }
  };

#endif
