#ifndef FOREX_RISK_BOT_RESEARCH_LOGGER_MQH
#define FOREX_RISK_BOT_RESEARCH_LOGGER_MQH

#include "Config.mqh"

class CResearchLogger
{
private:
   int    m_handle;
   string m_fileName;
   bool   m_enabled;

   string TimeStamp()
   {
      return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   }

   int CurrentHour()
   {
      MqlDateTime parts;
      TimeToStruct(TimeCurrent(), parts);
      return parts.hour;
   }

   int CurrentSpreadPoints(const string symbol)
   {
      return (int)SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   }

public:
   CResearchLogger()
   {
      m_handle = INVALID_HANDLE;
      m_fileName = "";
      m_enabled = false;
   }

   bool Init(const string symbol)
   {
      m_enabled = EnableResearchCsvLog;
      if(!m_enabled)
         return true;

      MqlDateTime localParts;
      TimeToStruct(TimeLocal(), localParts);
      m_fileName = StringFormat("ForexRiskBot_research_%s_%04d%02d%02d_%02d%02d%02d_%u_%I64d.csv",
                                symbol,
                                localParts.year,
                                localParts.mon,
                                localParts.day,
                                localParts.hour,
                                localParts.min,
                                localParts.sec,
                                GetTickCount(),
                                MagicNumber);

      m_handle = FileOpen(m_fileName,
                          FILE_WRITE | FILE_CSV | FILE_ANSI | FILE_COMMON,
                          ',');

      if(m_handle == INVALID_HANDLE)
      {
         Print("[WARN] research csv log could not be opened: ", m_fileName, " error=", GetLastError());
         m_enabled = false;
         return false;
      }

      FileWrite(m_handle,
                "timestamp",
                "symbol",
                "event",
                "action",
                "setup",
                "direction",
                "hour",
                "atr_points",
                "spread_points",
                "lots",
                "entry",
                "sl",
                "tp",
                "rr",
                "profit",
                "deal",
                "reason");
      FileFlush(m_handle);
      Print("[INFO] research csv log opened: ", m_fileName);
      return true;
   }

   void Close()
   {
      if(m_handle != INVALID_HANDLE)
      {
         FileFlush(m_handle);
         FileClose(m_handle);
         m_handle = INVALID_HANDLE;
      }
   }

   string FileName()
   {
      return m_fileName;
   }

   void LogEvent(const string symbol,
                 const string eventType,
                 const string action,
                 const string setup,
                 const string direction,
                 const double atrPoints,
                 const double lots,
                 const double entry,
                 const double sl,
                 const double tp,
                 const double rewardRisk,
                 const double profit,
                 const ulong deal,
                 const string reason)
   {
      if(!m_enabled || m_handle == INVALID_HANDLE)
         return;

      FileWrite(m_handle,
                TimeStamp(),
                symbol,
                eventType,
                action,
                setup,
                direction,
                CurrentHour(),
                DoubleToString(atrPoints, 1),
                CurrentSpreadPoints(symbol),
                DoubleToString(lots, 2),
                DoubleToString(entry, _Digits),
                DoubleToString(sl, _Digits),
                DoubleToString(tp, _Digits),
                DoubleToString(rewardRisk, 2),
                DoubleToString(profit, 2),
                (string)deal,
                reason);
      FileFlush(m_handle);
   }
};

#endif
