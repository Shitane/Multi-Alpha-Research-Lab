//+------------------------------------------------------------------+
//| MA_O01_R2_OneTradeGate_v1_00.mq5                                |
//| P2-G: demo-only, one 0.01-lot market order gate.                 |
//| REAL OrderSend is possible ONLY after every safety guard passes. |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

input double InpVolume=0.01;
input ulong  InpMagic=46102031;
input bool   InpArmRealOrder=false;
input bool   InpBuy=true;

bool g_attempted=false;

bool FinitePositive(const double x)
{
 return MathIsValidNumber(x) && x>0.0;
}

bool IsDemoAccount()
{
 long mode=AccountInfoInteger(ACCOUNT_TRADE_MODE);
 return (mode==ACCOUNT_TRADE_MODE_DEMO || mode==ACCOUNT_TRADE_MODE_CONTEST);
}

bool HasAnyExposure()
{
 if(PositionsTotal()>0 || OrdersTotal()>0) return true;
 return false;
}

bool BuildRequest(MqlTradeRequest &r,string &why)
{
 ZeroMemory(r);
 MqlTick tick;
 if(!SymbolInfoTick(_Symbol,tick)){why="NO_TICK";return false;}
 if(!FinitePositive(tick.bid)||!FinitePositive(tick.ask)||tick.ask<tick.bid)
 {why="BAD_MARKET";return false;}

 double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
 double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
 double vstep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
 if(MathAbs(InpVolume-0.01)>1e-12){why="VOLUME_NOT_001";return false;}
 if(vmin>0.0 && InpVolume+1e-12<vmin){why="VOLUME_MIN";return false;}
 if(vmax>0.0 && InpVolume-1e-12>vmax){why="VOLUME_MAX";return false;}
 if(vstep>0.0)
 {
  double q=InpVolume/vstep;
  if(MathAbs(q-MathRound(q))>1e-8){why="VOLUME_STEP";return false;}
 }

 r.action=TRADE_ACTION_DEAL;
 r.magic=InpMagic;
 r.symbol=_Symbol;
 r.volume=InpVolume;
 r.type=(InpBuy?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
 r.price=(InpBuy?tick.ask:tick.bid);
 r.deviation=20;
 r.type_time=ORDER_TIME_GTC;
 r.comment="MA_O01_R2_ONE_TRADE";

 long filling=0;
 if(SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE,filling))
 {
  if((filling & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) r.type_filling=ORDER_FILLING_FOK;
  else if((filling & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) r.type_filling=ORDER_FILLING_IOC;
  else r.type_filling=ORDER_FILLING_RETURN;
 }
 why="VALID";
 return true;
}

void TryOnce()
{
 if(g_attempted) return;
 g_attempted=true;

 if(!IsDemoAccount())
 {
  Print("[O01_R2_ONE_TRADE_GATE] result=BLOCK reason=NOT_DEMO ORDER_SEND_CALLED=0");
  return;
 }
 if(!InpArmRealOrder)
 {
  Print("[O01_R2_ONE_TRADE_GATE] result=BLOCK reason=NOT_ARMED ORDER_SEND_CALLED=0");
  return;
 }
 if(HasAnyExposure())
 {
  Print("[O01_R2_ONE_TRADE_GATE] result=BLOCK reason=EXISTING_EXPOSURE positions=",
        PositionsTotal()," orders=",OrdersTotal()," ORDER_SEND_CALLED=0");
  return;
 }

 MqlTradeRequest req;
 MqlTradeResult res;
 string why="";
 ZeroMemory(res);
 if(!BuildRequest(req,why))
 {
  Print("[O01_R2_ONE_TRADE_GATE] result=BLOCK reason=",why," ORDER_SEND_CALLED=0");
  return;
 }

 Print("[O01_R2_ONE_TRADE_REQUEST] side=",(InpBuy?"BUY":"SELL"),
       " symbol=",req.symbol,
       " volume=",DoubleToString(req.volume,2),
       " price=",DoubleToString(req.price,_Digits),
       " magic=",req.magic,
       " DEMO_ONLY=1 MAX_SENDS=1");

 ResetLastError();
 bool sent=OrderSend(req,res);
 int err=GetLastError();

 Print("[O01_R2_ONE_TRADE_RESULT] sent=",(sent?1:0),
       " retcode=",res.retcode,
       " order=",res.order,
       " deal=",res.deal,
       " err=",err,
       " ORDER_SEND_CALLED=1 MAX_SENDS=1");

 bool accepted=(sent &&
   (res.retcode==TRADE_RETCODE_DONE ||
    res.retcode==TRADE_RETCODE_DONE_PARTIAL ||
    res.retcode==TRADE_RETCODE_PLACED));

 Print("[O01_R2_ONE_TRADE_GATE] result=",(accepted?"PASS":"FAIL"),
       " DEMO_ONLY=1 volume=",DoubleToString(InpVolume,2),
       " ORDER_SEND_CALLED=1 MAX_SENDS=1");
}

int OnInit()
{
 Print("[O01_R2_ONE_TRADE_START] symbol=",_Symbol,
       " accountMode=",AccountInfoInteger(ACCOUNT_TRADE_MODE),
       " volume=",DoubleToString(InpVolume,2),
       " magic=",InpMagic,
       " armed=",(InpArmRealOrder?1:0),
       " side=",(InpBuy?"BUY":"SELL"),
       " DEMO_ONLY=1 MAX_SENDS=1");
 EventSetTimer(1);
 return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){EventKillTimer();}
void OnTimer(){TryOnce();}
void OnTick(){TryOnce();}
