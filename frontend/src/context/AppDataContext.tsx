import React, {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from "react";

import { storage } from "@/src/utils/storage";
import { DEFAULT_SETTINGS, type Settings, type ShowerRecord } from "@/src/types";

const RECORDS_KEY = "ssm_records_v1";
const SETTINGS_KEY = "ssm_settings_v1";

type AppData = {
  loading: boolean;
  records: ShowerRecord[];
  settings: Settings;
  addRecord: (
    input: Omit<ShowerRecord, "id">,
  ) => Promise<ShowerRecord>;
  updateRecord: (id: string, patch: Partial<ShowerRecord>) => Promise<void>;
  deleteRecord: (id: string) => Promise<void>;
  updateSettings: (patch: Partial<Settings>) => Promise<void>;
};

const Ctx = createContext<AppData | null>(null);

function genId(): string {
  return `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`;
}

export function AppDataProvider({ children }: { children: React.ReactNode }) {
  const [loading, setLoading] = useState(true);
  const [records, setRecords] = useState<ShowerRecord[]>([]);
  const [settings, setSettings] = useState<Settings>(DEFAULT_SETTINGS);

  useEffect(() => {
    (async () => {
      const storedRecords = await storage.getItem<string>(RECORDS_KEY, "[]");
      const storedSettings = await storage.getItem<string>(SETTINGS_KEY, "");
      try {
        const parsed = storedRecords ? JSON.parse(storedRecords) : [];
        if (Array.isArray(parsed)) setRecords(parsed);
      } catch {
        // ignore corrupt data
      }
      try {
        if (storedSettings) {
          setSettings({ ...DEFAULT_SETTINGS, ...JSON.parse(storedSettings) });
        }
      } catch {
        // ignore
      }
      setLoading(false);
    })();
  }, []);

  const persistRecords = useCallback(async (next: ShowerRecord[]) => {
    setRecords(next);
    await storage.setItem(RECORDS_KEY, JSON.stringify(next));
  }, []);

  const persistSettings = useCallback(async (next: Settings) => {
    setSettings(next);
    await storage.setItem(SETTINGS_KEY, JSON.stringify(next));
  }, []);

  const addRecord = useCallback(
    async (input: Omit<ShowerRecord, "id">) => {
      const rec: ShowerRecord = { id: genId(), ...input };
      const next = [rec, ...records].sort(
        (a, b) => +new Date(b.startedAt) - +new Date(a.startedAt),
      );
      await persistRecords(next);
      return rec;
    },
    [records, persistRecords],
  );

  const updateRecord = useCallback(
    async (id: string, patch: Partial<ShowerRecord>) => {
      const next = records.map((r) => (r.id === id ? { ...r, ...patch } : r));
      await persistRecords(next);
    },
    [records, persistRecords],
  );

  const deleteRecord = useCallback(
    async (id: string) => {
      await persistRecords(records.filter((r) => r.id !== id));
    },
    [records, persistRecords],
  );

  const updateSettings = useCallback(
    async (patch: Partial<Settings>) => {
      await persistSettings({ ...settings, ...patch });
    },
    [settings, persistSettings],
  );

  const value = useMemo<AppData>(
    () => ({
      loading,
      records,
      settings,
      addRecord,
      updateRecord,
      deleteRecord,
      updateSettings,
    }),
    [loading, records, settings, addRecord, updateRecord, deleteRecord, updateSettings],
  );

  return <Ctx.Provider value={value}>{children}</Ctx.Provider>;
}

export function useAppData(): AppData {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error("useAppData must be used within AppDataProvider");
  return ctx;
}
