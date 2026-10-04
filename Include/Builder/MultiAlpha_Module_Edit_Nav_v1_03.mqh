#ifndef MULTIALPHA_MODULE_EDIT_NAV_V1_03_MQH
#define MULTIALPHA_MODULE_EDIT_NAV_V1_03_MQH
// ModuleEdit-1c navigation.
// Functional edit flow is unchanged. This revision only corrects bottom navigation geometry.
// Fine spacing/text-overlap cleanup remains deferred to the panel-development polish gate.
// Buttons are anchored to the same right-panel coordinate system used by the Builder body.
// SAVE & BACK is kept well inside the panel right border with an explicit safety margin.
class CMultiAlphaModuleEditNav103{
 string p;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_ZORDER,55);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,int on=0){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,24);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,on?C'32,135,160':C'24,39,49');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,60);ObjectSetString(0,n,OBJPROP_TEXT,s);}
public:
 CMultiAlphaModuleEditNav103(){p="MAMODEDIT103_";}
 string RoleText(int r){return r==0?"ENTRY":r==1?"GRID":r==2?"MANAGE":"EXIT";}
 void Show(int r,int slot,string nm)
 {
  Delete();
  long cw=0;
  ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,cw);
  // Right workspace follows the chart's right side. Anchor navigation to the
  // current chart width instead of fixed X coordinates so resizing cannot
  // push SAVE & BACK outside the panel.
  int panel_right=(int)cw-76;
  int margin=12;
  int save_w=105;
  int cancel_w=90;
  int gap=10;
  int save_x=panel_right-margin-save_w;
  int cancel_x=save_x-gap-cancel_w;
  int ctx_x=1018;
  int ctx_max=cancel_x-ctx_x-12;
  Lab("CTX",ctx_x,545,"Editing: "+RoleText(r)+" MODULE #"+StringFormat("%02d",slot+1)+"  "+nm,8);
  Btn("CANCEL",cancel_x,575,cancel_w,"CANCEL");
  Btn("SAVE_BACK",save_x,575,save_w,"SAVE & BACK",1);
  ChartRedraw();
 }
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();}
 void Delete(){ObjectsDeleteAll(0,p);}
 int Event(int id,string s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(s==p+"SAVE_BACK")return 1;if(s==p+"CANCEL")return 2;return 0;}
};
#endif
