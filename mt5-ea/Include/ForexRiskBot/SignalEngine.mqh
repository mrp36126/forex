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

   TradeDirection Evaluate(const string symbol, string &reason)
   {
      double fastTrend, slowTrend, fastEntry, slowEntry, rsi, macdMain = 0.0, macdSignal = 0.0;
      if(!ReadOne(m_fastTrendHandle, 0, 1, fastTrend) ||
         !ReadOne(m_slowTrendHandle, 0, 1, slowTrend) ||
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

      double recentHigh = rates[1].high;
      double recentLow = rates[1].low;
      for(int i = 1; i <= StructureLookbackBars; i++)
      {
         recentHigh = MathMax(recentHigh, rates[i].high);
         recentLow = MathMin(recentLow, rates[i].low);
      }

      double close1 = rates[0].close;
      bool bullishTrend = fastTrend > slowTrend && close1 > slowTrend;
      bool bearishTrend = fastTrend < slowTrend && close1 < slowTrend;
      bool nearFastEma = MathAbs(close1 - fastEntry) <= PullbackTolerancePoints * _Point;

      if(UseMACDConfirmation)
      {
         if(!ReadOne(m_macdHandle, 0, 1, macdMain) || !ReadOne(m_macdHandle, 1, 1, macdSignal))
         {
            reason = "macd data unavailable";
            return DIR_NONE;
         }
      }

      if(AllowBuy && bullishTrend && fastEntry > slowEntry && nearFastEma &&
         rsi > RSIOversold && rsi < RSIOverbought &&
         (!UseMACDConfirmation || macdMain > macdSignal))
      {
         reason = "bullish trend pullback confirmed";
         return DIR_BUY;
      }

      if(AllowSell && bearishTrend && fastEntry < slowEntry && nearFastEma &&
         rsi < RSIOverbought && rsi > RSIOversold &&
         (!UseMACDConfirmation || macdMain < macdSignal))
      {
         reason = "bearish trend pullback confirmed";
         return DIR_SELL;
      }

      reason = "trend, pullback, or momentum confirmation missing";
      return DIR_NONE;
   }
};

#endif
