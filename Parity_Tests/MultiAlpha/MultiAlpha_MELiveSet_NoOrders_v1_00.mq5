#property strict
#property version "1.00"
// A14-28: live owned-position set capture and fail-closed recheck.
// No order send, modify or close APIs.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
struct SMA_A28Position
{
 ulong ticket;
 string symbol;
 long magic;
 int side;
 double lots;
};
void A28Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_LIVE_SET_CASE] ",name," ",ok?"PASS":"FAIL");
}
bool A28Read(SMA_A28Position &positions[],const string symbol,const long magic,const int side)
{
 ArrayResize(positions,0);
 if(symbol==""||magic<=0||(side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL))return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return false;
  if(PositionGetString(POSITION_SYMBOL)!=symbol||
     PositionGetInteger(POSITION_MAGIC)!=magic||
     (int)PositionGetInteger(POSITION_TYPE)!=side)continue;
  double lots=PositionGetDouble(POSITION_VOLUME);
  if(lots<=0||!MathIsValidNumber(lots))return false;
  int n=ArraySize(positions);
  for(int j=0;j<n;j++)if(positions[j].ticket==ticket)return false;
  ArrayResize(positions,n+1);
  positions[n].ticket=ticket;
  positions[n].symbol=symbol;
  positions[n].magic=magic;
  positions[n].side=side;
  positions[n].lots=lots;
 }
 return true;
}
bool A28Compare(const SMA_A28Position &snapshot[],const SMA_A28Position &live[],
 const string symbol,const long magic,const int side)
{
 int n=ArraySize(snapshot);
 if(n==0||n!=ArraySize(live)||symbol==""||magic<=0||
    (side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL))return false;
 for(int i=0;i<n;i++)
 {
  if(snapshot[i].ticket==0||snapshot[i].symbol!=symbol||
     snapshot[i].magic!=magic||snapshot[i].side!=side||
     snapshot[i].lots<=0||!MathIsValidNumber(snapshot[i].lots))return false;
  bool found=false;
  for(int j=0;j<n;j++)
  {
   if(i!=j&&snapshot[i].ticket==snapshot[j].ticket)return false;
   if(snapshot[i].ticket!=live[j].ticket)continue;
   if(live[j].symbol!=symbol||live[j].magic!=magic||live[j].side!=side||
      live[j].lots<=0||!MathIsValidNumber(live[j].lots)||
      MathAbs(snapshot[i].lots-live[j].lots)>0.00000001)return false;
   found=true;
  }
  if(!found)return false;
 }
 for(int j=0;j<n;j++)
  for(int k=0;k<j;k++)if(live[j].ticket==live[k].ticket)return false;
 return true;
}
void A28Copy(const SMA_A28Position &src[],SMA_A28Position &dst[])
{
 int n=ArraySize(src);ArrayResize(dst,n);
 for(int i=0;i<n;i++)dst[i]=src[i];
}
int OnInit()
{
 SMA_A28Position saved[],current[],mutated[];
 const int side=(int)POSITION_TYPE_SELL;
 bool captured=A28Read(saved,_Symbol,InpMagic,side);
 A28Check("CAPTURE_OK",captured);
 bool refreshed=A28Read(current,_Symbol,InpMagic,side);
 A28Check("REFRESH_OK",refreshed);
 int n=ArraySize(saved);
 if(captured&&refreshed&&n>0)
 {
  A28Check("LIVE_SET_MATCH",A28Compare(saved,current,_Symbol,InpMagic,side));
  A28Copy(current,mutated);mutated[0].lots+=0.01;
  A28Check("STALE_LOTS_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  A28Copy(current,mutated);mutated[0].ticket=0;
  A28Check("MISSING_TICKET_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  A28Copy(current,mutated);mutated[0].magic++;
  A28Check("WRONG_MAGIC_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  A28Copy(current,mutated);mutated[0].symbol+="_X";
  A28Check("WRONG_SYMBOL_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  A28Copy(current,mutated);mutated[0].side=(int)POSITION_TYPE_BUY;
  A28Check("WRONG_SIDE_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  A28Copy(current,mutated);ArrayResize(mutated,n+1);
  mutated[n]=current[0];mutated[n].ticket=(ulong)(-1);
  A28Check("ADDED_POSITION_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  A28Copy(current,mutated);ArrayResize(mutated,0);
  A28Check("EMPTY_SET_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  if(n>1)
  {
   A28Copy(current,mutated);mutated[1].ticket=mutated[0].ticket;
   A28Check("DUPLICATE_TICKET_REJECT",!A28Compare(saved,mutated,_Symbol,InpMagic,side));
  }
  for(int i=0;i<n;i++)
   Print("[MA_ME_LIVE_SET_TICKET] ticket=",saved[i].ticket,
         " side=",saved[i].side," lots=",DoubleToString(saved[i].lots,2));
 }
 Print("[MA_ME_LIVE_SET_INFO] symbol=",_Symbol," magic=",InpMagic,
       " owned_sell=",n," cases=",g_cases," failures=",g_fails);
 if(g_fails>0)
  Print("[MA_ME_LIVE_SET_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(n==0)
  Print("[MA_ME_LIVE_SET_INCONCLUSIVE] cases=",g_cases,
   " no_owned_sell=1 live_set_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_LIVE_SET_PASS] cases=",g_cases,
   " live_set_read_only=PASS multi_position_certified=",(n>1?1:0),
   " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
