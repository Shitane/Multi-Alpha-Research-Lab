#property strict
#property version "1.00"
#include <Builder/MultiAlpha_ME_Final_Preview_Gate_v1_00.mqh>
// A14-40: per-ticket MANAGE/EXIT arbitration with a 3-position fixture.
// No order submission or position mutation. Live multi-position NOT certified.
input long InpMagic=46102031;
int a40_cases=0,a40_failures=0;
void A40Check(const string label,const bool ok)
{
 a40_cases++;if(!ok)a40_failures++;
 Print("[MA_ME_MULTI_TICKET_CASE] ",label," ",ok?"PASS":"FAIL");
}
void A40Set(SMA_MEFinalPosition100 &p,const ulong ticket,
 const string symbol,const long magic,const int side,const double lots)
{
 p.ticket=ticket;p.symbol=symbol;p.magic=magic;p.side=side;p.lots=lots;
}
void A40Copy(SMA_MEFinalPosition100 &src[],SMA_MEFinalPosition100 &dst[])
{
 int count=ArraySize(src);ArrayResize(dst,count);
 for(int i=0;i<count;i++)dst[i]=src[i];
}
bool A40Run(SMA_MEFinalPosition100 &before[],SMA_MEFinalPosition100 &after[],
 const ulong ticket,const bool manageSignal,const bool exitSignal,
 const bool armed,const int expectedState,const int expectedAction)
{
 SMA_MEFinalPreview100 out;
 bool ok=MABuildMEFinalPreview100(before,after,_Symbol,InpMagic,
  ticket,manageSignal,exitSignal,armed,out);
 if(expectedState==MA_ME_FINAL_BLOCKED)
  return !ok&&out.state==MA_ME_FINAL_BLOCKED&&!out.brokerArmed;
 return ok&&out.state==expectedState&&out.action==expectedAction
  &&out.ticket==ticket&&!out.brokerArmed;
}
int OnInit()
{
 SMA_MEFinalPosition100 base[],current[],live[];
 ArrayResize(base,3);
 A40Set(base[0],940001,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.01);
 A40Set(base[1],940002,_Symbol,InpMagic,(int)POSITION_TYPE_SELL,0.02);
 A40Set(base[2],940003,_Symbol,InpMagic,(int)POSITION_TYPE_BUY,0.03);
 A40Copy(base,current);
 A40Check("BASE_SET_VALID",MASameMEFinalSet100(base,current,_Symbol,InpMagic));
 A40Check("TICKET1_EXIT_WINS",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_PREVIEW,2));
 A40Check("TICKET2_MANAGE_ONLY",A40Run(base,current,940002,true,false,false,MA_ME_FINAL_PREVIEW,1));
 A40Check("TICKET3_EXIT_ONLY",A40Run(base,current,940003,false,true,false,MA_ME_FINAL_PREVIEW,2));
 A40Check("TICKET2_IDLE_INDEPENDENT",A40Run(base,current,940002,false,false,false,MA_ME_FINAL_IDLE,0));
 A40Check("TICKET1_MANAGE_ONLY",A40Run(base,current,940001,true,false,false,MA_ME_FINAL_PREVIEW,1));
 A40Check("TICKET3_IDLE",A40Run(base,current,940003,false,false,false,MA_ME_FINAL_IDLE,0));
 A40Check("UNKNOWN_TICKET_REJECT",A40Run(base,current,949999,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Check("ZERO_TICKET_REJECT",A40Run(base,current,0,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Check("ARMED_REJECT",A40Run(base,current,940001,true,true,true,MA_ME_FINAL_BLOCKED,0));
 SMA_MEFinalPosition100 swap=current[0];current[0]=current[2];current[2]=swap;
 A40Check("REORDER_ACCEPT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_PREVIEW,2));
 A40Copy(base,current);current[1].lots=0.01;
 A40Check("PARTIAL_CLOSE_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);current[1].lots=0.03;
 A40Check("VOLUME_INCREASE_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);current[1].ticket=949999;
 A40Check("REPLACED_OTHER_TICKET_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);current[1].ticket=current[0].ticket;
 A40Check("DUPLICATE_TICKET_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);current[1].magic=InpMagic+1;
 A40Check("OTHER_MAGIC_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);current[1].symbol="OTHER_SYMBOL";
 A40Check("OTHER_SYMBOL_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);current[1].side=(int)POSITION_TYPE_BUY;
 A40Check("SIDE_CHANGED_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);ArrayResize(current,2);
 A40Check("REMOVED_POSITION_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);ArrayResize(current,4);
 A40Set(current[3],940004,_Symbol,InpMagic,(int)POSITION_TYPE_BUY,0.01);
 A40Check("ADDED_POSITION_REJECT",A40Run(base,current,940001,true,true,false,MA_ME_FINAL_BLOCKED,0));
 A40Copy(base,current);
 A40Check("RESTORED_SET_ACCEPT",A40Run(base,current,940002,true,false,false,MA_ME_FINAL_PREVIEW,1));
 bool captured=MACaptureMEFinalOwned100(_Symbol,InpMagic,live);
 A40Check("LIVE_CAPTURE",captured);
 bool liveValid=captured;
 for(int i=0;i<ArraySize(live);i++)
  if(!MAValidMEFinalPosition100(live[i],_Symbol,InpMagic))liveValid=false;
 A40Check("LIVE_OWNED_VALID",liveValid);
 if(ArraySize(live)>0)
 {
  SMA_MEFinalPosition100 fresh[];
  bool refreshed=MACaptureMEFinalOwned100(_Symbol,InpMagic,fresh);
  A40Check("LIVE_REFRESH",refreshed);
  bool same=refreshed&&MASameMEFinalSet100(live,fresh,_Symbol,InpMagic);
  A40Check("LIVE_UNCHANGED_SET",same);
  if(same)
   A40Check("LIVE_FIRST_TICKET_PREVIEW",A40Run(live,fresh,live[0].ticket,
    true,true,false,MA_ME_FINAL_PREVIEW,2));
 }
 Print("[MA_ME_MULTI_TICKET_INFO] symbol=",_Symbol," magic=",InpMagic,
  " fixture_positions=3 live_owned=",ArraySize(live),
  " cases=",a40_cases," failures=",a40_failures);
 if(a40_failures>0)
  Print("[MA_ME_MULTI_TICKET_FAIL] cases=",a40_cases," failures=",a40_failures," NO_ORDERS=1");
 else
  Print("[MA_ME_MULTI_TICKET_PASS] cases=",a40_cases,
   " fixture_multi_ticket=PASS live_multi_certified=0 saved_slot_multi_certified=0",
   " runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
