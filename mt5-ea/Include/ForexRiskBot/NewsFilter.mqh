#ifndef FOREX_RISK_BOT_NEWS_FILTER_MQH
#define FOREX_RISK_BOT_NEWS_FILTER_MQH
#include "Config.mqh"

class CNewsFilter
{
public:
   bool IsBlackoutWindow(const string symbol, string &reason)
   {
      if(!UseNewsFilter) return false;

      string base = StringSubstr(symbol, 0, 3);
      string quote = StringSubstr(symbol, 3, 3);
      datetime now = TimeTradeServer();
      datetime fromTime = now - NewsBlackoutMinutesBefore * 60;
      datetime toTime = now + NewsBlackoutMinutesAfter * 60;

      MqlCalendarValue values[];
      int countBase = CalendarValueHistory(values, fromTime, toTime, NULL, base);
      if(countBase < 0)
      {
         reason = "economic calendar unavailable for " + base;
         return true;
      }
      for(int i = 0; i < countBase; i++)
      {
         MqlCalendarEvent event;
         if(CalendarEventById(values[i].event_id, event) && event.importance == CALENDAR_IMPORTANCE_HIGH)
         {
            reason = "high-impact " + base + " news blackout";
            return true;
         }
      }

      ArrayFree(values);
      int countQuote = CalendarValueHistory(values, fromTime, toTime, NULL, quote);
      if(countQuote < 0)
      {
         reason = "economic calendar unavailable for " + quote;
         return true;
      }
      for(int j = 0; j < countQuote; j++)
      {
         MqlCalendarEvent event2;
         if(CalendarEventById(values[j].event_id, event2) && event2.importance == CALENDAR_IMPORTANCE_HIGH)
         {
            reason = "high-impact " + quote + " news blackout";
            return true;
         }
      }

      return false;
   }
};

#endif
