//+------------------------------------------------------------------+
//| MultiAlpha_Slot_State_v1_95.mqh                                 |
//| 50 independent slot configuration records. NO broker operations. |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_SLOT_STATE_V1_95_MQH
#define MULTIALPHA_SLOT_STATE_V1_95_MQH
#define MA_SLOT_COUNT_V195 50
struct SMA_SlotState195
{
 int slot_id;
 bool enabled;
 string symbol;
 string state_text;
 SMA_ModuleSelection150 route; // slot-local LOGIC / ROUTE draft
};
class CMultiAlphaSlotState195
{
 SMA_SlotState195 s[MA_SLOT_COUNT_V195];
 int selected;
public:
 CMultiAlphaSlotState195(){selected=1;}
 void Init(const string symbol,const SMA_ModuleSelection150 &initial_route)
 {
  for(int i=0;i<MA_SLOT_COUNT_V195;i++)
  {
   s[i].slot_id=i+1;
   s[i].enabled=(i==0);
   s[i].symbol=symbol;
   s[i].state_text=(i==0?"READY":"DISABLED");
   s[i].route=initial_route;
  }
  selected=1;
 }
 int Selected()const{return selected;}
 bool Select(const int id){if(id<1||id>MA_SLOT_COUNT_V195)return false;selected=id;return true;}
 bool ToggleSelected(){int i=selected-1;s[i].enabled=!s[i].enabled;s[i].state_text=s[i].enabled?"READY":"DISABLED";return s[i].enabled;}
 SMA_SlotState195 Get(const int id)const{int i=MathMax(1,MathMin(MA_SLOT_COUNT_V195,id))-1;return s[i];}
 SMA_SlotState195 Current()const{return Get(selected);}
 void SetRoute(const int id,const SMA_ModuleSelection150 &r){if(id>=1&&id<=MA_SLOT_COUNT_V195)s[id-1].route=r;}
 void SetCurrentRoute(const SMA_ModuleSelection150 &r){SetRoute(selected,r);}
 SMA_ModuleSelection150 CurrentRoute()const{return s[selected-1].route;}
};
#endif
