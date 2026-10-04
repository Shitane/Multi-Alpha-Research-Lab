//+------------------------------------------------------------------+
//| MultiAlpha_Builder_FreeSlot_Panel_v1_24.mqh                     |
//| M4-1: 4-role x 24-slot Builder skeleton. UI only / NO ORDERS.   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_24_MQH
#define MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_24_MQH
#define MA_BUILDER_FREE_SLOT_PANEL_VERSION "1.18"
#define MA_BUILDER_ROLE_COUNT 4
#define MA_BUILDER_SLOTS_PER_ROLE 24
#define MA_BUILDER_VISIBLE_ROWS 8
#define MA_BUILDER_PAGE_COUNT 3

enum ENUM_MA_BUILDER_ROLE124 { MA_BUILDER_ENTRY122=0,MA_BUILDER_MANAGE122=1,MA_BUILDER_EXIT122=2 };

class CMultiAlphaBuilderFreeSlotPanel124{
 string p,slot[MA_BUILDER_ROLE_COUNT][MA_BUILDER_SLOTS_PER_ROLE],params[MA_BUILDER_ROLE_COUNT][MA_BUILDER_SLOTS_PER_ROLE];
 int selected[MA_BUILDER_ROLE_COUNT],page[MA_BUILDER_ROLE_COUNT],role;
 string name24[MA_BUILDER_ROLE_COUNT],name72;
 string next24_name[MA_BUILDER_ROLE_COUNT],next72_name;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,int state=0){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);color bg=(state==2?C'32,135,160':(state==1?C'30,82,98':C'24,39,49'));ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Edit(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'20,31,40');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'65,90,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,45);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,550);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
 string RoleName(){return role==0?"ENTRY":role==1?"GRID":role==2?"MANAGE":"EXIT";} string DefaultName(){return "BUILDER_"+(role==0?"E01":role==1?"M01":"X01");}
 void CaptureNames(){string n24=p+"NAME24",n72=p+"NAME72";if(ObjectFind(0,n24)>=0)name24[role]=ObjectGetString(0,n24,OBJPROP_TEXT);if(ObjectFind(0,n72)>=0)name72=ObjectGetString(0,n72,OBJPROP_TEXT);}
 string Name24(){string n=p+"NAME24";if(ObjectFind(0,n)>=0)return ObjectGetString(0,n,OBJPROP_TEXT);return name24[role];}
 string Name72(){string n=p+"NAME72";if(ObjectFind(0,n)>=0)return ObjectGetString(0,n,OBJPROP_TEXT);return name72;}
 string RolePrefix(const int rr){return "MultiAlpha_Builder_"+(rr==0?"ENTRY_":rr==1?"MANAGE_":"EXIT_");}
 string RoleFileName(const int rr,const string nm){return RolePrefix(rr)+nm+".csv";}
 string StripName(const string fn,const string pre){if(StringFind(fn,pre)!=0)return "";string nm=StringSubstr(fn,StringLen(pre));int n=StringLen(nm);if(n>4&&StringSubstr(nm,n-4)==".csv")nm=StringSubstr(nm,0,n-4);return nm;}
 string NextByMask(const string mask,const string pre,const string current){string fn,first="",next="";bool take=false;long h=FileFindFirst(mask,fn,FILE_COMMON);if(h==INVALID_HANDLE)return current;do{string nm=StripName(fn,pre);if(nm=="")continue;if(first=="")first=nm;if(take){next=nm;break;}if(nm==current)take=true;}while(FileFindNext(h,fn));FileFindClose(h);if(next!="")return next;if(first!="")return first;return current;}
 void Next24(){string cur=Name24(),pre=RolePrefix(role);string nx=NextByMask(pre+"*.csv",pre,cur);name24[role]=nx;ObjectSetString(0,p+"NAME24",OBJPROP_TEXT,nx);}
 void Next72(){string cur=Name72(),pre="MultiAlpha_Builder_ALL_";string nx=NextByMask(pre+"*.csv",pre,cur);name72=nx;ObjectSetString(0,p+"NAME72",OBJPROP_TEXT,nx);}
 int Row(string s){for(int r=0;r<MA_BUILDER_VISIBLE_ROWS;r++)if(s==p+"S"+IntegerToString(r)||s==p+"E"+IntegerToString(r))return r;return -1;}
 void ClearRole(const int rr){for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++){slot[rr][i]="EMPTY";params[rr][i]="";}selected[rr]=-1;page[rr]=0;}
 bool SaveRoleFile(const int rr,const string nm,string &reason){if(nm==""){reason="NAME REQUIRED";return false;}string fn=RoleFileName(rr,nm);int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="FILE OPEN";return false;}FileWrite(h,"MA_BUILDER_ROLE","1.18",rr,MA_BUILDER_SLOTS_PER_ROLE);for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++)FileWrite(h,i+1,slot[rr][i],params[rr][i]);FileClose(h);reason="SAVED 24: "+nm;return true;}
 bool LoadRoleFile(const int rr,const string nm,string &reason){if(nm==""){reason="NAME REQUIRED";return false;}string fn=RoleFileName(rr,nm);int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){string legacy="MultiAlpha_Builder_"+nm+".csv";h=FileOpen(legacy,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="NOT FOUND: "+nm;return false;}}string sig=FileReadString(h),ver=FileReadString(h);int fr=(int)FileReadNumber(h),n=(int)FileReadNumber(h);if(sig!="MA_BUILDER_ROLE"||fr!=rr||n!=MA_BUILDER_SLOTS_PER_ROLE){FileClose(h);reason="INVALID ROLE FILE";return false;}ClearRole(rr);for(int i=0;i<n&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string pt=FileReadString(h),pa=FileReadString(h);if(no>=1&&no<=24){slot[rr][no-1]=pt;params[rr][no-1]=pa;}}FileClose(h);reason="LOADED 24: "+nm;return true;}
public:
 CMultiAlphaBuilderFreeSlotPanel124(){p="MAFREESLOT124_";role=0;for(int r=0;r<4;r++){ClearRole(r);name24[r]=(r==0?"BUILDER_E01":r==1?"BUILDER_G01":r==2?"BUILDER_M01":"BUILDER_X01");next24_name[r]="";}name72="BUILDER_ALL_01";next72_name="";}
 int Role(){return role;} string RoleText(){return RoleName();} int Selected(){return selected[role];} int SlotCount(){return 24;}
 string SelectedPart(){int i=selected[role];return i>=0&&i<24?slot[role][i]:"NONE";} string SelectedParams(){int i=selected[role];return i>=0&&i<24?params[role][i]:"";}
 void Export(string &a[],string &v[]){ArrayResize(a,24);ArrayResize(v,24);for(int i=0;i<24;i++){a[i]=slot[role][i];v[i]=params[role][i];}}
 void ImportRole(const int rr,const string nm,string &a[],string &v[]){if(rr<0||rr>=4||ArraySize(a)<24||ArraySize(v)<24)return;ClearRole(rr);name24[rr]=nm;for(int i=0;i<24;i++){slot[rr][i]=a[i];params[rr][i]=v[i];}}
 void SetRole(const int rr){if(rr>=0&&rr<4){CaptureNames();role=rr;page[role]=0;}}
 void ExportRole(const int rr,string &a[],string &v[]){ArrayResize(a,24);ArrayResize(v,24);if(rr<0||rr>=4){for(int i=0;i<24;i++){a[i]="EMPTY";v[i]="";}return;}for(int i=0;i<24;i++){a[i]=slot[rr][i];v[i]=params[rr][i];}}
 string DefinitionName(const int rr){if(rr<0||rr>=4)return "";return name24[rr];}
 string PartAt(const int rr,const int ii){if(rr<0||rr>=4||ii<0||ii>=24)return "EMPTY";return slot[rr][ii];}
 string ParamsAt(const int rr,const int ii){if(rr<0||rr>=4||ii<0||ii>=24)return "";return params[rr][ii];}
 void BeginRoleImport(const int rr,const string nm){if(rr<0||rr>=4)return;ClearRole(rr);name24[rr]=nm;}
 void SetRoleItem(const int rr,const int ii,const string pt,const string pa){if(rr<0||rr>=4||ii<0||ii>=24)return;slot[rr][ii]=pt;params[rr][ii]=pa;}
 bool PutSelected(string part,string par){int i=selected[role];if(i<0||i>=24)return false;slot[role][i]=part;params[role][i]=par;return true;}
 bool DeleteSelected(){int i=selected[role];if(i<0||i>=24)return false;slot[role][i]="EMPTY";params[role][i]="";return true;}
 void ClearSlots(){ClearRole(role);}
 void LoadO01EntryExample(){role=0;ClearRole(0);string a[8]={"CYCLE_NEW","AND","TIME_ALLOWED","AND","FILTERS_OK","AND","RSI_THRESHOLD","SIGNAL BUY/SELL"};for(int i=0;i<8;i++)slot[0][i]=a[i];params[0][6]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL=30;UPPER=70";}
 void LoadGenericO01ReferenceSeed()
 {
  // Transitional proof seed only: O01 is a reference recipe, never a runtime module ID.
  // Every stored item is a reusable generic Builder part.
  for(int r=0;r<4;r++)ClearRole(r);
  name24[0]="REF_O01_GENERIC_ENTRY";name24[1]="REF_O01_GENERIC_GRID";name24[2]="REF_O01_GENERIC_MANAGE";name24[3]="REF_O01_GENERIC_EXIT";name72="REF_O01_GENERIC_ALL";

  string ep[19]={"CYCLE_NEW","AND","FILTERS_OK","AND","SIDE_COUNT","AND","RSI_THRESHOLD","AND","BUY",
                 "OR","CYCLE_NEW","AND","FILTERS_OK","AND","SIDE_COUNT","AND","RSI_THRESHOLD","AND","SELL"};
  for(int i=0;i<19;i++)slot[0][i]=ep[i];
  params[0][4]="SIDE=BUY;COND=EQ;VALUE=0";
  params[0][6]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL=30";
  params[0][14]="SIDE=SELL;COND=EQ;VALUE=0";
  params[0][16]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=GT;LEVEL=70";

  // M4-1: legacy MANAGE recipe stays in MANAGE until M4-3 split.
  string mp[23]={"SIDE_COUNT","AND","MAX_ORDERS","AND","TRAILING_PAUSE","AND","FILTERS_OK","AND","ONE_ORDER_PER_BAR","AND",
                 "FIXED_DISTANCE","AND","DYNAMIC_DISTANCE","AND","INITIAL_LOT","AND","LOT_MULTIPLIER","AND","MAX_LOT","AND",
                 "MAX_TOTAL_LOT","AND","ADD_BUY"};
  for(int i=0;i<23;i++)slot[2][i]=mp[i];
  params[3][0]="SIDE=CURRENT;COND=GT;VALUE=0";
  params[3][2]="COUNT=10";params[3][4]="ENABLED=1";params[3][8]="ENABLED=1";
  params[3][10]="POINTS=200";params[2][12]="START_ORDER=3;START_POINTS=300;MULT=1.20";
  params[2][14]="LOT=0.01";params[2][16]="MULT=1.50";params[2][18]="LOT=5.00";params[2][20]="LOT=1.20";
  // ADD_BUY is side-neutral at recipe level through SIDE=CURRENT. Runtime evaluator will resolve the active side.
  params[2][22]="SIDE=CURRENT";

  // GRID intentionally remains empty until semantic split in M4-3.
  string xp[13]={"POSITION_COUNT","AND","VIRTUAL_SL","OR","FIXED_TP","OR","SINGLE_TRAILING","OR","BASKET_TRAILING","AND","CLOSE_SIDE","AND","EMPTY"};
  for(int i=0;i<13;i++)slot[3][i]=xp[i];
  params[3][0]="SIDE=CURRENT;COND=GT;VALUE=0";
  params[3][2]="POINTS=1500";params[3][4]="POINTS=110";
  params[3][6]="START=110;LOCK=60;DISTANCE=50;STEP=10";
  params[3][8]="START=100;LOCK=50;DISTANCE=50;STEP=10";
  params[3][10]="SIDE=CURRENT";
  role=0;page[0]=page[1]=page[2]=page[3]=0;
 }
 bool SaveNamed(string &reason){return SaveRoleFile(role,Name24(),reason);} bool LoadNamed(string &reason){return LoadRoleFile(role,Name24(),reason);}
 bool SaveAll72(string &reason){string nm=Name72();if(nm==""){reason="NAME REQUIRED";return false;}string fn="MultiAlpha_Builder_ALL_"+nm+".csv";int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="FILE OPEN";return false;}FileWrite(h,"MA_BUILDER_ALL","1.24",4,24,96);for(int r=0;r<4;r++){FileWrite(h,"ROLE",r,r==0?"ENTRY":r==1?"MANAGE":"EXIT");for(int i=0;i<24;i++)FileWrite(h,r,i+1,slot[r][i],params[r][i]);}FileClose(h);reason="SAVED ALL 96: "+nm;return true;}
 bool LoadAll72(string &reason){string nm=Name72();if(nm==""){reason="NAME REQUIRED";return false;}string fn="MultiAlpha_Builder_ALL_"+nm+".csv";int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="NOT FOUND ALL: "+nm;return false;}string sig=FileReadString(h),ver=FileReadString(h);int rc=(int)FileReadNumber(h),sp=(int)FileReadNumber(h),tot=(int)FileReadNumber(h);if(sig!="MA_BUILDER_ALL"||rc!=4||sp!=24||tot!=96){FileClose(h);reason="INVALID ALL FILE";return false;}for(int r=0;r<4;r++){string mark=FileReadString(h);int rr=(int)FileReadNumber(h);string rn=FileReadString(h);if(mark!="ROLE"||rr!=r){FileClose(h);reason="INVALID ROLE BLOCK";return false;}ClearRole(r);for(int i=0;i<24&&!FileIsEnding(h);i++){int fr=(int)FileReadNumber(h),no=(int)FileReadNumber(h);string pt=FileReadString(h),pa=FileReadString(h);if(fr!=r||no<1||no>24){FileClose(h);reason="INVALID SLOT BLOCK";return false;}slot[r][no-1]=pt;params[r][no-1]=pa;}}FileClose(h);reason="LOADED ALL 96: "+nm;return true;}
 void Show(){CaptureNames();Delete();Box();Lab("TITLE",656,70,"EA LOGIC / LOGIC BUILDER",10);Btn("ROLE_E",656,94,90,"ENTRY",role==0?2:0);Btn("ROLE_G",756,94,90,"GRID",role==1?2:0);Btn("ROLE_M",856,94,90,"MANAGE",role==2?2:0);Btn("ROLE_X",956,94,90,"EXIT",role==3?2:0);Lab("SUB",1060,99,"Role: "+RoleName()+"   NO ORDERS",8);Lab("HELP",656,124,"ADD/EDIT -> EA PARTS -> configure -> APPLY.  UP/DOWN changes 8-slot page.",8);int y=150,start=page[role]*8;for(int r=0;r<8;r++){int i=start+r;string no=(i<9?"0":"")+IntegerToString(i+1);Lab("N"+IntegerToString(r),656,y+4,(i==selected[role]?"> ":"  ")+no,8);string shown=slot[role][i];if(params[role][i]!="")shown+="  {"+params[role][i]+"}";int row_state=(i==selected[role]?2:(slot[role][i]!="EMPTY"?1:0));Btn("S"+IntegerToString(r),686,y,360,shown,row_state);Btn("E"+IntegerToString(r),1055,y,90,(slot[role][i]=="EMPTY"?"ADD":"EDIT"),row_state);y+=30;}Btn("UP",1155,150,70,"UP");Btn("DOWN",1155,180,70,"DOWN");Lab("RANGE",1155,215,(start<9?"0":"")+IntegerToString(start+1)+"-"+IntegerToString(start+8)+" / 24",8);Btn("CLEAR",1155,240,70,"CLEAR");
 Lab("N24",656,407,"Name 24",8);Edit("NAME24",710,403,180,name24[role]);Btn("SAVE",900,403,90,"SAVE 24");Btn("LOAD",1000,403,90,"LOAD 24");Btn("NEXT24",1100,403,90,"NEXT");
 Lab("N72",656,437,"Name 72",8);Edit("NAME72",710,433,180,name72);Btn("SAVEALL",900,433,90,"SAVE 72");Btn("LOADALL",1000,433,90,"LOAD 72");Btn("NEXT72",1100,433,90,"NEXT");
 Lab("STATUS",656,476,"Ready",8);ChartRedraw();}
 void Status(string s,color c=clrWhite){Lab("STATUS",656,476,s,8);ObjectSetInteger(0,p+"STATUS",OBJPROP_COLOR,c);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();} void Delete(){ObjectsDeleteAll(0,p);}
 int OnChartEvent(const int id,const long lparam,const double dparam,const string s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(s==p+"ROLE_E"||s==p+"ROLE_G"||s==p+"ROLE_M"||s==p+"ROLE_X"){role=(s==p+"ROLE_E"?0:s==p+"ROLE_G"?1:s==p+"ROLE_M"?2:3);page[role]=0;Show();return 5;}if(s==p+"UP"){if(page[role]<2)page[role]++;Show();return 1;}if(s==p+"DOWN"){if(page[role]>0)page[role]--;Show();return 1;}if(s==p+"CLEAR"){ClearRole(role);Show();return 1;}if(s==p+"NEXT24"){CaptureNames();Next24();ObjectSetInteger(0,p+"NEXT24",OBJPROP_STATE,false);ChartRedraw();return 1;}if(s==p+"NEXT72"){CaptureNames();Next72();ObjectSetInteger(0,p+"NEXT72",OBJPROP_STATE,false);ChartRedraw();return 1;}if(s==p+"SAVE"){string w;bool ok=SaveNamed(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return 3;}if(s==p+"LOAD"){string w;bool ok=LoadNamed(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return ok?4:3;}if(s==p+"SAVEALL"){string w;bool ok=SaveAll72(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return 3;}if(s==p+"LOADALL"){string w;bool ok=LoadAll72(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return ok?4:3;}int rr=Row(s);if(rr>=0){selected[role]=page[role]*8+rr;Show();return 2;}return 0;}
};
#endif
