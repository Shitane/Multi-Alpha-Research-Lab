#ifndef MULTIALPHA_ME_STATE_FLAGS100_V1_00_MQH
#define MULTIALPHA_ME_STATE_FLAGS100_V1_00_MQH
#include "MultiAlpha_Manage_Exit_Grammar_v1_01.mqh"
// Synthetic state only. Unsupported condition fails closed. No orders.
struct SMA_MEState100 { int buyCount; int sellCount; };
bool MAMEIntCmp(const int a,const string op,const int b)
{
 if(op=="EQ")return a==b;
 if(op=="GT")return a>b;
 if(op=="GE")return a>=b;
 if(op=="LT")return a<b;
 if(op=="LE")return a<=b;
 return false;
}
bool MAMEStateFlags100(const int role,const string &p[],const string &v[],
 const SMA_MEState100 &state,bool &flags[],string &reason)
{
 ArrayResize(flags,100);
 for(int i=0;i<100;i++)flags[i]=false;
 if(!MA2KValidateManageExit100(role,p,v,reason))return false;
 if(state.buyCount<0||state.sellCount<0){reason="INVALID_STATE";return false;}
 for(int i=0;i<100;i++)
 {
  string part=MA101CanonicalPart(p[i]);
  if(part==""||part=="EMPTY"||part=="AND"||part=="OR")continue;
  bool action=(role==2&&(part=="SINGLE_TRAILING"||part=="BASKET_TRAILING"||part=="OVERLAP"))||
              (role==3&&(part=="CLOSE_SIDE"||part=="CLOSE_OPPOSITE"));
  if(action)continue;
  if(part!="SIDE_COUNT"){reason="UNSUPPORTED_CONDITION_"+part;return false;}
  string side=MA101Param(v[i],"SIDE","");
  if(side!="BUY"&&side!="SELL"){reason="SIDE_CURRENT_UNSUPPORTED";return false;}
  string value=MA101Param(v[i],"VALUE","");
  if(value==""||StringToInteger(value)<0){reason="INVALID_COUNT";return false;}
  flags[i]=MAMEIntCmp(side=="BUY"?state.buyCount:state.sellCount,
                       MA101Param(v[i],"COND",""),(int)StringToInteger(value));
 }
 reason="SYNTHETIC_ONLY";return true;
}
#endif
