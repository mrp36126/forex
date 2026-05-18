#ifndef FOREX_RISK_BOT_TRADE_MANAGER_MQH
#define FOREX_RISK_BOT_TRADE_MANAGER_MQH
#include <Trade/Trade.mqh>
#include "Config.mqh"

class CTradeManager
{
private:
   CTrade m_trade;

public:
   void Init()
   {
      m_trade.SetExpertMagicNumber(MagicNumber);
      m_trade.SetDeviationInPoints(10);
   }

   bool HasOpenPosition(const string symbol)
   {
      return PositionSelect(symbol);
   }

   bool IsSpreadAcceptable(const string symbol, string &reason)
   {
      long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
      if(spread > MaxSpreadPoints)
      {
         reason = "spread too high";
         return false;
      }
      return true;
   }

   bool IsWithinTradingHours(string &reason)
   {
      MqlDateTime tm;
      TimeToStruct(TimeCurrent(), tm);
      bool inSession = false;
      if(TradeStartHour <= TradeEndHour)
         inSession = (tm.hour >= TradeStartHour && tm.hour < TradeEndHour);
      else
         inSession = (tm.hour >= TradeStartHour || tm.hour < TradeEndHour);

      if(!inSession) reason = "outside trading hours";
      return inSession;
   }

   bool OpenPosition(const string symbol, const TradeDirection direction, const double lots,
                     const double stopLoss, const double takeProfit, string &reason)
   {
      bool submitted = false;
      if(direction == DIR_BUY)
         submitted = m_trade.Buy(lots, symbol, 0.0, stopLoss, takeProfit, "ForexRiskBot");
      else if(direction == DIR_SELL)
         submitted = m_trade.Sell(lots, symbol, 0.0, stopLoss, takeProfit, "ForexRiskBot");

      if(!submitted)
      {
         reason = "trade request submission failed";
         return false;
      }

      uint retcode = m_trade.ResultRetcode();
      if(retcode != TRADE_RETCODE_DONE && retcode != TRADE_RETCODE_PLACED)
      {
         reason = "trade rejected retcode=" + IntegerToString((int)retcode);
         return false;
      }
      return true;
   }

   bool AreStopsValid(const string symbol, const TradeDirection direction,
                      const double entry, const double stopLoss, const double takeProfit,
                      string &reason)
   {
      int stopsLevelPoints = (int)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double minimumDistance = stopsLevelPoints * SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(minimumDistance <= 0.0) return true;

      double stopDistance = MathAbs(entry - stopLoss);
      double targetDistance = MathAbs(takeProfit - entry);
      if(stopDistance < minimumDistance || targetDistance < minimumDistance)
      {
         reason = "stop or target is inside broker minimum distance";
         return false;
      }

      return true;
   }
};

#endif
