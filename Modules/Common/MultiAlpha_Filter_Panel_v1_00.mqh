//+------------------------------------------------------------------+
//| MultiAlpha_Filter_Panel_v1_00.mqh                               |
//| Compact slot-local FILTER workspace. UI/config only.             |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_FILTER_PANEL_V1_00_MQH
#define MULTIALPHA_FILTER_PANEL_V1_00_MQH
#include "MultiAlpha_Common_Filter_v1_00.mqh"
class CMultiAlphaFilterPanel100
{
 string p;int slot;bool shown;
 void V(string id,bool on){string n=p+id;if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,bool on){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,on?C'45,91,108':C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,on?C'118,166,188':C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,65);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 string OnOff(bool v){return v?"ON":"OFF";}
 void Paint(const SMA_CommonFilterConfig100 &c,const SMA_FilterPermission100 &q){
  ObjectSetString(0,p+"TITLE",OBJPROP_TEXT,StringFormat("COMMON FILTER / SLOT #%02d",slot));
  Btn("TIME",458,150,112,"TIME ["+OnOff(c.trading_time)+"]",c.trading_time);Btn("NEWS",582,150,112,"NEWS ["+OnOff(c.news)+"]",c.news);
  Btn("FOMC",458,180,112,"FOMC ["+OnOff(c.fomc)+"]",c.fomc);Btn("NFP",582,180,112,"NFP ["+OnOff(c.nfp)+"]",c.nfp);
  Btn("CPI",458,210,112,"CPI ["+OnOff(c.cpi)+"]",c.cpi);Btn("MEND",582,210,112,"MONTH END ["+OnOff(c.month_end)+"]",c.month_end);
  Btn("MSTART",458,240,112,"MONTH START ["+OnOff(c.month_start)+"]",c.month_start);Btn("QEND",582,240,112,"QTR END ["+OnOff(c.quarter_end)+"]",c.quarter_end);
  ObjectSetString(0,p+"TIMEVAL",OBJPROP_TEXT,StringFormat("TIME %02d:%02d - %02d:%02d",c.start_hour,c.start_minute,c.end_hour,c.end_minute));
  ObjectSetString(0,p+"PERM",OBJPROP_TEXT,"NEW ENTRY: "+(q.new_entry?"ALLOW":"BLOCK "+q.new_reason)+"    ADD ENTRY: "+(q.add_entry?"ALLOW":"BLOCK "+q.add_reason));
 }
public:
 CMultiAlphaFilterPanel100(){p="MAFILTER100_";slot=1;shown=false;}
 void Create(){Lab("TITLE",458,104,"COMMON FILTER / SLOT #01",9);Lab("NOTE",458,126,"ALL PARTS DEFAULT OFF / EXIT + SAFETY UNAFFECTED",8);Lab("TIMEVAL",458,272,"TIME 10:00 - 14:00",8);Lab("PERM",458,300,"NEW ENTRY: ALLOW    ADD ENTRY: ALLOW",8);Hide();}
 void Show(const int s,const SMA_CommonFilterConfig100 &c,const SMA_FilterPermission100 &q){slot=s;shown=true;string ids[]={"TITLE","NOTE","TIMEVAL","PERM","TIME","NEWS","FOMC","NFP","CPI","MEND","MSTART","QEND"};for(int i=0;i<ArraySize(ids);i++)V(ids[i],true);Paint(c,q);ChartRedraw();}
 void Hide(){shown=false;string ids[]={"TITLE","NOTE","TIMEVAL","PERM","TIME","NEWS","FOMC","NFP","CPI","MEND","MSTART","QEND"};for(int i=0;i<ArraySize(ids);i++)V(ids[i],false);ChartRedraw();}
 int Event(const int id,const string name,SMA_CommonFilterConfig100 &c){if(!shown||id!=CHARTEVENT_OBJECT_CLICK)return 0;string x=name;if(x==p+"TIME")c.trading_time=!c.trading_time;else if(x==p+"NEWS")c.news=!c.news;else if(x==p+"FOMC")c.fomc=!c.fomc;else if(x==p+"NFP")c.nfp=!c.nfp;else if(x==p+"CPI")c.cpi=!c.cpi;else if(x==p+"MEND")c.month_end=!c.month_end;else if(x==p+"MSTART")c.month_start=!c.month_start;else if(x==p+"QEND")c.quarter_end=!c.quarter_end;else return 0;ObjectSetInteger(0,name,OBJPROP_STATE,false);return 1;}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
