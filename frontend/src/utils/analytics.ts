import dayjs from "dayjs";

import type { ShowerRecord } from "@/src/types";
import { costForRecord, litersForRecord } from "@/src/utils/format";

export type Metric = "time" | "water" | "cost";

export type Bucket = {
  key: string;
  label: string;
  seconds: number;
  liters: number;
  cost: number;
  count: number;
};

export type AnalyticsResult = {
  buckets: Bucket[];
  totals: { seconds: number; liters: number; cost: number; count: number };
  avgDuration: number; // seconds per session
  avgPerActiveDay: number; // seconds per day that had a shower
  longest: number; // seconds
  activeDays: number;
  busiestDayLabel: string | null;
  trendPct: number | null; // % change in total seconds vs previous period
};

function emptyTotals() {
  return { seconds: 0, liters: 0, cost: 0, count: 0 };
}

function sumRange(records: ShowerRecord[], start: dayjs.Dayjs, end: dayjs.Dayjs) {
  const t = emptyTotals();
  for (const r of records) {
    const d = dayjs(r.startedAt);
    if (d.isAfter(start) && !d.isAfter(end)) {
      t.seconds += r.duration;
      t.liters += litersForRecord(r);
      t.cost += costForRecord(r);
      t.count += 1;
    }
  }
  return t;
}

export function computeAnalytics(
  records: ShowerRecord[],
  days: number,
): AnalyticsResult {
  const now = dayjs();
  const start = now.subtract(days - 1, "day").startOf("day");

  const inRange = records.filter((r) => {
    const d = dayjs(r.startedAt);
    return !d.isBefore(start) && !d.isAfter(now);
  });

  // Bucketing: daily up to 31 days, else weekly.
  const weekly = days > 31;
  const bucketMap = new Map<string, Bucket>();

  if (weekly) {
    const weeks = Math.ceil(days / 7);
    for (let i = weeks - 1; i >= 0; i--) {
      const wStart = now.subtract(i, "week").startOf("day");
      const key = wStart.format("YYYY-ww");
      bucketMap.set(key, {
        key,
        label: wStart.format("MMM D"),
        ...emptyTotals(),
      });
    }
  } else {
    for (let i = days - 1; i >= 0; i--) {
      const d = now.subtract(i, "day");
      const key = d.format("YYYY-MM-DD");
      bucketMap.set(key, {
        key,
        label: d.format(days <= 7 ? "dd" : "D"),
        ...emptyTotals(),
      });
    }
  }

  const keys = Array.from(bucketMap.keys());
  const dailyTotals = new Map<string, number>();

  for (const r of inRange) {
    const d = dayjs(r.startedAt);
    const dayKey = d.format("YYYY-MM-DD");
    dailyTotals.set(dayKey, (dailyTotals.get(dayKey) ?? 0) + r.duration);

    let key: string;
    if (weekly) {
      // find the closest week bucket start
      const diffWeeks = Math.floor(now.diff(d, "day") / 7);
      key = keys[keys.length - 1 - diffWeeks] ?? keys[keys.length - 1];
    } else {
      key = dayKey;
    }
    const b = bucketMap.get(key);
    if (b) {
      b.seconds += r.duration;
      b.liters += litersForRecord(r);
      b.cost += costForRecord(r);
      b.count += 1;
    }
  }

  const buckets = Array.from(bucketMap.values());
  const totals = buckets.reduce((acc, b) => {
    acc.seconds += b.seconds;
    acc.liters += b.liters;
    acc.cost += b.cost;
    acc.count += b.count;
    return acc;
  }, emptyTotals());

  const activeDays = dailyTotals.size;
  const avgDuration = totals.count > 0 ? totals.seconds / totals.count : 0;
  const avgPerActiveDay = activeDays > 0 ? totals.seconds / activeDays : 0;
  const longest = inRange.reduce((m, r) => Math.max(m, r.duration), 0);

  let busiestDayLabel: string | null = null;
  let busiestVal = -1;
  for (const [k, v] of dailyTotals.entries()) {
    if (v > busiestVal) {
      busiestVal = v;
      busiestDayLabel = dayjs(k).format("ddd, MMM D");
    }
  }

  // Trend vs previous equal-length period
  const prevEnd = start;
  const prevStart = start.subtract(days, "day");
  const prev = sumRange(records, prevStart, prevEnd);
  let trendPct: number | null = null;
  if (prev.seconds > 0) {
    trendPct = ((totals.seconds - prev.seconds) / prev.seconds) * 100;
  } else if (totals.seconds > 0) {
    trendPct = 100;
  }

  return {
    buckets,
    totals,
    avgDuration,
    avgPerActiveDay,
    longest,
    activeDays,
    busiestDayLabel,
    trendPct,
  };
}
