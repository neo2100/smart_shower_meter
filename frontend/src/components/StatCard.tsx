import React from "react";
import { StyleSheet, Text, View } from "react-native";
import Animated, { FadeInDown } from "react-native-reanimated";

import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";

type Props = {
  icon: React.ReactNode;
  label: string;
  value: string;
  sub?: string;
  accent?: string;
  index?: number;
  testID?: string;
};

export function StatCard({
  icon,
  label,
  value,
  sub,
  accent = colors.brandTertiary,
  index = 0,
  testID,
}: Props) {
  return (
    <Animated.View
      entering={FadeInDown.delay(index * 60).springify().damping(18)}
      style={styles.card}
      testID={testID}
    >
      <View style={[styles.iconWrap, { backgroundColor: accent }]}>{icon}</View>
      <Text style={styles.value} numberOfLines={1} adjustsFontSizeToFit>
        {value}
      </Text>
      <Text style={styles.label}>{label}</Text>
      {sub ? <Text style={styles.sub}>{sub}</Text> : null}
    </Animated.View>
  );
}

const styles = StyleSheet.create({
  card: {
    flex: 1,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.soft,
  },
  iconWrap: {
    width: 40,
    height: 40,
    borderRadius: radius.md,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: spacing.md,
  },
  value: {
    fontFamily: fonts.display,
    fontSize: 26,
    color: colors.onSurface,
    fontWeight: "500",
  },
  label: {
    fontFamily: fonts.text,
    fontSize: 13,
    color: colors.onSurfaceTertiary,
    marginTop: 2,
    fontWeight: "600",
  },
  sub: {
    fontFamily: fonts.text,
    fontSize: 12,
    color: colors.muted,
    marginTop: 2,
  },
});
