#property strict
#property version "1.00"
#include "../../../Include/Builder/MultiAlpha_ME_Owned_Side_Audit_v1_00.mqh"
// A14-19: reads existing owned positions, never creates/modifies/closes them.
input long InpMagic=46102031;
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;Print("[MA_ME_OWNED_SIDE_CASE] ",name," ",ok?"PASS":"FAIL");
 if(!ok)failures++;
}
void Fixture(SMA_MEAdapterPreview100 &p,SMA_MECloseSideResolution100 &s,const int side)
{
 MAResetMEAdapterPreview100(p);MAResetMECloseSideResolution100(s);
 p.state=MA_ME_PREVIEW_ACCEPTED;p.role=3;p.action="CLOSE_SIDE";
 p.symbol=_Symbol;p.magic=InpMagic;p.slotIndex=99;
 s.state=MA_ME_SIDE_CANDIDATE;s.side=side;
}
int OnInit()
{
 SMA_PositionMetrics100 m;string why="";
 if(!MAReadPositionMetrics100(_Symbol,InpMagic,m,why))
 {Print("[MA_ME_OWNED_SIDE_FAIL] metrics=",why);return INIT_FAILED;}
 SMA_MEAdapterPreview100 p;SMA_MECloseSideResolution100 s;
 SMA_MEOwnedSideAudit100 out;
 int side=m.sellCount>0?(int)POSITION_TYPE_SELL:(int)POSITION_TYPE_BUY;
 int count=side==(int)POSITION_TYPE_SELL?m.sellCount:m.buyCount;
 double lots=side==(int)POSITION_TYPE_SELL?m.sellLots:m.buyLots;
 Fixture(p,s,side);
 bool ok=MAAuditMEOwnedCandidateSide100(p,s,out);
 Check("OBSERVED_OR_EMPTY",count>0?(ok&&out.state==MA_ME_OWNED_OBSERVED):(!ok&&out.state==MA_ME_OWNED_BLOCKED));
 Check("COUNT_MATCH",count>0?(out.ownedCount==count):(out.ownedCount==0));
 Check("LOTS_MATCH",count>0?(MathAbs(out.ownedLots-lots)<1e-8):(out.ownedLots==0.0));
 Check("NO_EXECUTION_AUTHORIZATION",!out.brokerArmed);
 p.brokerArmed=true;
 Check("ARMED_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 p.brokerArmed=false;s.brokerArmed=true;
 Check("SIDE_ARMED_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 s.brokerArmed=false;s.side=-1;
 Check("INVALID_SIDE_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 s.side=side;p.magic=0;
 Check("ZERO_MAGIC_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 p.magic=InpMagic;p.symbol="";
 Check("EMPTY_SYMBOL_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 p.symbol=_Symbol;p.role=2;
 Check("MANAGE_ROLE_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 p.role=3;p.action="CLOSE_OPPOSITE";
 Check("OPPOSITE_ACTION_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 p.action="CLOSE_SIDE";p.slotIndex=100;
 Check("SLOT_RANGE_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 p.slotIndex=99;s.state=MA_ME_SIDE_BLOCKED;
 Check("UNRESOLVED_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 s.state=MA_ME_SIDE_CANDIDATE;p.state=MA_ME_PREVIEW_BLOCKED;
 Check("PREVIEW_BLOCKED_REJECT",!MAAuditMEOwnedCandidateSide100(p,s,out));
 Print("[MA_ME_OWNED_SIDE_INFO] symbol=",_Symbol," magic=",InpMagic,
       " buy=",m.buyCount," sell=",m.sellCount," selected_count=",count);
 if(failures>0)
  Print("[MA_ME_OWNED_SIDE_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 else if(count==0)
  Print("[MA_ME_OWNED_SIDE_INCONCLUSIVE] cases=",checks,
   " zero_owned_candidate_side=1 fixture_checks=PASS runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else
  Print("[MA_ME_OWNED_SIDE_PASS] cases=",checks,
   " owned_candidate_nonzero=1 target_authorized=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
