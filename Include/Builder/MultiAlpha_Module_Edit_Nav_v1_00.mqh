#ifndef MULTIALPHA_MODULE_EDIT_NAV_V1_00_MQH
#define MULTIALPHA_MODULE_EDIT_NAV_V1_00_MQH
// ModuleEdit-1 navigation. Functional flow belongs to this gate.
// Fine spacing/text-overlap cleanup remains deferred to the panel-development polish gate.
// ModuleEdit-1a: keep navigation buttons inside the current EA LOGIC panel boundary.
class CMultiAlphaModuleEditNav100{
 string p;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_ZORDER,55);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,int on=0){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,24);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,on?C'32,135,160':C'24,39,49');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,60);ObjectSetString(0,n,OBJPROP_TEXT,s);}
public:
 CMultiAlphaModuleEditNav100(){p="MAMODEDIT100_";}
 string RoleText(int r){return r==0?"ENTRY":r==1?"GRID":r==2?"MANAGE":"EXIT";}
 void Show(int r,int slot,string nm){Delete();Lab("CTX",1018,545,"Editing: "+RoleText(r)+" MODULE #"+StringFormat("%02d",slot+1)+"  "+nm,8);Btn("CANCEL",1070,575,100,"CANCEL");Btn("SAVE_BACK",1180,575,130,"SAVE & BACK",1);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 int Event(int id,string s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(s==p+"SAVE_BACK")return 1;if(s==p+"CANCEL")return 2;return 0;}
};
#endif
