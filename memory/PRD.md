# Smart Shower Meter — PRD

## Original Problem Statement
Redesign and rebuild the PWA-ready Flutter app "Smart Shower Meter"
(https://github.com/neo2100/smart_shower_meter) as a modern-looking mobile app.

## User Choices (gathered)
- Storage: **fully local / offline** (no account, no backend).
- Smart Meter: **include** microphone-based auto-detect (device-only feature).
- Visual style: **Clean & calm** (botanical ceramic Seafoam/Sage/Sand palette, no blues).
- Analytics: **keep** water + cost tracking, and **add more analytics options**.

## Architecture
- **Frontend:** Expo Router (React Native, SDK 54), TypeScript.
- **State/Storage:** React Context (`AppDataContext`) persisting to on-device
  AsyncStorage via `@/src/utils/storage`. No backend used.
- **Fonts:** SpaceGrotesk (numeric displays) + PlusJakartaSans (UI) via expo-font.
- **Icons:** phosphor-react-native. **Audio metering:** expo-audio. **Keep awake:** expo-keep-awake.
- **Keyboard:** react-native-keyboard-controller. **Haptics:** expo-haptics.
- Navigation: bottom tabs — Timer, History, Insights (Analytics), Settings.
  Smart Meter is a modal opened from the Timer screen.

## User Persona
Eco/cost-conscious individuals who want to track shower duration, water usage,
and cost, and reduce consumption over time — with a calm, private, offline tool.

## Core Requirements (static)
- Manual shower timer (start/pause/resume/stop) with live water + cost.
- Microphone Smart Meter that auto-starts/stops the timer from water sounds.
- History of sessions with edit (flow/cost) and delete.
- Analytics: bar charts + summary stats + richer insights, periods 7/14/30/90 days.
- Configurable flow rate, cost per liter, currency, detection sensitivity.
- Fully local, private, no login.

## Implemented (2026-06)
- ✅ Timer screen: animated dial, live HH:MM:SS, live liters & cost, keep-awake,
  haptics, sessions <3s discarded, saves to local store.
- ✅ Smart Meter screen: contextual mic permission flow (undetermined → intro,
  denied → retry / Open Settings), live waveform from real metering data,
  auto start/stop detection driven by sensitivity, auto-save on stop.
- ✅ History: sessions grouped by day, tap-to-edit sheet (flow rate & cost per
  liter with live water/cost preview), delete, empty state.
- ✅ Insights/Analytics: period + metric segmented controls, daily/weekly bar
  chart, trend vs previous period, stat cards (total time/water/cost, avg per
  shower), Details (active days, avg per active day, longest, busiest day),
  empty state.
- ✅ Settings: flow rate, cost/liter, currency, sensitivity, 10-min preview,
  privacy note, save + persistence.
- ✅ Calm ceramic design system, toasts (no Alerts), reusable components.
- ✅ End-to-end tested (frontend) — 100% pass, no blocking bugs.

## Backlog / Remaining
- P1: Weekly/monthly goals + streaks; water-saved-vs-goal eco score.
- P1: Water-saving tips surfaced contextually.
- P2: Export/share history (CSV); currency presets picker.
- P2: Swipe-to-delete gesture on history rows.
- P2 (web polish): migrate `shadow*` tokens to `boxShadow` to silence RN-Web warnings.

## Notes
- Smart Meter mic detection only works on a real device build (not Expo Go/preview).
