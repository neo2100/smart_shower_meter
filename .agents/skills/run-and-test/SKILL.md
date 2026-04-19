---
name: smart-shower-meter-run-and-test
description: Guide for running and testing the Smart Shower Meter Flutter application. Use this when you need to build, run, or test the app.
---

## Setup & Running

### Prerequisites
- Flutter SDK (3.10.7+)
- Dart SDK (included with Flutter)

### Install Dependencies
```bash
flutter pub get
```

### Run on Target Platform
```bash
# Web (Chrome)
flutter run -d chrome

# Android (emulator or device)
flutter run -d emulator-5554

# iOS
flutter run -d ios

# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Testing

### Test Structure
- Unit tests in `test/` directory
- Name test files: `{component}_test.dart`
- Use `mockito` for service mocking

### Test Files
- `smart_meter_page_test.dart` - UI tests for Smart Meter page
- `sound_detection_service_test.dart` - Audio detection logic tests
- `timer_page_test.dart` - UI tests for Timer page

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/sound_detection_service_test.dart

# Run with coverage
flutter test --coverage

# Run tests with verbose output
flutter test -v
```

### Testing Services
- Mock external dependencies (e.g., audio input)
- Test edge cases and error scenarios
- Verify state changes and callbacks

### Testing Pages (Widget Tests)
- Use `WidgetTester` for UI tests
- Test user interactions (taps, scrolls)
- Verify page navigation

## Code Quality

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
dart format lib/ test/
```

### Clean Build
```bash
flutter clean
```

### Code Generation
```bash
flutter pub run build_runner build
```

## Common Commands

```bash
# Get fresh dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# See available devices
flutter devices

# Run with specific configuration
flutter run --release
```

## Before Pushing Changes
1. Run `flutter analyze` to check for violations
2. Run `flutter test` to ensure all tests pass
3. Run `dart format lib/ test/` to format code
4. Test on multiple platforms (Android/iOS if possible)

