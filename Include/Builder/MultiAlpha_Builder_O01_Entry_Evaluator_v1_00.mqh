//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Entry_Evaluator_v1_00.mqh                |
//| LB-01 first executable Builder evaluator: O01 ENTRY decisions.   |
//| Decision only. NO ORDERS / VIRTUAL NOT FILL.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_ENTRY_EVALUATOR_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_ENTRY_EVALUATOR_V1_00_MQH

#include "MultiAlpha_Builder_Definition_v1_00.mqh"
#include "MultiAlpha_Builder_Part_Registry_v1_00.mqh"
#include "..\\O01\\O01_GSG_RSI30_Entry_Module_v1_00.mqh"

#define MA_BUILDER_O01_ENTRY_EVALUATOR_VERSION "1.00"
#define MA_BUILDER_NO_ORDERS 1
#define MA_BUILDER_VIRTUAL_NOT_FILL 1

class CMultiAlphaBuilderO01EntryEvaluator100
{
private:
 bool GateCommon(const SO01EntryConfig &c,const SO01EntryContext &x) const
 {
  return (c.new_cycles && !x.emergency_lock && x.time_allowed &&
          !x.news_blocked && x.spread_ok && x.filters_ok);
 }

public:
 // First parity bridge. This expresses the verified O01 Entry module as
 // Builder-compatible reusable conditions without changing its semantics.
 ENUM_O01_ENTRY_SIGNAL Evaluate(const SO01EntryConfig &c,const SO01EntryContext &x) const
 {
  if(!GateCommon(c,x)) return O01_ENTRY_NONE;

  if(c.trade_buy && x.buy_count==0 && x.rsi<c.rsi_lower)
     return O01_ENTRY_BUY;

  if(c.trade_sell && x.sell_count==0 && x.rsi>c.rsi_upper)
     return O01_ENTRY_SELL;

  return O01_ENTRY_NONE;
 }

 // Reference-vs-Builder decision comparison. No broker action is possible.
 bool ParityCheck(const SO01EntryConfig &c,const SO01EntryContext &x,
                  ENUM_O01_ENTRY_SIGNAL &reference_signal,
                  ENUM_O01_ENTRY_SIGNAL &builder_signal) const
 {
  CO01EntryModule reference;
  reference_signal=reference.Evaluate(c,x);
  builder_signal=Evaluate(c,x);
  return (reference_signal==builder_signal);
 }

 // Creates the first serializable Builder definition for the O01 ENTRY path.
 void BuildDefinition(SMA_BuilderDefinition100 &d) const
 {
  CMultiAlphaBuilderDefinition100 defs;
  defs.Clear(d);
  d.id="BUILDER_E01";
  d.name="O01 ENTRY Builder";
  d.version="1.00";
  d.role=MA_BUILDER_ENTRY100;
  d.group_count=2;

  // Group A = common gates.
  d.groups[0].enabled=true;
  d.groups[0].op=MA_BUILDER_AND100;
  d.groups[0].slot_count=6;
  string common[6]={"CYCLE_NEW","EMERGENCY_UNLOCKED","TIME_ALLOWED","NEWS_CLEAR","SPREAD_OK","FILTERS_OK"};
  for(int i=0;i<6;i++){d.groups[0].slots[i].enabled=true;d.groups[0].slots[i].part_id=common[i];d.groups[0].slots[i].part_version="1.00";}

  // Group B documents side eligibility + RSI threshold. Runtime evaluates
  // BUY and SELL symmetrically from the same verified O01 context/config.
  d.groups[1].enabled=true;
  d.groups[1].op=MA_BUILDER_AND100;
  d.groups[1].slot_count=2;
  d.groups[1].slots[0].enabled=true; d.groups[1].slots[0].part_id="SIDE_COUNT_ZERO"; d.groups[1].slots[0].part_version="1.00";
  d.groups[1].slots[1].enabled=true; d.groups[1].slots[1].part_id="RSI_THRESHOLD"; d.groups[1].slots[1].part_version="1.00";

  d.output_part_id="SIGNAL_BUY|SIGNAL_SELL";
  d.output_parameters="same verified O01 direction semantics";
 }
};

#endif
