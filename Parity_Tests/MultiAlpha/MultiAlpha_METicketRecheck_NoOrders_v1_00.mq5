#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Explicit_Target_Preview_v1_00.mqh>
// A14-24: recheck previously selected ticket immediately before a hypothetical close.
// Strictly read-only: no CTrade, OrderSend, PositionClose or trade requests.
input long InpMagic=46102031;
int g_cases=0,g_fails=0;
void A24Check(const string name,const bool ok)
{
 g_cases++;if(!ok)g_fails++;
 Print("[MA_ME_RECHECK_CASE] ",name," ",ok?"PASS":"FAIL");
}
struct SMA_A24TicketSnapshot
{
 ulong ticket;
 string symbol;
 long magic;
 int side;
 double lots;
};
bool A24Valid(const SMA_A24TicketSnapshot &s)
{
 return s.ticket>0&&s.symbol!=""&&s.magic>0&&
 (s.side==(int)POSITION_TYPE_BUY||s.side==(int)POSITION_TYPE_SELL)&&
 s.lots>0.0&&MathIsValidNumber(s.lots);
}
bool A24Compare(const SMA_A24TicketSnapshot &expected,
 const SMA_A24TicketSnapshot &actual)
{
 if(!A24Valid(expected)||!A24Valid(actual))return false;
 return expected.ticket==actual.ticket&&expected.symbol==actual.symbol&&
 expected.magic==actual.magic&&expected.side==actual.side&&
 MathAbs(expected.lots-actual.lots)<0.00000001;
}
bool A24Read(const ulong ticket,SMA_A24TicketSnapshot &out)
{
 if(ticket==0||!PositionSelectByTicket(ticket))return false;
 out.ticket=ticket;
 out.symbol=PositionGetString(POSITION_SYMBOL);
 out.magic=PositionGetInteger(POSITION_MAGIC);
 out.side=(int)PositionGetInteger(POSITION_TYPE);
 out.lots=PositionGetDouble(POSITION_VOLUME);
 return A24Valid(out);
}
bool A24Recheck(const SMA_A24TicketSnapshot &expected,
 const string symbol,const long magic,const int targetSide,
 const bool brokerArmed)
{
 if(brokerArmed||symbol==""||magic<=0||!A24Valid(expected))return false;
 if(expected.symbol!=symbol||expected.magic!=magic||
    expected.side!=targetSide)return false;
 SMA_A24TicketSnapshot current;
 if(!A24Read(expected.ticket,current))return false;
 return A24Compare(expected,current);
}
int OnInit()
{
 SMA_A24TicketSnapshot snapshot,changed;
 bool found=false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)continue;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||
     PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  if(A24Read(ticket,snapshot)){found=true;break;}
 }
 // Deterministic fixture tests, independent of broker positions.
 SMA_A24TicketSnapshot fixture;
 fixture.ticket=1234567;fixture.symbol=_Symbol;fixture.magic=InpMagic;
 fixture.side=(int)POSITION_TYPE_SELL;fixture.lots=0.01;
 A24Check("FIXTURE_VALID",A24Valid(fixture));
 changed=fixture;A24Check("SAME_SNAPSHOT",A24Compare(fixture,changed));
 changed=fixture;changed.ticket++;
 A24Check("TICKET_CHANGED_REJECT",!A24Compare(fixture,changed));
 changed=fixture;changed.symbol+="_OTHER";
 A24Check("SYMBOL_CHANGED_REJECT",!A24Compare(fixture,changed));
 changed=fixture;changed.magic++;
 A24Check("MAGIC_CHANGED_REJECT",!A24Compare(fixture,changed));
 changed=fixture;changed.side=(int)POSITION_TYPE_BUY;
 A24Check("SIDE_CHANGED_REJECT",!A24Compare(fixture,changed));
 changed=fixture;changed.lots=0.02;
 A24Check("LOTS_CHANGED_REJECT",!A24Compare(fixture,changed));
 changed=fixture;changed.lots=0.0;
 A24Check("ZERO_LOTS_REJECT",!A24Compare(fixture,changed));
 changed=fixture;changed.ticket=0;
 A24Check("ZERO_TICKET_REJECT",!A24Compare(fixture,changed));
 A24Check("NONEXISTENT_TICKET_REJECT",!A24Recheck(fixture,_Symbol,InpMagic,fixture.side,false));
 if(found)
 {
  A24Check("LIVE_RECHECK",A24Recheck(snapshot,_Symbol,InpMagic,snapshot.side,false));
  A24Check("LIVE_WRONG_MAGIC_REJECT",!A24Recheck(snapshot,_Symbol,InpMagic+1,snapshot.side,false));
  A24Check("LIVE_WRONG_SYMBOL_REJECT",!A24Recheck(snapshot,_Symbol+"_OTHER",InpMagic,snapshot.side,false));
  A24Check("LIVE_OPPOSITE_SIDE_REJECT",!A24Recheck(snapshot,_Symbol,InpMagic,1-snapshot.side,false));
  A24Check("LIVE_ARMED_REJECT",!A24Recheck(snapshot,_Symbol,InpMagic,snapshot.side,true));
  changed=snapshot;changed.lots+=0.01;
  A24Check("LIVE_STALE_LOTS_REJECT",!A24Recheck(changed,_Symbol,InpMagic,changed.side,false));
  Print("[MA_ME_RECHECK_INFO] ticket=",snapshot.ticket," side=",snapshot.side,
   " lots=",DoubleToString(snapshot.lots,2)," symbol=",snapshot.symbol," magic=",snapshot.magic);
 }
 Print("[MA_ME_RECHECK_INFO] owned_found=",found?1:0," cases=",g_cases," failures=",g_fails);
 if(g_fails>0)
  Print("[MA_ME_RECHECK_FAIL] cases=",g_cases," failures=",g_fails," NO_ORDERS=1");
 else if(!found)
  Print("[MA_ME_RECHECK_INCONCLUSIVE] cases=",g_cases," zero_owned_positions=1 fixture_checks=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_RECHECK_PASS] cases=",g_cases," live_ticket_recheck=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
