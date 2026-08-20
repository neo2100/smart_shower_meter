import dayjs from "dayjs";

import type { ShowerRecord } from "@/src/types";

const pad = (n: number) => String(n).padStart(2, "0");

// Big timer display -> H:MM:SS (hours only when present)
export function formatClock(totalSeconds: number): string {
  const s = Math.max(0, Math.floor(totalSeconds));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  if (h > 0) return `${h}:${pad(m)}:${pad(sec)}`;
  return `${pad(m)}:${pad(sec)}`;
}

// Human friendly short duration -> "12m 30s"
export function formatDurationShort(totalSeconds: number): string {
  const s = Math.max(0, Math.floor(totalSeconds));
  const h = Math.floor(s / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  if (h > 0) return `${h}h ${m}m`;
  if (m > 0) return `${m}m ${pad(sec)}s`;
  return `${sec}s`;
}

export function litersForRecord(r: ShowerRecord): number {
  return (r.flowRate * r.duration) / 60;
}

export function costForRecord(r: ShowerRecord): number {
  return litersForRecord(r) * r.costPerLiter;
}

export function formatLiters(liters: number): string {
  if (liters >= 100) return `${Math.round(liters)} L`;
  return `${liters.toFixed(1)} L`;
}

export function formatCost(amount: number, currency: string): string {
  return `${currency}${amount.toFixed(2)}`;
}

export function formatDayLabel(iso: string): string {
  const d = dayjs(iso);
  if (d.isSame(dayjs(), "day")) return "Today";
  if (d.isSame(dayjs().subtract(1, "day"), "day")) return "Yesterday";
  return d.format("ddd, MMM D");
}

export function formatTime(iso: string): string {
  return dayjs(iso).format("h:mm A");
}
