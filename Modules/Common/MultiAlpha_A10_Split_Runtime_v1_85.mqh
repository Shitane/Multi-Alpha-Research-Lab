//+------------------------------------------------------------------+
//| MultiAlpha_A10_Split_Runtime_v1_85.mqh                           |
//| A10 ENTRY+MANAGE+EXIT virtual lifecycle for Multi Alpha host.    |
//| Based on documented A10 split parity v1.01. NO BROKER ORDERS.    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_A10_SPLIT_RUNTIME_V1_85_MQH
#define MULTIALPHA_A10_SPLIT_RUNTIME_V1_85_MQH
#include "..\\A10\\A10_Entry_Module_v1_00.mqh"
#include "..\\A10\\A10_Manage_Module_v1_00.mqh"
#include "..\\A10\\A10_Exit_Module_v1_00.mqh"
#include "..\\A10\\A10_Full_Module_v1_00.mqh"

struct SA10SplitEvent185{bool valid;bool is_entry;int mode;int direction;string reason;double price;ulong ticket;};

class CMultiAlphaA10SplitRuntime185{
 CA10EntryModule m_entry[4];CA10ExitModule m_exit[4];CA10ManageModule100 m_manage;
 ulong m_next_ticket;long m_ticks,m_entries,m_exits,m_en[4],m_ex[4];bool m_ready;
 void ClearEvent(SA10SplitEvent185 &e){e.valid=false;e.is_entry=false;e.mode=-1;e.direction=0;e.reason="";e.price=0;e.ticket=0;}
 bool SetupEntry(const int i,const SA10EntryModeSettings100 &s,const ENUM_A10_ENTRY_MODE mode,const double tick){
  return m_entry[i].Configure(s.enabled,mode,tick,s.brick_size,s.bb_period,s.deviation,s.squeeze_max_width,s.entry_run,0,1.0);
 }
 bool CloseVirtual(const int mode,const string why,const MqlTick &t,SA10SplitEvent185 &e){
  SA10ManagePosition100 p={};if(!m_manage.PositionSnapshot(mode,p))return false;
  e.valid=true;e.is_entry=false;e.mode=mode;e.direction=p.direction;e.reason=why;e.price=(p.direction>0?t.bid:t.ask);e.ticket=p.ticket;
  m_manage.MarkExitPending(mode);m_manage.SetTransitionPending(true);m_manage.ConfirmExit(mode);m_exits++;m_ex[mode]++;return true;
 }
public:
 CMultiAlphaA10SplitRuntime185(){m_ready=false;}
 bool Init(const SA10EntrySettings100 &ec,const SA10FullConfig100 &mx,const double tick){
  m_ready=false;if(tick<=0||!A10ValidateEntrySettings100(ec))return false;
  if(!m_manage.Init(mx.max_positions,ec.skip_opposite_signals,mx.entry_ttl_seconds))return false;
  if(!SetupEntry(0,ec.breakout,A10_ENTRY_BREAKOUT,tick)||!SetupEntry(1,ec.reentry,A10_ENTRY_REENTRY,tick)||!SetupEntry(2,ec.midline,A10_ENTRY_MIDLINE,tick)||!SetupEntry(3,ec.squeeze,A10_ENTRY_SQUEEZE,tick))return false;
  for(int i=0;i<4;i++){
   SA10EntryModeSettings100 es=(i==0?ec.breakout:(i==1?ec.reentry:(i==2?ec.midline:ec.squeeze)));
   if(!m_manage.ConfigureMode(i,es.enabled,mx.mode[i].cooldown,mx.mode[i].max_spread,m_entry[i].Brick()))return false;
   if(!m_exit[i].Configure(mx.mode[i].tp,mx.mode[i].sl,mx.mode[i].max_hold))return false;
   m_en[i]=0;m_ex[i]=0;
  }
  m_next_ticket=1;m_ticks=0;m_entries=0;m_exits=0;m_ready=true;
  Print("[MA_A10_SPLIT185_START] ENTRY=A10 MANAGE=A10 EXIT=A10 NO_ORDERS=1 VIRTUAL_NOT_FILL=1");return true;
 }
 bool OnTick(const MqlTick &t,SA10SplitEvent185 &e){
  ClearEvent(e);if(!m_ready||t.bid<=0||t.ask<t.bid)return false;m_ticks++;
  // Original priority: price exits before signal processing.
  for(int i=0;i<4;i++){SA10ManagePosition100 p={};if(!m_manage.PositionSnapshot(i,p)||m_manage.ExitPending(i))continue;SA10ExitDecision d={};m_exit[i].CheckPrice(p.direction,p.open_price,p.open_time,t.bid,t.ask,TimeCurrent(),m_entry[i].Brick(),d);if(d.exit)return CloseVirtual(i,m_exit[i].ReasonText(d.reason),t,e);}
  SA10EntryResult r[4];for(int i=0;i<4;i++){m_entry[i].PushPrice(t.bid,r[i]);m_manage.OnCompletedBricks(i,r[i].completed);}
  for(int i=0;i<4;i++){SA10ManagePosition100 p={};if(!m_manage.PositionSnapshot(i,p)||m_manage.ExitPending(i))continue;SA10ExitDecision d={};m_exit[i].CheckSignal(i,p.direction,r[i].completed,r[i].raw_signal,r[i].bb_ready,r[i].final_close,r[i].bb_mid,d);if(d.exit)return CloseVirtual(i,m_exit[i].ReasonText(d.reason),t,e);}
  int sig[4]={r[0].signal,r[1].signal,r[2].signal,r[3].signal};m_manage.QueueSignals(sig,t,TimeCurrent());
  SA10ManageEntryRequest100 q={};if(!m_manage.NextEntryRequest(t,TimeCurrent(),q))return false;
  double px=(q.direction>0?t.ask:t.bid);ulong ticket=m_next_ticket++;m_manage.ConfirmEntry(q.mode,q.direction,px,TimeCurrent(),ticket);
  m_entries++;m_en[q.mode]++;e.valid=true;e.is_entry=true;e.mode=q.mode;e.direction=q.direction;e.reason="ENTRY";e.price=px;e.ticket=ticket;return true;
 }
 bool Ready()const{return m_ready;}long Ticks()const{return m_ticks;}long Entries()const{return m_entries;}long Exits()const{return m_exits;}int OpenCount()const{return m_manage.OpenCount();}
 long ModeEntries(const int i)const{return(i>=0&&i<4?m_en[i]:0);}long ModeExits(const int i)const{return(i>=0&&i<4?m_ex[i]:0);}
};
#endif
