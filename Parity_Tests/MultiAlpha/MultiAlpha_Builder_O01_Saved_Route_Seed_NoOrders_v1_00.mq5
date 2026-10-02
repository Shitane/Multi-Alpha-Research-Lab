//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Saved_Route_Seed_NoOrders_v1_00.mq5     |
//| Seeds missing O01 MANAGE/EXIT SAVE24 role files for route gate.  |
//| Uses only generic Builder parts. NO ORDERS / VIRTUAL NOT FILL.   |
//+------------------------------------------------------------------+
#property strict
#property version "1.00"

input string InpManageName="BUILDER_M01";
input string InpExitName="BUILDER_X01";
input bool   InpOverwrite=false;

string Prefix(const int role)
{
 return "MultiAlpha_Builder_"+(role==1?"MANAGE_":"EXIT_");
}
bool Exists(const int role,const string name)
{
 int h=FileOpen(Prefix(role)+name+".csv",FILE_READ|FILE_CSV|FILE_COMMON,'|');
 if(h==INVALID_HANDLE)return false;
 FileClose(h); return true;
}
bool WriteRole(const int role,const string name,const string &part[],const string &param[],string &why)
{
 if(name==""){why="NAME REQUIRED";return false;}
 string fn=Prefix(role)+name+".csv";
 if(!InpOverwrite && Exists(role,name)){why="EXISTS (preserved): "+fn;return true;}
 int h=FileOpen(fn,FILE_WRITE|FILE_CSV|FILE_COMMON,'|');
 if(h==INVALID_HANDLE){why="FILE OPEN FAILED: "+fn;return false;}
 FileWrite(h,"MA_BUILDER_ROLE","1.00",role,24);
 for(int i=0;i<24;i++) FileWrite(h,i+1,part[i],param[i]);
 FileClose(h); why="SAVED: "+fn; return true;
}
void Empty24(string &part[],string &param[])
{
 ArrayResize(part,24);ArrayResize(param,24);
 for(int i=0;i<24;i++){part[i]="EMPTY";param[i]="";}
}
int OnInit()
{
 string mp[],mv[],xp[],xv[]; Empty24(mp,mv); Empty24(xp,xv);

 // Generic O01 MANAGE definition: grid eligibility chain.
 mp[0]="SIDE_COUNT"; mp[1]="AND"; mp[2]="MAX_ORDERS"; mp[3]="AND";
 mp[4]="TRAIL_PAUSE"; mp[5]="AND"; mp[6]="TIME"; mp[7]="AND";
 mp[8]="NEWS"; mp[9]="AND"; mp[10]="SPREAD"; mp[11]="AND";
 mp[12]="ONE/BAR"; mp[13]="AND"; mp[14]="DYNAMIC_DIST"; mp[15]="AND";
 mp[16]="LOT_MULT"; mp[17]="AND"; mp[18]="MAX_LOT"; mp[19]="AND";
 mp[20]="MAX_TOTAL"; mp[21]="AND"; mp[22]="ADD BUY";

 // Generic O01 EXIT definition: position-aware exit chain.
 xp[0]="SIDE_COUNT"; xp[1]="AND"; xp[2]="VIRTUAL_SL"; xp[3]="OR";
 xp[4]="FIXED_TP"; xp[5]="OR"; xp[6]="SINGLE_TRAIL"; xp[7]="OR";
 xp[8]="BASKET_TRAIL"; xp[9]="OR"; xp[10]="CLOSE";

 string mw="",xw="";
 bool m=WriteRole(1,InpManageName,mp,mv,mw);
 bool x=WriteRole(2,InpExitName,xp,xv,xw);

 Print("============================================================");
 Print("MULTI ALPHA / O01 SAVED ROUTE SEED / NO ORDERS v1.00");
 Print("MANAGE ",mw);
 Print("EXIT   ",xw);
 Print((m&&x)?"RESULT: PASS - MANAGE/EXIT SAVE24 route files are ready"
             :"RESULT: FAIL - could not create saved route files");
 Print("NEXT: run MultiAlpha_Builder_Saved_Route_LiveMarket_NoOrders_Gate_v1_00");
 Print("NO ORDERS / VIRTUAL NOT FILL / BROKER ACTIONS ARMED=0");
 Print("============================================================");
 return (m&&x)?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
