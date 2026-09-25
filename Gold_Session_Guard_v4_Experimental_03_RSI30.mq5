//+------------------------------------------------------------------+
//| Gold_Session_Guard_Demo_v4_OfficialTest.mq5                                   |
//| Independent demo-only XAUUSD EA for forward testing.             |
//| Uses common RSI/ATR/session/grid/risk-management techniques.      |
//| Designed as an original codebase for future multi-broker tests.  |
//+------------------------------------------------------------------+
#property strict
#property version   "4.60"
#property description "v4 Experimental 03: Stable 01 baseline with BUY RSI threshold changed from 20 to 30."

#include <Trade/Trade.mqh>
#include <Canvas/Canvas.mqh>

CTrade trade;

//------------------------------ Demo safety -------------------------
input bool   InpRestrictToGold           = true;     // Allow only symbols containing XAUUSD
input long   InpMagic                    = 46102030;  // Stable benchmark branch: separate history from Stable
input string InpComment                  = "GSG v4 EXP03 RSI30";

//------------------------------ Cycle / direction -------------------
input bool   InpNewCycles                = true;
input bool   InpTradeBuy                 = true;
input bool   InpTradeSell                = true;
input bool   InpAllowGridOutsideTime     = true;     // Manage/add to an existing cycle after End Hour

//------------------------------ Lots --------------------------------
input double InpInitialLot               = 0.01;
input double InpLotMultiplier            = 1.50;     // Risk guide recommends <= 1.5
input double InpMaxLot                   = 5.00;
input int    InpMaxBuyOrders             = 10;
input int    InpMaxSellOrders            = 10;
input double InpMaxTotalLotsPerSide      = 1.20;     // extra safety guard

//------------------------------ Entry signal ------------------------
input int    InpRSIPeriod                = 8;
input double InpRSIUpper                 = 70.0;     // Sell above
input double InpRSILower                 = 30.0;     // Buy below
input int    InpATRPeriod1               = 15;
input double InpATRMin1Points            = 0.0;
input double InpATRMax1Points            = 10000.0;
input int    InpATRPeriod2               = 15;
input ENUM_TIMEFRAMES InpATRTimeframe2   = PERIOD_CURRENT;
input double InpATRMin2Points            = 0.0;
input double InpATRMax2Points            = 10000.0;

//------------------------------ TP / SL ------------------------------
enum ENUM_SINGLE_TP_MODE
{
   SINGLE_TP_POINTS = 0,
   SINGLE_TP_MONEY  = 1
};
input ENUM_SINGLE_TP_MODE InpSingleTPMode = SINGLE_TP_POINTS;
input int    InpVirtualTPPointsSingle    = 110;      // v4 official test default: one-position TP from entry (points)
input double InpSingleTPMoney            = 15.0;     // optional account-currency target when SINGLE_TP_MONEY is selected
input int    InpBasketTPPoints           = 100;      // basket TP from weighted breakeven
input int    InpVirtualSLPoints          = 1500;     // basket emergency SL from weighted breakeven; 0=off
input bool   InpCloseOppositeOnTPorSL    = false;


//------------------------------ Trailing test -----------------------
// Virtual trailing: the EA watches price internally and closes market positions.
// No broker-side SL is placed. "Points" are symbol points (_Point).
enum ENUM_EXIT_MODE
{
   EXIT_FIXED_TP = 0,
   EXIT_TRAILING = 1
};

input ENUM_EXIT_MODE InpSingleExitMode   = EXIT_TRAILING;
input int    InpSingleTrailStartPoints   = 110;      // activate trailing after this favorable move
input int    InpSingleTrailLockPoints    = 60;       // minimum virtual locked profit after activation
input int    InpSingleTrailDistancePoints= 50;       // trail behind best favorable move
input int    InpSingleTrailStepPoints    = 10;       // raise trail only after peak improves by this much

input ENUM_EXIT_MODE InpBasketExitMode   = EXIT_TRAILING;
input int    InpBasketTrailStartPoints   = 100;      // from weighted basket breakeven
input int    InpBasketTrailLockPoints    = 50;
input int    InpBasketTrailDistancePoints= 50;
input int    InpBasketTrailStepPoints    = 10;

input bool   InpPauseGridWhileTrailing   = true;     // recommended for first v4.1 test

//------------------------------ Grid --------------------------------
input int    InpFixedDistancePoints      = 200;
input int    InpDynamicStartOrder        = 3;        // dynamic distance starts at this order number
input int    InpDynamicStartPoints       = 300;
input double InpDistanceMultiplier       = 1.20;
input bool   InpOneOrderPerBar           = true;

//------------------------------ Overlap -----------------------------
input bool   InpUseOverlap               = true;
input int    InpOverlapOrderNumber       = 8;
input double InpOverlapPercent           = 3.0;

//------------------------------ Time filter -------------------------
enum ENUM_TIME_MODE
{
   AUTO_GMT    = 0,   // Recommended for distribution: keep the same world-time session
   SERVER_TIME = 1,   // Advanced/testing: use broker server clock directly
   CUSTOM_GMT  = 2    // User-defined world-time session
};
input ENUM_TIME_MODE InpTimeMode         = AUTO_GMT;

// Recommended AUTO_GMT window.
// Current research baseline: Titan GMT+3 server 10:00-14:00 = GMT 07:00-11:00.
input int    InpAutoGMTStartHour         = 7;
input int    InpAutoGMTStartMinute       = 0;
input int    InpAutoGMTEndHour           = 11;
input int    InpAutoGMTEndMinute         = 0;

// SERVER_TIME manual window.
input int    InpServerStartHour          = 10;
input int    InpServerStartMinute        = 0;
input int    InpServerEndHour            = 14;
input int    InpServerEndMinute          = 0;

// CUSTOM_GMT manual world-time window.
input int    InpCustomGMTStartHour       = 7;
input int    InpCustomGMTStartMinute     = 0;
input int    InpCustomGMTEndHour         = 11;
input int    InpCustomGMTEndMinute       = 0;

// Weekday control.
input bool   InpTradeMonday              = true;
input bool   InpTradeTuesday             = true;
input bool   InpTradeWednesday           = true;
input bool   InpTradeThursday            = true;
input bool   InpTradeFriday              = true;

// Optional server-time block windows retained for research.
input bool   InpBlockMondayWindow        = false;
input int    InpMondayBlockStartHour     = 10;
input int    InpMondayBlockStartMinute   = 30;
input int    InpMondayBlockEndHour       = 11;
input int    InpMondayBlockEndMinute     = 0;
input bool   InpBlockFridayWindow        = false;
input int    InpFridayBlockStartHour     = 10;
input int    InpFridayBlockStartMinute   = 30;
input int    InpFridayBlockEndHour       = 11;
input int    InpFridayBlockEndMinute     = 30;

// If AUTO_GMT/CUSTOM_GMT cannot safely determine the server offset,
// stop NEW cycles instead of silently shifting the session.
input bool   InpGMTFailSafeStopNewCycles = true;

input bool   InpShowInfoPanel            = true;
input int    InpPanelOpacity             = 145;
input int    InpPanelRefreshMilliseconds = 2000;


//------------------------------ News filter -------------------------
// Uses the built-in MT5 Economic Calendar. No WebRequest URL is required.
enum ENUM_NEWS_STOP_MODE
{
   STOP_NEW_CYCLE_ONLY = 0, // no new initial cycle; existing grid may continue
   MANAGE_ONLY         = 1  // no new cycle + no new grid; TP/SL/Trailing/DD protection remain active
};

enum ENUM_NEWS_FAIL_MODE
{
   NEWS_FAIL_ALLOW_TRADING       = 0,
   NEWS_FAIL_STOP_NEW_CYCLE      = 1,
   NEWS_FAIL_MANAGE_ONLY         = 2
};

input bool   InpUseNewsFilter            = true;
input ENUM_NEWS_STOP_MODE InpNewsStopMode = MANAGE_ONLY;
input ENUM_NEWS_FAIL_MODE InpNewsFailMode = NEWS_FAIL_MANAGE_ONLY;

input bool   InpPauseHighImpact          = true;
input bool   InpPauseMediumImpact        = false;
input bool   InpPauseLowImpact           = false;

input int    InpHighBeforeMinutes        = 180;
input int    InpHighAfterMinutes         = 120;
input int    InpMediumBeforeMinutes      = 15;
input int    InpMediumAfterMinutes       = 15;
input int    InpLowBeforeMinutes         = 5;
input int    InpLowAfterMinutes          = 5;

input string InpNewsCountryCode          = "US";
input string InpNewsCurrency             = "USD";
input int    InpNewsLookAheadDays        = 7;
input int    InpNewsRefreshSeconds       = 30;

//------------------------------ Risk guard --------------------------
enum ENUM_DD_CALC_MODE
{
   BALANCE_EQUITY = 0,
   PEAK_EQUITY    = 1
};

enum ENUM_AFTER_EMERGENCY
{
   STOP_UNTIL_MANUAL_RESET = 0,
   STOP_UNTIL_NEXT_SESSION = 1,
   CONTINUE                 = 2
};

input ENUM_DD_CALC_MODE InpDDCalculationMode = BALANCE_EQUITY;

input bool   InpEnableWarning            = true;
input double InpWarningDDPercent         = 8.0;
input bool   InpEnableGridPause          = true;
input double InpPauseGridDDPercent       = 12.0;
input bool   InpEnableEmergencyClose     = true;
input double InpEmergencyCloseDDPercent  = 15.0;
input ENUM_AFTER_EMERGENCY InpAfterEmergency = STOP_UNTIL_NEXT_SESSION;

input int    InpMaxSpreadPoints          = 0;        // 0=off
input bool   InpPersistMaxDD              = true;
input bool   InpResetPersistentStats      = false;    // set true once, attach EA, then return to false
input bool   InpShowResetLockButton       = true;
input bool   InpEnableCloseReasonLog      = true;     // print detailed close reason to Experts/Journal

int rsiHandle  = INVALID_HANDLE;
int atr1Handle = INVALID_HANDLE;
int atr2Handle = INVALID_HANDLE;
datetime lastBuyOrderBar  = 0;
datetime lastSellOrderBar = 0;

//------------------------------ Dashboard / persistent runtime ------
double   g_peakEquityAllTime = 0.0;
double   g_riskPeakEquity    = 0.0;
double   g_maxDDPersistent   = 0.0;
double   g_maxDDMoney        = 0.0;
datetime g_maxDDTime         = 0;
double   g_todayProfitCache  = 0.0;
double   g_totalProfitCache  = 0.0;
datetime g_profitCacheTime   = 0;
bool     g_emergencyLock     = false;
datetime g_emergencyLockUntil= 0;
datetime g_resetArmTime      = 0;
string   g_lastState         = "INITIALIZING";
string   g_lastCloseReason   = "-";

string PANEL_PREFIX="GSG4E03_";
CCanvas g_panelCanvas;
bool    g_panelCanvasReady=false;
int     g_lastPanelOpacity=-1;
uint    g_lastPanelRefreshMs=0;

datetime g_newsLastRefresh=0;
bool     g_newsCalendarOK=true;
bool     g_newsPauseActive=false;
string   g_newsEventName="-";
string   g_newsImportance="-";
datetime g_newsEventTime=0;
datetime g_newsStopFrom=0;
datetime g_newsResumeAt=0;

bool   g_buyTrailActive=false;
bool   g_sellTrailActive=false;
double g_buyTrailPeakPts=0.0;
double g_sellTrailPeakPts=0.0;
double g_buyTrailStopPts=0.0;
double g_sellTrailStopPts=0.0;
int    g_buyTrailCount=0;
int    g_sellTrailCount=0;

//+------------------------------------------------------------------+
int OnInit()
{
   // Hard demo lock requested for this version.
   long trade_mode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
   if(trade_mode != ACCOUNT_TRADE_MODE_DEMO)
   {
      Print("Gold Session Guard Demo v4 Official Test: DEMO ACCOUNT ONLY. Initialization stopped.");
      return(INIT_FAILED);
   }

   if(InpRestrictToGold && StringFind(_Symbol,"XAUUSD") < 0)
   {
      Print("This demo version is restricted to XAUUSD symbols. Current symbol: ",_Symbol);
      return(INIT_FAILED);
   }

   if(InpInitialLot <= 0.0 || InpLotMultiplier < 1.0 || InpDistanceMultiplier < 1.0)
      return(INIT_PARAMETERS_INCORRECT);

   if(InpSingleTrailStartPoints<0 || InpSingleTrailLockPoints<0 ||
      InpSingleTrailDistancePoints<0 || InpSingleTrailStepPoints<0 ||
      InpBasketTrailStartPoints<0 || InpBasketTrailLockPoints<0 ||
      InpBasketTrailDistancePoints<0 || InpBasketTrailStepPoints<0)
      return(INIT_PARAMETERS_INCORRECT);

   rsiHandle  = iRSI(_Symbol,_Period,InpRSIPeriod,PRICE_CLOSE);
   atr1Handle = iATR(_Symbol,_Period,InpATRPeriod1);
   atr2Handle = iATR(_Symbol,InpATRTimeframe2,InpATRPeriod2);

   if(rsiHandle==INVALID_HANDLE || atr1Handle==INVALID_HANDLE || atr2Handle==INVALID_HANDLE)
   {
      Print("Indicator handle creation failed.");
      return(INIT_FAILED);
   }

   long margin_mode=AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   if(margin_mode!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
   {
      Print("Gold Session Guard Demo v4 Official Test requires a HEDGING account.");
      return(INIT_FAILED);
   }

   trade.SetExpertMagicNumber(InpMagic);
   trade.SetTypeFillingBySymbol(_Symbol);
   trade.SetAsyncMode(false);

   InitializePersistentState();
   RefreshClosedProfitStats(true);
   UpdateNewsInfo(true);
   CreateOrRefreshPanelObjects();

   Print("Gold Session Guard v4 Experimental 03 RSI30 initialized on ",_Symbol," ",EnumToString(_Period));
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   SavePersistentState();
   if(rsiHandle!=INVALID_HANDLE)  IndicatorRelease(rsiHandle);
   if(atr1Handle!=INVALID_HANDLE) IndicatorRelease(atr1Handle);
   if(atr2Handle!=INVALID_HANDLE) IndicatorRelease(atr2Handle);
   if(g_panelCanvasReady)
   {
      g_panelCanvas.Destroy();
      g_panelCanvasReady=false;
   }
   DeletePanelObjects();
   Comment("");
}

//+------------------------------------------------------------------+
void OnTick()
{
   UpdatePersistentMaxDD();
   UpdateEmergencyLockState();

   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      DrawStatus("AUTO TRADING DISABLED");
      return;
   }

   double dd=CurrentDrawdownPercent();

   // Emergency close is triggered only when this EA actually has open positions.
   if(InpEnableEmergencyClose && InpEmergencyCloseDDPercent>0.0 &&
      TotalEAOrders()>0 && dd>=InpEmergencyCloseDDPercent)
   {
      LogCloseReason("EMERGENCY_DD",POSITION_TYPE_BUY,TotalEAOrders(),0.0,0.0,0.0,CurrentFloatingEAProfit(),dd);
      CloseAllEA();
      ActivatePostEmergencyMode();
      DrawStatus("EMERGENCY CLOSE");
      return;
   }

   // Always manage existing positions, even outside the new-cycle session.
   ManageSide(POSITION_TYPE_BUY,dd);
   ManageSide(POSITION_TYPE_SELL,dd);

   if(g_emergencyLock)
   {
      DrawStatus("EMERGENCY LOCK");
      return;
   }

   bool newsNewCycleBlocked=NewsBlocksNewCycle();

   if(!InpNewCycles || !IsNewCycleTimeAllowed())
   {
      DrawStatus(newsNewCycleBlocked ? "MANAGING ONLY / NEWS STOP" : "MANAGING ONLY");
      return;
   }

   if(newsNewCycleBlocked)
   {
      DrawStatus(g_newsCalendarOK ? "NEWS STOP" : "NEWS DATA FAIL-SAFE");
      return;
   }

   if(!SpreadOK())
   {
      DrawStatus("SPREAD STOP");
      return;
   }

   if(!SignalFiltersOK())
   {
      DrawStatus("FILTER WAIT");
      return;
   }

   double rsi=GetBufferValue(rsiHandle,0);
   if(rsi==EMPTY_VALUE) return;

   if(InpTradeBuy && CountSide(POSITION_TYPE_BUY)==0 && rsi < InpRSILower)
      OpenInitial(POSITION_TYPE_BUY);

   if(InpTradeSell && CountSide(POSITION_TYPE_SELL)==0 && rsi > InpRSIUpper)
      OpenInitial(POSITION_TYPE_SELL);

   if(InpEnableWarning && InpWarningDDPercent>0.0 && dd>=InpWarningDDPercent)
      DrawStatus("ACTIVE - DD WARNING");
   else
      DrawStatus("ACTIVE");
}

//+------------------------------------------------------------------+
void ResetTrailState(const ENUM_POSITION_TYPE side)
{
   if(side==POSITION_TYPE_BUY)
   {
      g_buyTrailActive=false; g_buyTrailPeakPts=0.0; g_buyTrailStopPts=0.0; g_buyTrailCount=0;
   }
   else
   {
      g_sellTrailActive=false; g_sellTrailPeakPts=0.0; g_sellTrailStopPts=0.0; g_sellTrailCount=0;
   }
}

bool TrailIsActive(const ENUM_POSITION_TYPE side)
{
   return (side==POSITION_TYPE_BUY ? g_buyTrailActive : g_sellTrailActive);
}

double TrailPeakPts(const ENUM_POSITION_TYPE side)
{
   return (side==POSITION_TYPE_BUY ? g_buyTrailPeakPts : g_sellTrailPeakPts);
}

double TrailStopPts(const ENUM_POSITION_TYPE side)
{
   return (side==POSITION_TYPE_BUY ? g_buyTrailStopPts : g_sellTrailStopPts);
}

void SetTrailState(const ENUM_POSITION_TYPE side,const bool active,const double peak,const double stop,const int count)
{
   if(side==POSITION_TYPE_BUY)
   {
      g_buyTrailActive=active; g_buyTrailPeakPts=peak; g_buyTrailStopPts=stop; g_buyTrailCount=count;
   }
   else
   {
      g_sellTrailActive=active; g_sellTrailPeakPts=peak; g_sellTrailStopPts=stop; g_sellTrailCount=count;
   }
}

// Returns true if trailing closed the side.
bool ManageVirtualTrailing(const ENUM_POSITION_TYPE side,const int count,const double avg,
                           const double px,const double movePts,const double dd)
{
   bool single=(count==1);
   ENUM_EXIT_MODE mode=(single ? InpSingleExitMode : InpBasketExitMode);
   if(mode!=EXIT_TRAILING)
   {
      ResetTrailState(side);
      return false;
   }

   int startPts=(single ? InpSingleTrailStartPoints : InpBasketTrailStartPoints);
   int lockPts =(single ? InpSingleTrailLockPoints  : InpBasketTrailLockPoints);
   int distPts =(single ? InpSingleTrailDistancePoints : InpBasketTrailDistancePoints);
   int stepPts =(single ? InpSingleTrailStepPoints : InpBasketTrailStepPoints);

   bool active=TrailIsActive(side);
   double peak=TrailPeakPts(side);
   double stop=TrailStopPts(side);

   // If grid is allowed during trailing and the basket composition changed,
   // restart trailing from the new weighted breakeven to avoid using stale levels.
   int storedCount=(side==POSITION_TYPE_BUY ? g_buyTrailCount : g_sellTrailCount);
   if(active && storedCount!=count)
   {
      active=false; peak=0.0; stop=0.0;
   }

   if(!active)
   {
      if(startPts>0 && movePts>=startPts)
      {
         active=true;
         peak=movePts;
         stop=MathMax((double)lockPts,peak-(double)distPts);
         SetTrailState(side,true,peak,stop,count);
         Print("[GSG TRAIL] activated side=",EnumToString(side),
               " mode=",(single ? "SINGLE" : "BASKET"),
               " orders=",count,
               " move_pts=",DoubleToString(movePts,1),
               " stop_pts=",DoubleToString(stop,1));
      }
      else
      {
         SetTrailState(side,false,0.0,0.0,count);
         return false;
      }
   }
   else
   {
      // Peak only moves in the profitable direction. Step prevents tiny tick-by-tick updates.
      if(movePts>peak && (stepPts<=0 || movePts-peak>=stepPts))
      {
         peak=movePts;
         double candidate=MathMax((double)lockPts,peak-(double)distPts);
         if(candidate>stop) stop=candidate;
         SetTrailState(side,true,peak,stop,count);
      }
   }

   // Close only after activation and a retracement to the virtual trail.
   if(active && movePts<=stop)
   {
      string reason=(single ? "SINGLE_TRAILING" : "BASKET_TRAILING");
      LogCloseReason(reason,side,count,avg,px,movePts,SideFloatingProfit(side),dd);
      Print("[GSG TRAIL] exit side=",EnumToString(side),
            " peak_pts=",DoubleToString(peak,1),
            " trail_pts=",DoubleToString(stop,1),
            " exit_move_pts=",DoubleToString(movePts,1));
      CloseSide(side);
      ResetTrailState(side);
      return true;
   }

   return false;
}

//+------------------------------------------------------------------+
void ManageSide(const ENUM_POSITION_TYPE side,const double dd)
{
   int count=CountSide(side);
   if(count<=0)
   {
      ResetTrailState(side);
      return;
   }

   double avg=WeightedAveragePrice(side);
   if(avg<=0.0) return;

   MqlTick tick;
   if(!SymbolInfoTick(_Symbol,tick)) return;
   double px=(side==POSITION_TYPE_BUY ? tick.bid : tick.ask);
   double movePts=(side==POSITION_TYPE_BUY ? (px-avg)/_Point : (avg-px)/_Point);

   // Virtual SL remains independent from the profit-exit mode.
   bool slHit=false;
   if(side==POSITION_TYPE_BUY)
      slHit=(InpVirtualSLPoints>0 && px <= avg - InpVirtualSLPoints*_Point);
   else
      slHit=(InpVirtualSLPoints>0 && px >= avg + InpVirtualSLPoints*_Point);

   if(slHit)
   {
      LogCloseReason("VIRTUAL_SL",side,count,avg,px,movePts,SideFloatingProfit(side),dd);
      CloseSide(side);
      ResetTrailState(side);
      if(InpCloseOppositeOnTPorSL)
      {
         ENUM_POSITION_TYPE opp=(side==POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY);
         if(CountSide(opp)>0)
         {
            LogCloseReason("OPPOSITE_CLOSE_AFTER_VIRTUAL_SL",opp,CountSide(opp),WeightedAveragePrice(opp),
                           (opp==POSITION_TYPE_BUY ? tick.bid : tick.ask),0.0,SideFloatingProfit(opp),dd);
            CloseSide(opp);
            ResetTrailState(opp);
         }
      }
      return;
   }

   bool single=(count==1);
   ENUM_EXIT_MODE exitMode=(single ? InpSingleExitMode : InpBasketExitMode);

   if(exitMode==EXIT_TRAILING)
   {
      if(ManageVirtualTrailing(side,count,avg,px,movePts,dd))
      {
         if(InpCloseOppositeOnTPorSL)
         {
            ENUM_POSITION_TYPE opp=(side==POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY);
            if(CountSide(opp)>0)
            {
               LogCloseReason("OPPOSITE_CLOSE_AFTER_TRAILING",opp,CountSide(opp),WeightedAveragePrice(opp),
                              (opp==POSITION_TYPE_BUY ? tick.bid : tick.ask),0.0,SideFloatingProfit(opp),dd);
               CloseSide(opp);
               ResetTrailState(opp);
            }
         }
         return;
      }
   }
   else
   {
      ResetTrailState(side);

      int tpPts=(single ? InpVirtualTPPointsSingle : InpBasketTPPoints);
      bool tpHit=false;
      if(single && InpSingleTPMode==SINGLE_TP_MONEY)
         tpHit=(InpSingleTPMoney>0.0 && SideFloatingProfit(side) >= InpSingleTPMoney);
      else if(side==POSITION_TYPE_BUY)
         tpHit=(tpPts>0 && px >= avg + tpPts*_Point);
      else
         tpHit=(tpPts>0 && px <= avg - tpPts*_Point);

      if(tpHit)
      {
         string reason;
         if(single && InpSingleTPMode==SINGLE_TP_MONEY) reason="SINGLE_TP_MONEY";
         else if(single) reason="SINGLE_TP_POINTS";
         else reason="BASKET_TP";

         LogCloseReason(reason,side,count,avg,px,movePts,SideFloatingProfit(side),dd);
         CloseSide(side);
         if(InpCloseOppositeOnTPorSL)
         {
            ENUM_POSITION_TYPE opp=(side==POSITION_TYPE_BUY ? POSITION_TYPE_SELL : POSITION_TYPE_BUY);
            if(CountSide(opp)>0)
            {
               LogCloseReason("OPPOSITE_CLOSE_AFTER_"+reason,opp,CountSide(opp),WeightedAveragePrice(opp),
                              (opp==POSITION_TYPE_BUY ? tick.bid : tick.ask),0.0,SideFloatingProfit(opp),dd);
               CloseSide(opp);
               ResetTrailState(opp);
            }
         }
         return;
      }
   }

   if(InpUseOverlap && count>=InpOverlapOrderNumber)
      TryOverlap(side);

   count=CountSide(side);
   if(count<=0)
   {
      ResetTrailState(side);
      return;
   }

   int maxOrders=(side==POSITION_TYPE_BUY ? InpMaxBuyOrders : InpMaxSellOrders);
   if(count>=maxOrders) return;
   if(InpEnableGridPause && InpPauseGridDDPercent>0.0 && dd>=InpPauseGridDDPercent) return;
   if(InpPauseGridWhileTrailing && TrailIsActive(side)) return;
   if(!InpAllowGridOutsideTime && !IsNewCycleTimeAllowed()) return;
   if(NewsBlocksGrid() || !SpreadOK()) return;
   if(InpOneOrderPerBar && AlreadyOrderedThisBar(side)) return;

   double lastPrice=NewestPositionOpenPrice(side);
   if(lastPrice<=0.0) return;

   int nextOrder=count+1;
   double distancePts=RequiredDistancePoints(nextOrder);
   MqlTick t;
   if(!SymbolInfoTick(_Symbol,t)) return;

   bool distanceMet=false;
   if(side==POSITION_TYPE_BUY)
      distanceMet=(t.ask <= lastPrice - distancePts*_Point);
   else
      distanceMet=(t.bid >= lastPrice + distancePts*_Point);

   if(!distanceMet) return;

   double lot=NextLot(side);
   if(lot<=0.0) return;

   double total=TotalLots(side);
   if(InpMaxTotalLotsPerSide>0.0 && total+lot > InpMaxTotalLotsPerSide+1e-9)
   {
      Print("Grid blocked by MaxTotalLotsPerSide. side=",EnumToString(side)," total=",total," next=",lot);
      return;
   }

   OpenMarket(side,lot,"GRID #"+IntegerToString(nextOrder));
}

//+------------------------------------------------------------------+
bool OpenInitial(const ENUM_POSITION_TYPE side)
{
   if(InpOneOrderPerBar && AlreadyOrderedThisBar(side)) return false;
   return OpenMarket(side,NormalizeLot(InpInitialLot),"INITIAL");
}

//+------------------------------------------------------------------+
bool OpenMarket(const ENUM_POSITION_TYPE side,const double lot,const string tag)
{
   if(lot<=0.0 || !SpreadOK()) return false;
   bool ok=false;
   string cmt=InpComment+" "+tag;
   if(side==POSITION_TYPE_BUY)
      ok=trade.Buy(lot,_Symbol,0,0,0,cmt);
   else
      ok=trade.Sell(lot,_Symbol,0,0,0,cmt);

   if(ok)
   {
      datetime bar=iTime(_Symbol,_Period,0);
      if(side==POSITION_TYPE_BUY) lastBuyOrderBar=bar; else lastSellOrderBar=bar;
   }
   else
      Print("Order failed: ",trade.ResultRetcode()," ",trade.ResultRetcodeDescription());
   return ok;
}

//+------------------------------------------------------------------+
bool SignalFiltersOK()
{
   double a1=GetBufferValue(atr1Handle,0);
   double a2=GetBufferValue(atr2Handle,0);
   if(a1==EMPTY_VALUE || a2==EMPTY_VALUE) return false;
   double p1=a1/_Point;
   double p2=a2/_Point;
   return (p1>=InpATRMin1Points && p1<=InpATRMax1Points &&
           p2>=InpATRMin2Points && p2<=InpATRMax2Points);
}

//+------------------------------------------------------------------+
double GetBufferValue(const int handle,const int shift)
{
   double buf[1];
   if(CopyBuffer(handle,0,shift,1,buf)!=1) return EMPTY_VALUE;
   return buf[0];
}

//+------------------------------------------------------------------+
int CountSide(const ENUM_POSITION_TYPE side)
{
   int n=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      n++;
   }
   return n;
}

//+------------------------------------------------------------------+
double TotalLots(const ENUM_POSITION_TYPE side)
{
   double v=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      v+=PositionGetDouble(POSITION_VOLUME);
   }
   return v;
}

//+------------------------------------------------------------------+
double WeightedAveragePrice(const ENUM_POSITION_TYPE side)
{
   double sumPV=0.0,sumV=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      double v=PositionGetDouble(POSITION_VOLUME);
      sumV+=v;
      sumPV+=v*PositionGetDouble(POSITION_PRICE_OPEN);
   }
   return (sumV>0.0 ? sumPV/sumV : 0.0);
}

//+------------------------------------------------------------------+
double NewestPositionOpenPrice(const ENUM_POSITION_TYPE side)
{
   datetime newest=0;
   double price=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      datetime tm=(datetime)PositionGetInteger(POSITION_TIME);
      if(tm>=newest)
      {
         newest=tm;
         price=PositionGetDouble(POSITION_PRICE_OPEN);
      }
   }
   return price;
}

//+------------------------------------------------------------------+
double NextLot(const ENUM_POSITION_TYPE side)
{
   // Apply multiplier to latest position lot, matching observed series behaviour.
   datetime newest=0;
   double lastLot=InpInitialLot;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      datetime tm=(datetime)PositionGetInteger(POSITION_TIME);
      if(tm>=newest)
      {
         newest=tm;
         lastLot=PositionGetDouble(POSITION_VOLUME);
      }
   }
   return NormalizeLot(MathMin(InpMaxLot,lastLot*InpLotMultiplier));
}

//+------------------------------------------------------------------+
double NormalizeLot(double lot)
{
   double minv=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double maxv=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double step=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(step<=0.0) step=0.01;
   lot=MathMax(minv,MathMin(maxv,lot));
   // Original observed lots are rounded to nearest broker step rather than always floored.
   lot=MathRound(lot/step)*step;
   int digits=(int)MathMax(0,MathRound(-MathLog10(step)));
   return NormalizeDouble(lot,digits);
}

//+------------------------------------------------------------------+
double RequiredDistancePoints(const int nextOrder)
{
   if(nextOrder < InpDynamicStartOrder)
      return (double)InpFixedDistancePoints;
   int power=nextOrder-InpDynamicStartOrder;
   return (double)InpDynamicStartPoints*MathPow(InpDistanceMultiplier,power);
}

//+------------------------------------------------------------------+
bool AlreadyOrderedThisBar(const ENUM_POSITION_TYPE side)
{
   datetime bar=iTime(_Symbol,_Period,0);
   return (side==POSITION_TYPE_BUY ? lastBuyOrderBar==bar : lastSellOrderBar==bar);
}

//+------------------------------------------------------------------+
void TryOverlap(const ENUM_POSITION_TYPE side)
{
   ulong oldestTicket=0,newestTicket=0;
   datetime oldest=LONG_MAX,newest=0;
   double oldestProfit=0.0,newestProfit=0.0;

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      datetime tm=(datetime)PositionGetInteger(POSITION_TIME);
      double pf=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      if(tm<oldest){oldest=tm; oldestTicket=ticket; oldestProfit=pf;}
      if(tm>=newest){newest=tm; newestTicket=ticket; newestProfit=pf;}
   }

   if(oldestTicket==0 || newestTicket==0 || oldestTicket==newestTicket) return;
   if(oldestProfit>=0.0 || newestProfit<=0.0) return;

   double needed=MathAbs(oldestProfit)*(1.0+InpOverlapPercent/100.0);
   if(newestProfit>=needed)
   {
      // Close newest winner first, then oldest loser.
      if(InpEnableCloseReasonLog)
         Print("[GSG CLOSE] reason=OVERLAP side=",EnumToString(side),
               " oldest_ticket=",oldestTicket," oldest_pl=",DoubleToString(oldestProfit,2),
               " newest_ticket=",newestTicket," newest_pl=",DoubleToString(newestProfit,2),
               " overlap_percent=",DoubleToString(InpOverlapPercent,2));
      g_lastCloseReason="OVERLAP";
      bool a=trade.PositionClose(newestTicket);
      bool b=trade.PositionClose(oldestTicket);
      if(!(a && b)) Print("Overlap close failed: ",trade.ResultRetcode()," ",trade.ResultRetcodeDescription());
   }
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void LogCloseReason(const string reason,const ENUM_POSITION_TYPE side,const int count,
                    const double avg,const double px,const double movePts,
                    const double floating,const double dd)
{
   g_lastCloseReason=reason;
   if(!InpEnableCloseReasonLog) return;

   MqlTick t;
   double spreadPts=0.0;
   if(SymbolInfoTick(_Symbol,t)) spreadPts=(t.ask-t.bid)/_Point;

   Print("[GSG CLOSE] reason=",reason,
         " side=",EnumToString(side),
         " orders=",count,
         " avg=",DoubleToString(avg,_Digits),
         " close_px=",DoubleToString(px,_Digits),
         " move_pts=",DoubleToString(movePts,1),
         " floating=",DoubleToString(floating,2),
         " dd=",DoubleToString(dd,2),"%",
         " spread_pts=",DoubleToString(spreadPts,1),
         " server_time=",TimeToString(TimeTradeServer(),TIME_DATE|TIME_SECONDS));
}

void CloseSide(const ENUM_POSITION_TYPE side)
{
   ulong tickets[];
   ArrayResize(tickets,0);
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      int n=ArraySize(tickets); ArrayResize(tickets,n+1); tickets[n]=ticket;
   }
   for(int j=0;j<ArraySize(tickets);j++) trade.PositionClose(tickets[j]);
}

//+------------------------------------------------------------------+
void CloseAllEA()
{
   ulong tickets[];
   ArrayResize(tickets,0);
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol || PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      int n=ArraySize(tickets); ArrayResize(tickets,n+1); tickets[n]=ticket;
   }
   for(int j=0;j<ArraySize(tickets);j++) trade.PositionClose(tickets[j]);
   ResetTrailState(POSITION_TYPE_BUY);
   ResetTrailState(POSITION_TYPE_SELL);
}

//+------------------------------------------------------------------+
double CurrentDrawdownPercent()
{
   double eq=AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq<=0.0) return 0.0;

   if(InpDDCalculationMode==PEAK_EQUITY)
   {
      if(g_riskPeakEquity<=0.0 || eq>g_riskPeakEquity)
      {
         g_riskPeakEquity=eq;
         SavePersistentState();
      }
      if(g_riskPeakEquity<=0.0) return 0.0;
      return MathMax(0.0,(g_riskPeakEquity-eq)/g_riskPeakEquity*100.0);
   }

   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   if(bal<=0.0) return 0.0;
   return MathMax(0.0,(bal-eq)/bal*100.0);
}

//+------------------------------------------------------------------+
bool SpreadOK()
{
   if(InpMaxSpreadPoints<=0) return true;
   MqlTick t;
   if(!SymbolInfoTick(_Symbol,t)) return false;
   double spr=(t.ask-t.bid)/_Point;
   return spr<=InpMaxSpreadPoints;
}

//+------------------------------------------------------------------+
double DetectServerGMTOffsetHours()
{
   datetime server=TimeTradeServer();
   datetime gmt=TimeGMT();
   if(server<=0 || gmt<=0) return 0.0;
   // Round to 15 minutes to avoid a few seconds of clock skew.
   double hours=(double)(server-gmt)/3600.0;
   return MathRound(hours*4.0)/4.0;
}

int NormalizeMinutes(int m)
{
   while(m<0) m+=1440;
   while(m>=1440) m-=1440;
   return m;
}

bool GetServerGMTOffset(double &offsetHours)
{
   datetime server=TimeTradeServer();
   datetime gmt=TimeGMT();
   if(server<=0 || gmt<=0)
   {
      offsetHours=0.0;
      return false;
   }

   double hours=(double)(server-gmt)/3600.0;
   if(MathAbs(hours)>14.0)
   {
      offsetHours=0.0;
      return false;
   }

   offsetHours=MathRound(hours*4.0)/4.0;
   return true;
}

void EffectiveServerWindow(int &startMin,int &endMin)
{
   if(InpTimeMode==SERVER_TIME)
   {
      startMin=NormalizeMinutes(InpServerStartHour*60+InpServerStartMinute);
      endMin  =NormalizeMinutes(InpServerEndHour*60+InpServerEndMinute);
      return;
   }

   int gmtStart,gmtEnd;
   if(InpTimeMode==CUSTOM_GMT)
   {
      gmtStart=InpCustomGMTStartHour*60+InpCustomGMTStartMinute;
      gmtEnd  =InpCustomGMTEndHour*60+InpCustomGMTEndMinute;
   }
   else
   {
      gmtStart=InpAutoGMTStartHour*60+InpAutoGMTStartMinute;
      gmtEnd  =InpAutoGMTEndHour*60+InpAutoGMTEndMinute;
   }

   double serverGMT=0.0;
   if(!GetServerGMTOffset(serverGMT))
   {
      // Values are only for display/fallback. IsNewCycleTimeAllowed()
      // applies the configured GMT fail-safe.
      startMin=NormalizeMinutes(gmtStart);
      endMin=NormalizeMinutes(gmtEnd);
      return;
   }

   int shift=(int)MathRound(serverGMT*60.0);
   startMin=NormalizeMinutes(gmtStart+shift);
   endMin=NormalizeMinutes(gmtEnd+shift);
}

bool IsMinuteInWindow(const int mins,const int s,const int e)
{
   if(s==e) return true;
   if(s<e) return (mins>=s && mins<e);
   return (mins>=s || mins<e);
}

bool WeekdayEnabled(const int dow)
{
   if(dow==1) return InpTradeMonday;
   if(dow==2) return InpTradeTuesday;
   if(dow==3) return InpTradeWednesday;
   if(dow==4) return InpTradeThursday;
   if(dow==5) return InpTradeFriday;
   return false; // Saturday/Sunday
}

bool IsNewCycleTimeAllowed()
{
   if(InpTimeMode!=SERVER_TIME && InpGMTFailSafeStopNewCycles)
   {
      double off=0.0;
      if(!GetServerGMTOffset(off))
         return false;
   }

   MqlDateTime dt;
   TimeToStruct(TimeTradeServer(),dt);

   if(!WeekdayEnabled(dt.day_of_week))
      return false;

   int mins=dt.hour*60+dt.min;
   int s,e; EffectiveServerWindow(s,e);
   if(!IsMinuteInWindow(mins,s,e)) return false;

   // Optional research block windows remain SERVER-TIME windows.
   if(dt.day_of_week==1 && InpBlockMondayWindow)
   {
      int bs=InpMondayBlockStartHour*60+InpMondayBlockStartMinute;
      int be=InpMondayBlockEndHour*60+InpMondayBlockEndMinute;
      if(IsMinuteInWindow(mins,bs,be)) return false;
   }
   if(dt.day_of_week==5 && InpBlockFridayWindow)
   {
      int bs=InpFridayBlockStartHour*60+InpFridayBlockStartMinute;
      int be=InpFridayBlockEndHour*60+InpFridayBlockEndMinute;
      if(IsMinuteInWindow(mins,bs,be)) return false;
   }
   return true;
}

string HHMM(const int mins)
{
   int m=NormalizeMinutes(mins);
   return StringFormat("%02d:%02d",m/60,m%60);
}

string TimeModeText()
{
   if(InpTimeMode==SERVER_TIME) return "SERVER_TIME";
   if(InpTimeMode==CUSTOM_GMT)  return "CUSTOM_GMT";
   return "AUTO_GMT";
}

string ImportanceText(const ENUM_CALENDAR_EVENT_IMPORTANCE imp)
{
   if(imp==CALENDAR_IMPORTANCE_HIGH)     return "HIGH";
   if(imp==CALENDAR_IMPORTANCE_MODERATE) return "MEDIUM";
   if(imp==CALENDAR_IMPORTANCE_LOW)      return "LOW";
   return "NONE";
}

bool ImportanceSettings(const ENUM_CALENDAR_EVENT_IMPORTANCE imp,bool &enabled,int &before,int &after)
{
   enabled=false; before=0; after=0;
   if(imp==CALENDAR_IMPORTANCE_HIGH)
   {
      enabled=InpPauseHighImpact; before=InpHighBeforeMinutes; after=InpHighAfterMinutes;
      return true;
   }
   if(imp==CALENDAR_IMPORTANCE_MODERATE)
   {
      enabled=InpPauseMediumImpact; before=InpMediumBeforeMinutes; after=InpMediumAfterMinutes;
      return true;
   }
   if(imp==CALENDAR_IMPORTANCE_LOW)
   {
      enabled=InpPauseLowImpact; before=InpLowBeforeMinutes; after=InpLowAfterMinutes;
      return true;
   }
   return false;
}

string ShortText(const string s,const int maxLen)
{
   if(StringLen(s)<=maxLen) return s;
   if(maxLen<=3) return StringSubstr(s,0,maxLen);
   return StringSubstr(s,0,maxLen-3)+"...";
}

void ClearNewsInfo()
{
   g_newsPauseActive=false;
   g_newsEventName="-";
   g_newsImportance="-";
   g_newsEventTime=0;
   g_newsStopFrom=0;
   g_newsResumeAt=0;
}

void UpdateNewsInfo(const bool force=false)
{
   if(!InpUseNewsFilter)
   {
      g_newsCalendarOK=true;
      ClearNewsInfo();
      return;
   }

   datetime localNow=TimeLocal();
   if(!force && g_newsLastRefresh>0 &&
      localNow-g_newsLastRefresh<MathMax(5,InpNewsRefreshSeconds))
      return;

   g_newsLastRefresh=localNow;
   ClearNewsInfo();

   int maxAfter=MathMax(InpHighAfterMinutes,MathMax(InpMediumAfterMinutes,InpLowAfterMinutes));
   datetime now=TimeTradeServer();
   datetime from=now-maxAfter*60;
   datetime to=now+(datetime)MathMax(1,InpNewsLookAheadDays)*86400;

   MqlCalendarValue values[];
   ResetLastError();
   int n=CalendarValueHistory(values,from,to,InpNewsCountryCode,InpNewsCurrency);

   if(n<0)
   {
      g_newsCalendarOK=false;
      g_newsEventName="CALENDAR DATA ERROR";
      Print("Economic calendar query failed. error=",GetLastError());
      return;
   }

   g_newsCalendarOK=true;

   bool activeFound=false;
   datetime bestActiveTime=0;
   datetime bestNextTime=0;
   string nextName="-",nextImportance="-";
   datetime nextStop=0,nextResume=0;

   for(int i=0;i<n;i++)
   {
      MqlCalendarEvent ev;
      if(!CalendarEventById(values[i].event_id,ev))
         continue;

      bool enabled=false;
      int before=0,after=0;
      if(!ImportanceSettings(ev.importance,enabled,before,after) || !enabled)
         continue;

      datetime et=values[i].time;
      datetime stopFrom=et-before*60;
      datetime resumeAt=et+after*60;

      if(now>=stopFrom && now<=resumeAt)
      {
         // If windows overlap, show the event closest to now.
         if(!activeFound || MathAbs((long)(et-now))<MathAbs((long)(bestActiveTime-now)))
         {
            activeFound=true;
            bestActiveTime=et;
            g_newsPauseActive=true;
            g_newsEventName=ShortText(ev.name,48);
            g_newsImportance=ImportanceText(ev.importance);
            g_newsEventTime=et;
            g_newsStopFrom=stopFrom;
            g_newsResumeAt=resumeAt;
         }
      }
      else if(et>now)
      {
         if(bestNextTime==0 || et<bestNextTime)
         {
            bestNextTime=et;
            nextName=ShortText(ev.name,48);
            nextImportance=ImportanceText(ev.importance);
            nextStop=stopFrom;
            nextResume=resumeAt;
         }
      }
   }

   if(!activeFound && bestNextTime>0)
   {
      g_newsEventName=nextName;
      g_newsImportance=nextImportance;
      g_newsEventTime=bestNextTime;
      g_newsStopFrom=nextStop;
      g_newsResumeAt=nextResume;
   }
}

bool NewsFailBlocksNewCycle()
{
   if(g_newsCalendarOK) return false;
   return (InpNewsFailMode==NEWS_FAIL_STOP_NEW_CYCLE ||
           InpNewsFailMode==NEWS_FAIL_MANAGE_ONLY);
}

bool NewsFailBlocksGrid()
{
   if(g_newsCalendarOK) return false;
   return (InpNewsFailMode==NEWS_FAIL_MANAGE_ONLY);
}

bool NewsBlocksNewCycle()
{
   if(!InpUseNewsFilter) return false;
   UpdateNewsInfo(false);
   if(!g_newsCalendarOK) return NewsFailBlocksNewCycle();
   return g_newsPauseActive;
}

bool NewsBlocksGrid()
{
   if(!InpUseNewsFilter) return false;
   UpdateNewsInfo(false);
   if(!g_newsCalendarOK) return NewsFailBlocksGrid();
   return (g_newsPauseActive && InpNewsStopMode==MANAGE_ONLY);
}

string NewsStatusText()
{
   if(!InpUseNewsFilter) return "OFF";
   UpdateNewsInfo(false);
   if(!g_newsCalendarOK) return "CALENDAR ERROR";
   if(g_newsPauseActive) return "NEWS STOP";
   return "CLEAR";
}

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double DealNetProfit(const ulong dealTicket)
{
   return HistoryDealGetDouble(dealTicket,DEAL_PROFIT)
        + HistoryDealGetDouble(dealTicket,DEAL_SWAP)
        + HistoryDealGetDouble(dealTicket,DEAL_COMMISSION)
        + HistoryDealGetDouble(dealTicket,DEAL_FEE);
}

//+------------------------------------------------------------------+
double ClosedEAProfit(const datetime from,const datetime to)
{
   if(!HistorySelect(from,to)) return 0.0;
   double total=0.0;
   int n=HistoryDealsTotal();
   for(int i=0;i<n;i++)
   {
      ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0) continue;
      if(HistoryDealGetString(ticket,DEAL_SYMBOL)!=_Symbol) continue;
      if((long)HistoryDealGetInteger(ticket,DEAL_MAGIC)!=InpMagic) continue;
      ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
      if(entry!=DEAL_ENTRY_OUT && entry!=DEAL_ENTRY_OUT_BY && entry!=DEAL_ENTRY_INOUT) continue;
      total+=DealNetProfit(ticket);
   }
   return total;
}

//+------------------------------------------------------------------+
void RefreshClosedProfitStats(const bool force=false)
{
   datetime now=TimeTradeServer();
   if(!force && g_profitCacheTime>0 && now-g_profitCacheTime<5) return;

   MqlDateTime dt;
   TimeToStruct(now,dt);
   dt.hour=0; dt.min=0; dt.sec=0;
   datetime dayStart=StructToTime(dt);

   g_todayProfitCache=ClosedEAProfit(dayStart,now);
   g_totalProfitCache=ClosedEAProfit((datetime)0,now);
   g_profitCacheTime=now;
}

//+------------------------------------------------------------------+
void UpdatePersistentMaxDD()
{
   double eq=AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq<=0.0) return;

   bool changed=false;
   if(g_peakEquityAllTime<=0.0 || eq>g_peakEquityAllTime)
   {
      g_peakEquityAllTime=eq;
      changed=true;
   }
   if(g_riskPeakEquity<=0.0 || eq>g_riskPeakEquity)
   {
      g_riskPeakEquity=eq;
      changed=true;
   }

   if(g_peakEquityAllTime>0.0)
   {
      double loss=MathMax(0.0,g_peakEquityAllTime-eq);
      double dd=loss/g_peakEquityAllTime*100.0;
      if(dd>g_maxDDPersistent)
      {
         g_maxDDPersistent=dd;
         g_maxDDMoney=loss;
         g_maxDDTime=TimeTradeServer();
         changed=true;
      }
   }
   if(changed) SavePersistentState();
}

//+------------------------------------------------------------------+
double SideFloatingProfit(const ENUM_POSITION_TYPE side)
{
   double v=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      if((ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE)!=side) continue;
      v+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   }
   return v;
}

//+------------------------------------------------------------------+
double CurrentFloatingEAProfit()
{
   double v=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      v+=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
   }
   return v;
}

//+------------------------------------------------------------------+
double LargestCurrentLot()
{
   double mx=0.0;
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0 || !PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;
      mx=MathMax(mx,PositionGetDouble(POSITION_VOLUME));
   }
   return mx;
}

//+------------------------------------------------------------------+
string CurrentCycleText()
{
   int b=CountSide(POSITION_TYPE_BUY);
   int s=CountSide(POSITION_TYPE_SELL);
   if(b>0 && s>0) return "BUY + SELL";
   if(b>0) return "BUY";
   if(s>0) return "SELL";
   return "NONE";
}

//+------------------------------------------------------------------+
datetime ServerDateAtMinutes(const datetime base,const int mins)
{
   MqlDateTime dt;
   TimeToStruct(base,dt);
   int m=NormalizeMinutes(mins);
   dt.hour=m/60; dt.min=m%60; dt.sec=0;
   return StructToTime(dt);
}

//+------------------------------------------------------------------+
bool IsWeekend(const datetime t)
{
   MqlDateTime dt; TimeToStruct(t,dt);
   return (dt.day_of_week==0 || dt.day_of_week==6);
}

//+------------------------------------------------------------------+
datetime NextWeekdayAt(datetime t,const int mins)
{
   datetime d=ServerDateAtMinutes(t,mins);
   while(IsWeekend(d)) d+=86400;
   return d;
}

//+------------------------------------------------------------------+
void NextSessionTimes(datetime &nextStart,datetime &nextEnd)
{
   datetime now=TimeTradeServer();
   int ws,we; EffectiveServerWindow(ws,we);
   int span=(we-ws+1440)%1440;
   if(span==0) span=1440;

   datetime startToday=ServerDateAtMinutes(now,ws);
   datetime endForStart=startToday+span*60;

   if(now<startToday)
   {
      nextStart=NextWeekdayAt(startToday,ws);
      nextEnd=nextStart+span*60;
      return;
   }

   if(now<endForStart)
   {
      datetime tomorrow=startToday+86400;
      nextStart=NextWeekdayAt(tomorrow,ws);
      nextEnd=endForStart;
      return;
   }

   datetime tomorrow=startToday+86400;
   nextStart=NextWeekdayAt(tomorrow,ws);
   nextEnd=nextStart+span*60;
}

//+------------------------------------------------------------------+
string MoneyText(const double v)
{
   string sign=(v>0.0 ? "+" : "");
   return sign+DoubleToString(v,0)+" "+AccountInfoString(ACCOUNT_CURRENCY);
}

//+------------------------------------------------------------------+
string GVBase()
{
   return "GSG4E03_"+IntegerToString((int)AccountInfoInteger(ACCOUNT_LOGIN))+"_"+IntegerToString((int)InpMagic)+"_"+_Symbol;
}

string GVName(const string suffix)
{
   string n=GVBase()+"_"+suffix;
   if(StringLen(n)>63) n=StringSubstr(n,0,63);
   return n;
}

void InitializePersistentState()
{
   double eq=AccountInfoDouble(ACCOUNT_EQUITY);
   if(InpResetPersistentStats)
   {
      GlobalVariableDel(GVName("PEAK"));
      GlobalVariableDel(GVName("RPEAK"));
      GlobalVariableDel(GVName("MAXDD"));
      GlobalVariableDel(GVName("MAXDM"));
      GlobalVariableDel(GVName("MAXDT"));
      GlobalVariableDel(GVName("LOCK"));
      GlobalVariableDel(GVName("LOCKUNT"));
   }

   if(InpPersistMaxDD && GlobalVariableCheck(GVName("PEAK")))
      g_peakEquityAllTime=GlobalVariableGet(GVName("PEAK"));
   else g_peakEquityAllTime=eq;

   if(GlobalVariableCheck(GVName("RPEAK")))
      g_riskPeakEquity=GlobalVariableGet(GVName("RPEAK"));
   else g_riskPeakEquity=eq;

   if(InpPersistMaxDD && GlobalVariableCheck(GVName("MAXDD")))
      g_maxDDPersistent=GlobalVariableGet(GVName("MAXDD"));
   else g_maxDDPersistent=0.0;

   if(InpPersistMaxDD && GlobalVariableCheck(GVName("MAXDM")))
      g_maxDDMoney=GlobalVariableGet(GVName("MAXDM"));
   else g_maxDDMoney=0.0;

   if(InpPersistMaxDD && GlobalVariableCheck(GVName("MAXDT")))
      g_maxDDTime=(datetime)GlobalVariableGet(GVName("MAXDT"));
   else g_maxDDTime=0;

   if(GlobalVariableCheck(GVName("LOCK")))
      g_emergencyLock=(GlobalVariableGet(GVName("LOCK"))>0.5);
   if(GlobalVariableCheck(GVName("LOCKUNT")))
      g_emergencyLockUntil=(datetime)GlobalVariableGet(GVName("LOCKUNT"));

   UpdateEmergencyLockState();
   SavePersistentState();
}

void SavePersistentState()
{
   if(InpPersistMaxDD)
   {
      GlobalVariableSet(GVName("PEAK"),g_peakEquityAllTime);
      GlobalVariableSet(GVName("MAXDD"),g_maxDDPersistent);
      GlobalVariableSet(GVName("MAXDM"),g_maxDDMoney);
      GlobalVariableSet(GVName("MAXDT"),(double)g_maxDDTime);
   }
   GlobalVariableSet(GVName("RPEAK"),g_riskPeakEquity);
   GlobalVariableSet(GVName("LOCK"),(g_emergencyLock?1.0:0.0));
   GlobalVariableSet(GVName("LOCKUNT"),(double)g_emergencyLockUntil);
}

void ResetRiskPeak()
{
   g_riskPeakEquity=AccountInfoDouble(ACCOUNT_EQUITY);
   SavePersistentState();
}

int TotalEAOrders()
{
   return CountSide(POSITION_TYPE_BUY)+CountSide(POSITION_TYPE_SELL);
}

void ActivatePostEmergencyMode()
{
   if(InpAfterEmergency==CONTINUE)
   {
      g_emergencyLock=false;
      g_emergencyLockUntil=0;
      ResetRiskPeak();
      return;
   }

   g_emergencyLock=true;
   if(InpAfterEmergency==STOP_UNTIL_NEXT_SESSION)
   {
      datetime ns=0,ne=0;
      NextSessionTimes(ns,ne);
      g_emergencyLockUntil=ns;
   }
   else
      g_emergencyLockUntil=0;
   SavePersistentState();
}

void UpdateEmergencyLockState()
{
   if(!g_emergencyLock) return;
   if(InpAfterEmergency==STOP_UNTIL_NEXT_SESSION && g_emergencyLockUntil>0 && TimeTradeServer()>=g_emergencyLockUntil)
   {
      g_emergencyLock=false;
      g_emergencyLockUntil=0;
      ResetRiskPeak();
      Print("Emergency lock released at next session.");
   }
}

void ManualResetEmergencyLock()
{
   g_emergencyLock=false;
   g_emergencyLockUntil=0;
   g_resetArmTime=0;
   ResetRiskPeak();
   Print("Emergency lock manually reset.");
}

double CurrentSpreadPoints()
{
   MqlTick t;
   if(!SymbolInfoTick(_Symbol,t)) return 0.0;
   return (t.ask-t.bid)/_Point;
}

string BoolOnOff(const bool v)
{
   return (v ? "ON" : "OFF");
}

void DeletePanelObjects()
{
   if(g_panelCanvasReady)
   {
      g_panelCanvas.Destroy();
      g_panelCanvasReady=false;
   }
   ObjectsDeleteAll(0,PANEL_PREFIX);
   g_lastPanelOpacity=-1;
   g_lastPanelRefreshMs=0;
}

void CreateLabel(const string id,const int x,const int y,const int size,const color clr,const string text)
{
   string n=PANEL_PREFIX+id;

   // IMPORTANT:
   // Set the initial text ONLY when the object is first created.
   // Dynamic labels are created with an empty initial string. Re-applying that
   // empty string on every GUI refresh would momentarily erase the text and
   // then SetPanelText() would write it again, producing visible flicker.
   if(ObjectFind(0,n)<0)
   {
      ObjectCreate(0,n,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,n,OBJPROP_CORNER,CORNER_LEFT_UPPER);
      ObjectSetInteger(0,n,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0,n,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,n,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,n,OBJPROP_FONTSIZE,size);
      ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
      ObjectSetString(0,n,OBJPROP_FONT,"Arial");
      ObjectSetInteger(0,n,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,n,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,n,OBJPROP_ZORDER,20);
      ObjectSetString(0,n,OBJPROP_TEXT,text);
   }
}


string MakeMarkerBar(const double value,const double minValue,const double maxValue,const int width=26)
{
   int w=MathMax(8,width);
   double lo=minValue, hi=maxValue;
   if(hi<=lo) hi=lo+1.0;

   double ratio=(value-lo)/(hi-lo);
   ratio=MathMax(0.0,MathMin(1.0,ratio));
   int marker=(int)MathRound(ratio*(w-1));

   string s="[";
   for(int i=0;i<w;i++)
      s+=(i==marker ? "|" : "-");
   s+="]";
   return s;
}

void SetPanelColor(const string id,const color clr)
{
   string n=PANEL_PREFIX+id;
   if(ObjectFind(0,n)>=0 && (color)ObjectGetInteger(0,n,OBJPROP_COLOR)!=clr)
      ObjectSetInteger(0,n,OBJPROP_COLOR,clr);
}

color EntryStateColor(const string s)
{
   // Red is reserved for genuine faults / emergency states.
   if(StringFind(s,"EMERGENCY")>=0 || StringFind(s,"FAIL-SAFE")>=0 || StringFind(s,"NO DATA")>=0)
      return C'245,105,105';

   // Planned / normal pauses are not errors.
   if(StringFind(s,"NEWS")>=0)
      return C'245,175,70';       // orange
   if(StringFind(s,"OUTSIDE SESSION")>=0 || StringFind(s,"TIME")>=0 ||
      StringFind(s,"NEW CYCLES OFF")>=0 || StringFind(s,"DISABLED")>=0)
      return C'90,195,235';       // light blue

   if(StringFind(s,"READY")>=0 || StringFind(s,"OK")>=0 || StringFind(s,"CLEAR")>=0)
      return C'100,225,125';      // green
   if(StringFind(s,"NEAR")>=0)
      return C'245,205,80';       // yellow

   return C'225,230,235';         // WAIT / WAITING
}

void EnsureTransparentPanel()
{
   const int x=8, y=18, w=590, h=500;
   string bg=PANEL_PREFIX+"BG_CANVAS";
   bool created=false;

   if(!g_panelCanvasReady || ObjectFind(0,bg)<0)
   {
      if(g_panelCanvasReady)
         g_panelCanvas.Destroy();

      g_panelCanvasReady=g_panelCanvas.CreateBitmapLabel(0,0,bg,x,y,w,h,COLOR_FORMAT_ARGB_NORMALIZE);
      if(!g_panelCanvasReady)
      {
         Print("Panel canvas creation failed. Labels will still be shown.");
         return;
      }
      ObjectSetInteger(0,bg,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,bg,OBJPROP_HIDDEN,true);
      ObjectSetInteger(0,bg,OBJPROP_ZORDER,1);
      created=true;
   }

   int alpha=MathMax(0,MathMin(255,InpPanelOpacity));

   // IMPORTANT: do not erase/repaint the bitmap on every tick.
   // Repainting the canvas causes MT5 to briefly show intermediate label states,
   // which is perceived as panel flicker. Draw only at creation or opacity change.
   if(created || g_lastPanelOpacity!=alpha)
   {
      g_panelCanvas.Erase(ColorToARGB(C'18,22,28',(uchar)alpha));
      uint frame=ColorToARGB(C'105,120,135',(uchar)MathMin(255,alpha+55));
      uint sep=ColorToARGB(C'70,90,108',(uchar)MathMin(255,alpha+20));
      g_panelCanvas.Rectangle(0,0,w-1,h-1,frame);
      g_panelCanvas.Line(12,36,w-12,36,sep);
      g_panelCanvas.Line(12,137,w-12,137,sep);
      g_panelCanvas.Line(12,235,w-12,235,sep);
      g_panelCanvas.Line(12,347,w-12,347,sep);
      g_panelCanvas.Update(false);
      g_lastPanelOpacity=alpha;
   }
}

void CreateOrRefreshPanelObjects()
{
   // Display-only redesign: a semi-transparent canvas background and objects created once.
   // Avoid reapplying every visual property on each tick, which can cause visible flicker.
   EnsureTransparentPanel();

   CreateLabel("TITLE",22,29,12,C'245,210,70',"GOLD SESSION GUARD   v4 EXPERIMENTAL 03");
   CreateLabel("STATUS",435,29,10,C'120,220,140',"INITIALIZING");

   CreateLabel("SERVER",22,56,9,C'80,195,230',"SERVER / SESSION");
   CreateLabel("S1",22,75,9,C'235,235,235',"");
   CreateLabel("S2",22,93,9,C'235,235,235',"");
   CreateLabel("S3",22,111,9,C'235,235,235',"");
   CreateLabel("S4",22,129,9,C'235,235,235',"");

   CreateLabel("PERF",22,154,9,C'80,195,230',"PERFORMANCE");
   CreateLabel("P1",22,173,9,C'235,235,235',"");
   CreateLabel("P2",22,191,9,C'235,235,235',"");
   CreateLabel("P3",22,209,9,C'235,235,235',"");
   CreateLabel("P4",22,227,9,C'235,235,235',"");

   CreateLabel("RISK",22,252,9,C'80,195,230',"RISK / POSITION");
   CreateLabel("R1",22,271,9,C'235,235,235',"");
   CreateLabel("R2",22,289,8,C'225,225,225',"");
   CreateLabel("R3",22,307,8,C'225,225,225',"");
   CreateLabel("R4",22,325,8,C'225,225,225',"");
   CreateLabel("R5",290,271,8,C'225,225,225',"");
   CreateLabel("R6",290,289,8,C'225,225,225',"");
   CreateLabel("R7",290,307,8,C'225,225,225',"");

   CreateLabel("NEWS",22,360,9,C'80,195,230',"NEWS FILTER");
   CreateLabel("N1",22,379,8,C'235,235,235',"");
   CreateLabel("N2",22,397,8,C'235,235,235',"");
   CreateLabel("N3",22,415,8,C'235,235,235',"");
   CreateLabel("N4",22,433,8,C'235,235,235',"");
   CreateLabel("N5",22,451,8,C'235,235,235',"");

   if(InpShowResetLockButton)
   {
      string b=PANEL_PREFIX+"RESET";
      if(ObjectFind(0,b)<0)
      {
         ObjectCreate(0,b,OBJ_BUTTON,0,0,0);
         ObjectSetInteger(0,b,OBJPROP_CORNER,CORNER_LEFT_UPPER);
         ObjectSetInteger(0,b,OBJPROP_XDISTANCE,455);
         ObjectSetInteger(0,b,OBJPROP_YDISTANCE,322);
         ObjectSetInteger(0,b,OBJPROP_XSIZE,120);
         ObjectSetInteger(0,b,OBJPROP_YSIZE,24);
         ObjectSetInteger(0,b,OBJPROP_BGCOLOR,C'38,44,52');
         ObjectSetInteger(0,b,OBJPROP_COLOR,C'235,235,235');
         ObjectSetInteger(0,b,OBJPROP_BORDER_COLOR,C'85,105,120');
         ObjectSetString(0,b,OBJPROP_TEXT,"RESET LOCK");
         ObjectSetInteger(0,b,OBJPROP_FONTSIZE,8);
         ObjectSetInteger(0,b,OBJPROP_HIDDEN,true);
         ObjectSetInteger(0,b,OBJPROP_ZORDER,30);
      }
   }
}

void SetPanelText(const string id,const string txt)
{
   string n=PANEL_PREFIX+id;
   if(ObjectFind(0,n)<0) CreateOrRefreshPanelObjects();
   if(ObjectGetString(0,n,OBJPROP_TEXT)!=txt)
      ObjectSetString(0,n,OBJPROP_TEXT,txt);
}

void SetStatusColor(const string state)
{
   color c=C'120,210,140';
   if(StringFind(state,"EMERGENCY")>=0) c=C'235,95,95';
   else if(StringFind(state,"WARNING")>=0 || StringFind(state,"STOP")>=0 || StringFind(state,"PAUSED")>=0) c=C'240,190,90';
   else if(StringFind(state,"MANAGING")>=0 || StringFind(state,"WAIT")>=0) c=C'170,180,195';
   if((color)ObjectGetInteger(0,PANEL_PREFIX+"STATUS",OBJPROP_COLOR)!=c)
      ObjectSetInteger(0,PANEL_PREFIX+"STATUS",OBJPROP_COLOR,c);
}

void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
{
   if(id!=CHARTEVENT_OBJECT_CLICK) return;
   if(sparam!=PANEL_PREFIX+"RESET") return;

   if(!g_emergencyLock)
   {
      g_resetArmTime=0;
      ObjectSetString(0,PANEL_PREFIX+"RESET",OBJPROP_TEXT,"NO LOCK");
      return;
   }

   datetime now=TimeLocal();
   if(g_resetArmTime==0 || now-g_resetArmTime>5)
   {
      g_resetArmTime=now;
      ObjectSetString(0,PANEL_PREFIX+"RESET",OBJPROP_TEXT,"CONFIRM RESET");
      return;
   }

   ManualResetEmergencyLock();
   ObjectSetString(0,PANEL_PREFIX+"RESET",OBJPROP_TEXT,"RESET LOCK");
}

void DrawStatus(const string state)
{
   bool stateChanged=(state!=g_lastState);
   g_lastState=state;
   if(!InpShowInfoPanel)
   {
      DeletePanelObjects();
      return;
   }

   // Trading logic still runs on every tick, but GUI refresh is limited to once
   // at the configured interval unless the operating state changes. This prevents visible flicker
   // on fast XAUUSD tick streams without changing any trading behavior.
   uint nowMs=GetTickCount();
   if(!stateChanged && g_lastPanelRefreshMs!=0 && (nowMs-g_lastPanelRefreshMs)<(uint)MathMax(250,InpPanelRefreshMilliseconds))
      return;
   g_lastPanelRefreshMs=nowMs;

   RefreshClosedProfitStats(false);
   UpdatePersistentMaxDD();

   // The panel is created once in OnInit(). Recreate only if the chart/object
   // was actually removed. Avoid touching the static canvas/labels every second.
   if(ObjectFind(0,PANEL_PREFIX+"BG_CANVAS")<0 ||
      ObjectFind(0,PANEL_PREFIX+"TITLE")<0 ||
      ObjectFind(0,PANEL_PREFIX+"STATUS")<0)
      CreateOrRefreshPanelObjects();

   double dd=CurrentDrawdownPercent();
   double floating=CurrentFloatingEAProfit();
   UpdateNewsInfo(false);
   bool newsPause=NewsBlocksNewCycle();
   string serverName=AccountInfoString(ACCOUNT_SERVER);
   double serverGMT=DetectServerGMTOffsetHours();
   int ws,we; EffectiveServerWindow(ws,we);
   string mode=TimeModeText();
   string ddMode=(InpDDCalculationMode==BALANCE_EQUITY ? "BALANCE_EQUITY" : "PEAK_EQUITY");
   string gmtText=(serverGMT>=0.0 ? "+" : "")+DoubleToString(serverGMT,2);

   int buyCount=CountSide(POSITION_TYPE_BUY);
   int sellCount=CountSide(POSITION_TYPE_SELL);
   int orderCount=buyCount+sellCount;
   double spread=CurrentSpreadPoints();

   datetime nextStart=0,nextEnd=0;
   NextSessionTimes(nextStart,nextEnd);

   string newsText=NewsStatusText();
   string lockText="NONE";
   if(g_emergencyLock)
   {
      if(InpAfterEmergency==STOP_UNTIL_MANUAL_RESET) lockText="MANUAL RESET";
      else if(InpAfterEmergency==STOP_UNTIL_NEXT_SESSION) lockText="UNTIL "+TimeToString(g_emergencyLockUntil,TIME_DATE|TIME_MINUTES);
      else lockText="NONE";
   }

   string singleTP=(InpSingleTPMode==SINGLE_TP_MONEY ? "MONEY "+MoneyText(InpSingleTPMoney) : "POINTS "+IntegerToString(InpVirtualTPPointsSingle)+" pt");
   string maxDDWhen=(g_maxDDTime>0 ? TimeToString(g_maxDDTime,TIME_DATE|TIME_MINUTES) : "-");

   SetPanelText("TITLE","GOLD SESSION GUARD   v4 EXPERIMENTAL 03");
   SetPanelText("STATUS",state);
   SetStatusColor(state);

   SetPanelText("SERVER","SERVER / SESSION");
   SetPanelText("S1","Broker     "+serverName);
   SetPanelText("S2","Server     "+TimeToString(TimeTradeServer(),TIME_DATE|TIME_SECONDS)+"   GMT"+gmtText);
   string worldWindow="-";
   if(InpTimeMode==AUTO_GMT)
      worldWindow=StringFormat("%02d:%02d-%02d:%02d GMT",InpAutoGMTStartHour,InpAutoGMTStartMinute,InpAutoGMTEndHour,InpAutoGMTEndMinute);
   else if(InpTimeMode==CUSTOM_GMT)
      worldWindow=StringFormat("%02d:%02d-%02d:%02d GMT",InpCustomGMTStartHour,InpCustomGMTStartMinute,InpCustomGMTEndHour,InpCustomGMTEndMinute);
   else
      worldWindow="SERVER MANUAL";

   SetPanelText("S3","Mode       "+mode+"   Server window "+HHMM(ws)+" - "+HHMM(we));
   SetPanelText("S4","World      "+worldWindow+"   Next "+TimeToString(nextStart,TIME_DATE|TIME_MINUTES));

   SetPanelText("PERF","PERFORMANCE");
   SetPanelText("P1","Today      "+MoneyText(g_todayProfitCache)+"   Floating "+MoneyText(floating));
   SetPanelText("P2","Total      "+MoneyText(g_totalProfitCache));
   SetPanelText("P3","Max DD     "+DoubleToString(g_maxDDPersistent,2)+"% / "+MoneyText(-g_maxDDMoney));
   SetPanelText("P4","Max DD at  "+maxDDWhen);

   SetPanelText("RISK","RISK / POSITION");
   SetPanelText("R1","DD         "+DoubleToString(dd,2)+"%   Basis "+ddMode);
   SetPanelText("R2","Limits     Warn "+BoolOnOff(InpEnableWarning)+" "+DoubleToString(InpWarningDDPercent,1)+"% | Grid "+BoolOnOff(InpEnableGridPause)+" "+DoubleToString(InpPauseGridDDPercent,1)+"% | Close "+BoolOnOff(InpEnableEmergencyClose)+" "+DoubleToString(InpEmergencyCloseDDPercent,1)+"%");
   SetPanelText("R3","Cycle      "+CurrentCycleText()+"   Orders "+IntegerToString(orderCount)+" (B"+IntegerToString(buyCount)+"/S"+IntegerToString(sellCount)+")   Lots "+DoubleToString(TotalLots(POSITION_TYPE_BUY)+TotalLots(POSITION_TYPE_SELL),2));
   SetPanelText("R4","Max lot    "+DoubleToString(LargestCurrentLot(),2)+" / "+DoubleToString(InpMaxLot,2)+"   Spread "+DoubleToString(spread,1)+" pt");
   string singleExit=(InpSingleExitMode==EXIT_TRAILING ? "TRAIL" : "FIXED");
   string basketExit=(InpBasketExitMode==EXIT_TRAILING ? "TRAIL" : "FIXED");
   string trailState="OFF";
   if(g_buyTrailActive)
      trailState="BUY "+DoubleToString(g_buyTrailPeakPts,0)+"/"+DoubleToString(g_buyTrailStopPts,0)+"pt";
   else if(g_sellTrailActive)
      trailState="SELL "+DoubleToString(g_sellTrailPeakPts,0)+"/"+DoubleToString(g_sellTrailStopPts,0)+"pt";

   SetPanelText("R5","Exit       S:"+singleExit+" B:"+basketExit+"   Trail "+trailState);
   SetPanelText("R6","Lock       "+lockText);
   SetPanelText("R7","Last close "+g_lastCloseReason);

   // RSI/ATR entry diagnostics moved to the separate Logic Monitor indicator.

   string newsModeText=(InpNewsStopMode==MANAGE_ONLY ? "MANAGE_ONLY" : "STOP_NEW_CYCLE_ONLY");
   string newsAction;
   if(!InpUseNewsFilter) newsAction="New Entry ACTIVE | Grid ACTIVE | Protection ACTIVE";
   else if(!g_newsCalendarOK)
   {
      if(InpNewsFailMode==NEWS_FAIL_MANAGE_ONLY) newsAction="New Entry STOP | Grid STOP | TP/SL/Trail ACTIVE";
      else if(InpNewsFailMode==NEWS_FAIL_STOP_NEW_CYCLE) newsAction="New Entry STOP | Grid ACTIVE | TP/SL/Trail ACTIVE";
      else newsAction="Calendar fail-open: New Entry/Grid ACTIVE";
   }
   else if(g_newsPauseActive && InpNewsStopMode==MANAGE_ONLY)
      newsAction="New Entry STOP | Grid STOP | TP/SL/Trail ACTIVE";
   else if(g_newsPauseActive)
      newsAction="New Entry STOP | Grid ACTIVE | TP/SL/Trail ACTIVE";
   else
      newsAction="New Entry ACTIVE | Grid ACTIVE | Protection ACTIVE";

   string eventTime=(g_newsEventTime>0 ? TimeToString(g_newsEventTime,TIME_DATE|TIME_MINUTES) : "-");
   string stopFrom=(g_newsStopFrom>0 ? TimeToString(g_newsStopFrom,TIME_DATE|TIME_MINUTES) : "-");
   string resumeAt=(g_newsResumeAt>0 ? TimeToString(g_newsResumeAt,TIME_DATE|TIME_MINUTES) : "-");

   SetPanelText("N1","Status "+newsText+"   Mode "+newsModeText+"   Importance "+g_newsImportance);
   SetPanelText("N2","Event  "+g_newsEventName);
   SetPanelText("N3","Event time "+eventTime+"   Stop from "+stopFrom);
   SetPanelText("N4","Resume "+resumeAt+"   "+newsAction);
   SetPanelText("N5","TP / SL / Trailing / DD Protection remain ACTIVE while managing.");

   if(InpShowResetLockButton)
   {
      string btn=(g_resetArmTime>0 && TimeLocal()-g_resetArmTime<=5 ? "CONFIRM RESET" : "RESET LOCK");
      if(ObjectGetString(0,PANEL_PREFIX+"RESET",OBJPROP_TEXT)!=btn)
         ObjectSetString(0,PANEL_PREFIX+"RESET",OBJPROP_TEXT,btn);
   }

   // No forced ChartRedraw on every tick. MT5 redraws naturally; this avoids flicker.
}

//+------------------------------------------------------------------+
