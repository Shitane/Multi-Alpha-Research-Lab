#property strict
#property version "1.00"
// A14-33: NoOrders fixture-only MANAGE/EXIT arbitration.
// EXIT wins for the same target; unrelated tickets are independent.
input long InpMagic=46102031;
int checks=0,failures=0;
void Check(const string name,const bool ok)
{
 checks++;if(!ok)failures++;
 Print("[MA_ME_CONFLICT_CASE] ",name," ",ok?"PASS":"FAIL");
}
int Choose(const ulong ticket,const string symbol,const long magic,
           const int side,const double volume,const bool manage,const bool exitSignal)
{
 if(ticket==0||symbol!=_Symbol||magic!=InpMagic||InpMagic<=0||
    (side!=(int)POSITION_TYPE_BUY&&side!=(int)POSITION_TYPE_SELL)||
    volume<=0||!MathIsValidNumber(volume))return 0;
 if(exitSignal)return 2;
 if(manage)return 1;
 return 0;
}
int OnInit()
{
 ulong t=10001;
 int sell=(int)POSITION_TYPE_SELL;
 Check("BOTH_EXIT_PRIORITY",Choose(t,_Symbol,InpMagic,sell,0.01,true,true)==2);
 Check("MANAGE_ONLY",Choose(t,_Symbol,InpMagic,sell,0.01,true,false)==1);
 Check("EXIT_ONLY",Choose(t,_Symbol,InpMagic,sell,0.01,false,true)==2);
 Check("NO_SIGNAL_BLOCK",Choose(t,_Symbol,InpMagic,sell,0.01,false,false)==0);
 Check("WRONG_MAGIC_BLOCK",Choose(t,_Symbol,InpMagic+1,sell,0.01,true,true)==0);
 Check("WRONG_SYMBOL_BLOCK",Choose(t,_Symbol+"_X",InpMagic,sell,0.01,true,true)==0);
 Check("ZERO_TICKET_BLOCK",Choose(0,_Symbol,InpMagic,sell,0.01,true,true)==0);
 Check("ZERO_VOLUME_BLOCK",Choose(t,_Symbol,InpMagic,sell,0,true,true)==0);
 Check("INVALID_SIDE_BLOCK",Choose(t,_Symbol,InpMagic,-1,0.01,true,true)==0);
 Check("OTHER_TICKET_MANAGE",Choose(t+1,_Symbol,InpMagic,sell,0.01,true,false)==1);
 bool found=false;
 for(int i=0;i<PositionsTotal();i++)
 {
  ulong ticket=PositionGetTicket(i);
  if(ticket==0)continue;
  if(PositionGetString(POSITION_SYMBOL)!=_Symbol||
     PositionGetInteger(POSITION_MAGIC)!=InpMagic)continue;
  found=true;
  int side=(int)PositionGetInteger(POSITION_TYPE);
  double lots=PositionGetDouble(POSITION_VOLUME);
  Check("LIVE_BOTH_EXIT_PRIORITY",Choose(ticket,_Symbol,InpMagic,side,lots,true,true)==2);
  Check("LIVE_MANAGE_ONLY",Choose(ticket,_Symbol,InpMagic,side,lots,true,false)==1);
  Print("[MA_ME_CONFLICT_INFO] ticket=",ticket," lots=",DoubleToString(lots,8));
  break;
 }
 if(failures>0)Print("[MA_ME_CONFLICT_FAIL] cases=",checks," failures=",failures," NO_ORDERS=1");
 else if(!found)Print("[MA_ME_CONFLICT_INCONCLUSIVE] cases=",checks," fixture_only=PASS live_owned=0 builder_integration_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 else Print("[MA_ME_CONFLICT_PASS] cases=",checks," live_target_arbitration=PASS builder_integration_certified=0 runtime_certified=0 NO_ORDERS=1 BROKER_ACTIONS_ARMED=0 VIRTUAL_NOT_FILL=1");
 return INIT_SUCCEEDED;
}
void OnTick(){}
