//+------------------------------------------------------------------+
//| MultiAlpha_Builder_FreeSlot_Panel_v1_25.mqh                     |
//| M4-2: 4-role x 40-Part Builder, 10 rows x 4 pages. NO ORDERS.   |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_25_MQH
#define MULTIALPHA_BUILDER_FREE_SLOT_PANEL_V1_25_MQH
#define MA_BUILDER_FREE_SLOT_PANEL_VERSION "1.25"
#define MA_BUILDER_ROLE_COUNT 4
#define MA_BUILDER_SLOTS_PER_ROLE 40
#define MA_BUILDER_VISIBLE_ROWS 10
#define MA_BUILDER_PAGE_COUNT 4

enum ENUM_MA_BUILDER_ROLE125 { MA_BUILDER_ENTRY125=0,MA_BUILDER_GRID125=1,MA_BUILDER_MANAGE125=2,MA_BUILDER_EXIT125=3 };

class CMultiAlphaBuilderFreeSlotPanel125{
 string p,slot[MA_BUILDER_ROLE_COUNT][MA_BUILDER_SLOTS_PER_ROLE],params[MA_BUILDER_ROLE_COUNT][MA_BUILDER_SLOTS_PER_ROLE];
 int selected[MA_BUILDER_ROLE_COUNT],page[MA_BUILDER_ROLE_COUNT],role,displayed_role;
 string name40[MA_BUILDER_ROLE_COUNT],name160;
 string next40_name[MA_BUILDER_ROLE_COUNT],next160_name;
 void Lab(string id,int x,int y,string s,int fs=8){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,35);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Btn(string id,int x,int y,int w,string s,int state=0){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_BUTTON,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);color bg=(state==2?C'32,135,160':(state==1?C'30,82,98':C'24,39,49'));ObjectSetInteger(0,n,OBJPROP_BGCOLOR,bg);ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,40);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Edit(string id,int x,int y,int w,string s){string n=p+id;if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_EDIT,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);ObjectSetInteger(0,n,OBJPROP_XSIZE,w);ObjectSetInteger(0,n,OBJPROP_YSIZE,22);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'20,31,40');ObjectSetInteger(0,n,OBJPROP_COLOR,clrWhite);ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'65,90,105');ObjectSetInteger(0,n,OBJPROP_FONTSIZE,8);ObjectSetInteger(0,n,OBJPROP_ZORDER,45);ObjectSetString(0,n,OBJPROP_TEXT,s);}
 void Box(){string n=p+"BG";if(ObjectFind(0,n)<0)ObjectCreate(0,n,OBJ_RECTANGLE_LABEL,0,0,0);ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);ObjectSetInteger(0,n,OBJPROP_XDISTANCE,640);ObjectSetInteger(0,n,OBJPROP_YDISTANCE,58);ObjectSetInteger(0,n,OBJPROP_XSIZE,660);ObjectSetInteger(0,n,OBJPROP_YSIZE,550);ObjectSetInteger(0,n,OBJPROP_BGCOLOR,C'12,20,27');ObjectSetInteger(0,n,OBJPROP_BORDER_COLOR,C'55,70,80');ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);ObjectSetInteger(0,n,OBJPROP_ZORDER,20);}
 string RoleName(){return role==0?"ENTRY":role==1?"GRID":role==2?"MANAGE":"EXIT";} string DefaultName(){return "BUILDER_"+(role==0?"E01":role==1?"G01":role==2?"M01":"X01");}
 void CaptureNames(){string n24=p+"NAME40",n72=p+"NAME160";int rr=(displayed_role>=0&&displayed_role<MA_BUILDER_ROLE_COUNT?displayed_role:role);if(ObjectFind(0,n24)>=0)name40[rr]=ObjectGetString(0,n24,OBJPROP_TEXT);if(ObjectFind(0,n72)>=0)name160=ObjectGetString(0,n72,OBJPROP_TEXT);}
 string Name40(){string n=p+"NAME40";if(ObjectFind(0,n)>=0)return ObjectGetString(0,n,OBJPROP_TEXT);return name40[role];}
 string Name160(){string n=p+"NAME160";if(ObjectFind(0,n)>=0)return ObjectGetString(0,n,OBJPROP_TEXT);return name160;}
 string RolePrefix(const int rr){return "MultiAlpha_Builder_"+(rr==0?"ENTRY_":rr==1?"GRID_":rr==2?"MANAGE_":"EXIT_");}
 string RoleFileName(const int rr,const string nm){return RolePrefix(rr)+nm+".csv";}
 string StripName(const string fn,const string pre){if(StringFind(fn,pre)!=0)return "";string nm=StringSubstr(fn,StringLen(pre));int n=StringLen(nm);if(n>4&&StringSubstr(nm,n-4)==".csv")nm=StringSubstr(nm,0,n-4);return nm;}
 string NextByMask(const string mask,const string pre,const string current){string fn,first="",next="";bool take=false;long h=FileFindFirst(mask,fn,FILE_COMMON);if(h==INVALID_HANDLE)return current;do{string nm=StripName(fn,pre);if(nm=="")continue;if(first=="")first=nm;if(take){next=nm;break;}if(nm==current)take=true;}while(FileFindNext(h,fn));FileFindClose(h);if(next!="")return next;if(first!="")return first;return current;}
 void Next40(){string cur=Name40(),pre=RolePrefix(role);string nx=NextByMask(pre+"*.csv",pre,cur);name40[role]=nx;ObjectSetString(0,p+"NAME40",OBJPROP_TEXT,nx);}
 void Next160(){string cur=Name160(),pre="MultiAlpha_Builder_ALL_";string nx=NextByMask(pre+"*.csv",pre,cur);name160=nx;ObjectSetString(0,p+"NAME160",OBJPROP_TEXT,nx);}
 int Row(string s){for(int r=0;r<MA_BUILDER_VISIBLE_ROWS;r++)if(s==p+"S"+IntegerToString(r)||s==p+"E"+IntegerToString(r))return r;return -1;}
 void ClearRole(const int rr){for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++){slot[rr][i]="EMPTY";params[rr][i]="";}selected[rr]=-1;page[rr]=0;}
 bool SaveRoleFile(const int rr,const string nm,string &reason){if(nm==""){reason="NAME REQUIRED";return false;}string fn=RoleFileName(rr,nm);int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="FILE OPEN";return false;}FileWrite(h,"MA_BUILDER_ROLE","1.25",rr,MA_BUILDER_SLOTS_PER_ROLE);for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++)FileWrite(h,i+1,slot[rr][i],params[rr][i]);FileClose(h);reason="SAVED 40: "+nm;return true;}
 bool LoadRoleFile(const int rr,const string nm,string &reason){if(nm==""){reason="NAME REQUIRED";return false;}string fn=RoleFileName(rr,nm);int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){string legacy="MultiAlpha_Builder_"+nm+".csv";h=FileOpen(legacy,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="NOT FOUND: "+nm;return false;}}string sig=FileReadString(h),ver=FileReadString(h);int fr=(int)FileReadNumber(h),n=(int)FileReadNumber(h);if(sig!="MA_BUILDER_ROLE"||fr!=rr||(n!=24&&n!=MA_BUILDER_SLOTS_PER_ROLE)){FileClose(h);reason="INVALID ROLE FILE";return false;}ClearRole(rr);for(int i=0;i<n&&!FileIsEnding(h);i++){int no=(int)FileReadNumber(h);string pt=FileReadString(h),pa=FileReadString(h);if(no>=1&&no<=MA_BUILDER_SLOTS_PER_ROLE){slot[rr][no-1]=pt;params[rr][no-1]=pa;}}FileClose(h);reason=(n==24?"LOADED LEGACY 24 -> 40: ":"LOADED 40: ")+nm;return true;}
public:
 CMultiAlphaBuilderFreeSlotPanel125(){p="MAFREESLOT125_";role=0;displayed_role=-1;for(int r=0;r<4;r++){ClearRole(r);name40[r]=(r==0?"BUILDER_E01":r==1?"BUILDER_G01":r==2?"BUILDER_M01":"BUILDER_X01");next40_name[r]="";}name160="BUILDER_ALL_01";next160_name="";}
 int Role(){return role;} string RoleText(){return RoleName();} int Selected(){return selected[role];} int SlotCount(){return MA_BUILDER_SLOTS_PER_ROLE;}
 string SelectedPart(){int i=selected[role];return i>=0&&i<MA_BUILDER_SLOTS_PER_ROLE?slot[role][i]:"NONE";} string SelectedParams(){int i=selected[role];return i>=0&&i<MA_BUILDER_SLOTS_PER_ROLE?params[role][i]:"";}
 void Export(string &a[],string &v[]){ArrayResize(a,MA_BUILDER_SLOTS_PER_ROLE);ArrayResize(v,MA_BUILDER_SLOTS_PER_ROLE);for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++){a[i]=slot[role][i];v[i]=params[role][i];}}
 void ImportRole(const int rr,const string nm,string &a[],string &v[]){if(rr<0||rr>=4||ArraySize(a)<MA_BUILDER_SLOTS_PER_ROLE||ArraySize(v)<MA_BUILDER_SLOTS_PER_ROLE)return;ClearRole(rr);name40[rr]=nm;for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++){slot[rr][i]=a[i];params[rr][i]=v[i];}}
 void SetRole(const int rr){if(rr>=0&&rr<4){CaptureNames();role=rr;page[role]=0;}}
 void ExportRole(const int rr,string &a[],string &v[]){ArrayResize(a,MA_BUILDER_SLOTS_PER_ROLE);ArrayResize(v,MA_BUILDER_SLOTS_PER_ROLE);if(rr<0||rr>=4){for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++){a[i]="EMPTY";v[i]="";}return;}for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++){a[i]=slot[rr][i];v[i]=params[rr][i];}}
 string DefinitionName(const int rr){if(rr<0||rr>=4)return "";return name40[rr];}
 string PartAt(const int rr,const int ii){if(rr<0||rr>=4||ii<0||ii>=MA_BUILDER_SLOTS_PER_ROLE)return "EMPTY";return slot[rr][ii];}
 string ParamsAt(const int rr,const int ii){if(rr<0||rr>=4||ii<0||ii>=MA_BUILDER_SLOTS_PER_ROLE)return "";return params[rr][ii];}
 void BeginRoleImport(const int rr,const string nm){if(rr<0||rr>=4)return;ClearRole(rr);name40[rr]=nm;}
 void SetRoleItem(const int rr,const int ii,const string pt,const string pa){if(rr<0||rr>=4||ii<0||ii>=MA_BUILDER_SLOTS_PER_ROLE)return;slot[rr][ii]=pt;params[rr][ii]=pa;}
 bool PutSelected(string part,string par){int i=selected[role];if(i<0||i>=MA_BUILDER_SLOTS_PER_ROLE)return false;slot[role][i]=part;params[role][i]=par;return true;}
 bool DeleteSelected(){int i=selected[role];if(i<0||i>=MA_BUILDER_SLOTS_PER_ROLE)return false;slot[role][i]="EMPTY";params[role][i]="";return true;}
 void ClearSlots(){ClearRole(role);}
 void LoadO01EntryExample(){role=0;ClearRole(0);string a[8]={"CYCLE_NEW","AND","TIME_ALLOWED","AND","FILTERS_OK","AND","RSI_THRESHOLD","SIGNAL BUY/SELL"};for(int i=0;i<8;i++)slot[0][i]=a[i];params[0][6]="TF=CURRENT;PERIOD=8;PRICE=CLOSE;COND=LT;LEVEL=30;UPPER=70";}
 void LoadGenericO01ReferenceSeed()
 {
  // Transitional proof seed only: O01 is a reference recipe, never a runtime module ID.
  // Every stored item is a reusable generic Builder part.
  for(int r=0;r<4;r++)ClearRole(r);
  name40[0]="REF_O01_GENERIC_ENTRY";name40[1]="REF_O01_GENERIC_GRID";name40[2]="REF_O01_GENERIC_MANAGE";name40[3]="REF_O01_GENERIC_EXIT";name160="REF_O01_GENERIC_ALL";

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
  params[2][0]="SIDE=CURRENT;COND=GT;VALUE=0";
  params[2][2]="COUNT=10";params[2][4]="ENABLED=1";params[2][8]="ENABLED=1";
  params[2][10]="POINTS=200";params[2][12]="START_ORDER=3;START_POINTS=300;MULT=1.20";
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
 bool SaveNamed(string &reason){return SaveRoleFile(role,Name40(),reason);} bool LoadNamed(string &reason){return LoadRoleFile(role,Name40(),reason);}
 bool SaveAll160(string &reason){string nm=Name160();if(nm==""){reason="NAME REQUIRED";return false;}string fn="MultiAlpha_Builder_ALL_"+nm+".csv";int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="FILE OPEN";return false;}FileWrite(h,"MA_BUILDER_ALL","1.25",4,40,160);for(int r=0;r<4;r++){FileWrite(h,"ROLE",r,r==0?"ENTRY":r==1?"GRID":r==2?"MANAGE":"EXIT");for(int i=0;i<MA_BUILDER_SLOTS_PER_ROLE;i++)FileWrite(h,r,i+1,slot[r][i],params[r][i]);}FileClose(h);reason="SAVED ALL 160: "+nm;return true;}
 bool LoadAll160(string &reason){string nm=Name160();if(nm==""){reason="NAME REQUIRED";return false;}string fn="MultiAlpha_Builder_ALL_"+nm+".csv";int h=FileOpen(fn,FILE_READ|FILE_CSV|FILE_COMMON,'|');if(h==INVALID_HANDLE){reason="NOT FOUND ALL: "+nm;return false;}string sig=FileReadString(h),ver=FileReadString(h);int rc=(int)FileReadNumber(h),sp=(int)FileReadNumber(h),tot=(int)FileReadNumber(h);bool legacy=(rc==4&&sp==24&&tot==96);if(sig!="MA_BUILDER_ALL"||(!legacy&&(rc!=4||sp!=40||tot!=160))){FileClose(h);reason="INVALID ALL FILE";return false;}for(int r=0;r<4;r++){string mark=FileReadString(h);int rr=(int)FileReadNumber(h);string rn=FileReadString(h);if(mark!="ROLE"||rr!=r){FileClose(h);reason="INVALID ROLE BLOCK";return false;}ClearRole(r);for(int i=0;i<sp&&!FileIsEnding(h);i++){int fr=(int)FileReadNumber(h),no=(int)FileReadNumber(h);string pt=FileReadString(h),pa=FileReadString(h);if(fr!=r||no<1||no>MA_BUILDER_SLOTS_PER_ROLE){FileClose(h);reason="INVALID SLOT BLOCK";return false;}slot[r][no-1]=pt;params[r][no-1]=pa;}}FileClose(h);reason=(legacy?"LOADED LEGACY ALL 96 -> 160: ":"LOADED ALL 160: ")+nm;return true;}
 void Show(){CaptureNames();Delete();Box();Lab("TITLE",656,70,"EA LOGIC / LOGIC BUILDER",10);Btn("ROLE_E",656,94,90,"ENTRY",role==0?2:0);Btn("ROLE_G",756,94,90,"GRID",role==1?2:0);Btn("ROLE_M",856,94,90,"MANAGE",role==2?2:0);Btn("ROLE_X",956,94,90,"EXIT",role==3?2:0);Lab("SUB",1060,99,"Role: "+RoleName()+"   NO ORDERS",8);Lab("HELP",656,124,"ADD/EDIT -> EA PARTS -> configure -> APPLY.  UP/DOWN changes 10-Part page.",8);int y=150,start=page[role]*MA_BUILDER_VISIBLE_ROWS;for(int r=0;r<MA_BUILDER_VISIBLE_ROWS;r++){int i=start+r;string no=(i<9?"0":"")+IntegerToString(i+1);Lab("N"+IntegerToString(r),656,y+4,(i==selected[role]?"> ":"  ")+no,8);string shown=slot[role][i];if(params[role][i]!="")shown+="  {"+params[role][i]+"}";int row_state=(i==selected[role]?2:(slot[role][i]!="EMPTY"?1:0));Btn("S"+IntegerToString(r),686,y,360,shown,row_state);Btn("E"+IntegerToString(r),1055,y,90,(slot[role][i]=="EMPTY"?"ADD":"EDIT"),row_state);y+=30;}Btn("UP",1155,150,70,"UP");Btn("DOWN",1155,180,70,"DOWN");Lab("RANGE",1155,215,(start<9?"0":"")+IntegerToString(start+1)+"-"+IntegerToString(start+MA_BUILDER_VISIBLE_ROWS)+" / 40",8);Btn("CLEAR",1155,240,70,"CLEAR");
 Lab("N40",656,467,"Name 40",8);Edit("NAME40",710,463,180,name40[role]);Btn("SAVE",900,463,90,"SAVE 40");Btn("LOAD",1000,463,90,"LOAD 40");Btn("NEXT40",1100,463,90,"NEXT");
 Lab("N160",656,497,"Name 160",8);Edit("NAME160",710,493,180,name160);Btn("SAVEALL",900,493,90,"SAVE 160");Btn("LOADALL",1000,493,90,"LOAD 160");Btn("NEXT160",1100,493,90,"NEXT");
 Lab("STATUS",656,536,"Ready",8);displayed_role=role;ChartRedraw();}
 void Status(string s,color c=clrWhite){Lab("STATUS",656,536,s,8);ObjectSetInteger(0,p+"STATUS",OBJPROP_COLOR,c);ChartRedraw();}
 void Hide(){int total=ObjectsTotal(0,0,-1);for(int i=total-1;i>=0;i--){string n=ObjectName(0,i,0,-1);if(StringFind(n,p)==0)ObjectSetInteger(0,n,OBJPROP_TIMEFRAMES,0);}ChartRedraw();} void Delete(){ObjectsDeleteAll(0,p);}
 int OnChartEvent(const int id,const long lparam,const double dparam,const string s){if(id!=CHARTEVENT_OBJECT_CLICK)return 0;if(s==p+"ROLE_E"||s==p+"ROLE_G"||s==p+"ROLE_M"||s==p+"ROLE_X"){role=(s==p+"ROLE_E"?0:s==p+"ROLE_G"?1:s==p+"ROLE_M"?2:3);page[role]=0;Show();return 5;}if(s==p+"UP"){if(page[role]<MA_BUILDER_PAGE_COUNT-1)page[role]++;Show();return 1;}if(s==p+"DOWN"){if(page[role]>0)page[role]--;Show();return 1;}if(s==p+"CLEAR"){ClearRole(role);Show();return 1;}if(s==p+"NEXT40"){CaptureNames();Next40();ObjectSetInteger(0,p+"NEXT40",OBJPROP_STATE,false);ChartRedraw();return 1;}if(s==p+"NEXT160"){CaptureNames();Next160();ObjectSetInteger(0,p+"NEXT160",OBJPROP_STATE,false);ChartRedraw();return 1;}if(s==p+"SAVE"){string w;bool ok=SaveNamed(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return 3;}if(s==p+"LOAD"){string w;bool ok=LoadNamed(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return ok?4:3;}if(s==p+"SAVEALL"){string w;bool ok=SaveAll160(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return 3;}if(s==p+"LOADALL"){string w;bool ok=LoadAll160(w);Show();Status(w,ok?C'70,210,150':C'245,150,70');return ok?4:3;}int rr=Row(s);if(rr>=0){selected[role]=page[role]*MA_BUILDER_VISIBLE_ROWS+rr;Show();return 2;}return 0;}
};
#endif
