#ifndef MULTIALPHA_SAVED_ME_METRICS_GATE_V1_00_MQH
#define MULTIALPHA_SAVED_ME_METRICS_GATE_V1_00_MQH
#include "MultiAlpha_Position_Metrics100_v1_00.mqh"
#include "MultiAlpha_Saved_Manage_Exit_Intent100_v1_00.mqh"
// A14-8: owned live position metrics -> saved MANAGE/EXIT SIDE_COUNT -> intent.
// Read-only. Other metric predicates are deliberately NOT interpreted until
// their parameter grammar and O01 parity are independently verified.
bool MASavedMEMetricsIntent100(const CMultiAlphaModuleLibraryStore101 &store,
 const int role,const int slotIndex,const string symbol,const long magic,
 bool &fire,string &action,string &reason)
{
 fire=false;action="";
 if(role!=2&&role!=3){reason="ROLE_NOT_MANAGE_EXIT";return false;}
 if(slotIndex<0||slotIndex>=MA_CAP_LOGIC_SLOTS_PER_ROLE){reason="SLOT_OUT_OF_RANGE";return false;}
 if(!store.IsSaved(role,slotIndex)){reason="SLOT_UNSAVED";return false;}
 if(!store.IsEnabled(role,slotIndex)){reason="SLOT_DISABLED";return false;}
 string name="",p[],v[];bool enabled=false;
 if(!store.LoadDefinition(role,slotIndex,name,p,v,enabled)||!enabled)
 {reason="LOAD_FAILED";return false;}
 string why="";
 if(!MA2KValidateManageExit100(role,p,v,why)){reason="GRAMMAR_"+why;return false;}
 SMA_PositionMetrics100 m;
 if(!MAReadPositionMetrics100(symbol,magic,m,why)){reason="METRICS_"+why;return false;}
 bool flags[];ArrayResize(flags,MA_CAP_PARTS_PER_LOGIC);
 for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)flags[i]=false;
 for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
 {
  string part=MA101CanonicalPart(p[i]);
  if(part==""||part=="EMPTY"||part=="AND"||part=="OR")continue;
  bool actionPart=(role==2&&(part=="SINGLE_TRAILING"||part=="BASKET_TRAILING"||part=="OVERLAP"))||
                  (role==3&&(part=="CLOSE_SIDE"||part=="CLOSE_OPPOSITE"));
  if(actionPart)continue;
  if(part!="SIDE_COUNT"){reason="UNSUPPORTED_METRIC_CONDITION_"+part;return false;}
  string side=MA101Param(v[i],"SIDE","");
  if(side!="BUY"&&side!="SELL"){reason="SIDE_CURRENT_UNSUPPORTED";return false;}
  string op=MA101Param(v[i],"COND","");
  if(op!="EQ"&&op!="GT"&&op!="GE"&&op!="LT"&&op!="LE")
  {reason="INVALID_COUNT_OPERATOR";return false;}
  string value=MA101Param(v[i],"VALUE","");
  if(value==""||StringToInteger(value)<0){reason="INVALID_COUNT_VALUE";return false;}
  int actual=side=="BUY"?m.buyCount:m.sellCount;
  int target=(int)StringToInteger(value);
  flags[i]=(op=="EQ"&&actual==target)||(op=="GT"&&actual>target)||
           (op=="GE"&&actual>=target)||(op=="LT"&&actual<target)||
           (op=="LE"&&actual<=target);
 }
 if(!MASavedManageExitIntent100(store,role,slotIndex,flags,fire,action,why))
 {fire=false;action="";reason="INTENT_"+why;return false;}
 reason="READ_ONLY_METRICS_INTENT_SIDE_COUNT_ONLY";return true;
}
#endif
