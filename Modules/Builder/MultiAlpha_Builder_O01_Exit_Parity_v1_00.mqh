//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Exit_Parity_v1_00.mqh                    |
//| LB-01 O01 EXIT reference-vs-Builder parity harness.              |
//| Decision/state only. NO ORDERS / VIRTUAL NOT FILL.               |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_EXIT_PARITY_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_EXIT_PARITY_V1_00_MQH

#include "MultiAlpha_Builder_O01_Exit_Evaluator_v1_00.mqh"

#define MA_BUILDER_O01_EXIT_PARITY_VERSION "1.00"

struct SMA_O01ExitParityCase100
{
 string name;
 bool is_buy;
 int count;
 double move_pts;
 SO01ExitConfig cfg;
 SO01TrailState state;
 ENUM_O01_EXIT_DECISION expected;
};

class CMultiAlphaBuilderO01ExitParity100
{
private:
 CMultiAlphaBuilderO01ExitEvaluator100 m_builder;

 void Base(SMA_O01ExitParityCase100 &t) const
 {
  t.name=""; t.is_buy=true; t.count=1; t.move_pts=0.0;
  t.cfg.trailing=true;
  t.cfg.tp_points=110;
  t.cfg.sl_points=1500;
  t.cfg.trail_start=110;
  t.cfg.trail_lock=60;
  t.cfg.trail_distance=50;
  t.cfg.trail_step=10;
  t.state.active=false;
  t.state.peak_pts=0.0;
  t.state.stop_pts=0.0;
  t.state.position_count=0;
  t.expected=O01_EXIT_NONE;
 }

 void Active(SMA_O01ExitParityCase100 &t,const int count,
             const double peak,const double stop) const
 {
  t.state.active=true;
  t.state.peak_pts=peak;
  t.state.stop_pts=stop;
  t.state.position_count=count;
 }

 void MakeCase(const int i,SMA_O01ExitParityCase100 &t) const
 {
  Base(t);
  if(i==0){t.name="NO_POSITION_RESET";t.count=0;Active(t,1,150,100);}
  else if(i==1){t.name="VIRTUAL_SL";t.move_pts=-1500;t.expected=O01_EXIT_VIRTUAL_SL;}
  else if(i==2){t.name="ABOVE_SL";t.move_pts=-1499;}
  else if(i==3){t.name="FIXED_TP";t.cfg.trailing=false;t.move_pts=110;t.expected=O01_EXIT_FIXED_TP;}
  else if(i==4){t.name="FIXED_TP_NOT_MET";t.cfg.trailing=false;t.move_pts=109;}
  else if(i==5){t.name="TRAIL_START_NOT_MET";t.move_pts=109;}
  else if(i==6){t.name="TRAIL_ACTIVATE_SINGLE";t.move_pts=110;}
  else if(i==7){t.name="SINGLE_TRAIL_HIT";t.move_pts=60;Active(t,1,110,60);t.expected=O01_EXIT_SINGLE_TRAILING;}
  else if(i==8){t.name="BASKET_TRAIL_HIT";t.count=2;t.move_pts=60;Active(t,2,110,60);t.expected=O01_EXIT_BASKET_TRAILING;}
  else if(i==9){t.name="TRAIL_ACTIVATE_BASKET";t.count=2;t.move_pts=110;}
  else if(i==10){t.name="POSITION_COUNT_CHANGE_RESET";t.count=2;t.move_pts=100;Active(t,1,150,100);}
  else if(i==11){t.name="TRAIL_STEP_NOT_MET";t.move_pts=129;Active(t,1,120,70);}
  else if(i==12){t.name="TRAIL_STEP_MET";t.move_pts=130;Active(t,1,120,70);}
  else if(i==13){t.name="TRAIL_LOCK_DOMINATES";t.move_pts=110;t.cfg.trail_lock=80;t.cfg.trail_distance=50;}
  else if(i==14){t.name="TRAIL_DISTANCE_DOMINATES";t.move_pts=110;t.cfg.trail_lock=20;t.cfg.trail_distance=50;}
  else if(i==15){t.name="SL_PRECEDENCE_WHILE_TRAILING";t.move_pts=-1500;Active(t,1,150,100);t.expected=O01_EXIT_VIRTUAL_SL;}
  else if(i==16){t.name="FIXED_TP_DISABLED";t.cfg.trailing=false;t.cfg.tp_points=0;t.move_pts=500;}
  else if(i==17){t.name="TRAIL_START_DISABLED";t.cfg.trail_start=0;t.move_pts=500;}
  else if(i==18){t.name="SELL_SINGLE_TRAIL_HIT";t.is_buy=false;t.move_pts=60;Active(t,1,110,60);t.expected=O01_EXIT_SINGLE_TRAILING;}
  else {t.name="TRAIL_STEP_ZERO_IMMEDIATE";t.cfg.trail_step=0;t.move_pts=121;Active(t,1,120,70);}
 }

 string Act(const ENUM_O01_EXIT_DECISION a) const
 {
  if(a==O01_EXIT_VIRTUAL_SL) return "VIRTUAL_SL";
  if(a==O01_EXIT_FIXED_TP) return "FIXED_TP";
  if(a==O01_EXIT_SINGLE_TRAILING) return "SINGLE_TRAILING";
  if(a==O01_EXIT_BASKET_TRAILING) return "BASKET_TRAILING";
  return "NONE";
 }

public:
 int CaseCount() const { return 20; }

 bool RunAll(string &report) const
 {
  report=""; int pass=0;
  for(int i=0;i<CaseCount();i++)
  {
   SMA_O01ExitParityCase100 t; MakeCase(i,t);
   ENUM_O01_EXIT_DECISION ref_d,bld_d;
   SO01TrailState ref_s,bld_s;
   bool same=m_builder.ParityCheck(t.is_buy,t.count,t.move_pts,t.cfg,t.state,
                                   ref_d,bld_d,ref_s,bld_s);
   bool ok=(same && ref_d==t.expected && bld_d==t.expected);
   if(ok) pass++;

   report+=IntegerToString(i+1)+" "+t.name+
           " REF="+Act(ref_d)+" BUILDER="+Act(bld_d)+
           " ACTIVE_REF="+IntegerToString(ref_s.active?1:0)+
           " ACTIVE_BUILDER="+IntegerToString(bld_s.active?1:0)+
           " PEAK_REF="+DoubleToString(ref_s.peak_pts,0)+
           " PEAK_BUILDER="+DoubleToString(bld_s.peak_pts,0)+
           " STOP_REF="+DoubleToString(ref_s.stop_pts,0)+
           " STOP_BUILDER="+DoubleToString(bld_s.stop_pts,0)+
           " "+(ok?"PASS":"FAIL")+"\n";
  }
  report="O01 EXIT PARITY "+IntegerToString(pass)+"/"+
         IntegerToString(CaseCount())+"\n"+report;
  return pass==CaseCount();
 }
};

#endif
