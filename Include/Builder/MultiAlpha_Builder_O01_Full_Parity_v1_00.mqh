//+------------------------------------------------------------------+
//| MultiAlpha_Builder_O01_Full_Parity_v1_00.mqh                    |
//| LB-01 integrated O01 ENTRY/MANAGE/EXIT Builder parity gate.      |
//| Reuses already-passing isolated parity harnesses unchanged.       |
//| NO ORDERS / VIRTUAL NOT FILL.                                    |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_BUILDER_O01_FULL_PARITY_V1_00_MQH
#define MULTIALPHA_BUILDER_O01_FULL_PARITY_V1_00_MQH

#include "MultiAlpha_Builder_O01_Entry_Parity_v1_00.mqh"
#include "MultiAlpha_Builder_O01_Manage_Parity_v1_00.mqh"
#include "MultiAlpha_Builder_O01_Exit_Parity_v1_00.mqh"

#define MA_BUILDER_O01_FULL_PARITY_VERSION "1.00"

class CMultiAlphaBuilderO01FullParity100
{
private:
 CMultiAlphaBuilderO01EntryParity100  m_entry;
 CMultiAlphaBuilderO01ManageParity100 m_manage;
 CMultiAlphaBuilderO01ExitParity100   m_exit;

public:
 bool RunAll(string &report) const
 {
  string entry_report="",manage_report="",exit_report="";
  bool entry_ok=m_entry.RunAll(entry_report);
  bool manage_ok=m_manage.RunAll(manage_report);
  bool exit_ok=m_exit.RunAll(exit_report);

  report="O01 BUILDER FULL INTEGRATION GATE\n";
  report+="ENTRY "+IntegerToString(m_entry.CaseCount())+" cases: "+(entry_ok?"PASS":"FAIL")+"\n";
  report+="MANAGE "+IntegerToString(m_manage.CaseCount())+" cases: "+(manage_ok?"PASS":"FAIL")+"\n";
  report+="EXIT "+IntegerToString(m_exit.CaseCount())+" cases: "+(exit_ok?"PASS":"FAIL")+"\n";
  report+="TOTAL "+IntegerToString(m_entry.CaseCount()+m_manage.CaseCount()+m_exit.CaseCount())+" cases\n";
  report+="\n--- ENTRY ---\n"+entry_report;
  report+="\n--- MANAGE ---\n"+manage_report;
  report+="\n--- EXIT ---\n"+exit_report;

  return entry_ok && manage_ok && exit_ok;
 }
};

#endif
