# Updating App Icons (Future Iterations)

If you want to replace the app icon or logo across platforms, follow these recommended steps.

- **Prepare the source image:** Provide a square PNG of at least 1024×1024 pixels named `smart_shower_meter.png` at the repository root.
- **Use the launcher icon generator (Android/iOS/macOS):** Ensure `flutter_launcher_icons` and the `flutter_icons` section exist in `pubspec.yaml`, then run:
   - `flutter pub get`
   - `flutter pub run flutter_launcher_icons:main`
- **Generate Web icons:** We include a helper script that creates web icons with a white background. Run:
   - `dart run tool/generate_web_icons.dart`
- **Manual overwrite (optional):** On Windows PowerShell you can copy the image directly to platform asset locations (example for Android):
   - `Copy-Item .\smart_shower_meter.png -Destination android/app/src/main/res/mipmap-mdpi/ic_launcher.png -Force`
   - Repeat for `mipmap-hdpi`, `mipmap-xhdpi`, `mipmap-xxhdpi`, and `mipmap-xxxhdpi`.
- **Adaptive icons:** If you need a white background for adaptive Android icons, set `android_adaptive_icon_background` in `pubspec.yaml` (we set it to `#FFFFFF`).
- **Refresh build assets:** After regenerating icons, run `flutter clean` and rebuild (`flutter run` or `flutter build`) to ensure changes are picked up.
- **Quality tips:** Use a square source image, avoid tiny details that vanish when scaled, and test on devices/emulators.
- **Commit:** After verifying the icons, commit the updated assets and `pubspec.yaml` changes.
