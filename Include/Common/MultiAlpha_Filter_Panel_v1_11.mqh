//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Panel_v1_11.mqh                               |
//| Left-panel FILTER workspace. Slot-local parts + parameters.       |
//| UI/config only. NO broker operations.                            |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_FILTER_PANEL_V1_11_MQH
#define MULTIALPHA_FILTER_PANEL_V1_11_MQH
#include "MultiAlpha_Common_Filter_v1_10.mqh"
class CMultiAlphaFilterPanel111
{
 string p;int slot;bool shown;
 void Vis(string id,bool on){string n=p+id;if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,61);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,bool on){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,on?C'45,91,108':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,on?C'118,166,188':C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,65);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Ed(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'35,45,53');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_ZORDER,66);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 string OO(bool v){return v?"ON":"OFF";} string I(int v){return IntegerToString(v);}
 void Paint(const SMA_CommonFilterConfig110 &c){
  ObjectSetString(0,p+"TITLE",OBJPROP_TEXT,StringFormat("FILTER PARTS / SLOT #%02d",slot));
  Btn("TIME",24,150,110,"TIME ["+OO(c.trading_time)+"]",c.trading_time);Lab("T1",146,153,"START");Ed("SH",188,149,38,I(c.start_hour));Ed("SM",230,149,38,I(c.start_minute));Lab("T2",280,153,"END");Ed("EH",318,149,38,I(c.end_hour));Ed("EM",352,149,38,I(c.end_minute));
  Btn("FOMC",24,178,110,"FOMC ["+OO(c.fomc)+"]",c.fomc);Lab("FB",146,181,"BEFORE H");Ed("FBV",210,177,48,I(c.fomc_before_hours));Lab("FA",280,181,"AFTER H");Ed("FAV",346,177,48,I(c.fomc_after_hours));
  Btn("NEWS",24,206,110,"NEWS ["+OO(c.news)+"]",c.news);Lab("NB",146,209,"BEFORE M");Ed("NBV",210,205,48,I(c.news_before_min));Lab("NA",280,209,"AFTER M");Ed("NAV",346,205,48,I(c.news_after_min));
  Btn("NFP",24,234,110,"NFP ["+OO(c.nfp)+"]",c.nfp);Lab("NFB",146,237,"BEFORE M");Ed("NFBV",210,233,48,I(c.nfp_before_min));Lab("NFA",280,237,"AFTER M");Ed("NFAV",346,233,48,I(c.nfp_after_min));
  Btn("CPI",24,262,110,"CPI ["+OO(c.cpi)+"]",c.cpi);Lab("CB",146,265,"BEFORE M");Ed("CBV",210,261,48,I(c.cpi_before_min));Lab("CA",280,265,"AFTER M");Ed("CAV",346,261,48,I(c.cpi_after_min));
  Btn("MEND",24,290,110,"MONTH END ["+OO(c.month_end)+"]",c.month_end);Lab("MED",146,293,"TRADING DAYS");Ed("MEDV",240,289,48,I(c.month_end_trading_days));
  Btn("MSTART",24,318,110,"MONTH START ["+OO(c.month_start)+"]",c.month_start);Lab("MSD",146,321,"TRADING DAYS");Ed("MSDV",240,317,48,I(c.month_start_trading_days));
  Btn("QEND",24,346,110,"QTR END ["+OO(c.quarter_end)+"]",c.quarter_end);Lab("QED",146,349,"TRADING DAYS");Ed("QEDV",240,345,48,I(c.quarter_end_trading_days));
  Btn("YEND",24,374,110,"YEAR END ["+OO(c.year_end)+"]",c.year_end);Lab("YED",146,377,"TRADING DAYS");Ed("YEDV",240,373,48,I(c.year_end_trading_days));
  Btn("ROLL",24,402,110,"ROLLOVER ["+OO(c.rollover)+"]",c.rollover);Lab("RB",146,405,"BEFORE M");Ed("RBV",210,401,48,I(c.rollover_before_min));Lab("RA",280,405,"AFTER M");Ed("RAV",346,401,48,I(c.rollover_after_min));
  Btn("FRI",24,430,110,"FRIDAY ["+OO(c.friday)+"]",c.friday);Lab("FS",146,433,"STOP");Ed("FSH",188,429,38,I(c.friday_stop_hour));Ed("FSM",230,429,38,I(c.friday_stop_minute));
  Btn("SPREAD",24,458,110,"SPREAD ["+OO(c.spread)+"]",c.spread);Lab("SP",146,461,"MAX POINTS");Ed("SPV",240,457,60,DoubleToString(c.max_spread_points,1));
  Btn("VOL",24,486,110,"VOLATILITY ["+OO(c.volatility)+"]",c.volatility);Lab("VMN",146,489,"ATR MIN");Ed("VMNV",200,485,55,DoubleToString(c.min_atr_points,1));Lab("VMX",270,489,"MAX");Ed("VMXV",318,485,55,DoubleToString(c.max_atr_points,1));
 }
 int GI(string id){return (int)StringToInteger(ObjectGetString(0,p+id,OBJPROP_TEXT));} double GD(string id){return StringToDouble(ObjectGetString(0,p+id,OBJPROP_TEXT));}
public:
 CMultiAlphaFilterPanel111(){p="MAFILTER111_";slot=1;shown=false;}
 void Create(){Lab("TITLE",24,105,"FILTER / SLOT #01",9);Lab("NOTE",24,126,"SLOT-LOCAL / ALL PARTS DEFAULT OFF / EXIT + SAFETY UNAFFECTED",8);Hide();}
 void Show(int s,const SMA_CommonFilterConfig110 &c){slot=s;shown=true;string ids[]={"TITLE","NOTE","TIME","T1","SH","SM","T2","EH","EM","FOMC","FB","FBV","FA","FAV","NEWS","NB","NBV","NA","NAV","NFP","NFB","NFBV","NFA","NFAV","CPI","CB","CBV","CA","CAV","MEND","MED","MEDV","MSTART","MSD","MSDV","QEND","QED","QEDV","YEND","YED","YEDV","ROLL","RB","RBV","RA","RAV","FRI","FS","FSH","FSM","SPREAD","SP","SPV","VOL","VMN","VMNV","VMX","VMXV"};for(int i=0;i<ArraySize(ids);i++)Vis(ids[i],true);Paint(c);ChartRedraw();}
 void Hide(){shown=false;ObjectsDeleteAll(0,p);ChartRedraw();}
 int Event(const int id,const string name,SMA_CommonFilterConfig110 &c){
  if(!shown)return 0;if(id==CHARTEVENT_OBJECT_CLICK){string x=name;
   if(x==p+"TIME")c.trading_time=!c.trading_time;else if(x==p+"FOMC")c.fomc=!c.fomc;else if(x==p+"NEWS")c.news=!c.news;else if(x==p+"NFP")c.nfp=!c.nfp;else if(x==p+"CPI")c.cpi=!c.cpi;else if(x==p+"MEND")c.month_end=!c.month_end;else if(x==p+"MSTART")c.month_start=!c.month_start;else if(x==p+"QEND")c.quarter_end=!c.quarter_end;else if(x==p+"YEND")c.year_end=!c.year_end;else if(x==p+"ROLL")c.rollover=!c.rollover;else if(x==p+"FRI")c.friday=!c.friday;else if(x==p+"SPREAD")c.spread=!c.spread;else if(x==p+"VOL")c.volatility=!c.volatility;else return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);return 1;}
  if(id==CHARTEVENT_OBJECT_ENDEDIT){c.start_hour=GI("SH");c.start_minute=GI("SM");c.end_hour=GI("EH");c.end_minute=GI("EM");c.fomc_before_hours=GI("FBV");c.fomc_after_hours=GI("FAV");c.news_before_min=GI("NBV");c.news_after_min=GI("NAV");c.nfp_before_min=GI("NFBV");c.nfp_after_min=GI("NFAV");c.cpi_before_min=GI("CBV");c.cpi_after_min=GI("CAV");c.month_end_trading_days=GI("MEDV");c.month_start_trading_days=GI("MSDV");c.quarter_end_trading_days=GI("QEDV");c.year_end_trading_days=GI("YEDV");c.rollover_before_min=GI("RBV");c.rollover_after_min=GI("RAV");c.friday_stop_hour=GI("FSH");c.friday_stop_minute=GI("FSM");c.max_spread_points=GD("SPV");c.min_atr_points=GD("VMNV");c.max_atr_points=GD("VMXV");return 1;}return 0;
 }
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
