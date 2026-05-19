
#property strict

#include <ForexRiskBot/Config.mqh>
#include <ForexRiskBot/Logger.mqh>
#include <ForexRiskBot/NewsFilter.mqh>
#include <ForexRiskBot/ResearchLogger.mqh>
#include <ForexRiskBot/RiskManager.mqh>
#include <ForexRiskBot/SignalEngine.mqh>
#include <ForexRiskBot/TradeManager.mqh>

CBotLogger   logger;
CNewsFilter  newsFilter;
CResearchLogger researchLogger;
CRiskManager riskManager;
CSignalEngine signalEngine;
CTradeManager tradeManager;

datetime lastEntryBarTime = 0;
int noTradeCount = 0;
int buyCount = 0;
int sellCount = 0;
int rejectedOrderCount = 0;
int outsideHoursBlockCount = 0;
int spreadBlockCount = 0;
int existingPositionBlockCount = 0;
int riskBlockCount = 0;
int newsBlockCount = 0;
int signalRangeBlockCount = 0;
int signalSetupBlockCount = 0;
int sentimentBlockCount = 0;
int volatilityBlockCount = 0;
int stopValidationBlockCount = 0;
int lotSizeBlockCount = 0;
string currentOpenSetupType = "unknown";
string currentOpenDirection = "NONE";
double currentOpenAtrPoints = 0.0;

string DetectSetupType(const string reason)
{
   if(StringFind(reason, "compression_breakout") >= 0) return "compression_breakout";
   if(StringFind(reason, "trend_pullback") >= 0) return "trend_pullback";
   if(StringFind(reason, "regime=range") >= 0) return "range";
   return "unknown";
}

string DirectionText(const TradeDirection direction)
{
   if(direction == DIR_BUY) return "BUY";
   if(direction == DIR_SELL) return "SELL";
   return "NONE";
}

void RecordNoTradeCategory(const string reason)
{
   if(StringFind(reason, "outside trading hours") >= 0)
      outsideHoursBlockCount++;
   else if(StringFind(reason, "spread") >= 0)
      spreadBlockCount++;
   else if(StringFind(reason, "position already open") >= 0)
      existingPositionBlockCount++;
   else if(StringFind(reason, "daily") >= 0 ||
           StringFind(reason, "consecutive") >= 0 ||
           StringFind(reason, "risk") >= 0 ||
           StringFind(reason, "profit target") >= 0)
      riskBlockCount++;
   else if(StringFind(reason, "news") >= 0 ||
           StringFind(reason, "blackout") >= 0 ||
           StringFind(reason, "calendar") >= 0)
      newsBlockCount++;
   else if(StringFind(reason, "regime=range") >= 0)
      signalRangeBlockCount++;
   else if(StringFind(reason, "playbook=trend_pullback blocked") >= 0)
      signalSetupBlockCount++;
   else if(StringFind(reason, "sentiment") >= 0)
      sentimentBlockCount++;
   else if(StringFind(reason, "atr") >= 0 ||
           StringFind(reason, "volatility") >= 0)
      volatilityBlockCount++;
   else if(StringFind(reason, "stop") >= 0)
      stopValidationBlockCount++;
   else if(StringFind(reason, "lot size") >= 0)
      lotSizeBlockCount++;
}

void RecordNoTrade(const string reason)
{
   noTradeCount++;
   RecordNoTradeCategory(reason);
   logger.Decision(_Symbol, "NO TRADE", reason);
   if(LogBlockedSignalsToCsv)
   {
      researchLogger.LogEvent(_Symbol,
                              "BLOCKED",
                              "NO_TRADE",
                              DetectSetupType(reason),
                              "NONE",
                              signalEngine.CurrentATRPoints(),
                              0.0,
                              0.0,
                              0.0,
                              0.0,
                              RewardRiskRatio,
                              0.0,
                              0,
                              reason);
   }
}

bool IsNewEntryBar()
{
   datetime currentBar = iTime(_Symbol, EntryTimeframe, 0);
   if(currentBar <= 0) return false;
   if(currentBar == lastEntryBarTime) return false;
   lastEntryBarTime = currentBar;
   return true;
}

void BuildStops(const TradeDirection direction, const double atr, double &sl, double &tp)
{
   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);
   double entry = direction == DIR_BUY ? tick.ask : tick.bid;
   double stopDistance = atr * ATRMultiplierSL;
   if(direction == DIR_BUY)
   {
      sl = entry - stopDistance;
      tp = entry + stopDistance * RewardRiskRatio;
   }
   else
   {
      sl = entry + stopDistance;
      tp = entry - stopDistance * RewardRiskRatio;
   }
   sl = NormalizeDouble(sl, _Digits);
   tp = NormalizeDouble(tp, _Digits);
}

int OnInit()
{
   logger.Info("initializing ForexRiskBot");

   if(RiskPercent <= 0.0 || RiskPercent > 1.0)
   {
      logger.Error("RiskPercent must be > 0 and <= 1.0");
      return INIT_PARAMETERS_INCORRECT;
   }
   if(MaxDailyLossPercent <= 0.0 || RewardRiskRatio < 1.5 || ATRMultiplierSL <= 0.0)
   {
      logger.Error("invalid risk configuration");
      return INIT_PARAMETERS_INCORRECT;
   }

   tradeManager.Init();
   researchLogger.Init(_Symbol);
   riskManager.RefreshDay();
   if(!signalEngine.Init(_Symbol))
   {
      logger.Error("failed to initialize indicators");
      return INIT_FAILED;
   }
   logger.Info("initialization complete");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   if(MQLInfoInteger(MQL_TESTER))
   {
      PrintFormat("[TESTER SUMMARY] symbol=%s no_trade=%d buys=%d sells=%d rejected_orders=%d",
                  _Symbol, noTradeCount, buyCount, sellCount, rejectedOrderCount);
      PrintFormat("[TESTER BLOCKS] outside_hours=%d spread=%d existing_position=%d risk=%d news=%d signal_range=%d signal_setup=%d sentiment=%d volatility=%d stops=%d lot_size=%d",
                  outsideHoursBlockCount,
                  spreadBlockCount,
                  existingPositionBlockCount,
                  riskBlockCount,
                  newsBlockCount,
                  signalRangeBlockCount,
                  signalSetupBlockCount,
                  sentimentBlockCount,
                  volatilityBlockCount,
                  stopValidationBlockCount,
                  lotSizeBlockCount);
   }
   signalEngine.Release();
   researchLogger.Close();
   logger.Info("deinitialized ForexRiskBot");
}

void OnTick()
{
   if(!IsNewEntryBar()) return;

   string reason = "";
   if(!tradeManager.IsWithinTradingHours(reason))
   {
      RecordNoTrade(reason);
      return;
   }

   if(!tradeManager.IsSpreadAcceptable(_Symbol, reason))
   {
      RecordNoTrade(reason);
      return;
   }

   if(tradeManager.HasOpenPosition(_Symbol))
   {
      RecordNoTrade("position already open for symbol");
      return;
   }

   if(!riskManager.CanOpenNewTrade(reason))
   {
      RecordNoTrade(reason);
      return;
   }

   if(newsFilter.IsBlackoutWindow(_Symbol, reason))
   {
      RecordNoTrade(reason);
      return;
   }

   TradeDirection direction = signalEngine.Evaluate(_Symbol, reason);
   if(direction == DIR_NONE)
   {
      RecordNoTrade(reason);
      return;
   }

   if(UseSentimentFilter)
   {
      RecordNoTrade("sentiment filter enabled but external bridge not configured");
      return;
   }

   double atr = signalEngine.CurrentATR();
   if(atr <= 0.0)
   {
      RecordNoTrade("atr unavailable");
      return;
   }
   if((atr / _Point) < MinATRPoints)
   {
      RecordNoTrade("atr below minimum volatility threshold");
      return;
   }

   double sl = 0.0;
   double tp = 0.0;
   BuildStops(direction, atr, sl, tp);

   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);
   double entry = direction == DIR_BUY ? tick.ask : tick.bid;
   if(!tradeManager.AreStopsValid(_Symbol, direction, entry, sl, tp, reason))
   {
      RecordNoTrade(reason);
      return;
   }
   double stopDistance = MathAbs(entry - sl);
   double lots = riskManager.CalculateLotSize(_Symbol, stopDistance);
   if(lots <= 0.0)
   {
      RecordNoTrade("lot size below broker minimum or risk data unavailable");
      return;
   }

   if(!tradeManager.OpenPosition(_Symbol, direction, lots, sl, tp, reason))
   {
      rejectedOrderCount++;
      RecordNoTrade(reason);
      return;
   }

   riskManager.RegisterTradeOpened();
   if(direction == DIR_BUY) buyCount++;
   if(direction == DIR_SELL) sellCount++;
   string setupType = DetectSetupType(reason);
   MqlDateTime tradeTimeParts;
   TimeToStruct(TimeCurrent(), tradeTimeParts);
   logger.Info(StringFormat("trade plan symbol=%s direction=%s setup=%s lots=%.2f entry=%.5f sl=%.5f tp=%.5f rr=%.2f atr_points=%.1f hour=%d",
                            _Symbol,
                            direction == DIR_BUY ? "BUY" : "SELL",
                            setupType,
                            lots,
                            entry,
                            sl,
                            tp,
                            RewardRiskRatio,
                            signalEngine.CurrentATRPoints(),
                            tradeTimeParts.hour));
   logger.Decision(_Symbol, direction == DIR_BUY ? "BUY" : "SELL", "entry accepted: " + reason);
   researchLogger.LogEvent(_Symbol,
                           "TRADE_PLAN",
                           direction == DIR_BUY ? "BUY" : "SELL",
                           setupType,
                           DirectionText(direction),
                           signalEngine.CurrentATRPoints(),
                           lots,
                           entry,
                           sl,
                           tp,
                           RewardRiskRatio,
                           0.0,
                           0,
                           reason);
   currentOpenSetupType = setupType;
   currentOpenDirection = DirectionText(direction);
   currentOpenAtrPoints = signalEngine.CurrentATRPoints();
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
{
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if(trans.deal <= 0) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if((long)HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != MagicNumber) return;
   if((ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) return;

   double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT)
                 + HistoryDealGetDouble(trans.deal, DEAL_SWAP)
                 + HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
   riskManager.RegisterClosedTrade(profit);
   string dealSymbol = HistoryDealGetString(trans.deal, DEAL_SYMBOL);
   researchLogger.LogEvent(dealSymbol,
                           "TRADE_CLOSE",
                           "CLOSE",
                           currentOpenSetupType,
                           currentOpenDirection,
                           currentOpenAtrPoints,
                           HistoryDealGetDouble(trans.deal, DEAL_VOLUME),
                           HistoryDealGetDouble(trans.deal, DEAL_PRICE),
                           0.0,
                           0.0,
                           RewardRiskRatio,
                           profit,
                           trans.deal,
                           "closed trade");
   currentOpenSetupType = "unknown";
   currentOpenDirection = "NONE";
   currentOpenAtrPoints = 0.0;
}

double OnTester()
{
   double profit = TesterStatistics(STAT_PROFIT);
   double drawdown = TesterStatistics(STAT_EQUITY_DDREL_PERCENT);
   double trades = TesterStatistics(STAT_TRADES);
   double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);

   PrintFormat("[TESTER METRICS] profit=%.2f drawdown=%.2f%% trades=%.0f profit_factor=%.2f",
               profit, drawdown, trades, profitFactor);

   if(trades < 10.0 || drawdown <= 0.0)
      return 0.0;

   return profitFactor / drawdown;
}
