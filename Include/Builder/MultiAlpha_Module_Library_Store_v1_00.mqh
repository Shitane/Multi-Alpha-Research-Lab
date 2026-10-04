#ifndef MULTIALPHA_MODULE_LIBRARY_STORE_V1_00_MQH
#define MULTIALPHA_MODULE_LIBRARY_STORE_V1_00_MQH
#define MA_MLS100_ROLE_COUNT 4
#define MA_MLS100_SLOT_COUNT 50
#define MA_MLS100_PART_COUNT 40
enum ENUM_MA_MODULE_ROLE100 { MA_MODULE_ENTRY100=0, MA_MODULE_GRID100=1, MA_MODULE_MANAGE100=2, MA_MODULE_EXIT100=3 };
enum ENUM_MA_MODULE_STATE100 { MA_MODULE_EMPTY100=0, MA_MODULE_SAVED_DISABLED100=1, MA_MODULE_SAVED_ENABLED100=2 };
struct SMA_ModuleSlot100 { bool saved; bool enabled; string name; string part[40]; string param[40]; };
class CMultiAlphaModuleLibraryStore100 {
 private:
  SMA_ModuleSlot100 m[4][50];
  bool VR(int r)const{return r>=0&&r<4;} bool VS(int s)const{return s>=0&&s<50;}
 public:
  CMultiAlphaModuleLibraryStore100(){ClearAll();}
  void ClearAll(){for(int r=0;r<4;r++)for(int s=0;s<50;s++)ClearSlot(r,s);}
  bool ClearSlot(int r,int s){if(!VR(r)||!VS(s))return false;m[r][s].saved=false;m[r][s].enabled=false;m[r][s].name="";for(int p=0;p<40;p++){m[r][s].part[p]="";m[r][s].param[p]="";}return true;}
  bool SaveDefinition(int r,int s,string n,const string &parts[],const string &params[],bool en){if(!VR(r)||!VS(s)||ArraySize(parts)<40||ArraySize(params)<40)return false;m[r][s].saved=true;m[r][s].enabled=en;m[r][s].name=n;for(int p=0;p<40;p++){m[r][s].part[p]=parts[p];m[r][s].param[p]=params[p];}return true;}
  bool LoadDefinition(int r,int s,string &n,string &parts[],string &params[],bool &en)const{if(!IsSaved(r,s))return false;ArrayResize(parts,40);ArrayResize(params,40);n=m[r][s].name;en=m[r][s].enabled;for(int p=0;p<40;p++){parts[p]=m[r][s].part[p];params[p]=m[r][s].param[p];}return true;}
  bool SetEnabled(int r,int s,bool en){if(!IsSaved(r,s))return false;m[r][s].enabled=en;return true;}
  bool IsSaved(int r,int s)const{return VR(r)&&VS(s)&&m[r][s].saved;}
  bool IsEnabled(int r,int s)const{return IsSaved(r,s)&&m[r][s].enabled;}
  ENUM_MA_MODULE_STATE100 State(int r,int s)const{if(!IsSaved(r,s))return MA_MODULE_EMPTY100;return m[r][s].enabled?MA_MODULE_SAVED_ENABLED100:MA_MODULE_SAVED_DISABLED100;}
  string Name(int r,int s)const{return IsSaved(r,s)?m[r][s].name:"";}
  int EnabledCount(int r)const{if(!VR(r))return 0;int n=0;for(int s=0;s<50;s++)if(IsEnabled(r,s))n++;return n;}
  int CollectEnabledSlots(int r,int &nums[])const{ArrayResize(nums,0);if(!VR(r))return 0;for(int s=0;s<50;s++)if(IsEnabled(r,s)){int n=ArraySize(nums);ArrayResize(nums,n+1);nums[n]=s+1;}return ArraySize(nums);}
};
#endif
