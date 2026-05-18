
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
   signalEngine.Release();
   logger.Info("deinitialized ForexRiskBot");
}

void OnTick()
{
   if(!IsNewEntryBar()) return;

   string reason = "";
   if(!tradeManager.IsWithinTradingHours(reason))
   {
      logger.Decision(_Symbol, "NO TRADE", reason);
      return;
   }

   if(!tradeManager.IsSpreadAcceptable(_Symbol, reason))
   {
      logger.Decision(_Symbol, "NO TRADE", reason);
      return;
   }

   if(tradeManager.HasOpenPosition(_Symbol))
   {
      logger.Decision(_Symbol, "NO TRADE", "position already open for symbol");
      return;
   }

   if(!riskManager.CanOpenNewTrade(reason))
   {
      logger.Decision(_Symbol, "NO TRADE", reason);
      return;
   }

   if(newsFilter.IsBlackoutWindow(_Symbol, reason))
   {
      logger.Decision(_Symbol, "NO TRADE", reason);
      return;
   }

   TradeDirection direction = signalEngine.Evaluate(_Symbol, reason);
   if(direction == DIR_NONE)
   {
      logger.Decision(_Symbol, "NO TRADE", reason);
      return;
   }

   if(UseSentimentFilter)
   {
      logger.Decision(_Symbol, "NO TRADE", "sentiment filter enabled but external bridge not configured");
      return;
   }

   double atr = signalEngine.CurrentATR();
   if(atr <= 0.0)
   {
      logger.Decision(_Symbol, "NO TRADE", "atr unavailable");
      return;
   }

   double sl = 0.0;
   double tp = 0.0;
   BuildStops(direction, atr, sl, tp);

   MqlTick tick;
   SymbolInfoTick(_Symbol, tick);
   double entry = direction == DIR_BUY ? tick.ask : tick.bid;
   double stopDistance = MathAbs(entry - sl);
   double lots = riskManager.CalculateLotSize(_Symbol, stopDistance);
   if(lots <= 0.0)
   {
      logger.Decision(_Symbol, "NO TRADE", "lot size below broker minimum or risk data unavailable");
      return;
   }

   if(!tradeManager.OpenPosition(_Symbol, direction, lots, sl, tp, reason))
   {
      logger.Decision(_Symbol, "NO TRADE", reason);
      return;
   }

   riskManager.RegisterTradeOpened();
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
