import React from "react";
import { Pressable, ScrollView, StyleSheet, Text, View } from "react-native";
import * as Haptics from "expo-haptics";

import { colors, fonts, radius, spacing } from "@/src/theme/theme";

export type SegOption<T extends string> = { label: string; value: T };

type Props<T extends string> = {
  options: SegOption<T>[];
  value: T;
  onChange: (v: T) => void;
  scrollable?: boolean;
  testID?: string;
};

export function Segmented<T extends string>({
  options,
  value,
  onChange,
  scrollable,
  testID,
}: Props<T>) {
  const content = options.map((opt) => {
    const active = opt.value === value;
    return (
      <Pressable
        key={opt.value}
        testID={`${testID}-${opt.value}`}
        onPress={() => {
          Haptics.selectionAsync();
          onChange(opt.value);
        }}
        style={[
          styles.chip,
          scrollable && styles.chipFixed,
          active && styles.chipActive,
        ]}
      >
        <Text style={[styles.chipText, active && styles.chipTextActive]}>
          {opt.label}
        </Text>
      </Pressable>
    );
  });

  if (scrollable) {
    return (
      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollRow}
        testID={testID}
      >
        {content}
      </ScrollView>
    );
  }

  return (
    <View style={styles.track} testID={testID}>
      {content}
    </View>
  );
}

const styles = StyleSheet.create({
  track: {
    flexDirection: "row",
    backgroundColor: colors.surfaceTertiary,
    borderRadius: radius.pill,
    padding: 4,
    gap: 4,
  },
  scrollRow: {
    gap: spacing.sm,
    paddingHorizontal: spacing.xs,
  },
  chip: {
    flex: 1,
    height: 40,
    borderRadius: radius.pill,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: spacing.md,
  },
  chipFixed: {
    flex: 0,
    flexShrink: 0,
    backgroundColor: colors.surfaceTertiary,
  },
  chipActive: {
    backgroundColor: colors.surfaceSecondary,
    shadowColor: "#1C1C1A",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.08,
    shadowRadius: 3,
    elevation: 1,
  },
  chipText: {
    fontFamily: fonts.text,
    fontSize: 14,
    fontWeight: "600",
    color: colors.onSurfaceTertiary,
  },
  chipTextActive: {
    color: colors.onSurface,
    fontWeight: "700",
  },
});
