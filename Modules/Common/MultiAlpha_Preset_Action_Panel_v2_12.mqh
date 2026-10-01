//+------------------------------------------------------------------+
//| MultiAlpha_Preset_Action_Panel_v2_12.mqh                        |
//| Self-explanatory preset/save/load action area. UI/config only.   |
//| NO broker operations.                                            |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_PRESET_ACTION_PANEL_V2_12_MQH
#define MULTIALPHA_PRESET_ACTION_PANEL_V2_12_MQH
class CMultiAlphaPresetActionPanel212
{
 string p; bool shown; int slot;
 void Vis(string id,bool on){string n=p+id;if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Lab(string id,int x,int y,string s,int fs=8,color c=clrWhite){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,c);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,71);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,75);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Ed(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'35,45,53');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_ZORDER,76);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 int Hit(int id,string name,string key,int code){if(id==CHARTEVENT_OBJECT_CLICK&&name==p+key){ObjectSetInteger(0,name,OBJPROP_STATE,false);return code;}return 0;}
public:
 CMultiAlphaPresetActionPanel212(){p="MAPRESET212_";shown=false;slot=1;}
 void Create(){
  Lab("TITLE",24,518,"SAVE / LOAD",9,C'118,190,220');
  Lab("NAME",24,542,"NAME"); Ed("EDIT",72,538,150,"");
  Lab("CUR",24,570,"CURRENT SLOT",8,C'118,190,220');
  Btn("DEFAULT",116,566,92,"LOAD DEFAULT"); Btn("SSAVE",214,566,82,"SAVE SLOT"); Btn("SLOAD",302,566,82,"LOAD SLOT");
  Lab("ALL",24,598,"ALL 50 SLOTS",8,C'118,190,220');
  Btn("ASAVE",116,594,92,"SAVE ALL"); Btn("ALOAD",214,594,92,"LOAD ALL");
  Lab("FILTER",24,626,"FILTER ONLY",8,C'118,190,220');
  Btn("FSAVE",116,622,92,"SAVE FILTER"); Btn("FLOAD",214,622,92,"LOAD FILTER");
  Lab("STATUS",24,650,"READY",8,C'170,190,200'); Hide();
 }
 void Show(int s){slot=s;shown=true;ObjectSetString(0,p+"CUR",OBJPROP_TEXT,StringFormat("CURRENT #%02d",slot));string a[]={"TITLE","NAME","EDIT","CUR","DEFAULT","SSAVE","SLOAD","ALL","ASAVE","ALOAD","FILTER","FSAVE","FLOAD","STATUS"};for(int i=0;i<ArraySize(a);i++)Vis(a[i],true);ChartRedraw();}
 void Hide(){shown=false;string a[]={"TITLE","NAME","EDIT","CUR","DEFAULT","SSAVE","SLOAD","ALL","ASAVE","ALOAD","FILTER","FSAVE","FLOAD","STATUS"};for(int i=0;i<ArraySize(a);i++)Vis(a[i],false);ChartRedraw();}
 string Name(){return ObjectGetString(0,p+"EDIT",OBJPROP_TEXT);}
 void Status(string msg,bool ok=true)
 {
  string n=p+"STATUS";
  color status_color=C'170,210,185';
  if(!ok) status_color=C'235,150,145';
  ObjectSetString(0,n,OBJPROP_TEXT,msg);
  ObjectSetInteger(0,n,OBJPROP_COLOR,status_color);
  ChartRedraw();
 }
 int Event(int id,string name){if(!shown)return 0;int r=0;if((r=Hit(id,name,"DEFAULT",1))!=0)return r;if((r=Hit(id,name,"SSAVE",2))!=0)return r;if((r=Hit(id,name,"SLOAD",3))!=0)return r;if((r=Hit(id,name,"ASAVE",4))!=0)return r;if((r=Hit(id,name,"ALOAD",5))!=0)return r;if((r=Hit(id,name,"FSAVE",6))!=0)return r;if((r=Hit(id,name,"FLOAD",7))!=0)return r;return 0;}
 void Delete()
 {
  string a[]={"TITLE","NAME","EDIT","CUR","DEFAULT","SSAVE","SLOAD","ALL","ASAVE","ALOAD","FILTER","FSAVE","FLOAD","STATUS"};
  for(int i=0;i<ArraySize(a);i++)
  {
   string n=p+a[i];
   if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
  }
 }
};
#endif
