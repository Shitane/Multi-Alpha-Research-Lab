//+------------------------------------------------------------------+
//| A10_Bollinger_Module_v1_00.mqh                                  |
//| Extracted from A10 original v1.30 after exact baseline parity.   |
//| Four independent Renko+Bollinger engines. NO ORDER OPERATIONS.   |
//+------------------------------------------------------------------+
#ifndef A10_BOLLINGER_MODULE_V1_00_MQH
#define A10_BOLLINGER_MODULE_V1_00_MQH

enum ENUM_A10_BB_MODE { A10_BREAKOUT=0,A10_REENTRY=1,A10_MIDLINE=2,A10_SQUEEZE=3 };

struct SA10Brick { double open,close; int direction,run; };
struct SA10TickResult { int completed,signal,raw_signal; double final_close; bool bb_ready; double bb_mid; };

class CA10RenkoBuilder {
 double m_tick; long m_size,m_close; int m_dir,m_run; bool m_anchor;
public:
 void Init(double tick,long size){m_tick=tick;m_size=size;m_close=0;m_dir=0;m_run=0;m_anchor=false;}
 int PushPrice(double price,SA10Brick &out[]){
  ArrayResize(out,0); long p=(long)MathRound(price/m_tick);
  if(!m_anchor){m_close=p;m_anchor=true;return 0;}
  long delta=p-m_close,count=0; int dir=m_dir; bool reversal=false;
  if(m_dir==0){if(delta>=m_size){dir=1;count=delta/m_size;}else if(delta<=-m_size){dir=-1;count=(-delta)/m_size;}}
  else if(m_dir>0){if(delta>=m_size)count=delta/m_size;else if(delta<=-2*m_size){dir=-1;reversal=true;count=(-delta)/m_size-1;}}
  else {if(delta<=-m_size)count=(-delta)/m_size;else if(delta>=2*m_size){dir=1;reversal=true;count=delta/m_size-1;}}
  if(count>4096)return -1; if(count==0)return 0; if(ArrayResize(out,(int)count)!=(int)count)return -1;
  for(int i=0;i<(int)count;i++){long op=m_close+((reversal&&i==0)?dir*m_size:0);m_close=op+dir*m_size;
   if(dir==m_dir)m_run++;else{m_dir=dir;m_run=1;} out[i].open=op*m_tick;out[i].close=m_close*m_tick;out[i].direction=dir;out[i].run=m_run;}
  return (int)count;
 }
};

class CA10Bollinger {
 int m_period,m_count; double m_closes[]; bool m_prev_ready,m_last_ready; int m_prev_relation,m_prev_mid_side; double m_last_mid;
 void Append(double c){if(m_count<m_period){m_closes[m_count++]=c;return;}for(int i=1;i<m_period;i++)m_closes[i-1]=m_closes[i];m_closes[m_period-1]=c;}
 bool Bands(double dev,double &mid,double &up,double &lo){if(m_count<m_period||m_period<2)return false;double s=0;for(int i=0;i<m_period;i++)s+=m_closes[i];mid=s/(double)m_period;double v=0;for(int i=0;i<m_period;i++){double d=m_closes[i]-mid;v+=d*d;}v/=double(m_period);double sd=MathSqrt(MathMax(0.0,v));up=mid+dev*sd;lo=mid-dev*sd;return true;}
public:
 void Init(int p){m_period=p;m_count=0;ArrayResize(m_closes,p);ArrayInitialize(m_closes,0.0);m_prev_ready=false;m_prev_relation=0;m_prev_mid_side=0;m_last_ready=false;m_last_mid=0;}
 int Push(const SA10Brick &b,ENUM_A10_BB_MODE mode,double dev,double brick,double squeeze){
  double mid=0,up=0,lo=0;if(!Bands(dev,mid,up,lo)){Append(b.close);m_last_ready=false;return 0;}
  int rel=0;if(b.close>up)rel=1;else if(b.close<lo)rel=-1;int side=(b.close>=mid?1:-1);double width=(brick>0?(up-lo)/brick:0);int sig=0;
  if(mode==A10_BREAKOUT){if(rel>0&&b.direction>0)sig=1;else if(rel<0&&b.direction<0)sig=-1;}
  else if(mode==A10_REENTRY){if(m_prev_ready&&m_prev_relation<0&&rel>=0&&b.direction>0)sig=1;else if(m_prev_ready&&m_prev_relation>0&&rel<=0&&b.direction<0)sig=-1;}
  else if(mode==A10_MIDLINE){if(m_prev_ready&&m_prev_mid_side<0&&side>0&&b.direction>0)sig=1;else if(m_prev_ready&&m_prev_mid_side>0&&side<0&&b.direction<0)sig=-1;}
  else if(mode==A10_SQUEEZE&&width<=squeeze){if(rel>0&&b.direction>0)sig=1;else if(rel<0&&b.direction<0)sig=-1;}
  m_last_ready=true;m_last_mid=mid;m_prev_ready=true;m_prev_relation=rel;m_prev_mid_side=side;Append(b.close);return sig;
 }
 bool Ready()const{return m_last_ready;} double Mid()const{return m_last_mid;}
};

class CA10ModeEngine {
 bool m_enabled,m_failed; ENUM_A10_BB_MODE m_mode; double m_brick,m_dev,m_squeeze,m_tp,m_sl,m_spread; int m_period,m_run,m_hold,m_cdset,m_cd; CA10RenkoBuilder m_renko; CA10Bollinger m_bb;
public:
 bool Configure(bool enabled,ENUM_A10_BB_MODE mode,double tick,double brick,int period,double dev,double squeeze,int run,double tp,double sl,int hold,int cd,double spread){
  m_enabled=enabled;m_failed=false;m_mode=mode;m_period=period;m_dev=dev;m_squeeze=squeeze;m_run=run;m_tp=tp;m_sl=sl;m_hold=hold;m_cdset=cd;m_cd=0;m_spread=spread;
  if(!enabled)return true;if(tick<=0||brick<=0||period<2||run<1||tp<=0||sl<=0||hold<0||cd<0||spread<=0)return false;long units=(long)MathMax(1.0,MathRound(brick/tick));m_brick=units*tick;m_renko.Init(tick,units);m_bb.Init(period);return true;}
 void PushPrice(double price,SA10TickResult &o){o.completed=0;o.signal=0;o.raw_signal=0;o.final_close=0;o.bb_ready=false;o.bb_mid=0;if(!m_enabled||m_failed)return;SA10Brick b[];int n=m_renko.PushPrice(price,b);if(n<0){m_failed=true;return;}if(n==0)return;o.completed=n;for(int i=0;i<n;i++){int raw=m_bb.Push(b[i],m_mode,m_dev,m_brick,m_squeeze);int sig=0;if(raw!=0&&b[i].run>=m_run&&b[i].direction==raw)sig=raw;o.signal=sig;o.raw_signal=raw;o.final_close=b[i].close;o.bb_ready=m_bb.Ready();o.bb_mid=m_bb.Mid();}if(m_cd>0){m_cd-=n;if(m_cd<0)m_cd=0;}}
 bool Enabled()const{return m_enabled;} double Brick()const{return m_brick;} double TP()const{return m_tp;} double SL()const{return m_sl;} int Hold()const{return m_hold;} int Cooldown()const{return m_cd;} double Spread()const{return m_spread;} void StartCooldown(){m_cd=m_cdset;}
};
#endif
