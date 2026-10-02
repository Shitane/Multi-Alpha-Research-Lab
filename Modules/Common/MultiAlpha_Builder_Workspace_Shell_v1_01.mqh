//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Workspace_Shell_v1_01.mqh                    |
//| EA LOGIC / EA PARTS full right-workspace shell. No runtime connection.       |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_WORKSPACE_SHELL_V1_01_MQH
#define MULTIALPHA_BUILDER_WORKSPACE_SHELL_V1_01_MQH
class CMultiAlphaBuilderWorkspaceShell101
{
 string p;
 void V(string n,bool on){if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Box(string id,int y,string title,string line1,string line2){string b=p+id+"_BG";if(ObjectFind(0,b)<0)ObjectCreate(0,b,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,b,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,b,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,b,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,b,OBJPROP_XSIZE,660);ObjectSetInteger(0,b,OBJPROP_YSIZE,246);ObjectSetInteger(0,b,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,b,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,b,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,b,OBJPROP_ZORDER,20);Lab(id+"_TITLE",656,y+12,title,10);Lab(id+"_L1",656,y+36,line1,9);Lab(id+"_L2",656,y+55,line2,8);}
 void Lab(string id,int x,int y,string s,int fs){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Group(string id,bool on){V(p+id+"_BG",on);V(p+id+"_TITLE",on);V(p+id+"_L1",on);V(p+id+"_L2",on);}
public:
 CMultiAlphaBuilderWorkspaceShell101(){p="MABUILD101_";}
 void Create(){Box("LOGIC",58,"EA LOGIC / O01 BUILDER","Definition: O01 Builder  |  Role: ENTRY / MANAGE / EXIT","Builder slots and AND/OR groups: implementation next");Box("PARTS",58,"EA PARTS / PART REGISTRY","Selected part: NONE","O01-required reusable parts will be added first");HideAll();}
 void ShowLogic(){Group("LOGIC",true);Group("PARTS",false);ChartRedraw();}
 void ShowParts(){Group("LOGIC",false);Group("PARTS",true);ChartRedraw();}
 void HideAll(){Group("LOGIC",false);Group("PARTS",false);ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
};
#endif
