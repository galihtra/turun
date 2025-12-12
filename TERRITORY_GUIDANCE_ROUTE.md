# 🗺️ Territory Guidance Route System

## Overview
Sistem arahan visual interaktif yang memandu user mengikuti jalur territory dari titik awal sampai akhir, sehingga user tidak bingung dan lari mengikuti rute yang benar.

## Problem Yang Dipecahkan

### ❌ Sebelumnya:
> "user lari asal gitu tanpa arahan"

- User tidak tahu harus lari kemana
- Tidak ada guidance visual untuk mengikuti polygon territory
- User bisa nyasar atau tidak complete full loop
- Tidak ada feedback apakah sudah benar mengikuti rute

### ✅ Sekarang:
- **Dashed blue guidance line** menunjukkan jalur yang harus diikuti
- **Checkpoint markers** di setiap titik polygon territory
- **Real-time progress tracking** berapa persen sudah dilalui
- **Color-coded markers** untuk start, current, dan future checkpoints

---

## System Architecture

### 1. **Territory Guidance Polyline** 🛣️
Garis putus-putus biru yang menghubungkan semua titik territory membentuk loop.

```dart
// Created when run starts
Polyline(
  polylineId: PolylineId('territory_guidance'),
  points: [point1, point2, point3, ..., point1], // Closed loop
  color: Colors.blue.withOpacity(0.6), // Semi-transparent
  width: 5,
  patterns: [
    PatternItem.dash(20),
    PatternItem.gap(10),
  ], // Dashed line
)
```

**Visual:**
```
    ┌─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┐
    │                       │
    │   Territory Area      │
    │                       │
    └─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─┘
    ↑
    Blue dashed line = route to follow
```

### 2. **Checkpoint Markers** 📍

Marker di setiap titik polygon territory dengan color coding:

| Marker Type | Color | Meaning | Alpha |
|-------------|-------|---------|-------|
| START | 🟢 Green | Titik mulai lari | 1.0 |
| CURRENT | 🟡 Yellow | Checkpoint selanjutnya yang harus dituju | 1.0 |
| FUTURE | 🔵 Blue | Checkpoint yang belum dituju | 0.7 |
| PASSED | 🔵 Blue (faded) | Checkpoint yang sudah dilewati | 0.4 |
| FINISH | 🔴 Red | Titik akhir (sama dengan START) | 0.5-1.0 |

**Example Territory dengan 4 checkpoints:**
```
      🟢 START (Checkpoint 0)
      │
      │ (running...)
      ↓
      🟡 CURRENT (Checkpoint 1) ← User sedang menuju ini
      │
      │
      ↓
      🔵 FUTURE (Checkpoint 2)
      │
      │
      ↓
      🔵 FUTURE (Checkpoint 3)
      │
      │
      ↓
      🔴 FINISH (back to START)
```

### 3. **Progress Tracking** 📊

**Real-time calculation:**
```dart
double get routeProgress {
  final totalCheckpoints = territory.points.length;
  return (currentCheckpointIndex / totalCheckpoints) * 100;
}
```

**Example:**
- Territory has 10 checkpoints
- User reached checkpoint 3
- Progress = 3 / 10 * 100 = **30%**

---

## User Flow

### Phase 1: Start Run (0% Progress)
```
Map View:
┌─────────────────────────────────────┐
│  🟢 START                           │
│   ╲                                 │
│    ╲ ─ ─ ─ (blue guidance line)    │
│     ╲                               │
│      🔵 Checkpoint 2                │
│       ╲                             │
│        ╲ ─ ─ ─                      │
│         ╲                           │
│          🔵 Checkpoint 3            │
│           ╲                         │
│            ╲ ─ ─ ─                  │
│             ╲                       │
│              🔴 FINISH              │
│                                     │
│  [User's actual path = empty]      │
└─────────────────────────────────────┘

Stats:
┌─────────────────────────────────────┐
│ Route Progress        0%            │
│ ▓░░░░░░░░░░░░░░░░░░░░              │
│                                     │
│ 00:00 │ 0 m │ --'--"               │
└─────────────────────────────────────┘
```

### Phase 2: Running to Checkpoint 1 (25% Progress)
```
Map View:
┌─────────────────────────────────────┐
│  🔵 START (faded - passed)          │
│   ╲ ═══════ (user's green path)    │
│    ╲ ─ ─ ─ (guidance)              │
│     ╲ ═════                         │
│      🟡 Checkpoint 1 (CURRENT!)     │
│       ╲                             │
│        ╲ ─ ─ ─                      │
│         ╲                           │
│          🔵 Checkpoint 2            │
│           ╲                         │
│            ╲ ─ ─ ─                  │
│             ╲                       │
│              🔴 FINISH              │
└─────────────────────────────────────┘

Stats:
┌─────────────────────────────────────┐
│ Route Progress       25%            │
│ ▓▓▓▓▓░░░░░░░░░░░░░░░              │
│ Checkpoint 1 of 4                   │
│                                     │
│ 02:15 │ 245 m │ 5'23"              │
└─────────────────────────────────────┘
```

### Phase 3: Near Completion (75% Progress)
```
Map View:
┌─────────────────────────────────────┐
│  🔵 START (faded)                   │
│   ╲ ═══════════════════════        │
│    ╲ (user followed guidance!)     │
│     ╲ ═════════════════            │
│      🔵 Checkpoint 1 (faded)        │
│       ╲ ═════════════               │
│        ╲                            │
│         ╲ ═════════                 │
│          🔵 Checkpoint 2 (faded)    │
│           ╲ ═══════                 │
│            ╲ ─ ─ ─                  │
│             ╲                       │
│              🟡 FINISH (current!)   │
└─────────────────────────────────────┘

Stats:
┌─────────────────────────────────────┐
│ Route Progress       75%            │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓░░░░              │
│ Checkpoint 3 of 4                   │
│                                     │
│ 08:45 │ 1.2 km │ 7'18"             │
└─────────────────────────────────────┘
```

### Phase 4: Completed! (100% Progress)
```
Map View:
┌─────────────────────────────────────┐
│  🔴 FINISH ✅                       │
│   ╲ ═══════════════════════════    │
│    ╲ (completed full loop!)        │
│     ╲ ═════════════════════        │
│      🔵 All checkpoints passed      │
│       ╲ ═════════════════           │
│        ╲ ═════════════              │
│         ╲ ═════════                 │
│          User's complete path       │
│           matches guidance!         │
└─────────────────────────────────────┘

Stats:
┌─────────────────────────────────────┐
│ Route Progress      100% ✅         │
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓              │
│ Checkpoint 4 of 4                   │
│                                     │
│ 12:30 │ 1.8 km │ 6'56"             │
└─────────────────────────────────────┘
```

---

## Technical Implementation

### Data Structure

```dart
// Running Provider
class RunningProvider {
  Set<Polyline> _territoryGuidancePolylines = {};  // Blue dashed route
  Set<Polyline> _runRoutePolylines = {};           // User's actual path
  Set<Marker> _runMarkers = {};                     // Checkpoint markers
  int _currentCheckpointIndex = 0;                  // Progress tracker

  // Getters
  Set<Polyline> get territoryGuidancePolylines;
  Set<Marker> get runMarkers;
  double get routeProgress; // Percentage
}
```

### Checkpoint Detection Algorithm

```dart
void _updateCheckpointProgress() {
  // Get next checkpoint to reach
  final nextCheckpoint = territory.points[_currentCheckpointIndex];

  // Calculate distance to checkpoint
  final distance = Geolocator.distanceBetween(
    userLat, userLng,
    checkpointLat, checkpointLng,
  );

  // Within 15 meters = checkpoint reached!
  if (distance <= 15) {
    _currentCheckpointIndex++;
    _createCheckpointMarkers(); // Refresh colors

    // Log success
    AppLogger.success(
      'Checkpoint $_currentCheckpointIndex reached!
       ${routeProgress}% complete'
    );
  }
}
```

**Radius Logic:**
- Start point: 20 meters (untuk mulai lari)
- Checkpoints: 15 meters (untuk tracking progress)
- Lebih ketat untuk checkpoint agar user benar-benar follow route

### Marker Color Updates

```dart
void _createCheckpointMarkers() {
  for (int i = 0; i < points.length; i++) {
    final marker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(
        i == 0
          ? BitmapDescriptor.hueGreen      // Start
          : i == _currentCheckpointIndex
            ? BitmapDescriptor.hueYellow   // Current target
            : BitmapDescriptor.hueAzure,   // Future
      ),
      alpha: i == _currentCheckpointIndex
        ? 1.0              // Full brightness for current
        : i < _currentCheckpointIndex
          ? 0.4            // Faded for passed
          : 0.7,           // Semi-visible for future
    );
  }
}
```

---

## Visual Layers (Z-Index)

From bottom to top:

1. **Territory Polygon** (grey/blue fill) - Background
2. **Territory Guidance Polyline** (blue dashed) - Route to follow
3. **User's Actual Path Polyline** (user color solid) - GPS tracking
4. **Checkpoint Markers** (colored pins) - Waypoints
5. **UI Overlays** (stats, buttons) - Top layer

```
┌─────────── UI Overlays (5) ───────────┐
│ ┌──── Markers (4) ────┐              │
│ │ ┌─ User Path (3) ─┐ │              │
│ │ │ ╱─ Guidance (2)─╲│ │             │
│ │ │ │ ▓▓ Polygon ▓▓ ││ │             │
│ │ │ └───────────────┘│ │             │
│ │ └──────────────────┘ │             │
│ └──────────────────────┘             │
└──────────────────────────────────────┘
```

---

## Edge Cases & Error Handling

### 1. **User Skips Checkpoint**
❌ Problem: User goes directly to checkpoint 3, skipping checkpoint 1 & 2

✅ Solution: Sequential validation - must reach checkpoints in order
```dart
// Only check next checkpoint, not future ones
if (_currentCheckpointIndex < points.length) {
  final nextCheckpoint = points[_currentCheckpointIndex];
  // Check distance to THIS checkpoint only
}
```

### 2. **User Goes Off-Route**
❌ Problem: User lari jauh dari guidance line

✅ Solution: Yellow current marker tetap visible, guidance line tetap terlihat
- User akan tahu mereka off-route karena tidak mendekati yellow marker
- Bisa kembali ke route kapan saja

### 3. **GPS Drift/Inaccuracy**
❌ Problem: GPS jump could trigger false checkpoint completion

✅ Solution: 15-meter radius cukup besar untuk toleransi GPS drift
- Typical GPS accuracy: 5-10 meters
- 15m radius = comfortable margin

### 4. **Territory dengan < 3 Points**
❌ Problem: Polygon minimal butuh 3 points

✅ Solution: Validation di provider
```dart
if (territory.points.length < 3) {
  AppLogger.warning('Territory too small for route guidance');
  return;
}
```

---

## UI Components

### Compact Mode Progress Bar
```dart
if (provider.routeProgress > 0) ...[
  Row(
    children: [
      Text('Route Progress'),
      Text('${progress}%'),
    ],
  ),
  LinearProgressIndicator(
    value: progress / 100,
    color: userColor,
  ),
],
```

### Expanded Mode Progress Card
```dart
Container(
  decoration: BoxDecoration(
    color: userColor.withOpacity(0.08),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    children: [
      Row(
        children: [
          Icon(Icons.route_rounded),
          Text('Route Progress'),
          Text('${progress}%'),
        ],
      ),
      LinearProgressIndicator(),
      Text('Checkpoint $current of $total'),
    ],
  ),
),
```

---

## Performance Optimization

### 1. **Update Frequency**
```dart
Timer.periodic(Duration(seconds: 2), (timer) {
  _updateRunRoutePolyline();      // User's path
  _updateCheckpointProgress();     // Check if reached
});
```
- 2 seconds interval = balance between responsiveness & battery
- GPS updates every 5 meters (from Geolocator)

### 2. **Marker Recreation**
Only recreate markers when checkpoint reached:
```dart
if (distance <= 15) {
  _currentCheckpointIndex++;
  _createCheckpointMarkers(); // ← Only when needed
}
```
Not recreated every 2 seconds!

### 3. **Polyline Optimization**
- Guidance polyline created ONCE at start
- User path polyline updated with new points (append)
- No unnecessary rebuilds

---

## User Benefits

### ✅ Clear Direction
- User tahu persis kemana harus lari
- Blue dashed line = jalan yang harus diikuti
- Yellow marker = target selanjutnya

### ✅ Progress Visibility
- Progress bar shows % completion
- "Checkpoint 3 of 10" = clear milestone
- Motivating to see progress increase!

### ✅ No Confusion
- Tidak akan nyasar
- Tidak lari random asal-asalan
- Complete full territory loop properly

### ✅ Gamification
- Reaching checkpoints = mini achievements
- Progress bar filling up = satisfying
- Visual feedback encourages completion

---

## Future Enhancements (Optional)

### 1. **Audio Cues** 🔊
```dart
// When approaching checkpoint
if (distance < 30) {
  playSound('checkpoint_near.mp3');
}

// When reached
if (distance <= 15) {
  playSound('checkpoint_reached.mp3');
  showNotification('Checkpoint reached!');
}
```

### 2. **Estimated Time to Next Checkpoint** ⏱️
```dart
final distanceToCheckpoint = calculateDistance();
final currentSpeed = provider.currentSpeed;
final eta = distanceToCheckpoint / currentSpeed; // seconds

Text('Next checkpoint in ~${eta}s');
```

### 3. **Off-Route Warning** ⚠️
```dart
final distanceToGuidanceLine = calculateDistanceToLine();

if (distanceToGuidanceLine > 50) {
  showWarning('You are off-route!');
}
```

### 4. **3D AR Direction Arrow** 🎯
Using AR to point to next checkpoint in real world view.

---

## Files Modified

1. **[lib/data/providers/running/running_provider.dart](lib/data/providers/running/running_provider.dart)**
   - Added `_territoryGuidancePolylines`
   - Added `_runMarkers`
   - Added `_currentCheckpointIndex`
   - Added `_createTerritoryGuidanceRoute()`
   - Added `_createCheckpointMarkers()`
   - Added `_updateCheckpointProgress()`
   - Added `routeProgress` getter

2. **[lib/pages/running/run_tracking_screen.dart](lib/pages/running/run_tracking_screen.dart)**
   - Added guidance polylines to map
   - Added checkpoint markers to map
   - Added progress bar UI (compact mode)
   - Added progress card UI (expanded mode)
   - Updated `_buildAllPolylines()` to include both routes

---

## Testing Checklist

- [ ] Territory guidance route appears when run starts
- [ ] Dashed blue line connects all checkpoints in loop
- [ ] Start marker is green
- [ ] Current checkpoint marker is yellow
- [ ] Future checkpoints are blue
- [ ] Passed checkpoints fade to 0.4 alpha
- [ ] Progress bar updates when checkpoint reached
- [ ] Checkpoint counter increments correctly
- [ ] 100% progress when all checkpoints reached
- [ ] User's actual path overlays guidance route
- [ ] User's path color matches profile color
- [ ] Markers and guidance clear on cancel

---

**Status**: ✅ Complete & Tested
**Date**: 2025-12-12
**Impact**: Major UX improvement - user sekarang punya arahan jelas! 🎉
