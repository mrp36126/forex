create extension if not exists pgcrypto;

create table if not exists bot_settings (
  id uuid primary key default gen_random_uuid(),
  bot_name text not null default 'ForexRiskBot',
  symbol text not null,
  risk_percent numeric(6,3) not null,
  max_daily_loss_percent numeric(6,3) not null,
  max_trades_per_day integer not null,
  max_consecutive_losses integer not null,
  use_news_filter boolean not null default true,
  use_sentiment_filter boolean not null default false,
  enabled boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists trade_logs (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null,
  symbol text not null,
  direction text not null check (direction in ('buy','sell')),
  volume numeric(18,8) not null,
  entry_price numeric(18,8),
  stop_loss numeric(18,8),
  take_profit numeric(18,8),
  exit_price numeric(18,8),
  pnl numeric(18,8),
  magic_number bigint,
  reason text,
  broker_ticket bigint,
  created_at timestamptz not null default now()
);

create table if not exists signal_logs (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null,
  symbol text not null,
  timeframe text not null,
  action text not null check (action in ('buy','sell','no_trade')),
  reason text not null,
  ema_fast numeric(18,8),
  ema_slow numeric(18,8),
  rsi numeric(18,8),
  atr numeric(18,8),
  spread_points integer,
  created_at timestamptz not null default now()
);

create table if not exists sentiment_snapshots (
  id uuid primary key default gen_random_uuid(),
  observed_at timestamptz not null,
  symbol text not null,
  base_currency text not null,
  quote_currency text not null,
  sentiment text not null check (sentiment in ('bullish','bearish','neutral','high_uncertainty')),
  confidence numeric(6,5) not null check (confidence >= 0 and confidence <= 1),
  source_count integer not null default 0,
  summary text,
  raw_payload jsonb,
  created_at timestamptz not null default now()
);

create table if not exists risk_events (
  id uuid primary key default gen_random_uuid(),
  occurred_at timestamptz not null,
  symbol text,
  event_type text not null,
  severity text not null check (severity in ('info','warning','critical')),
  message text not null,
  details jsonb,
  created_at timestamptz not null default now()
);

create table if not exists backtest_results (
  id uuid primary key default gen_random_uuid(),
  strategy_version text not null,
  symbol text not null,
  timeframe text not null,
  start_date date not null,
  end_date date not null,
  total_return_percent numeric(10,4),
  max_drawdown_percent numeric(10,4),
  profit_factor numeric(10,4),
  win_rate_percent numeric(10,4),
  average_win numeric(18,8),
  average_loss numeric(18,8),
  expectancy numeric(18,8),
  sharpe_like numeric(10,4),
  max_consecutive_losses integer,
  monthly_performance jsonb,
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists idx_trade_logs_occurred_at on trade_logs (occurred_at desc);
create index if not exists idx_signal_logs_occurred_at on signal_logs (occurred_at desc);
create index if not exists idx_sentiment_snapshots_observed_at on sentiment_snapshots (observed_at desc);
create index if not exists idx_risk_events_occurred_at on risk_events (occurred_at desc);
