import React, { useEffect, useState } from "react";
import { StyleSheet, Text, TextInput, View } from "react-native";
import { KeyboardAwareScrollView } from "react-native-keyboard-controller";
import * as Haptics from "expo-haptics";
import {
  Coins,
  Drop,
  Info,
  ShieldCheck,
  Waveform as WaveformIcon,
} from "phosphor-react-native";

import { ScreenHeader } from "@/src/components/ScreenHeader";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { Segmented } from "@/src/components/Segmented";
import { useAppData } from "@/src/context/AppDataContext";
import { useToast } from "@/src/components/Toast";
import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";
import { formatCost, formatLiters } from "@/src/utils/format";

const SENSITIVITY = [
  { label: "Low", value: "0.35" },
  { label: "Medium", value: "0.5" },
  { label: "High", value: "0.65" },
];

export default function SettingsScreen() {
  const { settings, updateSettings } = useAppData();
  const toast = useToast();

  const [flow, setFlow] = useState(String(settings.flowRate));
  const [cost, setCost] = useState(String(settings.costPerLiter));
  const [currency, setCurrency] = useState(settings.currency);
  const [sensitivity, setSensitivity] = useState(String(settings.sensitivity));

  useEffect(() => {
    setFlow(String(settings.flowRate));
    setCost(String(settings.costPerLiter));
    setCurrency(settings.currency);
    setSensitivity(String(settings.sensitivity));
  }, [settings]);

  const flowNum = parseFloat(flow) || 0;
  const costNum = parseFloat(cost) || 0;

  // 10 minute preview
  const previewLiters = (flowNum * 600) / 60;
  const previewCost = previewLiters * costNum;

  const handleSave = async () => {
    Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    await updateSettings({
      flowRate: flowNum,
      costPerLiter: costNum,
      currency: currency.trim() || "$",
      sensitivity: parseFloat(sensitivity) || 0.5,
    });
    toast("Settings saved", "success");
  };

  return (
    <View style={styles.container}>
      <ScreenHeader title="Settings" subtitle="Personalize your metering" />

      <KeyboardAwareScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
        bottomOffset={24}
      >
        {/* Water & cost */}
        <View style={styles.card}>
          <View style={styles.cardHead}>
            <Drop size={20} color={colors.brandPrimary} weight="fill" />
            <Text style={styles.cardTitle}>Water &amp; cost</Text>
          </View>

          <Text style={styles.label}>Flow rate (liters / minute)</Text>
          <TextInput
            testID="settings-flow-input"
            value={flow}
            onChangeText={setFlow}
            keyboardType="decimal-pad"
            style={styles.input}
            placeholder="9"
            placeholderTextColor={colors.muted}
          />

          <Text style={styles.label}>Cost per liter</Text>
          <TextInput
            testID="settings-cost-input"
            value={cost}
            onChangeText={setCost}
            keyboardType="decimal-pad"
            style={styles.input}
            placeholder="0.003"
            placeholderTextColor={colors.muted}
          />

          <Text style={styles.label}>Currency symbol</Text>
          <TextInput
            testID="settings-currency-input"
            value={currency}
            onChangeText={setCurrency}
            maxLength={3}
            style={styles.input}
            placeholder="$"
            placeholderTextColor={colors.muted}
          />

          <View style={styles.preview}>
            <View style={styles.previewItem}>
              <Drop size={16} color={colors.brandPrimary} weight="fill" />
              <Text style={styles.previewText}>
                {formatLiters(previewLiters)}
              </Text>
            </View>
            <View style={styles.previewItem}>
              <Coins size={16} color={colors.brandSecondary} weight="fill" />
              <Text style={styles.previewText}>
                {formatCost(previewCost, currency || "$")}
              </Text>
            </View>
            <Text style={styles.previewLabel}>per 10-min shower</Text>
          </View>
        </View>

        {/* Smart meter */}
        <View style={styles.card}>
          <View style={styles.cardHead}>
            <WaveformIcon size={20} color={colors.brandPrimary} weight="fill" />
            <Text style={styles.cardTitle}>Smart meter</Text>
          </View>
          <Text style={styles.label}>Detection sensitivity</Text>
          <Segmented
            testID="settings-sensitivity"
            options={SENSITIVITY}
            value={sensitivity}
            onChange={setSensitivity}
          />
          <Text style={styles.helper}>
            Higher sensitivity starts the timer with quieter water sounds.
          </Text>
        </View>

        {/* Privacy */}
        <View style={styles.card}>
          <View style={styles.cardHead}>
            <ShieldCheck size={20} color={colors.success} weight="fill" />
            <Text style={styles.cardTitle}>Privacy</Text>
          </View>
          <Text style={styles.helper}>
            All data stays on your device. No account, no cloud, no tracking.
            Microphone audio is analyzed locally and never recorded or uploaded.
          </Text>
        </View>

        <View style={styles.about}>
          <Info size={14} color={colors.muted} weight="bold" />
          <Text style={styles.aboutText}>Smart Shower Meter · v1.0</Text>
        </View>

        <PrimaryButton
          testID="settings-save-button"
          label="Save changes"
          onPress={handleSave}
        />
      </KeyboardAwareScrollView>
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
  card: {
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.soft,
  },
  cardHead: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.sm,
    marginBottom: spacing.lg,
  },
  cardTitle: {
    fontFamily: fonts.display,
    fontSize: 17,
    fontWeight: "500",
    color: colors.onSurface,
  },
  label: {
    fontFamily: fonts.text,
    fontSize: 13,
    fontWeight: "600",
    color: colors.onSurfaceTertiary,
    marginBottom: spacing.sm,
  },
  input: {
    height: 52,
    borderRadius: radius.md,
    backgroundColor: colors.surface,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.lg,
    fontFamily: fonts.text,
    fontSize: 16,
    color: colors.onSurface,
    marginBottom: spacing.lg,
  },
  preview: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.lg,
    backgroundColor: colors.brandTertiary,
    borderRadius: radius.md,
    padding: spacing.md,
  },
  previewItem: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.xs,
  },
  previewText: {
    fontFamily: fonts.display,
    fontSize: 15,
    fontWeight: "500",
    color: colors.onBrandTertiary,
  },
  previewLabel: {
    fontFamily: fonts.text,
    fontSize: 11,
    color: colors.onBrandTertiary,
    marginLeft: "auto",
    opacity: 0.8,
  },
  helper: {
    fontFamily: fonts.text,
    fontSize: 13,
    color: colors.muted,
    lineHeight: 19,
    marginTop: spacing.sm,
  },
  about: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: spacing.xs,
    paddingVertical: spacing.sm,
  },
  aboutText: {
    fontFamily: fonts.text,
    fontSize: 12,
    color: colors.muted,
  },
});
