#ifndef MULTIALPHA_MODULE_LIBRARY_PANEL_V1_00_MQH
#define MULTIALPHA_MODULE_LIBRARY_PANEL_V1_00_MQH
#include "MultiAlpha_Module_Library_Store_v1_00.mqh"
// ModuleUI-1: functional selector only.
// Visual spacing/text-overlap cleanup is intentionally deferred to the panel-development polish gate.
class CMultiAlphaModuleLibraryPanel100{
 string p; CMultiAlphaModuleLibraryStore100 *st; int role,sel;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,int state=0){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,state?C'32,135,160':C'24,39,49');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,550);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
 string RN(){return role==0?"ENTRY":role==1?"GRID":role==2?"MANAGE":"EXIT";}
public:
 CMultiAlphaModuleLibraryPanel100(){p="MAMODUI100_";st=NULL;role=0;sel=0;}
 void Bind(CMultiAlphaModuleLibraryStore100 *s){st=s;}
 int Role()const{return role;} int Selected()const{return sel;} string RoleText(){return RN();}
 string Name(){return st==NULL?"":st.Name(role,sel);}
 string StateText(){if(st==NULL)return "NO STORE";ENUM_MA_MODULE_STATE100 x=st.State(role,sel);return x==MA_MODULE_EMPTY100?"EMPTY":x==MA_MODULE_SAVED_ENABLED100?"SAVED / ENABLED":"SAVED / DISABLED";}
 void Show(){Delete();Box();Lab("TITLE",656,70,"EA LOGIC / MODULE LIBRARY",10);Btn("E",656,94,90,"ENTRY",role==0);Btn("G",756,94,90,"GRID",role==1);Btn("M",856,94,90,"MANAGE",role==2);Btn("X",956,94,90,"EXIT",role==3);Lab("ROLE",1060,99,"Role: "+RN()+"   NO ORDERS");
  Lab("ML",656,145,RN()+" MODULE",9);Btn("PREV",656,175,70,"< PREV");Lab("NO",742,180,StringFormat("#%02d / 50",sel+1),9);Btn("NEXT",830,175,70,"NEXT >");
  Lab("STATE_L",656,220,"State");Lab("STATE",742,220,StateText(),9);Lab("EN_L",656,250,"Enabled");Btn("EN",742,244,120,(st!=NULL&&st.IsEnabled(role,sel))?"ON":"OFF",(st!=NULL&&st.IsEnabled(role,sel)));
  Lab("NAME_L",656,285,"Name");Lab("NAME",742,285,Name(),9);Btn("EDIT",656,325,160,"EDIT",(st!=NULL&&st.IsSaved(role,sel)));
  Lab("HELP",656,370,"Module Slots #01-#50. EDIT opens the selected saved module in Logic Builder.",8);
  Lab("NOTE",656,400,"UI spacing/text-overlap cleanup: deferred panel-development improvement.",8);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 int Event(int id,string s){if(id!=CHARTEVENT_OBJECT_CLICK||StringFind(s,p)!=0)return 0;
  if(s==p+"E"||s==p+"G"||s==p+"M"||s==p+"X"){role=s==p+"E"?0:s==p+"G"?1:s==p+"M"?2:3;sel=0;Show();return 1;}
  if(s==p+"PREV"){sel=(sel+49)%50;Show();return 2;} if(s==p+"NEXT"){sel=(sel+1)%50;Show();return 2;}
  if(s==p+"EN"){if(st!=NULL&&st.IsSaved(role,sel))st.SetEnabled(role,sel,!st.IsEnabled(role,sel));Show();return 3;}
  if(s==p+"EDIT"){if(st!=NULL&&st.IsSaved(role,sel))return 4;Show();return 5;} return 0;}
};
#endif
