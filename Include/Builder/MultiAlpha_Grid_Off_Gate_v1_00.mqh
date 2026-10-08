#ifndef MA_GRID_OFF_GATE_V100
#define MA_GRID_OFF_GATE_V100
// Pure, panel-independent NoOrders GRID decision guard.
// A saved, validated GRID OFF definition always denies grid addition.
bool MAGridOffPart100(const string &parts[])
{
 for(int i=0;i<ArraySize(parts);i++)
  if(parts[i]=="GRID_OFF"||parts[i]=="GRID OFF")return true;
 return false;
}
bool MAGridDecisionGuard100(const bool saved_valid,const string &parts[],const bool proposed_add,string &reason)
{
 if(!saved_valid){reason="INVALID_GRID_LOGIC";return false;}
 if(MAGridOffPart100(parts)){reason="GRID_OFF";return false;}
 if(!proposed_add){reason="NO_ADD_SIGNAL";return false;}
 reason="ALLOW";return true;
}
#endif
