
#property strict

#include <ForexRiskBot/Config.mqh>
#include <ForexRiskBot/Logger.mqh>
#include <ForexRiskBot/NewsFilter.mqh>
#include <ForexRiskBot/RiskManager.mqh>
#include <ForexRiskBot/SignalEngine.mqh>
#include <ForexRiskBot/TradeManager.mqh>

CBotLogger   logger;
CNewsFilter  newsFilter;
CRiskManager riskManager;
CSignalEngine signalEngine;
CTradeManager tradeManager;

datetime lastEntryBarTime = 0;
int noTradeCount = 0;
int buyCount = 0;
int sellCount = 0;
int rejectedOrderCount = 0;

void RecordNoTrade(const string reason)
{
   noTradeCount++;
   logger.Decision(_Symbol, "NO TRADE", reason);
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
   }
   signalEngine.Release();
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
   logger.Info(StringFormat("trade plan symbol=%s direction=%s lots=%.2f entry=%.5f sl=%.5f tp=%.5f rr=%.2f",
                            _Symbol,
                            direction == DIR_BUY ? "BUY" : "SELL",
                            lots,
                            entry,
                            sl,
                            tp,
                            RewardRiskRatio));
   logger.Decision(_Symbol, direction == DIR_BUY ? "BUY" : "SELL", "entry accepted: " + reason);
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
