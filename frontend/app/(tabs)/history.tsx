import React, { useMemo, useState } from "react";
import {
  Modal,
  Pressable,
  ScrollView,
  SectionList,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import { KeyboardAvoidingView } from "react-native-keyboard-controller";
import Animated, { FadeIn } from "react-native-reanimated";
import * as Haptics from "expo-haptics";
import {
  Coins,
  Drop,
  PencilSimple,
  Timer,
  Trash,
  Waveform as WaveformIcon,
  X,
} from "phosphor-react-native";

import { ScreenHeader } from "@/src/components/ScreenHeader";
import { EmptyState } from "@/src/components/EmptyState";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAppData } from "@/src/context/AppDataContext";
import { useToast } from "@/src/components/Toast";
import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";
import type { ShowerRecord } from "@/src/types";
import {
  costForRecord,
  formatCost,
  formatDayLabel,
  formatDurationShort,
  formatLiters,
  formatTime,
  litersForRecord,
} from "@/src/utils/format";

export default function HistoryScreen() {
  const insets = useSafeAreaInsets();
  const { records, settings, updateRecord, deleteRecord } = useAppData();
  const toast = useToast();
  const [editing, setEditing] = useState<ShowerRecord | null>(null);

  const sections = useMemo(() => {
    const map = new Map<string, ShowerRecord[]>();
    for (const r of records) {
      const key = formatDayLabel(r.startedAt);
      if (!map.has(key)) map.set(key, []);
      map.get(key)!.push(r);
    }
    return Array.from(map.entries()).map(([title, data]) => ({ title, data }));
  }, [records]);

  return (
    <View style={styles.container}>
      <ScreenHeader
        title="History"
        subtitle={
          records.length
            ? `${records.length} shower${records.length > 1 ? "s" : ""} tracked`
            : "Your shower log"
        }
      />

      {records.length === 0 ? (
        <EmptyState
          testID="history-empty"
          imageUrl="https://images.unsplash.com/photo-1584982442479-16e4ac81adff?crop=entropy&cs=srgb&fm=jpg&w=400&q=80"
          title="No showers recorded yet"
          subtitle="Start the timer or use Smart Meter — your sessions will appear here."
        />
      ) : (
        <SectionList
          sections={sections}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.list}
          showsVerticalScrollIndicator={false}
          stickySectionHeadersEnabled={false}
          renderSectionHeader={({ section }) => (
            <Text style={styles.sectionTitle}>{section.title}</Text>
          )}
          renderItem={({ item, index }) => (
            <Animated.View entering={FadeIn.delay(index * 30)}>
              <Pressable
                testID={`history-row-${item.id}`}
                onPress={() => {
                  Haptics.selectionAsync();
                  setEditing(item);
                }}
                style={({ pressed }) => [styles.card, pressed && { opacity: 0.9 }]}
              >
                <View style={styles.cardIcon}>
                  {item.source === "smart" ? (
                    <WaveformIcon size={20} color={colors.brandPrimary} weight="fill" />
                  ) : (
                    <Timer size={20} color={colors.brandPrimary} weight="fill" />
                  )}
                </View>
                <View style={styles.cardMain}>
                  <Text style={styles.cardTime}>{formatTime(item.startedAt)}</Text>
                  <View style={styles.cardMeta}>
                    <Text style={styles.metaChip}>
                      {formatDurationShort(item.duration)}
                    </Text>
                    <Text style={styles.metaDot}>·</Text>
                    <Text style={styles.metaChip}>
                      {formatLiters(litersForRecord(item))}
                    </Text>
                  </View>
                </View>
                <View style={styles.cardTrailing}>
                  <Text style={styles.cardCost}>
                    {formatCost(costForRecord(item), settings.currency)}
                  </Text>
                  <PencilSimple size={16} color={colors.muted} weight="bold" />
                </View>
              </Pressable>
            </Animated.View>
          )}
        />
      )}

      <EditRecordModal
        record={editing}
        currency={settings.currency}
        onClose={() => setEditing(null)}
        onSave={async (id, patch) => {
          await updateRecord(id, patch);
          setEditing(null);
          toast("Record updated", "success");
        }}
        onDelete={async (id) => {
          Haptics.notificationAsync(Haptics.NotificationFeedbackType.Warning);
          await deleteRecord(id);
          setEditing(null);
          toast("Record deleted", "warning");
        }}
        bottomInset={insets.bottom}
      />
    </View>
  );
}

function EditRecordModal({
  record,
  currency,
  onClose,
  onSave,
  onDelete,
  bottomInset,
}: {
  record: ShowerRecord | null;
  currency: string;
  onClose: () => void;
  onSave: (id: string, patch: Partial<ShowerRecord>) => void;
  onDelete: (id: string) => void;
  bottomInset: number;
}) {
  const [flow, setFlow] = useState("");
  const [cost, setCost] = useState("");

  React.useEffect(() => {
    if (record) {
      setFlow(String(record.flowRate));
      setCost(String(record.costPerLiter));
    }
  }, [record]);

  if (!record) return null;

  const flowNum = parseFloat(flow) || 0;
  const costNum = parseFloat(cost) || 0;
  const preview: ShowerRecord = {
    ...record,
    flowRate: flowNum,
    costPerLiter: costNum,
  };

  return (
    <Modal
      visible={!!record}
      transparent
      animationType="slide"
      onRequestClose={onClose}
    >
      <Pressable style={styles.backdrop} onPress={onClose} />
      <KeyboardAvoidingView behavior="padding" keyboardVerticalOffset={0}>
        <View style={[styles.sheet, { paddingBottom: bottomInset + spacing.lg }]}>
          <View style={styles.sheetHandle} />
          <View style={styles.sheetHeader}>
            <Text style={styles.sheetTitle}>Edit session</Text>
            <Pressable testID="edit-close-button" onPress={onClose} hitSlop={10}>
              <X size={22} color={colors.onSurfaceTertiary} weight="bold" />
            </Pressable>
          </View>

          <ScrollView keyboardShouldPersistTaps="handled">
            <View style={styles.summaryRow}>
              <View style={styles.summaryItem}>
                <Timer size={18} color={colors.brandPrimary} weight="fill" />
                <Text style={styles.summaryVal}>
                  {formatDurationShort(record.duration)}
                </Text>
                <Text style={styles.summaryLabel}>Duration</Text>
              </View>
              <View style={styles.summaryItem}>
                <Drop size={18} color={colors.brandPrimary} weight="fill" />
                <Text style={styles.summaryVal}>
                  {formatLiters(litersForRecord(preview))}
                </Text>
                <Text style={styles.summaryLabel}>Water</Text>
              </View>
              <View style={styles.summaryItem}>
                <Coins size={18} color={colors.brandSecondary} weight="fill" />
                <Text style={styles.summaryVal}>
                  {formatCost(costForRecord(preview), currency)}
                </Text>
                <Text style={styles.summaryLabel}>Cost</Text>
              </View>
            </View>

            <Text style={styles.inputLabel}>Flow rate (L / min)</Text>
            <TextInput
              testID="edit-flow-input"
              value={flow}
              onChangeText={setFlow}
              keyboardType="decimal-pad"
              style={styles.input}
              placeholder="9"
              placeholderTextColor={colors.muted}
            />

            <Text style={styles.inputLabel}>Cost per liter ({currency})</Text>
            <TextInput
              testID="edit-cost-input"
              value={cost}
              onChangeText={setCost}
              keyboardType="decimal-pad"
              style={styles.input}
              placeholder="0.003"
              placeholderTextColor={colors.muted}
            />
          </ScrollView>

          <View style={styles.sheetActions}>
            <PrimaryButton
              testID="edit-delete-button"
              label="Delete"
              variant="ghost"
              icon={<Trash size={18} color={colors.warning} weight="bold" />}
              style={{ flex: 1 }}
              onPress={() => onDelete(record.id)}
            />
            <PrimaryButton
              testID="edit-save-button"
              label="Save"
              style={{ flex: 1 }}
              onPress={() =>
                onSave(record.id, { flowRate: flowNum, costPerLiter: costNum })
              }
            />
          </View>
        </View>
      </KeyboardAvoidingView>
    </Modal>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  list: {
    paddingHorizontal: spacing.lg,
    paddingBottom: 120,
  },
  sectionTitle: {
    fontFamily: fonts.text,
    fontSize: 13,
    fontWeight: "700",
    color: colors.muted,
    textTransform: "uppercase",
    letterSpacing: 0.5,
    marginTop: spacing.lg,
    marginBottom: spacing.sm,
  },
  card: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.md,
    marginBottom: spacing.sm,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.soft,
  },
  cardIcon: {
    width: 44,
    height: 44,
    borderRadius: radius.md,
    backgroundColor: colors.brandTertiary,
    alignItems: "center",
    justifyContent: "center",
  },
  cardMain: { flex: 1 },
  cardTime: {
    fontFamily: fonts.text,
    fontSize: 16,
    fontWeight: "700",
    color: colors.onSurface,
  },
  cardMeta: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.xs,
    marginTop: 2,
  },
  metaChip: {
    fontFamily: fonts.text,
    fontSize: 13,
    color: colors.onSurfaceTertiary,
  },
  metaDot: { color: colors.muted },
  cardTrailing: {
    alignItems: "flex-end",
    gap: 4,
  },
  cardCost: {
    fontFamily: fonts.display,
    fontSize: 16,
    fontWeight: "500",
    color: colors.onSurface,
  },
  // modal
  backdrop: {
    flex: 1,
    backgroundColor: "rgba(28,28,26,0.35)",
  },
  sheet: {
    backgroundColor: colors.surface,
    borderTopLeftRadius: radius.lg,
    borderTopRightRadius: radius.lg,
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.md,
  },
  sheetHandle: {
    alignSelf: "center",
    width: 40,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.borderStrong,
    marginBottom: spacing.md,
  },
  sheetHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: spacing.lg,
  },
  sheetTitle: {
    fontFamily: fonts.display,
    fontSize: 20,
    fontWeight: "500",
    color: colors.onSurface,
  },
  summaryRow: {
    flexDirection: "row",
    gap: spacing.sm,
    marginBottom: spacing.lg,
  },
  summaryItem: {
    flex: 1,
    alignItems: "center",
    gap: 4,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.md,
    paddingVertical: spacing.md,
    borderWidth: 1,
    borderColor: colors.border,
  },
  summaryVal: {
    fontFamily: fonts.display,
    fontSize: 15,
    fontWeight: "500",
    color: colors.onSurface,
  },
  summaryLabel: {
    fontFamily: fonts.text,
    fontSize: 11,
    color: colors.muted,
  },
  inputLabel: {
    fontFamily: fonts.text,
    fontSize: 13,
    fontWeight: "600",
    color: colors.onSurfaceTertiary,
    marginBottom: spacing.sm,
  },
  input: {
    height: 52,
    borderRadius: radius.md,
    backgroundColor: colors.surfaceSecondary,
    borderWidth: 1,
    borderColor: colors.border,
    paddingHorizontal: spacing.lg,
    fontFamily: fonts.text,
    fontSize: 16,
    color: colors.onSurface,
    marginBottom: spacing.lg,
  },
  sheetActions: {
    flexDirection: "row",
    gap: spacing.md,
    marginTop: spacing.sm,
  },
});
