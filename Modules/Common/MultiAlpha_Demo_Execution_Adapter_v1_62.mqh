//+------------------------------------------------------------------+
//| MultiAlpha_Demo_Execution_Adapter_v1_62.mqh                     |
//| Common broker boundary for future Multi Alpha DEMO execution.    |
//| v1.62 is SAFETY FOUNDATION ONLY: order methods remain unarmed.   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_DEMO_EXECUTION_ADAPTER_V1_62_MQH
#define MULTIALPHA_DEMO_EXECUTION_ADAPTER_V1_62_MQH

#include <Trade/Trade.mqh>

class CMultiAlphaDemoExecutionAdapter162
  {
private:
   CTrade m_trade;
   string m_symbol;
   long   m_magic;
   int    m_instance_id;
   bool   m_initialized;
   bool   m_transition_pending;

   bool OwnedSelectedPosition(const ulong ticket) const
     {
      if(ticket==0 || !PositionSelectByTicket(ticket)) return false;
      if(PositionGetString(POSITION_SYMBOL)!=m_symbol) return false;
      if(PositionGetInteger(POSITION_MAGIC)!=m_magic) return false;
      return true;
     }

public:
   CMultiAlphaDemoExecutionAdapter162()
     {
      m_symbol="";
      m_magic=0;
      m_instance_id=0;
      m_initialized=false;
      m_transition_pending=false;
     }

   bool Init(const int instance_id,const string symbol,const long magic,string &reason)
     {
      reason="";
      m_initialized=false;
      m_transition_pending=false;

      if(instance_id<=0){reason="instance id must be positive";return false;}
      if(symbol==""){reason="symbol is empty";return false;}
      if(magic<=0){reason="magic must be positive";return false;}
      if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
        {reason="DEMO account required";return false;}
      if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
        {reason="HEDGING account required";return false;}

      m_instance_id=instance_id;
      m_symbol=symbol;
      m_magic=magic;
      m_trade.SetExpertMagicNumber(m_magic);
      m_trade.SetTypeFillingBySymbol(m_symbol);
      m_trade.SetAsyncMode(false);
      m_initialized=true;

      Print("[MA_EXEC162_INIT] instance=",m_instance_id,
            " symbol=",m_symbol,
            " magic=",m_magic,
            " account=DEMO margin=HEDGING",
            " BROKER_ACTIONS_ARMED=0");
      return true;
     }

   bool Initialized() const{return m_initialized;}
   bool TransitionPending() const{return m_transition_pending;}
   string Symbol() const{return m_symbol;}
   long Magic() const{return m_magic;}

   int ManagedPositions() const
     {
      if(!m_initialized) return 0;
      int n=0;
      for(int i=PositionsTotal()-1;i>=0;i--)
        {
         ulong ticket=PositionGetTicket(i);
         if(OwnedSelectedPosition(ticket)) n++;
        }
      return n;
     }

   int ManagedPositionsSide(const ENUM_POSITION_TYPE side) const
     {
      if(!m_initialized) return 0;
      int n=0;
      for(int i=PositionsTotal()-1;i>=0;i--)
        {
         ulong ticket=PositionGetTicket(i);
         if(!OwnedSelectedPosition(ticket)) continue;
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
         n++;
        }
      return n;
     }

   double ManagedLotsSide(const ENUM_POSITION_TYPE side) const
     {
      if(!m_initialized) return 0.0;
      double lots=0.0;
      for(int i=PositionsTotal()-1;i>=0;i--)
        {
         ulong ticket=PositionGetTicket(i);
         if(!OwnedSelectedPosition(ticket)) continue;
         if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
         lots+=PositionGetDouble(POSITION_VOLUME);
        }
      return lots;
     }

   // Deliberately unarmed in v1.62. The next gate will add checked
   // Open/Close operations only after this ownership boundary compiles
   // and is verified on the remote DEMO/HEDGING account.
  };

#endif
