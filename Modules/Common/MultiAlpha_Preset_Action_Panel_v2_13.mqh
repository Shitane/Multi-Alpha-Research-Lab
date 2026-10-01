//+------------------------------------------------------------------+
//| MultiAlpha_Preset_Action_Panel_v2_13.mqh                        |
//| Self-explanatory preset/save/load action area. UI/config only.   |
//| NO broker operations.                                            |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_PRESET_ACTION_PANEL_V2_13_MQH
#define MULTIALPHA_PRESET_ACTION_PANEL_V2_13_MQH
class CMultiAlphaPresetActionPanel213
{
 bool m_ma213_visible; int m_ma213_current_slot;
 string Prefix(){return "MAPRESET213_";}
 void Vis(string id,bool on){string n=Prefix()+id;if(ObjectFind(0,n)>=0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,(long)(on?OBJ_ALL_PERIODS:0));}
 void Lab(string id,int x,int y,string s,int fs=8,color c=clrWhite){string n=Prefix()+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,c);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,71);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s){string n=Prefix()+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'42,52,61');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,75);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Ed(string id,int x,int y,int w,string s){string n=Prefix()+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,20);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'35,45,53');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'85,95,105');ObjectSetInteger(0,n,OBJPROP_ZORDER,76);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 int Hit(int id,string name,string key,int code){if(id==CHARTEVENT_OBJECT_CLICK&&name==Prefix()+key){ObjectSetInteger(0,name,OBJPROP_STATE,false);return code;}return 0;}
public:
 CMultiAlphaPresetActionPanel213(){m_ma213_visible=false;m_ma213_current_slot=1;}
 void Create(){
  Lab("TITLE",24,105,"PRESET / SAVE / LOAD",9,C'118,190,220');
  Lab("CUR",24,140,"CURRENT SLOT",8,C'118,190,220');
  Lab("SNAME",24,164,"NAME"); Ed("SEDIT",72,160,210,"");
  Btn("DEFAULT",292,160,92,"LOAD DEFAULT"); Btn("SSAVE",390,160,82,"SAVE SLOT"); Btn("SLOAD",478,160,82,"LOAD SLOT");
  Lab("ALL",24,205,"ALL 50 SLOTS",8,C'118,190,220');
  Lab("ANAME",24,229,"NAME"); Ed("AEDIT",72,225,210,"");
  Btn("ASAVE",292,225,92,"SAVE ALL"); Btn("ALOAD",390,225,92,"LOAD ALL");
  Lab("FILTER",24,270,"FILTER ONLY",8,C'118,190,220');
  Lab("FNAME",24,294,"NAME"); Ed("FEDIT",72,290,210,"");
  Btn("FSAVE",292,290,92,"SAVE FILTER"); Btn("FLOAD",390,290,92,"LOAD FILTER");
  Lab("STATUS",24,330,"READY",8,C'170,190,200'); Hide();
 }
 void Show(int s){m_ma213_current_slot=s;m_ma213_visible=true;ObjectSetString(0,Prefix()+"CUR",OBJPROP_TEXT,StringFormat("CURRENT #%02d",m_ma213_current_slot));string a[]={"TITLE","CUR","SNAME","SEDIT","DEFAULT","SSAVE","SLOAD","ALL","ANAME","AEDIT","ASAVE","ALOAD","FILTER","FNAME","FEDIT","FSAVE","FLOAD","STATUS"};for(int i=0;i<ArraySize(a);i++)Vis(a[i],true);ChartRedraw();}
 void Hide(){m_ma213_visible=false;string a[]={"TITLE","CUR","SNAME","SEDIT","DEFAULT","SSAVE","SLOAD","ALL","ANAME","AEDIT","ASAVE","ALOAD","FILTER","FNAME","FEDIT","FSAVE","FLOAD","STATUS"};for(int i=0;i<ArraySize(a);i++)Vis(a[i],false);ChartRedraw();}
 string SlotName(){return ObjectGetString(0,Prefix()+"SEDIT",OBJPROP_TEXT);} string AllName(){return ObjectGetString(0,Prefix()+"AEDIT",OBJPROP_TEXT);} string FilterName(){return ObjectGetString(0,Prefix()+"FEDIT",OBJPROP_TEXT);} string Name(){return SlotName();}
 void Status(string msg,bool ok=true)
 {
  string n=Prefix()+"STATUS";
  color status_color=C'170,210,185';
  if(!ok) status_color=C'235,150,145';
  ObjectSetString(0,n,OBJPROP_TEXT,msg);
  ObjectSetInteger(0,n,OBJPROP_COLOR,status_color);
  ChartRedraw();
 }
 int Event(int id,string name){if(!m_ma213_visible)return 0;int r=0;if((r=Hit(id,name,"DEFAULT",1))!=0)return r;if((r=Hit(id,name,"SSAVE",2))!=0)return r;if((r=Hit(id,name,"SLOAD",3))!=0)return r;if((r=Hit(id,name,"ASAVE",4))!=0)return r;if((r=Hit(id,name,"ALOAD",5))!=0)return r;if((r=Hit(id,name,"FSAVE",6))!=0)return r;if((r=Hit(id,name,"FLOAD",7))!=0)return r;return 0;}
 void Delete()
 {
  string a[]={"TITLE","CUR","SNAME","SEDIT","DEFAULT","SSAVE","SLOAD","ALL","ANAME","AEDIT","ASAVE","ALOAD","FILTER","FNAME","FEDIT","FSAVE","FLOAD","STATUS"};
  for(int i=0;i<ArraySize(a);i++)
  {
   string n=Prefix()+a[i];
   if(ObjectFind(0,n)>=0) ObjectDelete(0,n);
  }
 }
};
#endif
