import React, { useCallback, useEffect, useRef, useState } from "react";
import { Linking, Platform, StyleSheet, Text, View } from "react-native";
import { useRouter } from "expo-router";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import * as Haptics from "expo-haptics";
import {
  activateKeepAwakeAsync,
  deactivateKeepAwake,
} from "expo-keep-awake";
import {
  AudioModule,
  RecordingPresets,
  setAudioModeAsync,
  useAudioRecorder,
  useAudioRecorderState,
} from "expo-audio";
import {
  CaretLeft,
  MicrophoneSlash,
  Waveform as WaveformIcon,
} from "phosphor-react-native";
import Animated, { FadeIn } from "react-native-reanimated";

import { Waveform } from "@/src/components/Waveform";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAppData } from "@/src/context/AppDataContext";
import { useToast } from "@/src/components/Toast";
import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";
import { formatClock } from "@/src/utils/format";

const RECORD_OPTIONS = {
  ...RecordingPresets.HIGH_QUALITY,
  isMeteringEnabled: true,
};

const KEEP_AWAKE_TAG = "smart-meter";
const START_TICKS = 18; // ~1.8s above threshold to auto-start
const STOP_TICKS = 45; // ~4.5s below threshold to auto-stop

type Perm = "checking" | "undetermined" | "granted" | "denied";

export default function SmartMeterScreen() {
  const router = useRouter();
  const insets = useSafeAreaInsets();
  const { settings, addRecord } = useAppData();
  const toast = useToast();

  const [perm, setPerm] = useState<Perm>("checking");
  const [canAskAgain, setCanAskAgain] = useState(true);
  const [listening, setListening] = useState(false);
  const [detected, setDetected] = useState(false);
  const [sessionSeconds, setSessionSeconds] = useState(0);
  const [levels, setLevels] = useState<number[]>([]);

  const recorder = useAudioRecorder(RECORD_OPTIONS);
  const recorderState = useAudioRecorderState(recorder, 100);

  const aboveRef = useRef(0);
  const belowRef = useRef(0);
  const detectedRef = useRef(false);
  const sessionStartRef = useRef<number | null>(null);

  const threshold = 1 - (settings.sensitivity ?? 0.5); // higher sensitivity -> lower threshold

  // Permission check on mount
  useEffect(() => {
    (async () => {
      try {
        const res = await AudioModule.getRecordingPermissionsAsync();
        setCanAskAgain(res.canAskAgain);
        setPerm(res.granted ? "granted" : res.status === "denied" ? "denied" : "undetermined");
      } catch {
        setPerm("undetermined");
      }
    })();
  }, []);

  const requestPermission = useCallback(async () => {
    try {
      const res = await AudioModule.requestRecordingPermissionsAsync();
      setCanAskAgain(res.canAskAgain);
      setPerm(res.granted ? "granted" : "denied");
    } catch {
      setPerm("denied");
    }
  }, []);

  const stopListening = useCallback(async () => {
    try {
      await recorder.stop();
    } catch {
      // ignore
    }
    setListening(false);
    void Promise.resolve()
      .then(() => deactivateKeepAwake(KEEP_AWAKE_TAG))
      .catch(() => {});
  }, [recorder]);

  const startListening = useCallback(async () => {
    try {
      await setAudioModeAsync({ allowsRecording: true, playsInSilentMode: true });
      await recorder.prepareToRecordAsync();
      recorder.record();
      setListening(true);
      activateKeepAwakeAsync(KEEP_AWAKE_TAG).catch(() => {});
    } catch {
      toast("Couldn't access the microphone", "warning");
    }
  }, [recorder, toast]);

  // Auto-start listening once granted
  useEffect(() => {
    if (perm === "granted" && !listening) {
      startListening();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [perm]);

  // Cleanup
  useEffect(() => {
    return () => {
      void Promise.resolve()
        .then(() => deactivateKeepAwake(KEEP_AWAKE_TAG))
        .catch(() => {});
      recorder.stop().catch(() => {});
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const saveSession = useCallback(async () => {
    const start = sessionStartRef.current;
    if (!start) return;
    const dur = Math.round((Date.now() - start) / 1000);
    sessionStartRef.current = null;
    if (dur >= 3) {
      await addRecord({
        startedAt: new Date(start).toISOString(),
        duration: dur,
        flowRate: settings.flowRate,
        costPerLiter: settings.costPerLiter,
        source: "smart",
      });
      toast(`Shower saved · ${formatClock(dur)}`, "success");
    }
  }, [addRecord, settings, toast]);

  // Detection loop driven by live metering
  useEffect(() => {
    if (!listening) return;
    const db = recorderState.metering ?? -160;
    const level = Math.max(0, Math.min(1, (db + 60) / 60));

    setLevels((prev) => {
      const next = [...prev, level];
      return next.length > 48 ? next.slice(next.length - 48) : next;
    });

    if (level > threshold) {
      aboveRef.current += 1;
      belowRef.current = 0;
    } else {
      belowRef.current += 1;
      aboveRef.current = 0;
    }

    if (!detectedRef.current && aboveRef.current >= START_TICKS) {
      detectedRef.current = true;
      sessionStartRef.current = Date.now();
      setDetected(true);
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    }

    if (detectedRef.current) {
      const start = sessionStartRef.current;
      if (start) setSessionSeconds(Math.round((Date.now() - start) / 1000));
      if (belowRef.current >= STOP_TICKS) {
        detectedRef.current = false;
        setDetected(false);
        setSessionSeconds(0);
        saveSession();
        Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [recorderState.metering, listening]);

  const handleClose = async () => {
    await stopListening();
    if (detectedRef.current) await saveSession();
    router.back();
  };

  // ---- Permission states ----
  if (perm === "denied") {
    return (
      <View style={[styles.container, styles.centerPad]}>
        <View style={styles.deniedIcon}>
          <MicrophoneSlash size={40} color={colors.warning} weight="fill" />
        </View>
        <Text style={styles.title}>Microphone access needed</Text>
        <Text style={styles.body}>
          Smart Meter listens for water sounds to auto-start your timer. Enable
          microphone access to continue.
        </Text>
        <View style={styles.actions}>
          {canAskAgain ? (
            <PrimaryButton
              testID="grant-permission-button"
              label="Enable Microphone"
              onPress={requestPermission}
            />
          ) : (
            <PrimaryButton
              testID="open-settings-button"
              label="Open Settings"
              onPress={() => Linking.openSettings()}
            />
          )}
          <PrimaryButton
            testID="smart-close-button"
            label="Go Back"
            variant="ghost"
            onPress={() => router.back()}
          />
        </View>
      </View>
    );
  }

  if (perm === "undetermined" || perm === "checking") {
    return (
      <View style={[styles.container, styles.centerPad]}>
        <View style={styles.introIcon}>
          <WaveformIcon size={40} color={colors.brandPrimary} weight="fill" />
        </View>
        <Text style={styles.title}>Smart Meter</Text>
        <Text style={styles.body}>
          Let the app listen for running-water sounds and automatically start &
          stop your shower timer — hands free. Audio is analyzed on-device and
          never recorded.
        </Text>
        <View style={styles.actions}>
          <PrimaryButton
            testID="grant-permission-button"
            label="Enable Microphone"
            icon={<WaveformIcon size={18} color="#fff" weight="bold" />}
            onPress={requestPermission}
          />
          <PrimaryButton
            label="Not now"
            variant="ghost"
            onPress={() => router.back()}
          />
        </View>
      </View>
    );
  }

  // ---- Granted / listening ----
  return (
    <View style={styles.container}>
      <View style={[styles.header, { paddingTop: insets.top + spacing.sm }]}>
        <PrimaryButton
          testID="smart-close-button"
          label="Close"
          variant="ghost"
          compact
          icon={<CaretLeft size={18} color={colors.onSurface} weight="bold" />}
          onPress={handleClose}
        />
        <Text style={styles.headerTitle}>Smart Meter</Text>
        <View style={{ width: 84 }} />
      </View>

      <View style={styles.center}>
        <Animated.View
          entering={FadeIn}
          style={[styles.statusBadge, detected && styles.statusBadgeActive]}
        >
          <View
            style={[
              styles.pulseDot,
              { backgroundColor: detected ? colors.success : colors.brandSecondary },
            ]}
          />
          <Text style={[styles.statusText, detected && styles.statusTextActive]}>
            {detected ? "Shower detected" : "Listening for water…"}
          </Text>
        </Animated.View>

        <View style={styles.waveCard}>
          <Waveform levels={levels} active={detected} />
        </View>

        <Text style={styles.bigTime} testID="smart-timer">
          {formatClock(sessionSeconds)}
        </Text>
        <Text style={styles.hint}>
          {detected
            ? "Recording — will stop automatically when the water turns off"
            : "Turn on the shower to begin metering"}
        </Text>
      </View>

      <View style={[styles.footer, { paddingBottom: insets.bottom + spacing.lg }]}>
        <Text style={styles.deviceNote}>
          {Platform.OS === "web"
            ? "Live audio detection works best on a physical device."
            : "Keep this screen open while showering."}
        </Text>
        <PrimaryButton
          testID="smart-stop-button"
          label={detected ? "Stop & Save" : "Stop Listening"}
          variant="danger"
          onPress={handleClose}
        />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1, backgroundColor: colors.surface },
  centerPad: {
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: spacing.xl,
    gap: spacing.md,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.md,
  },
  headerTitle: {
    fontFamily: fonts.display,
    fontSize: 18,
    fontWeight: "500",
    color: colors.onSurface,
  },
  center: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    paddingHorizontal: spacing.xl,
    gap: spacing.xl,
  },
  statusBadge: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.sm,
    backgroundColor: colors.surfaceTertiary,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
  },
  statusBadgeActive: {
    backgroundColor: colors.brandTertiary,
  },
  pulseDot: { width: 8, height: 8, borderRadius: 4 },
  statusText: {
    fontFamily: fonts.text,
    fontSize: 14,
    fontWeight: "600",
    color: colors.onSurfaceTertiary,
  },
  statusTextActive: { color: colors.onBrandTertiary },
  waveCard: {
    width: "100%",
    backgroundColor: colors.surfaceSecondary,
    borderRadius: radius.lg,
    paddingVertical: spacing.lg,
    paddingHorizontal: spacing.md,
    borderWidth: 1,
    borderColor: colors.border,
    ...shadow.card,
  },
  bigTime: {
    fontFamily: fonts.display,
    fontSize: 56,
    fontWeight: "500",
    color: colors.onSurface,
    letterSpacing: -1,
  },
  hint: {
    fontFamily: fonts.text,
    fontSize: 14,
    color: colors.onSurfaceTertiary,
    textAlign: "center",
    marginTop: -spacing.md,
    maxWidth: 280,
    lineHeight: 20,
  },
  footer: {
    paddingHorizontal: spacing.xl,
    gap: spacing.md,
  },
  deviceNote: {
    fontFamily: fonts.text,
    fontSize: 12,
    color: colors.muted,
    textAlign: "center",
  },
  introIcon: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: colors.brandTertiary,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: spacing.sm,
  },
  deniedIcon: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: "#F3D9DA",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: spacing.sm,
  },
  title: {
    fontFamily: fonts.display,
    fontSize: 24,
    fontWeight: "500",
    color: colors.onSurface,
    textAlign: "center",
  },
  body: {
    fontFamily: fonts.text,
    fontSize: 15,
    color: colors.onSurfaceTertiary,
    textAlign: "center",
    lineHeight: 22,
    maxWidth: 320,
  },
  actions: {
    width: "100%",
    gap: spacing.sm,
    marginTop: spacing.lg,
  },
});
