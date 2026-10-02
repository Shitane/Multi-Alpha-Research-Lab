//+------------------------------------------------------------------+
//| MultiAlpha_Builder_Definition_v1_00.mqh                         |
//| LB-01 data model. UI-independent. NO ORDERS.                     |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_DEFINITION_V1_00_MQH
#define MULTIALPHA_BUILDER_DEFINITION_V1_00_MQH
#define MA_BUILDER_SCHEMA_VERSION "1.00"
#define MA_BUILDER_MAX_GROUPS 4
#define MA_BUILDER_MAX_SLOTS  8

enum ENUM_MA_BUILDER_ROLE100 { MA_BUILDER_ENTRY100=0, MA_BUILDER_MANAGE100=1, MA_BUILDER_EXIT100=2 };
enum ENUM_MA_BUILDER_GROUP_OP100 { MA_BUILDER_AND100=0, MA_BUILDER_OR100=1 };

struct SMA_BuilderSlot100
{
 bool enabled;
 string part_id;
 string part_version;
 string parameters;
};

struct SMA_BuilderGroup100
{
 bool enabled;
 ENUM_MA_BUILDER_GROUP_OP100 op;
 int slot_count;
 SMA_BuilderSlot100 slots[MA_BUILDER_MAX_SLOTS];
};

struct SMA_BuilderDefinition100
{
 string schema_version;
 string id;
 string name;
 string version;
 ENUM_MA_BUILDER_ROLE100 role;
 int group_count;
 SMA_BuilderGroup100 groups[MA_BUILDER_MAX_GROUPS];
 string output_part_id;
 string output_parameters;
};

class CMultiAlphaBuilderDefinition100
{
public:
 void Clear(SMA_BuilderDefinition100 &d) const
 {
  d.schema_version=MA_BUILDER_SCHEMA_VERSION; d.id=""; d.name=""; d.version="1.00";
  d.role=MA_BUILDER_ENTRY100; d.group_count=0; d.output_part_id=""; d.output_parameters="";
  for(int g=0;g<MA_BUILDER_MAX_GROUPS;g++){d.groups[g].enabled=false;d.groups[g].op=MA_BUILDER_AND100;d.groups[g].slot_count=0;
   for(int s=0;s<MA_BUILDER_MAX_SLOTS;s++){d.groups[g].slots[s].enabled=false;d.groups[g].slots[s].part_id="";d.groups[g].slots[s].part_version="";d.groups[g].slots[s].parameters="";}}
 }
 bool Validate(const SMA_BuilderDefinition100 &d,string &reason) const
 {
  if(d.schema_version!=MA_BUILDER_SCHEMA_VERSION){reason="SCHEMA";return false;}
  if(d.id==""||d.name==""){reason="IDENTITY";return false;}
  if(d.group_count<1||d.group_count>MA_BUILDER_MAX_GROUPS){reason="GROUP_COUNT";return false;}
  for(int g=0;g<d.group_count;g++){if(!d.groups[g].enabled)continue;
   if(d.groups[g].slot_count<1||d.groups[g].slot_count>MA_BUILDER_MAX_SLOTS){reason="SLOT_COUNT";return false;}
   for(int s=0;s<d.groups[g].slot_count;s++)if(d.groups[g].slots[s].enabled&&d.groups[g].slots[s].part_id==""){reason="EMPTY_PART";return false;}}
  if(d.output_part_id==""){reason="OUTPUT";return false;}
  reason="READY";return true;
 }
};
#endif
