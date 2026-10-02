//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Workspace_O01_v1_00.mqh                      |
//| LB-01 O01 ENTRY definition viewer. UI only / NO ORDERS.          |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_WORKSPACE_O01_V1_00_MQH
#define MULTIALPHA_BUILDER_WORKSPACE_O01_V1_00_MQH
#include "MultiAlpha_Builder_Definition_v1_00.mqh"
#include "MultiAlpha_Builder_O01_Entry_Evaluator_v1_00.mqh"

class CMultiAlphaBuilderWorkspaceO01100
{
 string p;
 void Lab(string id,int x,int y,string s,int fs=8)
 {
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);
 }
 void Box(string id,int x,int y,int w,int h)
 {
  string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);
  ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
  ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,h);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');
  ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);
 }
 string PartLine(const SMA_BuilderSlot100 &s){return (s.enabled?"[ON]  ":"[OFF] ")+s.part_id+"  v"+s.part_version;}
public:
 CMultiAlphaBuilderWorkspaceO01100(){p="MABO01100_";}
 void Show()
 {
  Delete();
  CMultiAlphaBuilderO01EntryEvaluator100 ev;SMA_BuilderDefinition100 d;ev.BuildDefinition(d);
  Box("BG",640,58,660,350);
  Lab("TITLE",656,70,"EA LOGIC / O01 BUILDER",10);
  Lab("DEF",656,92,"Definition: "+d.id+"  |  "+d.name+"  v"+d.version,8);
  Lab("ROLE",656,110,"Role: ENTRY   Schema: "+d.schema_version+"   Status: PARITY BRIDGE / NO ORDERS",8);
  int y=140;
  Lab("GA",656,y,"GROUP A / AND - Common Entry Gates",9);y+=22;
  for(int i=0;i<d.groups[0].slot_count;i++){Lab("A"+IntegerToString(i),672,y,PartLine(d.groups[0].slots[i]));y+=20;}
  y+=5;Lab("GB",656,y,"GROUP B / AND - Direction Eligibility",9);y+=22;
  for(int i=0;i<d.groups[1].slot_count;i++){Lab("B"+IntegerToString(i),672,y,PartLine(d.groups[1].slots[i]));y+=20;}
  y+=5;Lab("OUT",656,y,"OUTPUT: "+d.output_part_id,9);
  ChartRedraw();
 }
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
