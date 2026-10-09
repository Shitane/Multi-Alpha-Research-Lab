#property strict
#property version "1.00"
// A14-31: live owned-position target selection and fail-closed set recheck.
// Read-only. No OrderSend, CTrade, position modify or close APIs.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
struct A31Pos { ulong ticket; string symbol; long magic; int side; double lots; };
void Check31(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_LIVE_TARGET_CASE] ",name," ",ok?"PASS":"FAIL");
}
void Copy31(A31Pos &dst,const A31Pos &src)
{
 dst.ticket=src.ticket;dst.symbol=src.symbol;dst.magic=src.magic;
 dst.side=src.side;dst.lots=src.lots;
}
bool Valid31(const A31Pos &p,const string symbol,const long magic)
{
 return p.ticket>0&&p.symbol==symbol&&p.magic==magic&&
 (p.side==(int)POSITION_TYPE_BUY||p.side==(int)POSITION_TYPE_SELL)&&
 p.lots>0&&MathIsValidNumber(p.lots);
}
bool Capture31(A31Pos &out[],const string symbol,const long magic)
{
 ArrayResize(out,0);
 if(symbol==""||magic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0){ArrayResize(out,0);return false;}
  if(PositionGetString(POSITION_SYMBOL)!=symbol||
     PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  A31Pos p;
  p.ticket=ticket;
  p.symbol=PositionGetString(POSITION_SYMBOL);
  p.magic=PositionGetInteger(POSITION_MAGIC);
  p.side=(int)PositionGetInteger(POSITION_TYPE);
  p.lots=PositionGetDouble(POSITION_VOLUME);
  if(!Valid31(p,symbol,magic)){ArrayResize(out,0);return false;}
  for(int j=0;j<ArraySize(out);j++)
   if(out[j].ticket==p.ticket){ArrayResize(out,0);return false;}
  int n=ArraySize(out);ArrayResize(out,n+1);Copy31(out[n],p);
 }
 return true;
}
bool Select31(A31Pos &source[],const string symbol,const long magic,
              const int role,const int side,A31Pos &out[])
{
 ArrayResize(out,0);
 if(symbol==""||magic<=0||(role!=2&&role!=3)||
   (side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL)||
   ArraySize(source)<1)return false;
 for(int i=0;i<ArraySize(source);i++)
 {
  if(!Valid31(source[i],symbol,magic))return false;
  for(int j=0;j<i;j++)if(source[i].ticket==source[j].ticket)return false;
 }
 for(int i=0;i<ArraySize(source);i++)if(source[i].side==side)
 {
  int n=ArraySize(out);ArrayResize(out,n+1);Copy31(out[n],source[i]);
 }
 return ArraySize(out)>0;
}
bool Same31(A31Pos &baseline[],A31Pos &current[])
{
 int n=ArraySize(baseline);
 if(n<1||n!=ArraySize(current))return false;
 for(int i=0;i<n;i++)
 {
  if(baseline[i].ticket==0||baseline[i].lots<=0||
     !MathIsValidNumber(baseline[i].lots))return false;
  for(int k=0;k<i;k++)
   if(baseline[i].ticket==baseline[k].ticket||
      current[i].ticket==current[k].ticket)return false;
  bool found=false;
  for(int j=0;j<n;j++)
   if(baseline[i].ticket==current[j].ticket&&
      baseline[i].symbol==current[j].symbol&&
      baseline[i].magic==current[j].magic&&
      baseline[i].side==current[j].side&&
      MathAbs(baseline[i].lots-current[j].lots)<0.00000001)
   {found=true;break;}
  if(!found)return false;
 }
 return true;
}
bool Recheck31(A31Pos &baseline[],const string symbol,const long magic,
               const int role,const int side,A31Pos &currentTargets[])
{
 ArrayResize(currentTargets,0);
 A31Pos live[],selected[];
 if(!Capture31(live,symbol,magic))return false;
 if(!Select31(live,symbol,magic,role,side,selected))return false;
 if(!Same31(baseline,selected))return false;
 for(int i=0;i<ArraySize(selected);i++)
 {
  int n=ArraySize(currentTargets);ArrayResize(currentTargets,n+1);
  Copy31(currentTargets[n],selected[i]);
 }
 return true;
}
int OnInit()
{
 A31Pos owned[],baseline[],refreshed[],tampered[],scratch[],fullRefresh[];
 bool captured=Capture31(owned,_Symbol,InpMagic);
 Check31("LIVE_CAPTURE",captured);
 int n=ArraySize(owned),buys=0,sells=0;
 for(int i=0;i<n;i++)
 {
  if(owned[i].side==(int)POSITION_TYPE_BUY)buys++;
  if(owned[i].side==(int)POSITION_TYPE_SELL)sells++;
  Print("[MA_ME_LIVE_TARGET_TICKET] ticket=",owned[i].ticket,
        " side=",owned[i].side," lots=",DoubleToString(owned[i].lots,8));
 }
 Check31("LIVE_CAPTURE_REFRESH",Capture31(fullRefresh,_Symbol,InpMagic));
 if(n>0)
  Check31("LIVE_OWNED_SET_MATCH",Same31(owned,fullRefresh));
 else
  Print("[MA_ME_LIVE_TARGET_INFO] NO_OWNED_POSITIONS; runtime checks inconclusive");
 int side=(sells>0?(int)POSITION_TYPE_SELL:(int)POSITION_TYPE_BUY);
 int sideCount=(sells>0?sells:buys);
 bool ready=captured&&sideCount>0&&Select31(owned,_Symbol,InpMagic,3,side,baseline);
 if(ready)
 {
  Check31("EXIT_LIVE_TARGET_SELECT",ArraySize(baseline)==sideCount);
  Check31("EXIT_LIVE_RECHECK",Recheck31(baseline,_Symbol,InpMagic,3,side,refreshed)&&Same31(baseline,refreshed));
  Check31("MANAGE_LIVE_RECHECK",Recheck31(baseline,_Symbol,InpMagic,2,side,refreshed));
  Check31("ENTRY_ROLE_REJECT",!Recheck31(baseline,_Symbol,InpMagic,0,side,refreshed));
  Check31("GRID_ROLE_REJECT",!Recheck31(baseline,_Symbol,InpMagic,1,side,refreshed));
  Check31("OPPOSITE_SIDE_REJECT",!Recheck31(baseline,_Symbol,InpMagic,3,1-side,refreshed));
  Check31("WRONG_MAGIC_REJECT",!Recheck31(baseline,_Symbol,InpMagic+1,3,side,refreshed));
  Check31("WRONG_SYMBOL_REJECT",!Recheck31(baseline,_Symbol+"_OTHER",InpMagic,3,side,refreshed));
  Check31("ZERO_MAGIC_REJECT",!Recheck31(baseline,_Symbol,0,3,side,refreshed));
  Check31("EMPTY_SYMBOL_REJECT",!Recheck31(baseline,"",InpMagic,3,side,refreshed));
  ArrayResize(tampered,ArraySize(baseline));
  for(int i=0;i<ArraySize(baseline);i++)Copy31(tampered[i],baseline[i]);
  tampered[0].lots+=0.01;
  Check31("STALE_VOLUME_REJECT",!Recheck31(tampered,_Symbol,InpMagic,3,side,scratch));
  tampered[0].lots=baseline[0].lots;tampered[0].ticket=0;
  Check31("ZERO_TICKET_REJECT",!Recheck31(tampered,_Symbol,InpMagic,3,side,scratch));
  tampered[0].ticket=baseline[0].ticket;tampered[0].side=1-side;
  Check31("SIDE_CHANGED_REJECT",!Recheck31(tampered,_Symbol,InpMagic,3,side,scratch));
  tampered[0].side=baseline[0].side;tampered[0].ticket=baseline[0].ticket+999999;
  Check31("REPLACED_TICKET_REJECT",!Recheck31(tampered,_Symbol,InpMagic,3,side,scratch));
  if(ArraySize(baseline)>1)
  {
   Copy31(tampered[0],baseline[0]);
   Copy31(tampered[1],baseline[0]);
   Check31("DUPLICATE_TICKET_REJECT",!Recheck31(tampered,_Symbol,InpMagic,3,side,scratch));
   ArrayResize(tampered,ArraySize(baseline)-1);
   Check31("REMOVED_TARGET_REJECT",!Recheck31(tampered,_Symbol,InpMagic,3,side,scratch));
  }
 }
 Print("[MA_ME_LIVE_TARGET_INFO] symbol=",_Symbol," magic=",InpMagic,
       " owned_positions=",n," owned_buy=",buys," owned_sell=",sells,
       " target_count=",sideCount," cases=",g_cases," failures=",g_fails);
 if(g_fails>0)
  Print("[MA_ME_LIVE_TARGET_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(!ready||n<2||sideCount<2)
  Print("[MA_ME_LIVE_TARGET_INCONCLUSIVE] cases=",g_cases,
        " live_single_target_checks=",(ready?"PASS":"NOT_RUN"),
        " live_multi_target_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_LIVE_TARGET_PASS] cases=",g_cases,
        " live_multi_target_read_only=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
