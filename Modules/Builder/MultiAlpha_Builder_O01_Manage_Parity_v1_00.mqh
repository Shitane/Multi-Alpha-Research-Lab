//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Manage_Parity_v1_00.mqh                  |
//| LB-01 O01 MANAGE reference-vs-Builder parity harness.            |
//| Decision only. NO ORDERS / VIRTUAL NOT FILL.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_MANAGE_PARITY_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_MANAGE_PARITY_V1_00_MQH

#include "MultiAlpha_Builder_O01_Manage_Evaluator_v1_00.mqh"

#define MA_BUILDER_O01_MANAGE_PARITY_VERSION "1.00"

struct SMA_O01ManageParityCase100
{
 string name;
 bool is_buy;
 SO01ManageConfig cfg;
 SO01ManageContext ctx;
 ENUM_O01_MANAGE_DECISION expected;
 double expected_lot;
};

class CMultiAlphaBuilderO01ManageParity100
{
private:
 CMultiAlphaBuilderO01ManageEvaluator100 m_builder;

 void Base(SMA_O01ManageParityCase100 &t) const
 {
  t.name=""; t.is_buy=true; t.expected=O01_MANAGE_NONE; t.expected_lot=0.0;
  t.cfg.allow_grid_outside_time=false;
  t.cfg.one_order_per_bar=true;
  t.cfg.pause_grid_while_trailing=true;
  t.cfg.max_orders=5;
  t.cfg.max_total_lots_per_side=1.0;
  t.cfg.max_lot=0.50;
  t.cfg.lot_multiplier=2.0;
  t.cfg.fixed_distance_points=100;
  t.cfg.dynamic_start_order=3;
  t.cfg.dynamic_start_points=150;
  t.cfg.distance_multiplier=1.5;
  t.ctx.time_allowed=true;
  t.ctx.news_grid_blocked=false;
  t.ctx.spread_ok=true;
  t.ctx.trailing_active=false;
  t.ctx.same_bar_as_last_order=false;
  t.ctx.position_count=1;
  t.ctx.current_total_lots=0.01;
  t.ctx.last_price=2000.00;
  t.ctx.last_lot=0.01;
  t.ctx.market_price=1998.90;
  t.ctx.point=0.01;
 }

 void MakeCase(const int i,SMA_O01ManageParityCase100 &t) const
 {
  Base(t);
  if(i==0){t.name="BUY_FIXED_DISTANCE";t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.02;}
  else if(i==1){t.name="BUY_DISTANCE_NOT_MET";t.ctx.market_price=1999.50;}
  else if(i==2){t.name="SELL_FIXED_DISTANCE";t.is_buy=false;t.ctx.market_price=2001.10;t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.02;}
  else if(i==3){t.name="NO_POSITION";t.ctx.position_count=0;}
  else if(i==4){t.name="MAX_ORDERS";t.ctx.position_count=5;}
  else if(i==5){t.name="TRAILING_PAUSE";t.ctx.trailing_active=true;}
  else if(i==6){t.name="TIME_BLOCK";t.ctx.time_allowed=false;}
  else if(i==7){t.name="TIME_OUTSIDE_ALLOWED";t.ctx.time_allowed=false;t.cfg.allow_grid_outside_time=true;t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.02;}
  else if(i==8){t.name="NEWS_BLOCK";t.ctx.news_grid_blocked=true;}
  else if(i==9){t.name="SPREAD_BLOCK";t.ctx.spread_ok=false;}
  else if(i==10){t.name="ONE_ORDER_PER_BAR";t.ctx.same_bar_as_last_order=true;}
  else if(i==11){t.name="POINT_INVALID";t.ctx.point=0.0;}
  else if(i==12){t.name="MAX_LOT_CAP";t.ctx.last_lot=0.40;t.cfg.max_lot=0.50;t.ctx.current_total_lots=0.10;t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.50;}
  else if(i==13){t.name="TOTAL_LOT_CAP";t.ctx.last_lot=0.10;t.ctx.current_total_lots=0.95;t.cfg.max_total_lots_per_side=1.0;}
  else if(i==14){t.name="DYNAMIC_DISTANCE";t.ctx.position_count=2;t.ctx.market_price=1998.40;t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.02;}
  else if(i==15){t.name="DYNAMIC_DISTANCE_NOT_MET";t.ctx.position_count=2;t.ctx.market_price=1998.60;}
  else if(i==16){t.name="DYNAMIC_MULTIPLIER";t.ctx.position_count=3;t.ctx.market_price=1997.70;t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.02;}
  else {t.name="SELL_DYNAMIC_MULTIPLIER";t.is_buy=false;t.ctx.position_count=3;t.ctx.market_price=2002.30;t.expected=O01_MANAGE_ADD_GRID;t.expected_lot=0.02;}
 }

 string Act(const ENUM_O01_MANAGE_DECISION a) const
 {
  return a==O01_MANAGE_ADD_GRID ? "ADD_GRID" : "NONE";
 }

public:
 int CaseCount() const { return 18; }

 bool RunAll(string &report) const
 {
  report=""; int pass=0;
  for(int i=0;i<CaseCount();i++)
  {
   SMA_O01ManageParityCase100 t; MakeCase(i,t);
   SO01ManageDecision ref_d,bld_d;
   bool same=m_builder.ParityCheck(t.is_buy,t.cfg,t.ctx,ref_d,bld_d);
   bool ok=(same && ref_d.action==t.expected && bld_d.action==t.expected);
   if(t.expected==O01_MANAGE_ADD_GRID)
      ok=(ok && MathAbs(ref_d.requested_lot-t.expected_lot)<1e-9 &&
               MathAbs(bld_d.requested_lot-t.expected_lot)<1e-9);
   if(ok)pass++;
   report+=IntegerToString(i+1)+" "+t.name+
           " REF="+Act(ref_d.action)+" BUILDER="+Act(bld_d.action)+
           " LOT_REF="+DoubleToString(ref_d.requested_lot,2)+
           " LOT_BUILDER="+DoubleToString(bld_d.requested_lot,2)+
           " "+(ok?"PASS":"FAIL")+"\n";
  }
  report="O01 MANAGE PARITY "+IntegerToString(pass)+"/"+IntegerToString(CaseCount())+"\n"+report;
  return pass==CaseCount();
 }
};

#endif