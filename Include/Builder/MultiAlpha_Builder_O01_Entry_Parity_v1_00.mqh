//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Entry_Parity_v1_00.mqh                   |
//| LB-01: explicit O01 ENTRY reference-vs-Builder parity harness.   |
//| Decision only. NO ORDERS / VIRTUAL NOT FILL.                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_ENTRY_PARITY_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_ENTRY_PARITY_V1_00_MQH

#include "MultiAlpha_Builder_O01_Entry_Evaluator_v1_00.mqh"

#define MA_BUILDER_O01_ENTRY_PARITY_VERSION "1.00"

struct SMA_O01EntryParityCase100
{
 string name;
 SO01EntryConfig cfg;
 SO01EntryContext ctx;
 ENUM_O01_ENTRY_SIGNAL expected;
};

class CMultiAlphaBuilderO01EntryParity100
{
private:
 CMultiAlphaBuilderO01EntryEvaluator100 m_builder;

 void Base(SMA_O01EntryParityCase100 &t) const
 {
  t.cfg.new_cycles=true;
  t.cfg.trade_buy=true;
  t.cfg.trade_sell=true;
  t.cfg.rsi_lower=30.0;
  t.cfg.rsi_upper=70.0;
  t.ctx.emergency_lock=false;
  t.ctx.time_allowed=true;
  t.ctx.news_blocked=false;
  t.ctx.spread_ok=true;
  t.ctx.filters_ok=true;
  t.ctx.buy_count=0;
  t.ctx.sell_count=0;
  t.ctx.rsi=50.0;
  t.expected=O01_ENTRY_NONE;
 }

 void MakeCase(const int i,SMA_O01EntryParityCase100 &t) const
 {
  Base(t);
  if(i==0){t.name="BUY_LT_LOWER";t.ctx.rsi=29.9;t.expected=O01_ENTRY_BUY;}
  else if(i==1){t.name="BUY_EQ_LOWER";t.ctx.rsi=30.0;t.expected=O01_ENTRY_NONE;}
  else if(i==2){t.name="SELL_GT_UPPER";t.ctx.rsi=70.1;t.expected=O01_ENTRY_SELL;}
  else if(i==3){t.name="SELL_EQ_UPPER";t.ctx.rsi=70.0;t.expected=O01_ENTRY_NONE;}
  else if(i==4){t.name="BUY_SIDE_OPEN";t.ctx.rsi=20.0;t.ctx.buy_count=1;t.expected=O01_ENTRY_NONE;}
  else if(i==5){t.name="SELL_SIDE_OPEN";t.ctx.rsi=80.0;t.ctx.sell_count=1;t.expected=O01_ENTRY_NONE;}
  else if(i==6){t.name="NEW_CYCLES_OFF";t.ctx.rsi=20.0;t.cfg.new_cycles=false;t.expected=O01_ENTRY_NONE;}
  else if(i==7){t.name="EMERGENCY_LOCK";t.ctx.rsi=20.0;t.ctx.emergency_lock=true;t.expected=O01_ENTRY_NONE;}
  else if(i==8){t.name="TIME_BLOCK";t.ctx.rsi=20.0;t.ctx.time_allowed=false;t.expected=O01_ENTRY_NONE;}
  else if(i==9){t.name="NEWS_BLOCK";t.ctx.rsi=20.0;t.ctx.news_blocked=true;t.expected=O01_ENTRY_NONE;}
  else if(i==10){t.name="SPREAD_BLOCK";t.ctx.rsi=20.0;t.ctx.spread_ok=false;t.expected=O01_ENTRY_NONE;}
  else if(i==11){t.name="FILTER_BLOCK";t.ctx.rsi=20.0;t.ctx.filters_ok=false;t.expected=O01_ENTRY_NONE;}
  else if(i==12){t.name="BUY_DISABLED";t.ctx.rsi=20.0;t.cfg.trade_buy=false;t.expected=O01_ENTRY_NONE;}
  else if(i==13){t.name="SELL_DISABLED";t.ctx.rsi=80.0;t.cfg.trade_sell=false;t.expected=O01_ENTRY_NONE;}
  else if(i==14){t.name="CUSTOM_LEVEL_BUY";t.cfg.rsi_lower=25.5;t.ctx.rsi=25.4;t.expected=O01_ENTRY_BUY;}
  else {t.name="CUSTOM_LEVEL_SELL";t.cfg.rsi_upper=82.5;t.ctx.rsi=82.6;t.expected=O01_ENTRY_SELL;}
 }

 string Sig(const ENUM_O01_ENTRY_SIGNAL s) const
 {
  if(s==O01_ENTRY_BUY)return "BUY";
  if(s==O01_ENTRY_SELL)return "SELL";
  return "NONE";
 }

public:
 int CaseCount() const { return 16; }

 bool RunAll(string &report) const
 {
  report="";
  int pass=0;
  for(int i=0;i<CaseCount();i++)
  {
   SMA_O01EntryParityCase100 t; MakeCase(i,t);
   ENUM_O01_ENTRY_SIGNAL ref_sig,bld_sig;
   bool same=m_builder.ParityCheck(t.cfg,t.ctx,ref_sig,bld_sig);
   bool ok=(same && ref_sig==t.expected && bld_sig==t.expected);
   if(ok)pass++;
   report+=IntegerToString(i+1)+" "+t.name+" REF="+Sig(ref_sig)+" BUILDER="+Sig(bld_sig)+" EXPECT="+Sig(t.expected)+" "+(ok?"PASS":"FAIL")+"\n";
  }
  report="O01 ENTRY PARITY "+IntegerToString(pass)+"/"+IntegerToString(CaseCount())+"\n"+report;
  return pass==CaseCount();
 }
};

#endif
