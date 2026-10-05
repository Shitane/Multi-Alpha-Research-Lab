// MA_O01_R2_4RoleSeedGate_v1_00.mq5
#property strict
#include <Builder\MultiAlpha_Builder_Part_Schema_v1_01.mqh>
#include <Builder\MultiAlpha_O01_Canonical_40Parts_v1_00.mqh>

bool Has(int r,string q,string &p[][40]){for(int i=0;i<40;i++)if(p[r][i]==q)return true;return false;}
bool Check(int r,string &p[][40],string &v[][40])
{
 bool ok=true;int used=0;string why="";
 for(int i=0;i<40;i++){if(p[r][i]==""||p[r][i]=="EMPTY")continue;used++;
  if(!MA101ValidatePart(r,p[r][i],v[r][i],why)){Print("[O01_R2_4ROLE_PART_FAIL] role=",MA101RoleName(r)," slot=",i+1," part=",p[r][i]," reason=",why);ok=false;}}
 Print("[O01_R2_4ROLE_ROLE] role=",MA101RoleName(r)," used=",used," result=",(ok?"PASS":"FAIL"));return ok;
}
int OnInit()
{
 string p[4][40],v[4][40];MAO01LoadCanonical100(p,v);bool ok=true;
 for(int r=0;r<4;r++)ok&=Check(r,p,v);
 bool own=Has(0,"RSI_THRESHOLD",p)&&!Has(1,"RSI_THRESHOLD",p)&&
  Has(1,"FIXED_DISTANCE",p)&&Has(1,"DYNAMIC_DISTANCE",p)&&Has(1,"LOT_MULTIPLIER",p)&&
  !Has(2,"FIXED_DISTANCE",p)&&!Has(2,"SINGLE_TRAILING",p)&&Has(2,"AVG_PRICE",p)&&Has(2,"MOVE_POINTS",p)&&
  Has(3,"VIRTUAL_SL",p)&&Has(3,"SINGLE_TRAILING",p)&&Has(3,"BASKET_TRAILING",p)&&!Has(1,"VIRTUAL_SL",p);
 ok&=own;
 Print("[O01_R2_4ROLE_OWNERSHIP] ENTRY=signal GRID=add MANAGE=state EXIT=protection result=",(own?"PASS":"FAIL"));
 Print("[O01_R2_4ROLE_GATE] seed=",MA_O01_CANONICAL_40P_VERSION," order=ENTRY->GRID->MANAGE->EXIT result=",(ok?"PASS":"FAIL"),
 " P1_MISSING=GRID_DD_TIME_NEWS_SPREAD_DISTANCE_ACTION,OVERLAP,BASKET_FIXED_TP,MONEY_TP,CLOSE_OPPOSITE NO_ORDERS=1 VIRTUAL_NOT_FILL=1");
 return ok?INIT_SUCCEEDED:INIT_FAILED;
}
void OnTick(){}
