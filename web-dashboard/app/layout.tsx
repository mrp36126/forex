import "./globals.css";
import type { ReactNode } from "react";

export const metadata = {
  title: "ForexRiskBot Dashboard",
  description: "Monitoring-only dashboard for ForexRiskBot",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
