#ifndef MULTIALPHA_VERIFIED_PAIR_LOAD_V1_00_MQH
#define MULTIALPHA_VERIFIED_PAIR_LOAD_V1_00_MQH
#include "MultiAlpha_EASlot_Disk_v1_00.mqh"
#include "MultiAlpha_LogicSlot_Disk_v1_00.mqh"
#include "MultiAlpha_Snapshot_Manifest_v1_00.mqh"
// Staged verification + staged parsing; destination stores change only after all gates pass.
// Caller must use this entry point instead of independent Disk.Load calls.
// This is NOT a transaction across concurrent writers; do not allow writers during load.
class CMultiAlphaVerifiedPairLoad100
{
public:
 bool Load(const string manifest,const string generation,
           const string eaFile,const string logicFile,
           CMultiAlphaEASlotStore100 &ea,
           CMultiAlphaModuleLibraryStore101 &logic,
           string &reason)
 {
  CMultiAlphaSnapshotManifest100 gate;
  string why="";
  if(!gate.Verify(manifest,generation,eaFile,logicFile,why))
  {reason="PAIR_VERIFY_"+why;return false;}
  CMultiAlphaEASlotStore100 stagedEA;
  CMultiAlphaModuleLibraryStore101 stagedLogic;
  CMultiAlphaEASlotDisk100 eaDisk;
  CMultiAlphaLogicDisk100 logicDisk;
  if(!eaDisk.Load(eaFile,stagedEA,why))
  {reason="EA_PARSE_"+why;return false;}
  if(!logicDisk.Load(logicFile,stagedLogic,why))
  {reason="LOGIC_PARSE_"+why;return false;}
  // Verify again to reject accidental file changes between verification and parsing.
  if(!gate.Verify(manifest,generation,eaFile,logicFile,why))
  {reason="PAIR_REVERIFY_"+why;return false;}
  // Commit validated snapshots only. No broker orders or semantic certification.
  ea.ClearAll();
  for(int id=1;id<=MA_CAP_EA_SLOTS;id++)
  {
   string name="";int refs[];bool enabled=false;
   if(stagedEA.Load(id,name,refs,enabled))
    ea.Save(id,name,refs,enabled);
  }
  logic.ClearAll();
  for(int role=0;role<MA_CAP_LOGIC_ROLES;role++)
   for(int slot=0;slot<MA_CAP_LOGIC_SLOTS_PER_ROLE;slot++)
   {
    string name="",parts[],values[];bool enabled=false;
    if(stagedLogic.LoadDefinition(role,slot,name,parts,values,enabled))
     logic.SaveDefinition(role,slot,name,parts,values,enabled);
   }
  reason="PAIR_LOADED";
  return true;
 }
};
#endif
