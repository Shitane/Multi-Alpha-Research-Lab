#property strict
#property version "1.00"
// A14-30: read-only multi-position MANAGE/EXIT target selection.
// Fixture coverage is not live multi-position certification. No trade APIs.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
struct MA30Pos {ulong ticket;string symbol;long magic;int side;double lots;};
void Check30(string name,bool ok){g_cases++;if(!ok)g_fails++;Print("[MA_ME_TARGET_SET_CASE] ",name," ",ok?"PASS":"FAIL");}
void Set30(MA30Pos &p,ulong t,string s,long m,int side,double v){p.ticket=t;p.symbol=s;p.magic=m;p.side=side;p.lots=v;}
bool Valid30(const MA30Pos &p,string s,long m){return p.ticket>0&&p.symbol==s&&p.magic==m&&(p.side==(int)POSITION_TYPE_BUY||p.side==(int)POSITION_TYPE_SELL)&&p.lots>0&&MathIsValidNumber(p.lots);}
bool Capture30(MA30Pos &out[],string s,long m)
{
 ArrayResize(out,0);if(s==""||m<=0)return false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong t=PositionGetTicket(i);if(t==0)return false;
  if(PositionGetString(POSITION_SYMBOL)!=s||PositionGetInteger(POSITION_MAGIC)!=m)continue;
  int n=ArraySize(out);ArrayResize(out,n+1);
  Set30(out[n],t,PositionGetString(POSITION_SYMBOL),PositionGetInteger(POSITION_MAGIC),
   (int)PositionGetInteger(POSITION_TYPE),PositionGetDouble(POSITION_VOLUME));
 }
 return true;
}
bool Select30(MA30Pos &src[],string s,long m,int role,int side,MA30Pos &out[])
{
 ArrayResize(out,0);
 if(s==""||m<=0||(role!=2&&role!=3)||(side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL)||ArraySize(src)==0)return false;
 for(int i=0;i<ArraySize(src);i++)
 {
  if(!Valid30(src[i],s,m))return false;
  for(int j=0;j<i;j++)if(src[i].ticket==src[j].ticket)return false;
 }
 for(int i=0;i<ArraySize(src);i++)if(src[i].side==side)
 {
  int n=ArraySize(out);ArrayResize(out,n+1);
  Set30(out[n],src[i].ticket,src[i].symbol,src[i].magic,src[i].side,src[i].lots);
 }
 return ArraySize(out)>0;
}
bool Same30(MA30Pos &a[],MA30Pos &b[])
{
 int n=ArraySize(a);if(n<1||n!=ArraySize(b))return false;
 for(int i=0;i<n;i++)
 {
  bool found=false;
  for(int j=0;j<n;j++)if(a[i].ticket==b[j].ticket&&a[i].symbol==b[j].symbol&&
   a[i].magic==b[j].magic&&a[i].side==b[j].side&&MathAbs(a[i].lots-b[j].lots)<0.00000001){found=true;break;}
  if(!found)return false;
  for(int k=0;k<i;k++)if(a[i].ticket==a[k].ticket||b[i].ticket==b[k].ticket)return false;
 }
 return true;
}
int OnInit()
{
 MA30Pos src[],out[],expect[],live[],refresh[],a[],b[];
 ArrayResize(src,3);ArrayResize(expect,2);
 Set30(src[0],101,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.01);
 Set30(src[1],102,_Symbol,InpMagic,(int)POSITION_TYPE_BUY,0.02);
 Set30(src[2],103,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.03);
 Set30(expect[0],101,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.01);
 Set30(expect[1],103,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.03);
 Check30("EXIT_SELL_TWO",Select30(src,_Symbol,InpMagic,3,(int)POSITION_TYPE_SELL,out)&&Same30(out,expect));
 Check30("MANAGE_SELL_TWO",Select30(src,_Symbol,InpMagic,2,(int)POSITION_TYPE_SELL,out)&&Same30(out,expect));
 ArrayResize(expect,1);Set30(expect[0],102,_Symbol,InpMagic,(int)POSITION_TYPE_BUY,0.02);
 Check30("EXIT_BUY_ONLY",Select30(src,_Symbol,InpMagic,3,(int)POSITION_TYPE_BUY,out)&&Same30(out,expect));
 Check30("MANAGE_BUY_ONLY",Select30(src,_Symbol,InpMagic,2,(int)POSITION_TYPE_BUY,out)&&Same30(out,expect));
 Check30("ENTRY_ROLE_REJECT",!Select30(src,_Symbol,InpMagic,0,(int)POSITION_TYPE_SELL,out));
 Check30("GRID_ROLE_REJECT",!Select30(src,_Symbol,InpMagic,1,(int)POSITION_TYPE_SELL,out));
 Check30("INVALID_SIDE_REJECT",!Select30(src,_Symbol,InpMagic,3,9,out));
 Check30("EMPTY_SYMBOL_REJECT",!Select30(src,"",InpMagic,3,(int)POSITION_TYPE_SELL,out));
 Check30("ZERO_MAGIC_REJECT",!Select30(src,_Symbol,0,3,(int)POSITION_TYPE_SELL,out));
 src[2].ticket=101;
 Check30("DUPLICATE_REJECT",!Select30(src,_Symbol,InpMagic,3,(int)POSITION_TYPE_SELL,out));
 src[2].ticket=103;src[2].lots=0;
 Check30("ZERO_LOTS_REJECT",!Select30(src,_Symbol,InpMagic,3,(int)POSITION_TYPE_SELL,out));
 src[2].lots=0.03;src[2].magic=InpMagic+1;
 Check30("FOREIGN_MAGIC_REJECT",!Select30(src,_Symbol,InpMagic,3,(int)POSITION_TYPE_SELL,out));
 src[2].magic=InpMagic;src[2].symbol=_Symbol+"_OTHER";
 Check30("FOREIGN_SYMBOL_REJECT",!Select30(src,_Symbol,InpMagic,3,(int)POSITION_TYPE_SELL,out));
 src[2].symbol=_Symbol;
 ArrayResize(a,2);ArrayResize(b,2);
 Set30(a[0],101,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.01);
 Set30(a[1],103,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.03);
 Set30(b[0],103,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.03);
 Set30(b[1],101,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.01);
 Check30("REORDER_ACCEPT",Same30(a,b));
 b[0].lots=0.02;Check30("STALE_VOLUME_REJECT",!Same30(a,b));
 b[0].lots=0.03;b[0].ticket=104;Check30("REPLACED_TICKET_REJECT",!Same30(a,b));
 b[0].ticket=103;ArrayResize(b,1);Check30("REMOVED_TARGET_REJECT",!Same30(a,b));
 ArrayResize(b,3);Check30("ADDED_TARGET_REJECT",!Same30(a,b));
 bool cap=Capture30(live,_Symbol,InpMagic),ref=Capture30(refresh,_Symbol,InpMagic);
 Check30("LIVE_CAPTURE",cap);Check30("LIVE_REFRESH",ref);
 int n=ArraySize(live);
 bool multi=cap&&ref&&n>=2&&Same30(live,refresh);
 if(n>=2)Check30("LIVE_MULTI_MATCH",multi);
 else Check30("LIVE_MULTI_NOT_CERTIFIED",!multi);
 Print("[MA_ME_TARGET_SET_INFO] symbol=",_Symbol," magic=",InpMagic," owned_positions=",n," fixture_positions=3 cases=",g_cases," failures=",g_fails);
 if(g_fails>0)Print("[MA_ME_TARGET_SET_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else Print("[MA_ME_TARGET_SET_PASS] cases=",g_cases," fixture_target_selection=PASS live_multi_certified=",(multi?1:0)," runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
