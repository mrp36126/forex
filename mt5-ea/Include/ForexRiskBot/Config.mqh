
#pragma once

input double RiskPercent = 0.50;
input double MaxDailyLossPercent = 2.00;
input int    MaxTradesPerDay = 3;
input int    MaxConsecutiveLosses = 2;
input int    ATRPeriod = 14;
input double ATRMultiplierSL = 1.50;
input double RewardRiskRatio = 2.00;
input int    EMAFastPeriod = 50;
input int    EMASlowPeriod = 200;
input int    RSIPeriod = 14;
input double RSIOverbought = 70.0;
input double RSIOversold = 30.0;
input int    MaxSpreadPoints = 25;
input bool   AllowBuy = true;
input bool   AllowSell = true;
input bool   UseNewsFilter = true;
input int    NewsBlackoutMinutesBefore = 45;
input int    NewsBlackoutMinutesAfter = 45;
input bool   UseSentimentFilter = false;
input double MinimumSentimentConfidence = 0.70;
input int    TradeStartHour = 7;
input int    TradeEndHour = 20;
input long   MagicNumber = 26051801;

input ENUM_TIMEFRAMES TrendTimeframe = PERIOD_H1;
input ENUM_TIMEFRAMES EntryTimeframe = PERIOD_M15;
input bool   UseMACDConfirmation = false;
input bool   UseVolumeFilter = false;
input bool   EnableBreakEven = false;
input bool   EnableTrailingStop = false;
input double BreakEvenAtR = 1.0;
input double MaxTotalOpenRiskPercent = 2.0;
input double DailyProfitTargetPercent = 0.0;
input int    StructureLookbackBars = 20;
input int    PullbackTolerancePoints = 50;

enum TradeDirection
{
   DIR_NONE = 0,
   DIR_BUY = 1,
   DIR_SELL = -1
};

enum SentimentState
{
   SENTIMENT_NEUTRAL = 0,
   SENTIMENT_BULLISH = 1,
   SENTIMENT_BEARISH = -1,
   SENTIMENT_HIGH_UNCERTAINTY = 2
};
