#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Final_Preview_Gate_v1_00.mqh>
// A14-38 reusable gate integration: fixture mutations + live owned set.
// No OrderSend, CTrade, PositionClose or PositionModify.
input long InpMagic=46102031;
int a38_cases=0,a38_failures=0;
void A38Check(const string name,const bool ok)
{
 a38_cases++;if(!ok)a38_failures++;
 Print("[MA_ME_FINAL_GATE_CASE] ",name," ",ok?"PASS":"FAIL");
}
void A38Set(SMA_MEFinalPosition100 &p,const ulong ticket,const string symbol,
 const long magic,const int side,const double lots)
{p.ticket=ticket;p.symbol=symbol;p.magic=magic;p.side=side;p.lots=lots;}
void A38Copy(SMA_MEFinalPosition100 &d,const SMA_MEFinalPosition100 &s)
{A38Set(d,s.ticket,s.symbol,s.magic,s.side,s.lots);}
int OnInit()
{
 SMA_MEFinalPosition100 live[],fresh[],before[],after[];
 bool captured=MACaptureMEFinalOwned100(_Symbol,InpMagic,live);
 A38Check("LIVE_CAPTURE",captured);
 int side=(int)POSITION_TYPE_SELL;
 ArrayResize(before,3);ArrayResize(after,3);
 for(int i=0;i<3;i++)
 {
  A38Set(before[i],101+i,_Symbol,InpMagic,side,0.01*(i+1));
  A38Copy(after[i],before[i]);
 }
 SMA_MEFinalPreview100 out;
 bool ok=MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out);
 A38Check("EXIT_WINS",ok&&out.state==MA_ME_FINAL_PREVIEW&&out.action==2&&!out.brokerArmed);
 ok=MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,102,true,false,false,out);
 A38Check("MANAGE_INDEPENDENT",ok&&out.action==1&&out.ticket==102);
 ok=MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,103,false,false,false,out);
 A38Check("IDLE",ok&&out.state==MA_ME_FINAL_IDLE&&out.action==0);
 A38Check("ARMED_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,true,out)&&out.state==MA_ME_FINAL_BLOCKED);
 A38Check("UNKNOWN_TICKET_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,999,true,true,false,out));
 SMA_MEFinalPosition100 tmp;A38Copy(tmp,after[0]);A38Copy(after[0],after[2]);A38Copy(after[2],tmp);
 A38Check("REORDER_ACCEPT",MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 for(int i=0;i<3;i++)A38Copy(after[i],before[i]);
 after[0].lots=0.005;
 A38Check("PARTIAL_CLOSE_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 after[0].lots=0.04;
 A38Check("VOLUME_INCREASE_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].ticket=104;
 A38Check("REPLACED_TICKET_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].magic=InpMagic+1;
 A38Check("WRONG_MAGIC_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].symbol=_Symbol+"_OTHER";
 A38Check("WRONG_SYMBOL_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].side=(int)POSITION_TYPE_BUY;
 A38Check("SIDE_CHANGED_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].ticket=102;
 A38Check("DUPLICATE_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].ticket=0;
 A38Check("ZERO_TICKET_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);after[0].lots=0;
 A38Check("ZERO_LOTS_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Copy(after[0],before[0]);ArrayResize(after,2);
 A38Check("REMOVED_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 ArrayResize(after,4);
 for(int i=0;i<3;i++)A38Copy(after[i],before[i]);
 A38Set(after[3],104,_Symbol,InpMagic,side,0.04);
 A38Check("ADDED_REJECT",!MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,101,true,true,false,out));
 A38Check("LIVE_REFRESH",MACaptureMEFinalOwned100(_Symbol,InpMagic,fresh));
 bool same=captured&&MASameMEFinalSet100(live,fresh,_Symbol,InpMagic);
 A38Check("LIVE_SET_UNCHANGED",same);
 if(same)
 {
  bool liveOK=MABuildMEFinalPreview100(live,fresh,_Symbol,InpMagic,
   live[0].ticket,true,true,false,out);
  A38Check("LIVE_PREVIEW",liveOK&&out.state==MA_ME_FINAL_PREVIEW&&out.action==2&&!out.brokerArmed);
  Print("[MA_ME_FINAL_GATE_INFO] ticket=",out.ticket," action=",out.action," reason=",out.reason);
 }
 Print("[MA_ME_FINAL_GATE_INFO] symbol=",_Symbol," magic=",InpMagic,
  " live_owned=",ArraySize(live)," cases=",a38_cases," failures=",a38_failures);
 if(a38_failures>0)Print("[MA_ME_FINAL_GATE_FAIL] cases=",a38_cases," failures=",a38_failures," NO_ORDERS=1");
 else if(!same)Print("[MA_ME_FINAL_GATE_INCONCLUSIVE] cases=",a38_cases,
  " live_set_unavailable=1 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_FINAL_GATE_PASS] cases=",a38_cases,
  " reusable_final_gate=PASS saved_slot_upstream_not_integrated=1 live_multi_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
