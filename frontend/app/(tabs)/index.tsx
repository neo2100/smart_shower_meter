import React, { useCallback, useEffect, useRef, useState } from "react";
import { StyleSheet, Text, View } from "react-native";
import { useRouter, useFocusEffect } from "expo-router";
import { LinearGradient } from "expo-linear-gradient";
import * as Haptics from "expo-haptics";
import {
  activateKeepAwakeAsync,
  deactivateKeepAwake,
} from "expo-keep-awake";
import {
  Coins,
  Drop,
  Pause,
  Play,
  Stop,
  Waveform as WaveformIcon,
} from "phosphor-react-native";
import Animated, {
  useAnimatedStyle,
  useSharedValue,
  withRepeat,
  withTiming,
  Easing,
} from "react-native-reanimated";

import { ScreenHeader } from "@/src/components/ScreenHeader";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAppData } from "@/src/context/AppDataContext";
import { useToast } from "@/src/components/Toast";
import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";
import { formatClock, formatCost, formatLiters } from "@/src/utils/format";

const KEEP_AWAKE_TAG = "shower-timer";

type Status = "idle" | "running" | "paused";

export default function TimerScreen() {
  const router = useRouter();
  const { settings, addRecord } = useAppData();
  const toast = useToast();

  const [status, setStatus] = useState<Status>("idle");
  const [seconds, setSeconds] = useState(0);
  const startedAtRef = useRef<string | null>(null);
  const interval = useRef<ReturnType<typeof setInterval> | null>(null);

  const pulse = useSharedValue(0);

  const clearTick = () => {
    if (interval.current) {
      clearInterval(interval.current);
      interval.current = null;
    }
  };

  useEffect(() => {
    if (status === "running") {
      interval.current = setInterval(() => setSeconds((s) => s + 1), 1000);
      activateKeepAwakeAsync(KEEP_AWAKE_TAG).catch(() => {});
      pulse.value = withRepeat(
        withTiming(1, { duration: 1800, easing: Easing.inOut(Easing.ease) }),
        -1,
        true,
      );
    } else {
      clearTick();
      void Promise.resolve()
        .then(() => deactivateKeepAwake(KEEP_AWAKE_TAG))
        .catch(() => {});
      pulse.value = withTiming(0, { duration: 400 });
    }
    return clearTick;
  }, [status, pulse]);

  // Stop keep-awake when leaving the screen.
  useFocusEffect(
    useCallback(() => {
      return () => {
        void Promise.resolve()
          .then(() => deactivateKeepAwake(KEEP_AWAKE_TAG))
          .catch(() => {});
      };
    }, []),
  );

  const liters = (settings.flowRate * seconds) / 60;
  const cost = liters * settings.costPerLiter;

  const ringStyle = useAnimatedStyle(() => ({
    transform: [{ scale: 1 + pulse.value * 0.04 }],
    opacity: 0.5 + pulse.value * 0.5,
  }));

  const handleStart = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
    if (status === "idle") startedAtRef.current = new Date().toISOString();
    setStatus("running");
  };

  const handlePause = () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light);
    setStatus("paused");
  };

  const handleStop = async () => {
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Heavy);
    const total = seconds;
    const startedAt = startedAtRef.current ?? new Date().toISOString();
    setStatus("idle");
    setSeconds(0);
    startedAtRef.current = null;
    if (total >= 3) {
      await addRecord({
        startedAt,
        duration: total,
        flowRate: settings.flowRate,
        costPerLiter: settings.costPerLiter,
        source: "manual",
      });
      toast(`Shower saved · ${formatClock(total)}`, "success");
    }
  };

  const running = status === "running";

  return (
    <View style={styles.container}>
      <ScreenHeader
        title="Shower"
        subtitle={
          running
            ? "Metering in progress…"
            : status === "paused"
              ? "Paused"
              : "Tap start when you step in"
        }
        right={
          <PrimaryButton
            testID="open-smart-meter-button"
            label="Auto"
            variant="secondary"
            compact
            icon={<WaveformIcon size={18} color={colors.brandPrimary} weight="bold" />}
            onPress={() => router.push("/smart-meter")}
          />
        }
      />

      <View style={styles.center}>
        <View style={styles.dialWrap}>
          <Animated.View style={[styles.ringGlow, ringStyle]} />
          <LinearGradient
            colors={[colors.brandTertiary, colors.surfaceSecondary]}
            start={{ x: 0.2, y: 0 }}
            end={{ x: 0.8, y: 1 }}
            style={styles.dial}
          >
            <View style={styles.dialInner}>
              <Text style={styles.timeLabel}>ELAPSED</Text>
              <Text
                testID="timer-display"
                style={styles.time}
                numberOfLines={1}
                adjustsFontSizeToFit
              >
                {formatClock(seconds)}
              </Text>
              <View style={[styles.statusPill, running && styles.statusPillActive]}>
                <View
                  style={[
                    styles.statusDot,
                    { backgroundColor: running ? colors.success : colors.muted },
                  ]}
                />
                <Text style={styles.statusText}>
                  {running ? "Recording" : status === "paused" ? "Paused" : "Ready"}
                </Text>
              </View>
            </View>
          </LinearGradient>
        </View>

        <View style={styles.metrics}>
          <View style={styles.metricPill} testID="timer-liters">
            <Drop size={18} color={colors.brandPrimary} weight="fill" />
            <View>
              <Text style={styles.metricValue}>{formatLiters(liters)}</Text>
              <Text style={styles.metricLabel}>Water used</Text>
            </View>
          </View>
          <View style={styles.metricPill} testID="timer-cost">
            <Coins size={18} color={colors.brandSecondary} weight="fill" />
            <View>
              <Text style={styles.metricValue}>
                {formatCost(cost, settings.currency)}
              </Text>
              <Text style={styles.metricLabel}>Estimated cost</Text>
            </View>
          </View>
        </View>
      </View>

      <View style={styles.controls}>
        {status === "idle" ? (
          <PrimaryButton
            testID="timer-start-button"
            label="Start Shower"
            icon={<Play size={20} color="#fff" weight="fill" />}
            onPress={handleStart}
          />
        ) : (
          <View style={styles.controlRow}>
            <PrimaryButton
              testID="timer-pause-button"
              label={running ? "Pause" : "Resume"}
              variant="secondary"
              style={{ flex: 1 }}
              icon={
                running ? (
                  <Pause size={20} color={colors.onSurface} weight="fill" />
                ) : (
                  <Play size={20} color={colors.onSurface} weight="fill" />
                )
              }
              onPress={running ? handlePause : handleStart}
            />
            <PrimaryButton
              testID="timer-stop-button"
              label="Stop"
              variant="danger"
              style={{ flex: 1 }}
              icon={<Stop size={20} color="#fff" weight="fill" />}
              onPress={handleStop}
            />
          </View>
        )}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.surface,
  },
  center: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: spacing.xl,
  },
  dialWrap: {
    width: 280,
    height: 280,
    alignItems: "center",
    justifyContent: "center",
  },
  ringGlow: {
    position: "absolute",
    width: 280,
    height: 280,
    borderRadius: 140,
    backgroundColor: colors.brandSecondary,
  },
  dial: {
    width: 260,
    height: 260,
    borderRadius: 130,
    alignItems: "center",
    justifyContent: "center",
    ...shadow.card,
  },
  dialInner: {
    width: 214,
    height: 214,
    borderRadius: 107,
    backgroundColor: colors.surfaceSecondary,
    alignItems: "center",
    justifyContent: "center",
    gap: spacing.sm,
  },
  timeLabel: {
    fontFamily: fonts.text,
    fontSize: 11,
    letterSpacing: 2,
    color: colors.muted,
    fontWeight: "700",
  },
  time: {
    fontFamily: fonts.display,
    fontSize: 52,
    color: colors.onSurface,
    fontWeight: "500",
    letterSpacing: -1,
  },
  statusPill: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.xs,
    backgroundColor: colors.surfaceTertiary,
    paddingHorizontal: spacing.md,
    paddingVertical: 5,
    borderRadius: radius.pill,
  },
  statusPillActive: {
    backgroundColor: colors.brandTertiary,
  },
  statusDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
  },
  statusText: {
    fontFamily: fonts.text,
    fontSize: 12,
    fontWeight: "600",
    color: colors.onSurfaceTertiary,
  },
  metrics: {
    flexDirection: "row",
    gap: spacing.md,
    marginTop: spacing["2xl"],
    width: "100%",
  },
  metricPill: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    padding: spacing.lg,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.soft,
  },
  metricValue: {
    fontFamily: fonts.display,
    fontSize: 18,
    fontWeight: "500",
    color: colors.onSurface,
  },
  metricLabel: {
    fontFamily: fonts.text,
    fontSize: 11,
    color: colors.muted,
    marginTop: 1,
  },
  controls: {
    paddingHorizontal: spacing.xl,
    paddingBottom: spacing.xl,
    paddingTop: spacing.md,
  },
  controlRow: {
    flexDirection: "row",
    gap: spacing.md,
  },
});
