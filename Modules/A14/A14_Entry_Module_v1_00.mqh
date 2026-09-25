//+------------------------------------------------------------------+
//| A14 Entry Module v1.00                                          |
//| GDS Renko Momentum v0.12 entry logic. NO ORDERS.                |
//+------------------------------------------------------------------+
#ifndef __A14_ENTRY_MODULE_V1_00_MQH__
#define __A14_ENTRY_MODULE_V1_00_MQH__

struct A14RenkoBrick { double open,close; int direction,run; };
const int A14_MAX_BRICKS_PER_TICK=4096;

class CA14RenkoBuilder
{
 private: double m_tick_size; long m_size,m_close; int m_dir,m_run; bool m_anchor;
 public:
 void Init(const double ts,const long sz){m_tick_size=ts;m_size=sz;m_close=0;m_dir=0;m_run=0;m_anchor=false;}
 int PushPrice(const double price,A14RenkoBrick &out[])
 {
  ArrayResize(out,0); const long p=(long)MathRound(price/m_tick_size);
  if(!m_anchor){m_close=p;m_anchor=true;return 0;}
  const long delta=p-m_close; int dir=m_dir; long count=0; bool reversal=false;
  if(m_dir==0){if(delta>=m_size){dir=1;count=delta/m_size;}else if(delta<=-m_size){dir=-1;count=(-delta)/m_size;}}
  else if(m_dir>0){if(delta>=m_size)count=delta/m_size;else if(delta<=-2*m_size){dir=-1;reversal=true;count=(-delta)/m_size-1;}}
  else {if(delta<=-m_size)count=(-delta)/m_size;else if(delta>=2*m_size){dir=1;reversal=true;count=delta/m_size-1;}}
  if(count>A14_MAX_BRICKS_PER_TICK)return -1;if(count==0)return 0;
  if(ArrayResize(out,(int)count)!=(int)count)return -1;
  for(int i=0;i<(int)count;i++){const long op=m_close+((reversal&&i==0)?dir*m_size:0);m_close=op+dir*m_size;
   if(dir==m_dir)m_run++;else{m_dir=dir;m_run=1;}
   out[i].open=op*m_tick_size;out[i].close=m_close*m_tick_size;out[i].direction=dir;out[i].run=m_run;}
  return (int)count;
 }
};

class CA14RenkoMomentum
{
 private: double m_closes[]; int m_period,m_head,m_count; double m_size,m_threshold,m_previous,m_value; bool m_ready;
 public:
 bool Init(const int period,const double size,const double threshold){
  m_period=period;m_size=size;m_threshold=threshold;m_head=0;m_count=0;m_previous=0;m_value=0;m_ready=false;
  return ArrayResize(m_closes,period+1)==period+1;
 }
 int Push(const A14RenkoBrick &brick){
  const int capacity=m_period+1;m_closes[m_head]=brick.close;m_head=(m_head+1)%capacity;
  if(m_count<capacity)m_count++;if(m_count<capacity)return 0;
  m_value=(brick.close-m_closes[m_head])/m_size;
  if(!m_ready){m_ready=true;m_previous=m_value;return 0;}
  int signal=0;const double eps=1e-9;
  if(m_previous<m_threshold-eps&&m_value>=m_threshold-eps)signal=1;
  else if(m_previous>-m_threshold+eps&&m_value<=-m_threshold+eps)signal=-1;
  m_previous=m_value;return signal;
 }
};

class CA14EntryModule
{
 private:
  CA14RenkoBuilder m_renko; CA14RenkoMomentum m_momentum;
  double m_brick,m_spread_fraction; bool m_failed;
  long m_bricks,m_raw,m_spread_blocks,m_cooldown_blocks;
 public:
  bool Init(const double tick_size,const long brick_units,const int momentum_period,const double threshold,const double spread_fraction){
   m_brick=(double)brick_units*tick_size;m_spread_fraction=spread_fraction;m_failed=false;
   m_bricks=0;m_raw=0;m_spread_blocks=0;m_cooldown_blocks=0;
   m_renko.Init(tick_size,brick_units);return m_momentum.Init(momentum_period,m_brick,threshold);
  }
  int Process(const MqlTick &t,const bool position_open,const bool closed_this_tick,int &cooldown_left){
   if(m_failed)return 0; A14RenkoBrick b[]; const int n=m_renko.PushPrice(t.bid,b);
   if(n<0){m_failed=true;Print("[A14_SPLIT_BUILDER_FAILED] entries paused; virtual exits remain active");return 0;}
   if(n==0)return 0; m_bricks+=n; int final_signal=0;
   for(int i=0;i<n;i++)final_signal=m_momentum.Push(b[i]);
   if(cooldown_left>0){cooldown_left-=n;if(cooldown_left<0)cooldown_left=0;}
   if(position_open||closed_this_tick)return 0;
   if(cooldown_left>0){if(final_signal!=0)m_cooldown_blocks++;return 0;}
   if(final_signal==0)return 0; m_raw++;
   if((t.ask-t.bid)>m_brick*m_spread_fraction){m_spread_blocks++;return 0;}
   return final_signal;
  }
  double BrickSize()const{return m_brick;} long Bricks()const{return m_bricks;} long Raw()const{return m_raw;}
  long SpreadBlocks()const{return m_spread_blocks;} long CooldownBlocks()const{return m_cooldown_blocks;}
  bool Failed()const{return m_failed;}
};
#endif
