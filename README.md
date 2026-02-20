# Smart Shower Meter 🚿

A beautiful and feature-rich Flutter application for tracking and analyzing your shower habits. Monitor how long you spend in the shower, view historical records, and analyze your shower patterns with detailed charts.

## Features ✨

### 📱 Timer Page
- **Start, Pause, Stop Controls** - Full control over your shower timer
- **Large Display** - Easy-to-read timer with HH:MM:SS format
- **Status Indicator** - Visual feedback showing shower status (Running, Paused, Ready to Save)
- **Auto-Save** - Showers are automatically saved with timestamps

### 📋 History Page
- **Complete Shower Records** - View all your shower sessions
- **Detailed Information** - Date, time, and duration for each shower
- **Reverse Chronological Order** - Most recent showers appear first
- **Beautiful UI** - Card-based layout with icons and formatting

### 📊 Analytics Page
- **Shower Time Per Day** - Visual bar chart showing daily shower times
- **Week Day Indicators** - See which days of the week you shower most
- **Summary Statistics** - Total time, number of showers, and average duration
- **Flexible Time Periods** - View data for 7, 14, 30, or 90 days
- **Horizontal Scrolling** - Easily browse large date ranges
- **Smart Scrolling** - Charts automatically scroll to show recent data first

## Technical Features 🛠️

### Cross-Platform Support
- ✅ **Android** - Uses SharedPreferences for persistent storage
- ✅ **iOS** - Uses SharedPreferences for persistent storage
- ✅ **Web** - Uses browser localStorage via SharedPreferences
- ✅ **Windows/macOS/Linux** - Uses file-based storage via path_provider

### Architecture
- **Material Design 3** - Modern and clean UI with Material You theming
- **Singleton Pattern** - Efficient database service management
- **Persistent Storage** - Data survives app restarts across all platforms
- **Responsive Design** - Works seamlessly on phones, tablets, and desktops

### Dependencies
- `shared_preferences: ^2.2.2` - For mobile and web storage
- `path_provider: ^2.1.2` - For desktop file paths
- `hive: ^2.2.3` & `hive_flutter: ^1.1.0` - Alternative high-performance storage

## Project Structure 📁

```
lib/
├── main.dart                    # App entry point & home page
├── models/
│   └── shower_record.dart       # ShowerRecord data model
├── pages/
│   ├── timer_page.dart          # Shower timer interface
│   ├── history_page.dart        # Historical records list
│   └── analytics_page.dart      # Charts & statistics
└── services/
    └── database_service.dart    # Cross-platform data persistence
```

## Getting Started 🚀

### Prerequisites
- Flutter SDK (3.10.7 or higher)
- Dart SDK (included with Flutter)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/neo2100/smart_shower_meter.git
   cd smart_shower_meter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For web
   flutter run -d chrome
   
   # For Android
   # First run the emulator either by vscode or `flutter emulators` or
   emulator -avd pixel_api_34
   # then when using emulator run the following based on the emulator name
   flutter run -d emulator-5554

   # To run on mobile device
   flutter run
   
   # For iOS
   flutter run -d ios
   
   # For Windows
   flutter run -d windows
   
   # For macOS
   flutter run -d macos
   
   # For Linux
   flutter run -d linux
   ```

4. **Run tests**
   ```bash
   flutter test
   ```

5. **Analyze code before pushing**
   ```bash
   flutter analyze
   ```

## Building for Production 📦

### On Personal Mobile (Android)

Connect the mobile in developer mode by USB then run these two commands:

```bash
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Android
```bash
flutter build apk
# or for App Bundle
flutter build appbundle
```

### iOS
```bash
flutter build ios
```

### Web
```bash
flutter build web
```

### Windows
```bash
flutter build windows
```

### macOS
```bash
flutter build macos
```

### Linux
```bash
flutter build linux
```

## How to Use 📖

1. **Start a Shower**
   - Navigate to the Timer page (first tab)
   - Tap "Start" to begin timing
   - The timer will display your shower duration

2. **Control Your Shower**
   - Tap "Pause" to temporarily stop the timer
   - Tap "Start" again to resume
   - Tap "Stop" to end and save the shower

3. **View Your History**
   - Switch to the History page (second tab)
   - See all your past shower sessions with dates and times
   - Most recent showers appear at the top

4. **Analyze Your Patterns**
   - Go to the Analytics page (third tab)
   - Choose a time period (7, 14, 30, or 90 days)
   - View:
     - Total shower time
     - Number of showers taken
     - Average shower duration
     - Daily shower times in a chart

## Data Privacy 🔒

- All data is stored **locally** on your device
- No data is sent to external servers
- No account or login required
- Complete control over your shower data

## Future Enhancements 🔮

Potential features for future versions:
- [x] Water usage estimation (based on shower flow rate)
- [x] Add smart meter to use mic and automatically start and pause the timer
- [x] Be able to delete history records
- [x] Better UX: after stop go to history(analytic), one button for pause and start, simplified smart meter UI 
- [x] Improve water meter algorithm
- [ ] Auto adjust thresholds based on first test
- [ ] Better UX for flow config to add a timer and first ask what is the container capacity
- [ ] Test iOS
- [ ] Multi-language support
- [ ] Export and import feature (no need to access network)
- [ ] Publish to google play

## Contributing 🤝

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

## License 📄

This project is open source and available for personal and commercial use.

## Support 💬

For issues, questions, or suggestions, please open an issue on [GitHub](https://github.com/neo2100/smart_shower_meter/issues).

---

**Made with ❤️ using Flutter**
