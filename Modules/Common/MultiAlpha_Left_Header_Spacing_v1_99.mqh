//+------------------------------------------------------------------+
//| MultiAlpha_Left_Header_Spacing_v1_99.mqh                        |
//| Adds breathing room below the SLOT-local header context.         |
//| UI only. NO broker operations.                                   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_LEFT_HEADER_SPACING_V1_99_MQH
#define MULTIALPHA_LEFT_HEADER_SPACING_V1_99_MQH
class CMultiAlphaLeftHeaderSpacing199
{
 string p; bool shifted;
 void Move(const string id,const int dy)
 {
  string n=p+id;if(ObjectFind(0,n)<0)return;
  ObjectSetInteger(0,n,OBJPROP_YDISTANCE,(int)ObjectGetInteger(0,n,OBJPROP_YDISTANCE)+dy);
 }
 void Pair(const string id,const int dy){Move("L_"+id,dy);Move(id,dy);}
public:
 CMultiAlphaLeftHeaderSpacing199(){p="O01CFG160_";shifted=false;}
 void Apply()
 {
  // Shift only the first strategy block. The following MANAGE section
  // stays fixed, so overall panel height and lower controls do not move.
  if(!shifted)
  {
   const int dy=10;
   Move("L_H_ENTRY",dy);
   string f[]={"NEW","BUY","SELL","RSIP","RSIL","RSIU","ATR1P","ATR2P","ATR2TF"};
   for(int i=0;i<ArraySize(f);i++)Pair(f[i],dy);
   shifted=true;
  }
  // A10 mode buttons can be created later when Draft route changes.
  // Pin them to the matching shifted first block rather than accumulating offsets.
  string b1=p+"A10_FULL_MODE_NEXT",b2=p+"A10_MODE_NEXT";
  if(ObjectFind(0,b1)>=0)ObjectSetInteger(0,b1,OBJPROP_YDISTANCE,179);
  if(ObjectFind(0,b2)>=0)ObjectSetInteger(0,b2,OBJPROP_YDISTANCE,179);
  ChartRedraw();
 }
};
#endif
