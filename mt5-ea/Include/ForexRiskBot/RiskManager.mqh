#ifndef FOREX_RISK_BOT_RISK_MANAGER_MQH
#define FOREX_RISK_BOT_RISK_MANAGER_MQH
#include "Config.mqh"

class CRiskManager
{
private:
   datetime m_dayStart;
   double   m_dayStartBalance;
   int      m_tradesToday;
   int      m_consecutiveLosses;

   datetime StartOfDay(datetime value)
   {
      MqlDateTime parts;
      TimeToStruct(value, parts);
      parts.hour = 0;
      parts.min = 0;
      parts.sec = 0;
      return StructToTime(parts);
   }

public:
   CRiskManager()
   {
      m_dayStart = 0;
      m_dayStartBalance = 0.0;
      m_tradesToday = 0;
      m_consecutiveLosses = 0;
   }

   void RefreshDay()
   {
      datetime today = StartOfDay(TimeCurrent());
      if(today != m_dayStart)
      {
         m_dayStart = today;
         m_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_tradesToday = 0;
         m_consecutiveLosses = 0;
      }
   }

   double DailyPnlPercent()
   {
      RefreshDay();
      if(m_dayStartBalance <= 0.0) return 0.0;
      return ((AccountInfoDouble(ACCOUNT_EQUITY) - m_dayStartBalance) / m_dayStartBalance) * 100.0;
   }

   bool DailyLossLimitReached()
   {
      return DailyPnlPercent() <= -MathAbs(MaxDailyLossPercent);
   }

   bool DailyProfitTargetReached()
   {
      if(DailyProfitTargetPercent <= 0.0) return false;
      return DailyPnlPercent() >= DailyProfitTargetPercent;
   }

   bool CanOpenNewTrade(string &reason)
   {
      RefreshDay();
      if(DailyLossLimitReached())       { reason = "daily loss limit reached"; return false; }
      if(DailyProfitTargetReached())    { reason = "daily profit target reached"; return false; }
      if(m_tradesToday >= MaxTradesPerDay) { reason = "max trades per day reached"; return false; }
      if(m_consecutiveLosses >= MaxConsecutiveLosses) { reason = "consecutive loss lockout active"; return false; }
      if(CurrentOpenRiskPercent() >= MaxTotalOpenRiskPercent) { reason = "maximum total open risk reached"; return false; }
      return true;
   }

   void RegisterTradeOpened()
   {
      RefreshDay();
      m_tradesToday++;
   }

   void RegisterClosedTrade(const double profit)
   {
      if(profit < 0.0) m_consecutiveLosses++;
      else if(profit > 0.0) m_consecutiveLosses = 0;
   }

   double CalculateLotSize(const string symbol, const double stopDistancePrice)
   {
      if(stopDistancePrice <= 0.0) return 0.0;

      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskMoney = balance * (MathMin(MathMax(RiskPercent, 0.0), 1.0) / 100.0);
      double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double volumeMin = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double volumeMax = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);

      if(tickSize <= 0.0 || tickValue <= 0.0 || volumeStep <= 0.0) return 0.0;

      double lossPerLot = (stopDistancePrice / tickSize) * tickValue;
      if(lossPerLot <= 0.0) return 0.0;

      double rawLots = riskMoney / lossPerLot;
      double steppedLots = MathFloor(rawLots / volumeStep) * volumeStep;
      if(steppedLots < volumeMin) return 0.0;
      return MathMin(steppedLots, volumeMax);
   }

   double CurrentOpenRiskPercent()
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(balance <= 0.0) return 0.0;

      double totalRiskMoney = 0.0;
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0 || !PositionSelectByTicket(ticket)) continue;

         string symbol = PositionGetString(POSITION_SYMBOL);
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double stopLoss = PositionGetDouble(POSITION_SL);
         double volume = PositionGetDouble(POSITION_VOLUME);
         if(stopLoss <= 0.0 || volume <= 0.0) continue;

         double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
         double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
         if(tickSize <= 0.0 || tickValue <= 0.0) continue;

         double stopDistance = MathAbs(openPrice - stopLoss);
         totalRiskMoney += (stopDistance / tickSize) * tickValue * volume;
      }

      return (totalRiskMoney / balance) * 100.0;
   }
};

#endif
