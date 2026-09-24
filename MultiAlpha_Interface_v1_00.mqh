//+------------------------------------------------------------------+
//| MultiAlpha_Interface_v1_00.mqh                                  |
//| Common research interface for modular Alpha cores.               |
//| Decision/state transport only. NO ORDER OPERATIONS.              |
//+------------------------------------------------------------------+
#ifndef MULTI_ALPHA_INTERFACE_V1_00_MQH
#define MULTI_ALPHA_INTERFACE_V1_00_MQH

enum ENUM_MULTI_ALPHA_ID
  {
   ALPHA_NONE=0,
   ALPHA_A12=12,
   ALPHA_A15=15
  };

enum ENUM_ALPHA_ACTION
  {
   ALPHA_ACTION_NONE=0,
   ALPHA_ACTION_ENTRY=1,
   ALPHA_ACTION_EXIT=2
  };

// Read-only market input supplied by the host.
struct SMultiAlphaMarket
  {
   datetime time;
   long     time_msc;
   double   bid;
   double   ask;
  };

// Read-only position snapshot supplied by the host.
// The Alpha must not assume this is a broker fill unless the host says so.
struct SMultiAlphaPosition
  {
   bool     is_open;
   int      direction;     // +1 BUY, -1 SELL
   double   entry_price;
   datetime entry_time;
   double   volume;
  };

// Alpha output. The host owns lifecycle/execution.
struct SMultiAlphaDecision
  {
   ENUM_MULTI_ALPHA_ID alpha_id;
   ENUM_ALPHA_ACTION   action;
   int                 direction;
   string              reason;
   double              decision_price;
   datetime            time;
   long                time_msc;
  };

void MultiAlphaDecisionClear(SMultiAlphaDecision &d,
                             const ENUM_MULTI_ALPHA_ID alpha_id)
  {
   d.alpha_id=alpha_id;
   d.action=ALPHA_ACTION_NONE;
   d.direction=0;
   d.reason="";
   d.decision_price=0.0;
   d.time=0;
   d.time_msc=0;
  }

bool MultiAlphaMarketValid(const SMultiAlphaMarket &m)
  {
   return (m.time>0 && MathIsValidNumber(m.bid) && MathIsValidNumber(m.ask) &&
           m.bid>0.0 && m.ask>=m.bid);
  }

#endif // MULTI_ALPHA_INTERFACE_V1_00_MQH
