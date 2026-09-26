//+------------------------------------------------------------------+
//| MultiAlpha_Foundation_v1_40.mqh                                  |
//| v1.40 main-line architecture foundation.                         |
//| Strategy identity + execution boundary + panel appearance.       |
//+------------------------------------------------------------------+
#ifndef MULTIALPHA_FOUNDATION_V1_40_MQH
#define MULTIALPHA_FOUNDATION_V1_40_MQH

enum ENUM_MA_EXECUTION_MODE
{
   MA_EXECUTION_NO_ORDERS = 0,
   MA_EXECUTION_DEMO      = 1
};

enum ENUM_MA_RUN_MODE
{
   MA_MODE_FULL    = 0,
   MA_MODE_MODULAR = 1
};

struct SMA140StrategyIdentity
{
   int instance_id;
   string symbol;
   long magic;
   bool enabled;
   ENUM_MA_RUN_MODE run_mode;
   string full_module;
   string entry_module;
   string manage_module;
   string exit_module;
};

struct SMA140PanelTheme
{
   int opacity;
   color background;
   color text;
   color muted;
   color title;
   color section;
   color value;
   color border;
   color warning;
   int font_size;
};

void MA140_DefaultIdentity(SMA140StrategyIdentity &s,const string symbol)
{
   s.instance_id=1;
   s.symbol=symbol;
   s.magic=46102031;
   s.enabled=true;
   s.run_mode=MA_MODE_MODULAR;
   s.full_module="O01";
   s.entry_module="O01";
   s.manage_module="O01";
   s.exit_module="O01";
}

void MA140_DefaultTheme(SMA140PanelTheme &t)
{
   t.opacity=145;
   t.background=C'18,22,28';
   t.text=clrWhite;
   t.muted=C'175,185,195';
   t.title=C'235,200,70';
   t.section=C'70,200,235';
   t.value=C'235,235,235';
   t.border=C'70,85,95';
   t.warning=C'245,175,70';
   t.font_size=8;
}

string MA140_ExecutionText(const ENUM_MA_EXECUTION_MODE m)
{
   return (m==MA_EXECUTION_DEMO ? "DEMO" : "NO_ORDERS");
}

#endif
