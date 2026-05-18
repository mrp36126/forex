export function MetricCard({
  label,
  value,
  hint,
}: {
  label: string;
  value: string;
  hint?: string;
}) {
  return (
    <section className="card">
      <div className="muted">{label}</div>
      <div className="value">{value}</div>
      {hint ? <div className="muted">{hint}</div> : null}
    </section>
  );
}
