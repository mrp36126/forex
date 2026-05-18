
#pragma once

class CBotLogger
{
public:
   void Info(const string message)  { Print("[INFO] ", message); }
   void Warn(const string message)  { Print("[WARN] ", message); }
   void Error(const string message) { Print("[ERROR] ", message, " | last_error=", GetLastError()); }

   void Decision(const string symbol, const string action, const string reason)
   {
      Print("[DECISION] symbol=", symbol, " action=", action, " reason=", reason);
   }
};
