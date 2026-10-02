//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Readout_Panel_v1_03.mqh                       |
//| Visual VALID/INVALID + expression/evaluation readout.             |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_READOUT_PANEL_V1_03_MQH
#define MULTIALPHA_BUILDER_READOUT_PANEL_V1_03_MQH
class CMultiAlphaBuilderReadoutPanel103{
 string p;
 void Lab(string id,int x,int y,string s,int fs=8,color c=clrWhite){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,c);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,50);ObjectSetString(0,n,OBJPROP_TEXT,s);}
public:
 CMultiAlphaBuilderReadoutPanel103(){p="MAREAD103_";}
 void Show(const bool valid,const string reason,const string expr,const string trace=""){Delete();color c=valid?C'70,210,150':C'245,150,70';string mark=valid?"[OK] ":""; string status=mark+(valid?"VALID":"INVALID")+" : "+reason;
Lab("STATUS",656,500,status,9,c);
Lab("READLBL",656,532,"READ",8,clrWhite);
Lab("EXPR",656,552,expr,8,clrWhite);
if(trace!="")Lab("TRACE",656,572,"EVAL: "+trace,8,clrWhite);ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
};
#endif
