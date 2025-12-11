# Location History Tracker

A Flutter application for automatically tracking and recording your location history on a daily basis for both Android and iOS devices.

## Features

- **Automatic Location Tracking**: Automatically records your location once per day using background services
- **Location History**: View all recorded locations in a detailed list format
- **Search & Filter**: 
  - Search by date and time
  - Filter by specific day of the week
  - Search by coordinates or address
- **Location Details**: View detailed information about each recorded location including:
  - Exact coordinates (latitude, longitude)
  - Timestamp of when the location was recorded
  - Street address (converted from coordinates using geocoding)
  - GPS accuracy
- **Data Management**: Delete individual locations or all locations at once
- **Local Storage**: All data is stored locally using SQLite for privacy and offline access
- **Background Service**: Tracks location even when the app is not actively being used

## Supported Platforms

- **Android**: Version 5.0 (API level 21) or higher
- **iOS**: Version 11.0 or higher

## Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Provider**: State management
- **SQLite (sqflite)**: Local database for storing location history
- **Geolocator**: Accessing device location services
- **WorkManager**: Background task scheduling for Android
- **Geocoding**: Converting coordinates to readable addresses
- **Intl**: Date and time formatting

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/
│   └── location_entry.dart            # Location data model
├── database/
│   └── database_helper.dart           # SQLite database operations
├── services/
│   ├── location_service.dart          # Location tracking service
│   ├── geocoding_service.dart         # Address conversion service
│   └── background_location_service.dart # Background task service
├── providers/
│   └── location_history_provider.dart # State management with Provider
├── screens/
│   ├── home_screen.dart               # Home/Dashboard screen
│   ├── history_screen.dart            # Location history view
│   └── settings_screen.dart           # Settings and data management
└── widgets/
    └── location_card.dart             # Reusable location card widget
```

## Setup Instructions

### Prerequisites

- Flutter SDK installed (version 3.9.2 or higher recommended)
- Android SDK (for Android development)
- Xcode (for iOS development)
- A device or emulator for testing

### Installation Steps

1. **Clone/Navigate to the project directory**
   ```bash
   cd location_history_tracker
   ```

2. **Get Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android Permissions** (Already configured in AndroidManifest.xml)
   - Location permissions are already set up
   - The app will request runtime permissions when needed

4. **Configure iOS Permissions** (Already configured in Info.plist)
   - Location usage descriptions are already added
   - The app will request location access on first launch

5. **Run the app**
   
   For Android:
   ```bash
   flutter run
   ```
   
   For iOS:
   ```bash
   flutter run -d ios
   ```

   For a specific device:
   ```bash
   flutter run -d <device_id>
   ```

### Building for Release

**Android APK:**
```bash
flutter build apk --release
```

**Android App Bundle:**
```bash
flutter build appbundle --release
```

**iOS IPA:**
```bash
flutter build ios --release
```

## Usage

### Home Screen
- View the total number of locations recorded
- Manually capture your current location with the "Capture Current Location" button
- Enable/disable background location tracking from settings

### History Screen
- View all recorded locations in a list
- Search locations by date, time, coordinates, or address
- Filter locations by specific date using the date picker
- Filter locations by day of the week (Monday, Tuesday, etc.)
- Tap a location to see detailed information
- Delete individual locations with the menu button
- Pull down to refresh the list

### Settings Screen
- **Enable/Disable Background Tracking**: Toggle automatic daily location tracking
- **Delete All Locations**: Permanently delete all saved location data
- **View Statistics**: See total number of recorded locations
- **About**: View app information and instructions

## How It Works

1. **Location Capture**: The app uses the Geolocator plugin to get your device's current GPS location with high accuracy
2. **Background Tracking**: When enabled, the app uses WorkManager (Android) to schedule daily location recording tasks
3. **Data Storage**: All locations are saved to a local SQLite database with the following information:
   - Unique ID
   - Latitude and longitude
   - Timestamp
   - Optional address (converted from coordinates)
   - GPS accuracy

4. **Privacy**: 
   - All data is stored locally on your device
   - No data is sent to external servers
   - You have full control over your location data

## Permissions Required

### Android
- `ACCESS_FINE_LOCATION`: High-accuracy location access (GPS)
- `ACCESS_COARSE_LOCATION`: Approximate location access (network-based)
- `INTERNET`: For geocoding services

### iOS
- `NSLocationWhenInUseUsageDescription`: Permission message for using location while app is in use
- `NSLocationAlwaysAndWhenInUseUsageDescription`: Permission for background location access
- `NSLocationAlwaysUsageDescription`: Permission for always-on location access

## Troubleshooting

### Location not being captured
- Ensure location services are enabled on your device
- Grant location permissions when prompted
- Check that GPS or network location is available
- For background tracking, ensure the app has background execution permissions

### Geocoding not working
- Check internet connection (required for address conversion)
- Some locations may not have corresponding addresses
- Try enabling/disabling the feature from settings

### Database errors
- Clear app cache and data from device settings
- Delete the app and reinstall
- Check device storage for available space

## Future Enhancements

- Google Maps integration for visual location history
- Export location data to CSV or other formats
- Location clustering and heatmaps
- Custom tracking intervals
- Location categories or tagging
- Cloud backup options
- Trip planning based on history

## License

This project is for educational purposes.

## Support

For issues or questions, please check the Flutter documentation or the specific plugin documentation:
- [Geolocator Plugin](https://pub.dev/packages/geolocator)
- [WorkManager Plugin](https://pub.dev/packages/workmanager)
- [SQLite (sqflite)](https://pub.dev/packages/sqflite)
- [Provider Package](https://pub.dev/packages/provider)
- [Geocoding Plugin](https://pub.dev/packages/geocoding)

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
