import React from "react";
import { StyleSheet, Text, View } from "react-native";
import Animated, { FadeInUp } from "react-native-reanimated";

import { colors, fonts, radius, spacing } from "@/src/theme/theme";
import type { Bucket } from "@/src/utils/analytics";

type Props = {
  buckets: Bucket[];
  metric: "time" | "water" | "cost";
  color?: string;
  valueOf: (b: Bucket) => number;
  formatValue: (v: number) => string;
};

export function BarChart({ buckets, color = colors.brandPrimary, valueOf, formatValue }: Props) {
  const values = buckets.map(valueOf);
  const max = Math.max(1, ...values);
  const maxIdx = values.indexOf(Math.max(...values));

  return (
    <View style={styles.wrap}>
      <View style={styles.chart}>
        {buckets.map((b, i) => {
          const v = values[i];
          const ratio = v / max;
          const isMax = i === maxIdx && v > 0;
          return (
            <View key={b.key} style={styles.col}>
              <View style={styles.barTrack}>
                {v > 0 && (
                  <Animated.View
                    entering={FadeInUp.delay(i * 18).duration(420)}
                    style={[
                      styles.bar,
                      {
                        height: `${Math.max(4, ratio * 100)}%`,
                        backgroundColor: isMax ? color : colors.brandTertiary,
                      },
                    ]}
                  />
                )}
              </View>
            </View>
          );
        })}
      </View>
      <View style={styles.labels}>
        {buckets.map((b, i) => {
          // show a sparse set of labels to avoid clutter
          const step = Math.ceil(buckets.length / 7);
          const show = i % step === 0 || i === buckets.length - 1;
          return (
            <Text key={b.key} style={styles.label} numberOfLines={1}>
              {show ? b.label : ""}
            </Text>
          );
        })}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    gap: spacing.sm,
  },
  chart: {
    height: 160,
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 3,
  },
  col: {
    flex: 1,
    height: "100%",
    justifyContent: "flex-end",
  },
  barTrack: {
    height: "100%",
    justifyContent: "flex-end",
  },
  bar: {
    width: "100%",
    borderRadius: radius.sm,
    minHeight: 4,
  },
  labels: {
    flexDirection: "row",
    gap: 3,
  },
  label: {
    flex: 1,
    textAlign: "center",
    fontFamily: fonts.text,
    fontSize: 10,
    color: colors.muted,
  },
});
