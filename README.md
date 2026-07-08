# CoreGym Mobile (Flutter)

Member mobile app for the CoreGym gym management system.

## Requirements

- Flutter SDK 3.11+
- Running `gym-management-api` backend

## Configuration

Set the API base URL at build/run time:

```bash
# Android emulator (default)
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/v1

# Physical device on same LAN
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/v1

# Production
flutter run --dart-define=API_BASE_URL=https://api.example.com/v1
```

## Firebase / Google Sign-In

- Android: `android/app/google-services.json` (from Firebase console)
- iOS: add `GoogleService-Info.plist` via `flutterfire configure`

## Release signing (Android)

```bash
cp android/key.properties.example android/key.properties
# Edit key.properties and create your keystore
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com/v1
```

## Full setup guide

See [`../panduan/PANDUAN_MENJALANKAN.md`](../panduan/PANDUAN_MENJALANKAN.md)
