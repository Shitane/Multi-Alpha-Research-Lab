//+------------------------------------------------------------------+
//| A14 Split NoOrders Parity v1.00                                 |
//| Entry/Exit modules separated; virtual lifecycle only.            |
//| SAFETY: no OrderSend/OrderCheck/CTrade.                          |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"
#include <A14/A14_Entry_Module_v1_00.mqh>
#include <A14/A14_Exit_Module_v1_00.mqh>

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

CA14EntryModule g_entry; CA14ExitModule g_exit;
bool g_open=false,g_closed_this_tick=false; int g_dir=0,g_cooldown_left=0;
double g_open_price=0; datetime g_open_time=0;
long g_ticks=0,g_entries=0,g_exits=0,g_tp=0,g_sl=0,g_time=0;

bool ValidTick(const MqlTick &t){return MathIsValidNumber(t.bid)&&MathIsValidNumber(t.ask)&&t.bid>0&&t.ask>=t.bid&&t.time>0;}

void CloseVirtual(const string reason,const MqlTick &t){
 if(!g_open)return; const double px=(g_dir>0?t.bid:t.ask); g_exits++;
 if(reason=="TP")g_tp++;else if(reason=="SL")g_sl++;else if(reason=="TIME")g_time++;
 PrintFormat("[A14_SPLIT_EXIT] no=%I64d reason=%s dir=%s price=%.8f time=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
  g_exits,reason,(g_dir>0?"BUY":"SELL"),px,TimeToString(t.time,TIME_DATE|TIME_SECONDS));
 g_open=false;g_dir=0;g_open_price=0;g_open_time=0;g_cooldown_left=InpCooldownBricks;g_closed_this_tick=true;
}

int OnInit(){
 if(!MathIsValidNumber(InpBrickSize)||InpBrickSize<_Point||!MathIsValidNumber(InpMomentumThreshold)||
 !MathIsValidNumber(InpTakeProfitBricks)||!MathIsValidNumber(InpStopLossBricks)||!MathIsValidNumber(InpMaxSpreadFraction)||
 !MathIsValidNumber(InpLots)||InpMomentumPeriod<2||InpMomentumPeriod>200||InpMomentumThreshold<=0||InpMagic==0||
 InpTakeProfitBricks<=0||InpStopLossBricks<=0||InpMaxHoldMinutes<0||InpCooldownBricks<0||InpMaxSpreadFraction<=0||InpLots<=0)
 return INIT_PARAMETERS_INCORRECT;
 const double ts=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);if(!MathIsValidNumber(ts)||ts<=0)return INIT_FAILED;
 const double ur=InpBrickSize/ts;if(!MathIsValidNumber(ur)||ur<0.5||ur>1e9)return INIT_FAILED;
 const long units=(long)MathMax(1.0,MathRound(ur));
 if(!g_entry.Init(ts,units,InpMomentumPeriod,InpMomentumThreshold,InpMaxSpreadFraction))return INIT_FAILED;
 g_exit.Init(InpTakeProfitBricks,InpStopLossBricks,InpMaxHoldMinutes,g_entry.BrickSize());
 PrintFormat("[A14_SPLIT_START] effective_brick=%.8f momentum_period=%d threshold=%.8f NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
  g_entry.BrickSize(),InpMomentumPeriod,InpMomentumThreshold);
 return INIT_SUCCEEDED;
}

void OnTick(){
 g_ticks++;g_closed_this_tick=false;MqlTick t={};if(!SymbolInfoTick(_Symbol,t)||!ValidTick(t))return;
 const string reason=g_exit.Check(t,g_open,g_dir,g_open_price,g_open_time);if(reason!="")CloseVirtual(reason,t);
 const int signal=g_entry.Process(t,g_open,g_closed_this_tick,g_cooldown_left);
 if(signal==0)return;g_dir=signal;g_open=true;g_open_price=(g_dir>0?t.ask:t.bid);g_open_time=t.time;g_entries++;
 PrintFormat("[A14_SPLIT_ENTRY] no=%I64d dir=%s price=%.8f time=%s NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
  g_entries,(g_dir>0?"BUY":"SELL"),g_open_price,TimeToString(t.time,TIME_DATE|TIME_SECONDS));
}

void OnDeinit(const int reason){
 PrintFormat("[A14_SPLIT_SUMMARY] ticks=%I64d bricks=%I64d raw=%I64d entries=%I64d exits=%I64d open=%d tp=%I64d sl=%I64d time=%I64d spread_blocks=%I64d cooldown_blocks=%I64d builder_failed=%d reason=%d NO_ORDERS=1 VIRTUAL_NOT_FILL=1",
  g_ticks,g_entry.Bricks(),g_entry.Raw(),g_entries,g_exits,(int)g_open,g_tp,g_sl,g_time,g_entry.SpreadBlocks(),g_entry.CooldownBlocks(),(int)g_entry.Failed(),reason);
}
