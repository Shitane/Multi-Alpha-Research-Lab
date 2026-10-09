#property strict
#property version "1.00"
// A14-29: multi-position fixture and live owned-set read-only validation.
// No order send/modify/close calls.
input long InpMagic=46102031;
int g_cases=0,g_failures=0;
struct MA29Position { ulong ticket; string symbol; long magic; int side; double lots; };
void MA29Check(const string name,const bool ok)
{
 g_cases++; if(!ok)g_failures++;
 Print("[MA_ME_MULTI_CASE] ",name," ",ok?"PASS":"FAIL");
}
void MA29Copy(MA29Position &dst,const MA29Position &src)
{
 dst.ticket=src.ticket;dst.symbol=src.symbol;dst.magic=src.magic;dst.side=src.side;dst.lots=src.lots;
}
void MA29Set(MA29Position &p,const ulong ticket,const string symbol,const long magic,const int side,const double lots)
{
 p.ticket=ticket;p.symbol=symbol;p.magic=magic;p.side=side;p.lots=lots;
}
bool MA29Valid(const MA29Position &p,const string symbol,const long magic)
{
 return p.ticket>0 && p.symbol==symbol && p.magic==magic &&
        (p.side==POSITION_TYPE_BUY || p.side==POSITION_TYPE_SELL) && p.lots>0.0;
}
bool MA29Same(const MA29Position &a,const MA29Position &b)
{
 return a.ticket==b.ticket && a.symbol==b.symbol && a.magic==b.magic &&
        a.side==b.side && MathAbs(a.lots-b.lots)<0.00000001;
}
bool MA29Compare(MA29Position &baseline[],MA29Position &current[],const string symbol,const long magic)
{
 int n=ArraySize(baseline);
 if(n<2 || n!=ArraySize(current) || symbol=="" || magic<=0)return false;
 for(int i=0;i<n;i++)
 {
  if(!MA29Valid(baseline[i],symbol,magic) || !MA29Valid(current[i],symbol,magic))return false;
  for(int j=0;j<i;j++)
   if(baseline[i].ticket==baseline[j].ticket || current[i].ticket==current[j].ticket)return false;
  bool found=false;
  for(int k=0;k<n;k++)if(MA29Same(baseline[i],current[k])){found=true;break;}
  if(!found)return false;
 }
 return true;
}
bool MA29Capture(MA29Position &positions[],const string symbol,const long magic)
{
 ArrayResize(positions,0);
 if(symbol=="" || magic<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)return false;
  if(PositionGetString(POSITION_SYMBOL)!=symbol || PositionGetInteger(POSITION_MAGIC)!=magic)continue;
  int n=ArraySize(positions);
  ArrayResize(positions,n+1);
  MA29Set(positions[n],ticket,PositionGetString(POSITION_SYMBOL),
    PositionGetInteger(POSITION_MAGIC),(int)PositionGetInteger(POSITION_TYPE),
    PositionGetDouble(POSITION_VOLUME));
 }
 return true;
}
int OnInit()
{
 MA29Position base[],cur[];
 ArrayResize(base,2);ArrayResize(cur,2);
 MA29Set(base[0],101,_Symbol,InpMagic,POSITION_TYPE_SELL,0.01);
 MA29Set(base[1],102,_Symbol,InpMagic,POSITION_TYPE_SELL,0.02);
 MA29Copy(cur[0],base[0]);MA29Copy(cur[1],base[1]);
 MA29Check("TWO_POSITION_MATCH",MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[0],base[1]);MA29Copy(cur[1],base[0]);
 MA29Check("REORDER_ACCEPT",MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Set(cur[1],103,_Symbol,InpMagic,POSITION_TYPE_SELL,0.01);
 MA29Check("REPLACED_TICKET_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[0],base[0]);MA29Copy(cur[1],base[1]);
 cur[1].lots=0.03;
 MA29Check("VOLUME_CHANGE_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[1],base[1]);cur[1].side=POSITION_TYPE_BUY;
 MA29Check("SIDE_CHANGE_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[1],base[1]);cur[1].magic=InpMagic+1;
 MA29Check("MAGIC_CHANGE_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[1],base[1]);cur[1].symbol=_Symbol+"_OTHER";
 MA29Check("SYMBOL_CHANGE_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[1],base[0]);
 MA29Check("DUPLICATE_TICKET_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[1],base[1]);cur[1].lots=0;
 MA29Check("ZERO_LOTS_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 MA29Copy(cur[1],base[1]);cur[1].ticket=0;
 MA29Check("ZERO_TICKET_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 ArrayResize(cur,1);
 MA29Check("REMOVED_POSITION_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 ArrayResize(cur,3);MA29Copy(cur[0],base[0]);MA29Copy(cur[1],base[1]);
 MA29Set(cur[2],103,_Symbol,InpMagic,POSITION_TYPE_BUY,0.01);
 MA29Check("ADDED_POSITION_REJECT",!MA29Compare(base,cur,_Symbol,InpMagic));
 ArrayResize(cur,2);MA29Copy(cur[0],base[0]);MA29Copy(cur[1],base[1]);
 MA29Check("EMPTY_SYMBOL_REJECT",!MA29Compare(base,cur,"",InpMagic));
 MA29Check("ZERO_MAGIC_REJECT",!MA29Compare(base,cur,_Symbol,0));
 MA29Position live[],refresh[];
 bool captured=MA29Capture(live,_Symbol,InpMagic);
 bool refreshed=MA29Capture(refresh,_Symbol,InpMagic);
 MA29Check("LIVE_CAPTURE_OK",captured);
 MA29Check("LIVE_REFRESH_OK",refreshed);
 int count=ArraySize(live);
 bool certified=captured && refreshed && count>=2 && MA29Compare(live,refresh,_Symbol,InpMagic);
 if(count>=2)MA29Check("LIVE_MULTI_SET_MATCH",certified);
 else MA29Check("LIVE_MULTI_NOT_CERTIFIED",!certified);
 Print("[MA_ME_MULTI_INFO] symbol=",_Symbol," magic=",InpMagic,
       " owned_positions=",count," fixture_positions=2 cases=",g_cases," failures=",g_failures);
 if(g_failures>0)
  Print("[MA_ME_MULTI_FAIL] cases=",g_cases," failures=",g_failures," NO_ORDERS=1");
 else
  Print("[MA_ME_MULTI_PASS] cases=",g_cases,
        " fixture_multi_position=PASS live_multi_certified=",(certified?"1":"0"),
        " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
