import React, { useMemo, useState } from "react";
import { ScrollView, StyleSheet, Text, View } from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";
import {
  ArrowDown,
  ArrowUp,
  CalendarBlank,
  ChartLineUp,
  Coins,
  Drop,
  Timer,
  TrendUp,
} from "phosphor-react-native";

import { ScreenHeader } from "@/src/components/ScreenHeader";
import { Segmented } from "@/src/components/Segmented";
import { StatCard } from "@/src/components/StatCard";
import { BarChart } from "@/src/components/BarChart";
import { EmptyState } from "@/src/components/EmptyState";
import { useAppData } from "@/src/context/AppDataContext";
import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";
import { computeAnalytics, type Metric } from "@/src/utils/analytics";
import { formatCost, formatDurationShort, formatLiters } from "@/src/utils/format";

const PERIODS = [
  { label: "7 days", value: "7" },
  { label: "14 days", value: "14" },
  { label: "30 days", value: "30" },
  { label: "90 days", value: "90" },
] as const;

const METRICS: { label: string; value: Metric }[] = [
  { label: "Time", value: "time" },
  { label: "Water", value: "water" },
  { label: "Cost", value: "cost" },
];

export default function AnalyticsScreen() {
  const { records, settings } = useAppData();
  const [period, setPeriod] = useState<"7" | "14" | "30" | "90">("7");
  const [metric, setMetric] = useState<Metric>("time");

  const a = useMemo(
    () => computeAnalytics(records, parseInt(period, 10)),
    [records, period],
  );

  const metricColor =
    metric === "time"
      ? colors.brandPrimary
      : metric === "water"
        ? colors.brandPrimary
        : colors.brandSecondary;

  const valueOf = (b: (typeof a.buckets)[number]) =>
    metric === "time" ? b.seconds : metric === "water" ? b.liters : b.cost;

  const formatValue = (v: number) =>
    metric === "time"
      ? formatDurationShort(v)
      : metric === "water"
        ? formatLiters(v)
        : formatCost(v, settings.currency);

  const hasData = a.totals.count > 0;

  return (
    <View style={styles.container}>
      <ScreenHeader title="Insights" subtitle="Your shower patterns" />

      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
      >
        <Segmented
          testID="period-segment"
          options={PERIODS as any}
          value={period}
          onChange={(v) => setPeriod(v as any)}
        />

        {!hasData ? (
          <View style={{ marginTop: spacing["2xl"] }}>
            <EmptyState
              testID="analytics-empty"
              icon={<ChartLineUp size={40} color={colors.brandPrimary} weight="fill" />}
              title="Not enough data yet"
              subtitle="Track a few showers to unlock trends and insights for this period."
            />
          </View>
        ) : (
          <>
            {/* Chart card */}
            <Animated.View entering={FadeInDown.springify().damping(18)} style={styles.chartCard}>
              <View style={styles.chartHeader}>
                <View>
                  <Text style={styles.chartTotalLabel}>
                    Total {metric === "time" ? "shower time" : metric}
                  </Text>
                  <Text style={styles.chartTotal}>
                    {metric === "time"
                      ? formatDurationShort(a.totals.seconds)
                      : metric === "water"
                        ? formatLiters(a.totals.liters)
                        : formatCost(a.totals.cost, settings.currency)}
                  </Text>
                </View>
                {a.trendPct !== null && (
                  <View
                    style={[
                      styles.trendPill,
                      {
                        backgroundColor:
                          a.trendPct <= 0 ? colors.brandTertiary : "#F3D9DA",
                      },
                    ]}
                  >
                    {a.trendPct <= 0 ? (
                      <ArrowDown size={13} color={colors.success} weight="bold" />
                    ) : (
                      <ArrowUp size={13} color={colors.warning} weight="bold" />
                    )}
                    <Text
                      style={[
                        styles.trendText,
                        { color: a.trendPct <= 0 ? colors.success : colors.warning },
                      ]}
                    >
                      {Math.abs(Math.round(a.trendPct))}%
                    </Text>
                  </View>
                )}
              </View>

              <View style={styles.metricSwitch}>
                <Segmented
                  testID="metric-segment"
                  options={METRICS}
                  value={metric}
                  onChange={setMetric}
                />
              </View>

              <BarChart
                buckets={a.buckets}
                metric={metric}
                color={metricColor}
                valueOf={valueOf}
                formatValue={formatValue}
              />
            </Animated.View>

            {/* Summary cards */}
            <View style={styles.grid}>
              <StatCard
                index={0}
                testID="stat-total-time"
                icon={<Timer size={20} color={colors.brandPrimary} weight="fill" />}
                label="Total time"
                value={formatDurationShort(a.totals.seconds)}
                sub={`${a.totals.count} sessions`}
              />
              <StatCard
                index={1}
                testID="stat-total-water"
                icon={<Drop size={20} color={colors.brandPrimary} weight="fill" />}
                label="Water used"
                value={formatLiters(a.totals.liters)}
                accent={colors.brandTertiary}
              />
            </View>
            <View style={styles.grid}>
              <StatCard
                index={2}
                testID="stat-total-cost"
                icon={<Coins size={20} color={colors.brandSecondary} weight="fill" />}
                label="Total cost"
                value={formatCost(a.totals.cost, settings.currency)}
                accent="#EDE7D9"
              />
              <StatCard
                index={3}
                testID="stat-avg-duration"
                icon={<TrendUp size={20} color={colors.brandPrimary} weight="fill" />}
                label="Avg / shower"
                value={formatDurationShort(a.avgDuration)}
                accent={colors.brandTertiary}
              />
            </View>

            {/* Detailed insights */}
            <Animated.View entering={FadeInDown.delay(240)} style={styles.insights}>
              <Text style={styles.insightsTitle}>Details</Text>
              <InsightRow
                icon={<CalendarBlank size={18} color={colors.brandPrimary} weight="bold" />}
                label="Active days"
                value={`${a.activeDays} day${a.activeDays === 1 ? "" : "s"}`}
              />
              <InsightRow
                icon={<TrendUp size={18} color={colors.brandPrimary} weight="bold" />}
                label="Avg per active day"
                value={formatDurationShort(a.avgPerActiveDay)}
              />
              <InsightRow
                icon={<Timer size={18} color={colors.brandPrimary} weight="bold" />}
                label="Longest shower"
                value={formatDurationShort(a.longest)}
              />
              {a.busiestDayLabel && (
                <InsightRow
                  icon={<ChartLineUp size={18} color={colors.brandPrimary} weight="bold" />}
                  label="Busiest day"
                  value={a.busiestDayLabel}
                  last
                />
              )}
            </Animated.View>
          </>
        )}
      </ScrollView>
    </View>
  );
}

function InsightRow({
  icon,
  label,
  value,
  last,
}: {
  icon: React.ReactNode;
  label: string;
  value: string;
  last?: boolean;
}) {
  return (
    <View style={[styles.insightRow, !last && styles.insightBorder]}>
      <View style={styles.insightLeft}>
        {icon}
        <Text style={styles.insightLabel}>{label}</Text>
      </View>
      <Text style={styles.insightValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  scroll: {
    paddingHorizontal: spacing.lg,
    paddingBottom: 120,
    gap: spacing.md,
  },
  chartCard: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.card,
    gap: spacing.lg,
  },
  chartHeader: {
    flexDirection: "row",
    alignItems: "flex-start",
    justifyContent: "space-between",
  },
  chartTotalLabel: {
    fontFamily: fonts.text,
    fontSize: 13,
    color: colors.muted,
    fontWeight: "600",
    textTransform: "capitalize",
  },
  chartTotal: {
    fontFamily: fonts.display,
    fontSize: 28,
    fontWeight: "500",
    color: colors.onSurface,
    marginTop: 2,
  },
  trendPill: {
    flexDirection: "row",
    alignItems: "center",
    gap: 3,
    paddingHorizontal: spacing.sm,
    paddingVertical: 5,
    borderRadius: radius.pill,
  },
  trendText: {
    fontFamily: fonts.text,
    fontSize: 12,
    fontWeight: "700",
  },
  metricSwitch: {
    marginTop: -spacing.xs,
  },
  grid: {
    flexDirection: "row",
    gap: spacing.md,
  },
  insights: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.soft,
  },
  insightsTitle: {
    fontFamily: fonts.display,
    fontSize: 16,
    fontWeight: "500",
    color: colors.onSurface,
    marginBottom: spacing.sm,
  },
  insightRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingVertical: spacing.md,
  },
  insightBorder: {
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  insightLeft: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
  },
  insightLabel: {
    fontFamily: fonts.text,
    fontSize: 14,
    color: colors.onSurfaceTertiary,
    fontWeight: "500",
  },
  insightValue: {
    fontFamily: fonts.text,
    fontSize: 14,
    fontWeight: "700",
    color: colors.onSurface,
  },
});
