#ifndef MULTIALPHA_CAPACITY_V1_00_MQH
#define MULTIALPHA_CAPACITY_V1_00_MQH
// Canonical product capacities (2026-10-08).
// Legacy 40/50/60 modules are NOT migrated merely by including this file.
// Wire only through versioned, independently tested adapters.
#define MA_CAP_EA_SLOTS 100
#define MA_CAP_LOGIC_ROLES 4
#define MA_CAP_LOGIC_SLOTS_PER_ROLE 100
#define MA_CAP_PARTS_PER_LOGIC 100
#define MA_CAP_PAGE_SIZE 20
#define MA_CAP_PAGE_COUNT 5
bool MACapEASlotId(const int id){return id>=1&&id<=MA_CAP_EA_SLOTS;}
bool MACapLogicRole(const int role){return role>=0&&role<MA_CAP_LOGIC_ROLES;}
bool MACapLogicSlotId(const int id){return id>=1&&id<=MA_CAP_LOGIC_SLOTS_PER_ROLE;}
bool MACapPartIndex(const int index){return index>=0&&index<MA_CAP_PARTS_PER_LOGIC;}
int MACapPageStart(const int page){return page>=0&&page<MA_CAP_PAGE_COUNT?page*MA_CAP_PAGE_SIZE:-1;}
#endif
