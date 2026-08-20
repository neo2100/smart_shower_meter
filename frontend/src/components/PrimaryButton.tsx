import React from "react";
import {
  ActivityIndicator,
  Pressable,
  StyleSheet,
  Text,
  ViewStyle,
} from "react-native";
import * as Haptics from "expo-haptics";

import { colors, fonts, radius, spacing } from "@/src/theme/theme";

type Variant = "primary" | "secondary" | "danger" | "ghost";

type Props = {
  label: string;
  onPress: () => void;
  variant?: Variant;
  icon?: React.ReactNode;
  disabled?: boolean;
  loading?: boolean;
  style?: ViewStyle;
  testID?: string;
  compact?: boolean;
};

export function PrimaryButton({
  label,
  onPress,
  variant = "primary",
  icon,
  disabled,
  loading,
  style,
  testID,
  compact,
}: Props) {
  const bg =
    variant === "primary"
      ? colors.brandPrimary
      : variant === "danger"
        ? colors.warning
        : variant === "secondary"
          ? colors.surfaceSecondary
          : "transparent";
  const fg =
    variant === "primary" || variant === "danger"
      ? "#FFFFFF"
      : colors.onSurface;

  return (
    <Pressable
      testID={testID}
      disabled={disabled || loading}
      onPress={() => {
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
        onPress();
      }}
      style={({ pressed }) => [
        styles.base,
        compact && styles.compact,
        {
          backgroundColor: bg,
          borderWidth: variant === "secondary" || variant === "ghost" ? 1 : 0,
          borderColor: colors.border,
          opacity: disabled ? 0.5 : pressed ? 0.9 : 1,
          transform: [{ scale: pressed ? 0.98 : 1 }],
        },
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={fg} />
      ) : (
        <>
          {icon}
          <Text style={[styles.label, { color: fg }]}>{label}</Text>
        </>
      )}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  base: {
    height: 56,
    borderRadius: radius.pill,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: spacing.sm,
    paddingHorizontal: spacing.xl,
  },
  compact: {
    height: 46,
    paddingHorizontal: spacing.lg,
  },
  label: {
    fontFamily: fonts.text,
    fontSize: 16,
    fontWeight: "700",
    letterSpacing: 0.2,
  },
});
