// Central design tokens for Smart Shower Meter.
// Calm botanical / ceramic palette (Seafoam / Sage / Sand). No blues.

export const colors = {
  surface: "#F7F7F5",
  onSurface: "#1C1C1A",
  surfaceSecondary: "#FFFFFF",
  onSurfaceSecondary: "#1C1C1A",
  surfaceTertiary: "#EAEAE8",
  onSurfaceTertiary: "#4A4A46",
  surfaceInverse: "#1C1C1A",
  onSurfaceInverse: "#F7F7F5",

  brand: "#52796F",
  brandPrimary: "#52796F",
  onBrandPrimary: "#FFFFFF",
  brandSecondary: "#84A98C",
  onBrandSecondary: "#1C1C1A",
  brandTertiary: "#CAD2C5",
  onBrandTertiary: "#2F3E35",

  success: "#386641",
  onSuccess: "#FFFFFF",
  warning: "#BC4749",
  onWarning: "#FFFFFF",
  error: "#A8201A",
  onError: "#FFFFFF",

  muted: "#8A8A84",
  border: "#EAEAE8",
  borderStrong: "#C2C2BE",
  divider: "#EAEAE8",
} as const;

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 24,
  "2xl": 32,
  "3xl": 48,
} as const;

export const radius = {
  sm: 6,
  md: 12,
  lg: 20,
  pill: 999,
} as const;

export const fonts = {
  display: "SpaceGrotesk",
  text: "PlusJakartaSans",
} as const;

export const fontSize = {
  sm: 12,
  base: 14,
  lg: 16,
  xl: 20,
  "2xl": 24,
} as const;

export const shadow = {
  card: {
    shadowColor: "#1C1C1A",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.06,
    shadowRadius: 12,
    elevation: 2,
  },
  soft: {
    shadowColor: "#1C1C1A",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.04,
    shadowRadius: 6,
    elevation: 1,
  },
} as const;
