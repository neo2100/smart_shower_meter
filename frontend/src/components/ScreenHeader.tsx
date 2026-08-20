import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";

import { colors, fonts, spacing } from "@/src/theme/theme";

type Props = {
  title: string;
  subtitle?: string;
  right?: React.ReactNode;
};

export function ScreenHeader({ title, subtitle, right }: Props) {
  const insets = useSafeAreaInsets();
  return (
    <View style={[styles.wrap, { paddingTop: insets.top + spacing.sm }]}>
      <View style={styles.row}>
        <View style={styles.titles}>
          <Text style={styles.title}>{title}</Text>
          {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
        </View>
        {right ? <View>{right}</View> : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    backgroundColor: colors.surface,
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.md,
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  titles: {
    flexShrink: 1,
  },
  title: {
    fontFamily: fonts.display,
    fontSize: 28,
    fontWeight: "500",
    color: colors.onSurface,
    letterSpacing: -0.5,
  },
  subtitle: {
    fontFamily: fonts.text,
    fontSize: 14,
    color: colors.onSurfaceTertiary,
    marginTop: 2,
  },
});
