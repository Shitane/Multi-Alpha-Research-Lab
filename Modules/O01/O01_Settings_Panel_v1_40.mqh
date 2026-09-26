//+------------------------------------------------------------------+
//| O01_Settings_Panel_v1_40.mqh                                    |
//| STEP 1: fixed layout + appearance separated from trading logic.  |
//| Uses v1.33 settings behavior; adds v1.40 header/status identity.  |
//+------------------------------------------------------------------+
#ifndef O01_SETTINGS_PANEL_V1_40_MQH
#define O01_SETTINGS_PANEL_V1_40_MQH

#include "O01_Settings_Panel_v1_33.mqh"
#include "MultiAlpha_Foundation_v1_40.mqh"

class CO01SettingsPanel140
{
 private:
   CO01SettingsPanel133 legacy;
   string p;
   SMA140PanelTheme theme;
   SMA140StrategyIdentity identity;

   void Label(const string id,const int x,const int y,const string value,const color c,const int fs)
   {
      string n=p+id;
      if(ObjectFind(0,n)<0) ObjectCreate(0,n,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,n,OBJPROP_COLOR,c);
      ObjectSetInteger(0,n,OBJPROP_FONTSIZE,fs);
      ObjectSetString(0,n,OBJPROP_FONT,"Arial");
      ObjectSetString(0,n,OBJPROP_TEXT,value);
      ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,n,OBJPROP_ZORDER,5);
   }

   void DrawIdentity()
   {
      // Step 1 deliberately overlays only a compact architecture/status strip.
      // The v1.33 settings body remains unchanged for parity.
      Label("ARCH",18,4,"MULTI ALPHA v1.40 / STRATEGY INSTANCE",theme.section,theme.font_size);
      Label("INSTANCE",340,4,
            StringFormat("#%d  %s  E:%s M:%s X:%s",
                         identity.instance_id,
                         identity.symbol,
                         identity.entry_module,
                         identity.manage_module,
                         identity.exit_module),
            theme.text,theme.font_size);
   }

 public:
   void Create(const SO01RuntimeSettings110 &s,
               const SMA140StrategyIdentity &strategy_cfg,
               const SMA140PanelTheme &appearance)
   {
      p="O01CFG140_";
      identity=strategy_cfg;
      theme=appearance;
      legacy.Create(s);
      DrawIdentity();
      ChartRedraw();
   }

   void Delete()
   {
      legacy.Delete();
      ObjectsDeleteAll(0,p);
   }

   bool Pull(SO01RuntimeSettings110 &s)
   {
      return legacy.Pull(s);
   }

   int Event(const int id,const string name,SO01RuntimeSettings110 &s)
   {
      return legacy.Event(id,name,s);
   }

   void RefreshIdentity(const SMA140StrategyIdentity &strategy_cfg,
                        const SMA140PanelTheme &appearance)
   {
      identity=strategy_cfg;
      theme=appearance;
      DrawIdentity();
      ChartRedraw();
   }
};

#endif
