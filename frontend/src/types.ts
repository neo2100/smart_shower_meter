export type ShowerRecord = {
  id: string;
  startedAt: string; // ISO timestamp
  duration: number; // seconds
  flowRate: number; // liters per minute
  costPerLiter: number; // cost per liter in currency units
  source: "manual" | "smart";
};

export type Settings = {
  flowRate: number; // L/min
  costPerLiter: number;
  currency: string; // symbol
  sensitivity: number; // 0..1 mic detection sensitivity
};

export const DEFAULT_SETTINGS: Settings = {
  flowRate: 9,
  costPerLiter: 0.003,
  currency: "$",
  sensitivity: 0.5,
};
