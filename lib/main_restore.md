# Restore Main.dart

Setelah selesai testing RunShareScreen, restore main.dart ke original:

## Change this (Testing mode):
```dart
// TEMPORARY: Change to RunShareScreenDemo for testing
// home: child,
home: const RunShareScreenDemo(),
```

## Back to this (Production mode):
```dart
home: child,
// home: const RunShareScreenDemo(), // For testing only
```

Atau hapus import juga:
```dart
// import 'pages/running/run_share_screen_demo.dart'; // Demo for testing
```
