#ifndef MULTIALPHA_GRID_100_GATE_V1_00_MQH
#define MULTIALPHA_GRID_100_GATE_V1_00_MQH
#include "MultiAlpha_Capacity_v1_00.mqh"
#include "MultiAlpha_Builder_Grid_Interpreter_v1_00.mqh"
#include "MultiAlpha_Builder_Part_Schema_v1_04.mqh"
// Compatibility gate only: GRID OFF, or original 33-Part O01 GRID plan.
// Generic arbitrary 100-Part GRID runtime semantics are NOT certified.
enum ENUM_MA_GRID100_MODE { MA_GRID100_INVALID=0, MA_GRID100_OFF=1, MA_GRID100_LEGACY_O01=2 };
class CMultiAlphaGrid100Gate
{
 CMultiAlphaBuilderGridInterpreter100 m_legacy;
 bool Empty(const string p){return p==""||p=="EMPTY";}
public:
 ENUM_MA_GRID100_MODE Validate(const string &p[],const string &v[],string &reason)
 {
  if(ArraySize(p)!=MA_CAP_PARTS_PER_LOGIC||ArraySize(v)!=MA_CAP_PARTS_PER_LOGIC)
  {reason="SIZE_100";return MA_GRID100_INVALID;}
  int offCount=0,otherCount=0;
  for(int i=0;i<MA_CAP_PARTS_PER_LOGIC;i++)
  {
   string x=MA101CanonicalPart(p[i]);
   if(Empty(x))
   {
    if(v[i]!=""){reason="EMPTY_WITH_PARAMS";return MA_GRID100_INVALID;}
    continue;
   }
   if(x=="GRID_OFF"||x=="GRID OFF")
   {
    if(v[i]!=""){reason="GRID_OFF_PARAMS";return MA_GRID100_INVALID;}
    offCount++;
   }
   else otherCount++;
  }
  if(offCount>0)
  {
   if(offCount==1&&otherCount==0){reason="GRID_OFF_VALID";return MA_GRID100_OFF;}
   reason="GRID_OFF_CONFLICT";return MA_GRID100_INVALID;
  }
  // Old O01 plan is 33 parts + 7 EMPTY, with 60 new EMPTY slots.
  for(int i=40;i<MA_CAP_PARTS_PER_LOGIC;i++)
  if(!Empty(MA101CanonicalPart(p[i]))){reason="GENERIC_GRID_RUNTIME_UNPROVEN";return MA_GRID100_INVALID;}
  string oldP[],oldV[];ArrayResize(oldP,40);ArrayResize(oldV,40);
  for(int i=0;i<40;i++){oldP[i]=p[i];oldV[i]=v[i];}
  if(!m_legacy.ValidatePlan(oldP,oldV,reason))return MA_GRID100_INVALID;
  reason="LEGACY_O01_PLAN_VALID";return MA_GRID100_LEGACY_O01;
 }
 bool Evaluate(const string &p[],const string &v[],const bool &gate[],const int side,
               bool &addBuy,bool &addSell,string &stopAt,string &reason)
 {
  addBuy=false;addSell=false;stopAt="-";
  if(ArraySize(gate)!=MA_CAP_PARTS_PER_LOGIC){reason="GATE_SIZE_100";return false;}
  ENUM_MA_GRID100_MODE mode=Validate(p,v,reason);
  if(mode==MA_GRID100_INVALID)return false;
  if(mode==MA_GRID100_OFF){reason="GRID_OFF_NO_ADDITIONS";return true;}
  string oldP[],oldV[];bool oldGate[];
  ArrayResize(oldP,40);ArrayResize(oldV,40);ArrayResize(oldGate,40);
  for(int i=0;i<40;i++){oldP[i]=p[i];oldV[i]=v[i];oldGate[i]=gate[i];}
  return m_legacy.Evaluate(oldP,oldV,oldGate,side,addBuy,addSell,stopAt,reason);
 }
};
#endif
