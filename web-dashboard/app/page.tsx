import { MetricCard } from "../components/MetricCard";
import { createServerSupabaseClient } from "../lib/supabase";

export default async function DashboardPage() {
  const supabase = createServerSupabaseClient();

  const [{ data: latestTrades }, { data: latestSignals }, { data: latestRiskEvents }] =
    await Promise.all([
      supabase.from("trade_logs").select("*").order("occurred_at", { ascending: false }).limit(10),
      supabase.from("signal_logs").select("*").order("occurred_at", { ascending: false }).limit(10),
      supabase.from("risk_events").select("*").order("occurred_at", { ascending: false }).limit(10),
    ]);

  const realizedPnl =
    latestTrades?.reduce((sum, trade) => sum + Number(trade.pnl ?? 0), 0) ?? 0;
  const winCount = latestTrades?.filter((trade) => Number(trade.pnl ?? 0) > 0).length ?? 0;
  const tradeCount = latestTrades?.length ?? 0;
  const winRate = tradeCount > 0 ? (winCount / tradeCount) * 100 : 0;

  return (
    <main>
      <h1>ForexRiskBot</h1>
      <p className="muted">
        Monitoring only. The MT5 Expert Advisor is the only component allowed to trade.
      </p>

      <div className="grid">
        <MetricCard label="Recent realized P/L" value={realizedPnl.toFixed(2)} />
        <MetricCard label="Recent win rate" value={`${winRate.toFixed(1)}%`} />
        <MetricCard label="Recent trades" value={String(tradeCount)} />
        <MetricCard
          label="Risk posture"
          value={latestRiskEvents?.[0]?.severity ?? "unknown"}
          hint={latestRiskEvents?.[0]?.message ?? "No risk events logged yet"}
        />
      </div>

      <section className="card" style={{ marginTop: 20 }}>
        <h2>Latest trade history</h2>
        <table>
          <thead>
            <tr>
              <th>Time</th>
              <th>Symbol</th>
              <th>Side</th>
              <th>P/L</th>
              <th>Reason</th>
            </tr>
          </thead>
          <tbody>
            {latestTrades?.map((trade) => (
              <tr key={trade.id}>
                <td>{trade.occurred_at}</td>
                <td>{trade.symbol}</td>
                <td>{trade.direction}</td>
                <td>{trade.pnl ?? "-"}</td>
                <td>{trade.reason ?? "-"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>

      <section className="card" style={{ marginTop: 20 }}>
        <h2>Latest blocked / accepted signals</h2>
        <table>
          <thead>
            <tr>
              <th>Time</th>
              <th>Symbol</th>
              <th>Action</th>
              <th>Reason</th>
            </tr>
          </thead>
          <tbody>
            {latestSignals?.map((signal) => (
              <tr key={signal.id}>
                <td>{signal.occurred_at}</td>
                <td>{signal.symbol}</td>
                <td>{signal.action}</td>
                <td>{signal.reason}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </section>
    </main>
  );
}
