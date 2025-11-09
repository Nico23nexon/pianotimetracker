# Piano Practice Tracker

A minimalist, offline mobile app that lets pianists time, log, and track their practice sessions.

## Features

- **Stopwatch**: Start, pause, and reset a practice session timer
- **Session Log**: View all past practice sessions with piece names, duration, and notes
- **Progress Tracking**: See statistics including total practice time, weekly/monthly summaries, and practice streaks
- **Calendar View**: Browse practice sessions organized by date with expandable date cards

## Tech Stack

- Flutter 3.x
- Material 3 Design
- SharedPreferences for local storage
- Offline-first architecture

## Getting Started

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart
├── models/
│   └── practice_session.dart
├── services/
│   └── storage_service.dart
└── screens/
    ├── timer_screen.dart
    ├── log_screen.dart
    ├── progress_screen.dart
    └── calendar_screen.dart
```

## Platforms

- Android (primary)
- iOS (MAC:XCODE Windows or Linux via Codemagic/TestFlight)
