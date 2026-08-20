import React, {
  createContext,
  useCallback,
  useContext,
  useRef,
  useState,
} from "react";
import { StyleSheet, Text, View } from "react-native";
import { useSafeAreaInsets } from "react-native-safe-area-context";
import Animated, { FadeInDown, FadeOutUp } from "react-native-reanimated";
import { CheckCircle, Info, WarningCircle } from "phosphor-react-native";

import { colors, fonts, radius, shadow, spacing } from "@/src/theme/theme";

type ToastKind = "success" | "info" | "warning";
type ToastState = { message: string; kind: ToastKind } | null;

const Ctx = createContext<(message: string, kind?: ToastKind) => void>(
  () => {},
);

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toast, setToast] = useState<ToastState>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const insets = useSafeAreaInsets();

  const show = useCallback((message: string, kind: ToastKind = "success") => {
    if (timer.current) clearTimeout(timer.current);
    setToast({ message, kind });
    timer.current = setTimeout(() => setToast(null), 2600);
  }, []);

  const accent =
    toast?.kind === "warning"
      ? colors.warning
      : toast?.kind === "info"
        ? colors.onSurfaceTertiary
        : colors.success;

  return (
    <Ctx.Provider value={show}>
      {children}
      {toast && (
        <Animated.View
          entering={FadeInDown.springify().damping(18)}
          exiting={FadeOutUp.duration(180)}
          pointerEvents="none"
          style={[styles.wrap, { top: insets.top + spacing.md }]}
          testID="app-toast"
        >
          <View style={styles.toast}>
            <View style={[styles.dot, { backgroundColor: accent }]}>
              {toast.kind === "warning" ? (
                <WarningCircle size={16} color="#fff" weight="fill" />
              ) : toast.kind === "info" ? (
                <Info size={16} color="#fff" weight="fill" />
              ) : (
                <CheckCircle size={16} color="#fff" weight="fill" />
              )}
            </View>
            <Text style={styles.text} numberOfLines={2}>
              {toast.message}
            </Text>
          </View>
        </Animated.View>
      )}
    </Ctx.Provider>
  );
}

export function useToast() {
  return useContext(Ctx);
}

const styles = StyleSheet.create({
  wrap: {
    position: "absolute",
    left: spacing.lg,
    right: spacing.lg,
    alignItems: "center",
    zIndex: 999,
  },
  toast: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    backgroundColor: colors.surfaceInverse,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    borderRadius: radius.pill,
    maxWidth: "100%",
    ...shadow.card,
  },
  dot: {
    width: 24,
    height: 24,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
  },
  text: {
    color: colors.onSurfaceInverse,
    fontFamily: fonts.text,
    fontSize: 14,
    fontWeight: "600",
    flexShrink: 1,
  },
});
