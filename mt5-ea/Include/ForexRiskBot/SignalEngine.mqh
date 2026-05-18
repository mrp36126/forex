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
      bool bullishTrend = fastTrend > slowTrend && close1 > slowTrend &&
                          fastSlopePoints >= MinimumTrendSlopePoints &&
                          slowSlopePoints >= 0.0;
      bool bearishTrend = fastTrend < slowTrend && close1 < slowTrend &&
                          fastSlopePoints <= -MinimumTrendSlopePoints &&
                          slowSlopePoints <= 0.0;
      bool nearFastEma = MathAbs(close1 - fastEntry) <= PullbackTolerancePoints * _Point;
      bool bullishConfirmation = rates[0].close > fastEntry && rates[0].close > rates[1].high;
      bool bearishConfirmation = rates[0].close < fastEntry && rates[0].close < rates[1].low;
      bool bullishStructure = recentHigh > previousHigh && recentLow > previousLow;
      bool bearishStructure = recentHigh < previousHigh && recentLow < previousLow;
      bool bullishBreakout = rates[0].close > previousHigh + BreakoutBufferPoints * _Point;
      bool bearishBreakout = rates[0].close < previousLow - BreakoutBufferPoints * _Point;
      double breakoutBodyPoints = MathAbs(rates[0].close - rates[0].open) / _Point;
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
         reason = "range regime detected";
         return DIR_NONE;
      }

      if(AllowBuy && AllowLongPullbacks && bullishTrend && fastEntry > slowEntry && nearFastEma &&
         rsi > RSIOversold && rsi < RSIOverbought &&
         (!UseMACDConfirmation || macdMain > macdSignal) &&
         (!RequireConfirmationCandle || bullishConfirmation) &&
         bullishStructure &&
         roomToResistancePoints >= MinimumObstacleDistancePoints)
      {
         reason = "bullish trend continuation confirmed";
         return DIR_BUY;
      }

      if(AllowSell && AllowShortPullbacks && bearishTrend && fastEntry < slowEntry && nearFastEma &&
         rsi < RSIOverbought && rsi > RSIOversold &&
         (!UseMACDConfirmation || macdMain < macdSignal) &&
         (!RequireConfirmationCandle || bearishConfirmation) &&
         bearishStructure &&
         roomToSupportPoints >= MinimumObstacleDistancePoints)
      {
         reason = "bearish trend continuation confirmed";
         return DIR_SELL;
      }

      if(AllowBuy && bullishTrend && bullishBreakout && bullishStructure &&
         breakoutBodyPoints >= MinimumBreakoutBodyPoints &&
         rsi > 50.0 && roomToResistancePoints >= MinimumObstacleDistancePoints)
      {
         reason = "bullish breakout continuation confirmed";
         return DIR_BUY;
      }

      if(AllowSell && bearishTrend && bearishBreakout && bearishStructure &&
         breakoutBodyPoints >= MinimumBreakoutBodyPoints &&
         rsi < 50.0 && roomToSupportPoints >= MinimumObstacleDistancePoints)
      {
         reason = "bearish breakout continuation confirmed";
         return DIR_SELL;
      }

      reason = "regime, structure, obstacle, or confirmation filter blocked trade";
      return DIR_NONE;
   }
};

#endif
