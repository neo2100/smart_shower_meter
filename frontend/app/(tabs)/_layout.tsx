import { Tabs } from "expo-router";
import { StyleSheet, View } from "react-native";
import {
  ChartBar,
  ClockCounterClockwise,
  Drop,
  GearSix,
} from "phosphor-react-native";

import { colors, fonts } from "@/src/theme/theme";

function TabIcon({
  Icon,
  focused,
}: {
  Icon: typeof Drop;
  focused: boolean;
}) {
  return (
    <View style={styles.iconWrap}>
      <Icon
        size={24}
        color={focused ? colors.brandPrimary : colors.muted}
        weight={focused ? "fill" : "regular"}
      />
      {focused && <View style={styles.activeDot} />}
    </View>
  );
}

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.brandPrimary,
        tabBarInactiveTintColor: colors.muted,
        tabBarStyle: styles.tabBar,
        tabBarLabelStyle: styles.tabLabel,
        tabBarItemStyle: { paddingTop: 8 },
      }}
    >
      <Tabs.Screen
        name="index"
        options={{
          title: "Timer",
          tabBarIcon: ({ focused }) => <TabIcon Icon={Drop} focused={focused} />,
        }}
      />
      <Tabs.Screen
        name="history"
        options={{
          title: "History",
          tabBarIcon: ({ focused }) => (
            <TabIcon Icon={ClockCounterClockwise} focused={focused} />
          ),
        }}
      />
      <Tabs.Screen
        name="analytics"
        options={{
          title: "Insights",
          tabBarIcon: ({ focused }) => (
            <TabIcon Icon={ChartBar} focused={focused} />
          ),
        }}
      />
      <Tabs.Screen
        name="settings"
        options={{
          title: "Settings",
          tabBarIcon: ({ focused }) => (
            <TabIcon Icon={GearSix} focused={focused} />
          ),
        }}
      />
    </Tabs>
  );
}

const styles = StyleSheet.create({
  tabBar: {
    backgroundColor: colors.surfaceSecondary,
    borderTopColor: colors.border,
    borderTopWidth: 1,
    height: 88,
    paddingBottom: 28,
    paddingTop: 4,
  },
  tabLabel: {
    fontFamily: fonts.text,
    fontSize: 11,
    fontWeight: "600",
    marginTop: 2,
  },
  iconWrap: {
    alignItems: "center",
    justifyContent: "center",
    height: 28,
  },
  activeDot: {
    position: "absolute",
    bottom: -6,
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.brandPrimary,
  },
});
