#ifndef FOREX_RISK_BOT_SIGNAL_ENGINE_MQH
#define FOREX_RISK_BOT_SIGNAL_ENGINE_MQH
#include "Config.mqh"

class CSignalEngine
{
private:
   int m_fastTrendHandle;
   int m_slowTrendHandle;
   int m_fastEntryHandle;
   int m_slowEntryHandle;
   int m_rsiHandle;
   int m_atrHandle;
   int m_macdHandle;

   bool ReadOne(const int handle, const int buffer, const int shift, double &value)
   {
      double temp[];
      ArraySetAsSeries(temp, true);
      if(CopyBuffer(handle, buffer, shift, 1, temp) != 1) return false;
      value = temp[0];
      return true;
   }

   void AddBlocker(string &details, const string blocker)
   {
      if(details == "")
         details = blocker;
      else
         details += ", " + blocker;
   }

public:
   CSignalEngine()
   {
      m_fastTrendHandle = INVALID_HANDLE;
      m_slowTrendHandle = INVALID_HANDLE;
      m_fastEntryHandle = INVALID_HANDLE;
      m_slowEntryHandle = INVALID_HANDLE;
      m_rsiHandle = INVALID_HANDLE;
      m_atrHandle = INVALID_HANDLE;
      m_macdHandle = INVALID_HANDLE;
   }

   bool Init(const string symbol)
   {
      m_fastTrendHandle = iMA(symbol, TrendTimeframe, EMAFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
      m_slowTrendHandle = iMA(symbol, TrendTimeframe, EMASlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
      m_fastEntryHandle = iMA(symbol, EntryTimeframe, EMAFastPeriod, 0, MODE_EMA, PRICE_CLOSE);
      m_slowEntryHandle = iMA(symbol, EntryTimeframe, EMASlowPeriod, 0, MODE_EMA, PRICE_CLOSE);
      m_rsiHandle = iRSI(symbol, EntryTimeframe, RSIPeriod, PRICE_CLOSE);
      m_atrHandle = iATR(symbol, EntryTimeframe, ATRPeriod);
      if(UseMACDConfirmation)
         m_macdHandle = iMACD(symbol, EntryTimeframe, 12, 26, 9, PRICE_CLOSE);

      return m_fastTrendHandle != INVALID_HANDLE &&
             m_slowTrendHandle != INVALID_HANDLE &&
             m_fastEntryHandle != INVALID_HANDLE &&
             m_slowEntryHandle != INVALID_HANDLE &&
             m_rsiHandle != INVALID_HANDLE &&
             m_atrHandle != INVALID_HANDLE &&
             (!UseMACDConfirmation || m_macdHandle != INVALID_HANDLE);
   }

   void Release()
   {
      if(m_fastTrendHandle != INVALID_HANDLE) IndicatorRelease(m_fastTrendHandle);
      if(m_slowTrendHandle != INVALID_HANDLE) IndicatorRelease(m_slowTrendHandle);
      if(m_fastEntryHandle != INVALID_HANDLE) IndicatorRelease(m_fastEntryHandle);
      if(m_slowEntryHandle != INVALID_HANDLE) IndicatorRelease(m_slowEntryHandle);
      if(m_rsiHandle != INVALID_HANDLE) IndicatorRelease(m_rsiHandle);
      if(m_atrHandle != INVALID_HANDLE) IndicatorRelease(m_atrHandle);
      if(m_macdHandle != INVALID_HANDLE) IndicatorRelease(m_macdHandle);
   }

   double CurrentATR()
   {
      double value = 0.0;
      if(!ReadOne(m_atrHandle, 0, 1, value)) return 0.0;
      return value;
   }

   double CurrentATRPoints()
   {
      double atr = CurrentATR();
      if(atr <= 0.0) return 0.0;
      return atr / _Point;
   }

   TradeDirection Evaluate(const string symbol, string &reason)
   {
      double fastTrend, slowTrend, fastTrendPast, slowTrendPast, fastEntry, slowEntry, rsi, macdMain = 0.0, macdSignal = 0.0;
      if(!ReadOne(m_fastTrendHandle, 0, 1, fastTrend) ||
         !ReadOne(m_slowTrendHandle, 0, 1, slowTrend) ||
         !ReadOne(m_fastTrendHandle, 0, 1 + TrendSlopeLookbackBars, fastTrendPast) ||
         !ReadOne(m_slowTrendHandle, 0, 1 + TrendSlopeLookbackBars, slowTrendPast) ||
         !ReadOne(m_fastEntryHandle, 0, 1, fastEntry) ||
         !ReadOne(m_slowEntryHandle, 0, 1, slowEntry) ||
         !ReadOne(m_rsiHandle, 0, 1, rsi))
      {
         reason = "indicator data unavailable";
         return DIR_NONE;
      }

      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      if(CopyRates(symbol, EntryTimeframe, 1, StructureLookbackBars + 2, rates) < StructureLookbackBars + 2)
      {
         reason = "insufficient price history";
         return DIR_NONE;
      }

      int midpoint = MathMax(2, StructureLookbackBars / 2);
      double recentHigh = rates[1].high;
      double recentLow = rates[1].low;
      double previousHigh = rates[midpoint + 1].high;
      double previousLow = rates[midpoint + 1].low;
      for(int i = 1; i <= StructureLookbackBars; i++)
      {
         if(i <= midpoint)
         {
            recentHigh = MathMax(recentHigh, rates[i].high);
            recentLow = MathMin(recentLow, rates[i].low);
         }
         else
         {
            previousHigh = MathMax(previousHigh, rates[i].high);
            previousLow = MathMin(previousLow, rates[i].low);
         }
      }

      double close1 = rates[0].close;
      double structureRangePoints = (recentHigh - recentLow) / _Point;
      double fastSlopePoints = (fastTrend - fastTrendPast) / _Point;
      double slowSlopePoints = (slowTrend - slowTrendPast) / _Point;
      double trendSeparationPoints = MathAbs(fastTrend - slowTrend) / _Point;
      bool bullishTrend = fastTrend > slowTrend && close1 > slowTrend &&
                          fastSlopePoints >= MinimumTrendSlopePoints &&
                          slowSlopePoints >= 0.0 &&
                          trendSeparationPoints >= MinimumTrendSeparationPoints;
      bool bearishTrend = fastTrend < slowTrend && close1 < slowTrend &&
                          fastSlopePoints <= -MinimumTrendSlopePoints &&
                          slowSlopePoints <= 0.0 &&
                          trendSeparationPoints >= MinimumTrendSeparationPoints;
      bool bullishPullbackTouched = rates[1].low <= fastEntry + PullbackTolerancePoints * _Point &&
                                    rates[1].close >= slowEntry;
      bool bearishPullbackTouched = rates[1].high >= fastEntry - PullbackTolerancePoints * _Point &&
                                    rates[1].close <= slowEntry;
      bool bullishConfirmation = rates[0].close > fastEntry && rates[0].close > rates[1].high;
      bool bearishConfirmation = rates[0].close < fastEntry && rates[0].close < rates[1].low;
      bool bullishStructure = recentHigh > previousHigh && recentLow > previousLow;
      bool bearishStructure = recentHigh < previousHigh && recentLow < previousLow;
      double roomToResistancePoints = MathMax(0.0, (recentHigh - close1) / _Point);
      double roomToSupportPoints = MathMax(0.0, (close1 - recentLow) / _Point);
      bool inRange = structureRangePoints < MinStructureRangePoints;

      if(UseMACDConfirmation)
      {
         if(!ReadOne(m_macdHandle, 0, 1, macdMain) || !ReadOne(m_macdHandle, 1, 1, macdSignal))
         {
            reason = "macd data unavailable";
            return DIR_NONE;
         }
      }

      if(inRange)
      {
         reason = StringFormat("regime=range structure_range_points=%.1f min_required=%d",
                               structureRangePoints,
                               MinStructureRangePoints);
         return DIR_NONE;
      }

      bool buyEnabled = AllowBuy && AllowLongPullbacks;
      bool buyEntryAligned = fastEntry > slowEntry;
      bool buyRsiValid = rsi > RSIOversold && rsi < RSIOverbought;
      bool buyMacdValid = !UseMACDConfirmation || macdMain > macdSignal;
      bool buyConfirmationValid = !RequireConfirmationCandle || bullishConfirmation;
      bool buyRoomValid = roomToResistancePoints >= MinimumObstacleDistancePoints;

      if(buyEnabled && bullishTrend && buyEntryAligned && bullishPullbackTouched &&
         buyRsiValid && buyMacdValid && buyConfirmationValid && bullishStructure && buyRoomValid)
      {
         reason = StringFormat("playbook=trend_pullback regime=bullish accepted pullback=ema50 confirmation=%s rsi=%.1f room_points=%.1f",
                               RequireConfirmationCandle ? "candle" : "disabled",
                               rsi,
                               roomToResistancePoints);
         return DIR_BUY;
      }

      bool sellEnabled = AllowSell && AllowShortPullbacks;
      bool sellEntryAligned = fastEntry < slowEntry;
      bool sellRsiValid = rsi < RSIOverbought && rsi > RSIOversold;
      bool sellMacdValid = !UseMACDConfirmation || macdMain < macdSignal;
      bool sellConfirmationValid = !RequireConfirmationCandle || bearishConfirmation;
      bool sellRoomValid = roomToSupportPoints >= MinimumObstacleDistancePoints;

      if(sellEnabled && bearishTrend && sellEntryAligned && bearishPullbackTouched &&
         sellRsiValid && sellMacdValid && sellConfirmationValid && bearishStructure && sellRoomValid)
      {
         reason = StringFormat("playbook=trend_pullback regime=bearish accepted pullback=ema50 confirmation=%s rsi=%.1f room_points=%.1f",
                               RequireConfirmationCandle ? "candle" : "disabled",
                               rsi,
                               roomToSupportPoints);
         return DIR_SELL;
      }

      string buyBlockers = "";
      if(!buyEnabled) AddBlocker(buyBlockers, "disabled");
      if(!bullishTrend) AddBlocker(buyBlockers, "regime");
      if(!buyEntryAligned) AddBlocker(buyBlockers, "entry_ema_alignment");
      if(!bullishPullbackTouched) AddBlocker(buyBlockers, "pullback");
      if(!buyRsiValid) AddBlocker(buyBlockers, "rsi");
      if(!buyMacdValid) AddBlocker(buyBlockers, "macd");
      if(!buyConfirmationValid) AddBlocker(buyBlockers, "confirmation");
      if(!bullishStructure) AddBlocker(buyBlockers, "structure");
      if(!buyRoomValid) AddBlocker(buyBlockers, "obstacle_room");

      string sellBlockers = "";
      if(!sellEnabled) AddBlocker(sellBlockers, "disabled");
      if(!bearishTrend) AddBlocker(sellBlockers, "regime");
      if(!sellEntryAligned) AddBlocker(sellBlockers, "entry_ema_alignment");
      if(!bearishPullbackTouched) AddBlocker(sellBlockers, "pullback");
      if(!sellRsiValid) AddBlocker(sellBlockers, "rsi");
      if(!sellMacdValid) AddBlocker(sellBlockers, "macd");
      if(!sellConfirmationValid) AddBlocker(sellBlockers, "confirmation");
      if(!bearishStructure) AddBlocker(sellBlockers, "structure");
      if(!sellRoomValid) AddBlocker(sellBlockers, "obstacle_room");

      reason = StringFormat("playbook=trend_pullback blocked buy=[%s] sell=[%s] rsi=%.1f trend_sep_points=%.1f fast_slope_points=%.1f slow_slope_points=%.1f room_up_points=%.1f room_down_points=%.1f",
                            buyBlockers,
                            sellBlockers,
                            rsi,
                            trendSeparationPoints,
                            fastSlopePoints,
                            slowSlopePoints,
                            roomToResistancePoints,
                            roomToSupportPoints);
      return DIR_NONE;
   }
};

#endif
