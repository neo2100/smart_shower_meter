import React from "react";
import { StyleSheet, Text, View } from "react-native";
import { Image } from "expo-image";

import { colors, fonts, radius, spacing } from "@/src/theme/theme";

type Props = {
  title: string;
  subtitle?: string;
  icon?: React.ReactNode;
  imageUrl?: string;
  testID?: string;
};

export function EmptyState({ title, subtitle, icon, imageUrl, testID }: Props) {
  return (
    <View style={styles.wrap} testID={testID}>
      {imageUrl ? (
        <Image
          source={{ uri: imageUrl }}
          style={styles.image}
          contentFit="cover"
          transition={300}
        />
      ) : (
        <View style={styles.iconWrap}>{icon}</View>
      )}
      <Text style={styles.title}>{title}</Text>
      {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: {
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: spacing["3xl"],
    paddingHorizontal: spacing.xl,
    gap: spacing.sm,
  },
  image: {
    width: 120,
    height: 120,
    borderRadius: radius.lg,
    marginBottom: spacing.md,
    opacity: 0.9,
  },
  iconWrap: {
    width: 88,
    height: 88,
    borderRadius: radius.pill,
    backgroundColor: colors.brandTertiary,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: spacing.md,
  },
  title: {
    fontFamily: fonts.display,
    fontSize: 18,
    fontWeight: "500",
    color: colors.onSurface,
    textAlign: "center",
  },
  subtitle: {
    fontFamily: fonts.text,
    fontSize: 14,
    color: colors.onSurfaceTertiary,
    textAlign: "center",
    maxWidth: 260,
    lineHeight: 20,
  },
});
