//+------------------------------------------------------------------+
//| MA_O01_R2_ExecDryGate_v1_00.mq5                                 |
//| P2-F: O01 decision -> execution-request dry-run gate.             |
//| Builds/validates MqlTradeRequest only. NEVER calls OrderSend.     |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

input double InpVolume=0.01;
input ulong  InpMagic=46102031;
input int    InpTargetRequests=3;

int  g_requests=0;
bool g_done=false;

bool FinitePositive(const double x)
{
 return MathIsValidNumber(x) && x>0.0;
}

bool ValidateRequest(const MqlTradeRequest &r,string &why)
{
 if(r.action!=TRADE_ACTION_DEAL){why="ACTION";return false;}
 if(r.symbol!=_Symbol){why="SYMBOL";return false;}
 if(r.magic!=InpMagic){why="MAGIC";return false;}
 if(r.type!=ORDER_TYPE_BUY && r.type!=ORDER_TYPE_SELL){why="TYPE";return false;}
 if(!FinitePositive(r.volume)){why="VOLUME";return false;}
 if(!FinitePositive(r.price)){why="PRICE";return false;}

 double vmin=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
 double vmax=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
 double vstep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
 if(vmin>0.0 && r.volume+1e-12<vmin){why="VOLUME_MIN";return false;}
 if(vmax>0.0 && r.volume-1e-12>vmax){why="VOLUME_MAX";return false;}
 if(vstep>0.0)
 {
  double q=r.volume/vstep;
  if(MathAbs(q-MathRound(q))>1e-8){why="VOLUME_STEP";return false;}
 }
 why="VALID";
 return true;
}

bool BuildDryRequest(const bool isBuy,MqlTradeRequest &r,string &why)
{
 ZeroMemory(r);
 MqlTick tick;
 if(!SymbolInfoTick(_Symbol,tick)){why="NO_TICK";return false;}
 if(!FinitePositive(tick.bid)||!FinitePositive(tick.ask)||tick.ask<tick.bid)
 {why="BAD_MARKET";return false;}

 r.action=TRADE_ACTION_DEAL;
 r.magic=InpMagic;
 r.symbol=_Symbol;
 r.volume=InpVolume;
 r.type=(isBuy?ORDER_TYPE_BUY:ORDER_TYPE_SELL);
 r.price=(isBuy?tick.ask:tick.bid);
 r.deviation=20;
 r.type_time=ORDER_TIME_GTC;
 r.comment="MA_O01_R2_DRYRUN";

 long filling=0;
 if(SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE,filling))
 {
  if((filling & SYMBOL_FILLING_FOK)==SYMBOL_FILLING_FOK) r.type_filling=ORDER_FILLING_FOK;
  else if((filling & SYMBOL_FILLING_IOC)==SYMBOL_FILLING_IOC) r.type_filling=ORDER_FILLING_IOC;
  else r.type_filling=ORDER_FILLING_RETURN;
 }

 return ValidateRequest(r,why);
}

int OnInit()
{
 if(InpTargetRequests<1 || !FinitePositive(InpVolume))
 {
  Print("[O01_R2_EXEC_DRY_START] result=FAIL reason=INPUT NO_ORDERS=1 ORDER_SEND_CALLED=0");
  return INIT_PARAMETERS_INCORRECT;
 }
 EventSetTimer(1);
 Print("[O01_R2_EXEC_DRY_START] symbol=",_Symbol,
       " volume=",DoubleToString(InpVolume,2),
       " magic=",InpMagic,
       " target=",InpTargetRequests,
       " mode=REQUEST_BUILD_VALIDATE_ONLY NO_ORDERS=1 ORDER_SEND_CALLED=0");
 return INIT_SUCCEEDED;
}

void OnDeinit(const int reason){EventKillTimer();}

void Step()
{
 if(g_done) return;

 bool isBuy=((g_requests%2)==0);
 MqlTradeRequest req;
 string why="";
 bool ok=BuildDryRequest(isBuy,req,why);

 Print("[O01_R2_EXEC_DRY_REQUEST] n=",g_requests+1,
       " side=",(isBuy?"BUY":"SELL"),
       " symbol=",req.symbol,
       " volume=",DoubleToString(req.volume,2),
       " price=",DoubleToString(req.price,_Digits),
       " magic=",req.magic,
       " validation=",why,
       " result=",(ok?"PASS":"FAIL"),
       " NO_ORDERS=1 ORDER_SEND_CALLED=0");

 if(!ok)
 {
  g_done=true;
  Print("[O01_R2_EXEC_DRY_GATE] result=FAIL reason=",why,
        " NO_ORDERS=1 ORDER_SEND_CALLED=0");
  return;
 }

 g_requests++;
 if(g_requests>=InpTargetRequests)
 {
  g_done=true;
  Print("[O01_R2_EXEC_DRY_GATE] requests=",g_requests,
        " result=PASS mode=REQUEST_BUILD_VALIDATE_ONLY",
        " NO_ORDERS=1 ORDER_SEND_CALLED=0");
 }
}

void OnTimer(){Step();}
void OnTick(){Step();}
