import React from "react";
import { StyleSheet, View } from "react-native";

import { colors, radius } from "@/src/theme/theme";

type Props = {
  levels: number[]; // 0..1 amplitudes, oldest -> newest
  active: boolean;
  bars?: number;
};

// Live scrolling waveform driven by real mic metering data.
export function Waveform({ levels, active, bars = 40 }: Props) {
  // pad to fixed width so bars stay aligned as data streams in
  const padded =
    levels.length >= bars
      ? levels.slice(levels.length - bars)
      : [...Array(bars - levels.length).fill(0), ...levels];

  return (
    <View style={styles.wrap}>
      {padded.map((lvl, i) => {
        const h = Math.max(3, lvl * 100);
        return (
          <View
            key={i}
            style={[
              styles.bar,
              {
                height: `${h}%`,
                backgroundColor: active
                  ? lvl > 0.55
                    ? colors.brandPrimary
                    : colors.brandSecondary
                  : colors.surfaceTertiary,
              },
            ]}
          />
        );
      })}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    height: 140,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 3,
  },
  bar: {
    flex: 1,
    borderRadius: radius.pill,
    minHeight: 3,
    maxWidth: 6,
  },
});
