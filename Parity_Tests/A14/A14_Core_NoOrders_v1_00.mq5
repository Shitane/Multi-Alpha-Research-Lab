//+------------------------------------------------------------------+
//| A14 Core NoOrders v1.00                                         |
//| Source-faithful virtual reproduction of GDS Renko Momentum v0.12|
//| SAFETY: no OrderSend/OrderCheck/CTrade.                          |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

input double InpBrickSize=6.0;
input int InpMomentumPeriod=8;
input double InpMomentumThreshold=5.0;
input double InpTakeProfitBricks=10.0;
input double InpStopLossBricks=2.0;
input int InpMaxHoldMinutes=1440;
input int InpCooldownBricks=3;
input double InpMaxSpreadFraction=0.35;
input double InpLots=0.01;
input ulong InpMagic=26091043;

struct SRenkoBrick { double open,close; int direction,run; };

const int MAX_BRICKS_PER_TICK=4096;
class CRenkoBuilder
{
 private: double m_tick_size; long m_size,m_close; int m_dir,m_run; bool m_anchor;
 public:
 void Init(const double ts,const long sz){m_tick_size=ts;m_size=sz;m_close=0;m_dir=0;m_run=0;m_anchor=false;}
 int PushPrice(const double price,SRenkoBrick &out[])
 {
  ArrayResize(out,0); const long p=(long)MathRound(price/m_tick_size);
  if(!m_anchor){m_close=p;m_anchor=true;return 0;}
  const long delta=p-m_close; int dir=m_dir; long count=0; bool reversal=false;
  if(m_dir==0){if(delta>=m_size){dir=1;count=delta/m_size;}else if(delta<=-m_size){dir=-1;count=(-delta)/m_size;}}
  else if(m_dir>0){if(delta>=m_size)count=delta/m_size;else if(delta<=-2*m_size){dir=-1;reversal=true;count=(-delta)/m_size-1;}}
  else {if(delta<=-m_size)count=(-delta)/m_size;else if(delta>=2*m_size){dir=1;reversal=true;count=delta/m_size-1;}}
  if(count>MAX_BRICKS_PER_TICK)return -1;if(count==0)return 0;
  if(ArrayResize(out,(int)count)!=(int)count)return -1;
  for(int i=0;i<(int)count;i++){const long op=m_close+((reversal&&i==0)?dir*m_size:0);m_close=op+dir*m_size;
   if(dir==m_dir)m_run++;else{m_dir=dir;m_run=1;}
   out[i].open=op*m_tick_size;out[i].close=m_close*m_tick_size;out[i].direction=dir;out[i].run=m_run;}
  return (int)count;
 }
};

class CRenkoMomentum
{
 private: double m_closes[]; int m_period,m_head,m_count; double m_size,m_threshold,m_previous,m_value; bool m_ready;
 public:
 bool Init(const int period,const double size,const double threshold){
  m_period=period;m_size=size;m_threshold=threshold;m_head=0;m_count=0;m_previous=0;m_value=0;m_ready=false;
  return ArrayResize(m_closes,period+1)==period+1;
 }
 int Push(const SRenkoBrick &brick){
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

CRenkoBuilder g_renko; CRenkoMomentum g_momentum;
double g_effective_brick_size=0.0; bool g_builder_failed=false,g_closed_this_tick=false;
int g_cooldown_left=0; bool g_open=false; int g_dir=0; double g_open_price=0; datetime g_open_time=0;
long g_ticks=0,g_bricks=0,g_raw=0,g_entries=0,g_exits=0,g_tp=0,g_sl=0,g_time=0,g_spread_blocks=0,g_cooldown_blocks=0;

bool ValidTick(const MqlTick &t){return MathIsValidNumber(t.bid)&&MathIsValidNumber(t.ask)&&t.bid>0&&t.ask>=t.bid&&t.time>0;}

void ExitVirtual(const string reason,const MqlTick &t){
 if(!g_open)return;const double px=(g_dir>0?t.bid:t.ask);g_exits++;
 if(reason=="TP")g_tp++;else if(reason=="SL")g_sl++;else if(reason=="TIME")g_time++;
 PrintFormat("[A14_NOORDERS_EXIT] no=%I64d reason=%s dir=%s price=%.8f time=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
             g_exits,reason,(g_dir>0?"BUY":"SELL"),px,TimeToString(t.time,TIME_DATE|TIME_SECONDS));
 g_open=false;g_dir=0;g_open_price=0;g_open_time=0;g_cooldown_left=InpCooldownBricks;g_closed_this_tick=true;
}

void CheckPriceExit(const MqlTick &t){
 if(!g_open)return;const double ex=(g_dir>0?t.bid:t.ask),move=g_dir*(ex-g_open_price);
 const double tp=InpTakeProfitBricks*g_effective_brick_size,sl=InpStopLossBricks*g_effective_brick_size;
 if(move>=tp){ExitVirtual("TP",t);return;}if(move<=-sl){ExitVirtual("SL",t);return;}
 if(InpMaxHoldMinutes>0&&g_open_time>0&&(long)(t.time-g_open_time)>=(long)InpMaxHoldMinutes*60)ExitVirtual("TIME",t);
}

void UpdateRenkoAndTrade(const MqlTick &t){
 if(g_builder_failed)return;SRenkoBrick b[];const int n=g_renko.PushPrice(t.bid,b);
 if(n<0){g_builder_failed=true;Print("[A14_NOORDERS_BUILDER_FAILED] entries paused; virtual exits remain active");return;}if(n==0)return;
 g_bricks+=n;int final_signal=0;for(int i=0;i<n;i++)final_signal=g_momentum.Push(b[i]);
 if(g_cooldown_left>0){g_cooldown_left-=n;if(g_cooldown_left<0)g_cooldown_left=0;}
 if(g_open)return;if(g_closed_this_tick)return;
 if(g_cooldown_left>0){if(final_signal!=0)g_cooldown_blocks++;return;}
 if(final_signal==0)return;g_raw++;
 if((t.ask-t.bid)>g_effective_brick_size*InpMaxSpreadFraction){g_spread_blocks++;return;}
 g_dir=final_signal;g_open=true;g_open_price=(g_dir>0?t.ask:t.bid);g_open_time=t.time;g_entries++;
 PrintFormat("[A14_NOORDERS_ENTRY] no=%I64d dir=%s price=%.8f time=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
             g_entries,(g_dir>0?"BUY":"SELL"),g_open_price,TimeToString(t.time,TIME_DATE|TIME_SECONDS));
}

int OnInit(){
 if(!MathIsValidNumber(InpBrickSize)||InpBrickSize<_Point||!MathIsValidNumber(InpMomentumThreshold)||
 !MathIsValidNumber(InpTakeProfitBricks)||!MathIsValidNumber(InpStopLossBricks)||!MathIsValidNumber(InpMaxSpreadFraction)||
 !MathIsValidNumber(InpLots)||InpMomentumPeriod<2||InpMomentumPeriod>200||InpMomentumThreshold<=0||InpMagic==0||
 InpTakeProfitBricks<=0||InpStopLossBricks<=0||InpMaxHoldMinutes<0||InpCooldownBricks<0||InpMaxSpreadFraction<=0||InpLots<=0)
 return INIT_PARAMETERS_INCORRECT;
 const double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);if(!MathIsValidNumber(ts)||ts<=0)return INIT_FAILED;
 const double ur=InpBrickSize/ts;if(!MathIsValidNumber(ur)||ur<0.5||ur>1e9)return INIT_FAILED;
 const long units=(long)MathMax(1.0,MathRound(ur));g_effective_brick_size=(double)units*ts;
 g_renko.Init(ts,units);if(!g_momentum.Init(InpMomentumPeriod,g_effective_brick_size,InpMomentumThreshold))return INIT_FAILED;
 PrintFormat("[A14_NOORDERS_START] effective_brick=%.8f momentum_period=%d threshold=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
             g_effective_brick_size,InpMomentumPeriod,InpMomentumThreshold);
 return INIT_SUCCEEDED;
}

void OnTick(){
 g_ticks++;g_closed_this_tick=false;MqlTick t={};if(!SymbolInfoTick(_Symbol,t)||!ValidTick(t))return;
 CheckPriceExit(t);UpdateRenkoAndTrade(t);
}

void OnDeinit(const int reason){
 PrintFormat("[A14_NOORDERS_SUMMARY] ticks=%I64d bricks=%I64d raw=%I64d entries=%I64d exits=%I64d open=%d tp=%I64d sl=%I64d time=%I64d spread_blocks=%I64d cooldown_blocks=%I64d builder_failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
 g_ticks,g_bricks,g_raw,g_entries,g_exits,(int)g_open,g_tp,g_sl,g_time,g_spread_blocks,g_cooldown_blocks,(int)g_builder_failed,reason);
}
//+------------------------------------------------------------------+
