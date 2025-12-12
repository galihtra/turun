# 🔍 Debug Logging Guide - Marker State Issue

## Current Issue

**Problem**: Markers tidak muncul saat pertama kali tap "MULAI LARI"

**Log Output**:
```
✨ Run started with 0 markers visible
```

## Debugging Steps Added

### Added Detailed Logging

Saya telah menambahkan logging di 3 key functions:

#### 1. `_startRunRouteUpdates()`
```dart
🚀 _startRunRouteUpdates() START
   Current markers before: X
   (awaiting _createTerritoryGuidanceRoute...)
   Current markers after: Y
🚀 _startRunRouteUpdates() COMPLETE
```

#### 2. `_createTerritoryGuidanceRoute()`
```dart
🗺️ _createTerritoryGuidanceRoute() START
   Territory: <name>
   Points count: X
   ✅ Guidance polyline created
   Calling _createCheckpointMarkers()...
🗺️ _createTerritoryGuidanceRoute() COMPLETE: X markers ready
```

#### 3. `_createCheckpointMarkers()`
```dart
🔨 _createCheckpointMarkers() START
   Territory: <name>
   Points: X
📍 Creating markers for X points...
   Creating START marker...
   ✅ START marker created
   Creating Coin 1...
   ✅ Coin 1 created
   Creating Coin 2...
   ✅ Coin 2 created
   ...
   Creating FINISH marker...
   ✅ FINISH marker created
🔨 _createCheckpointMarkers() COMPLETE: X markers created
```

---

## What to Look For in Logs

### Scenario 1: Markers Created Successfully ✅
```
I/flutter: 🚀 _startRunRouteUpdates() START
I/flutter:    Current markers before: 0
I/flutter: 🗺️ _createTerritoryGuidanceRoute() START
I/flutter:    Territory: Test Territory
I/flutter:    Points count: 4
I/flutter:    ✅ Guidance polyline created
I/flutter:    Calling _createCheckpointMarkers()...
I/flutter: 🔨 _createCheckpointMarkers() START
I/flutter:    Territory: Test Territory
I/flutter:    Points: 4
I/flutter: 📍 Creating markers for 4 points...
I/flutter:    Creating START marker...
I/flutter:    ✅ START marker created
I/flutter:    Creating Coin 1...
I/flutter:    ✅ Coin 1 created
I/flutter:    Creating Coin 2...
I/flutter:    ✅ Coin 2 created
I/flutter:    Creating Coin 3...
I/flutter:    ✅ Coin 3 created
I/flutter:    Creating FINISH marker...
I/flutter:    ✅ FINISH marker created
I/flutter: 🔨 _createCheckpointMarkers() COMPLETE: 5 markers created
I/flutter: 🗺️ _createTerritoryGuidanceRoute() COMPLETE: 5 markers ready
I/flutter:    Current markers after: 5
I/flutter: 🚀 _startRunRouteUpdates() COMPLETE
I/flutter: ✅ Run started with 5 markers visible
```

**Result**: ✅ Markers should appear!

---

### Scenario 2: Territory is NULL ❌
```
I/flutter: 🚀 _startRunRouteUpdates() START
I/flutter:    Current markers before: 0
I/flutter: 🗺️ _createTerritoryGuidanceRoute() START
I/flutter: ❌ No territory or empty points in guidance route!
I/flutter:    Current markers after: 0
I/flutter: 🚀 _startRunRouteUpdates() COMPLETE
I/flutter: ✅ Run started with 0 markers visible
```

**Problem**: `_selectedTerritory` is NULL!
**Fix**: Check why territory is not selected

---

### Scenario 3: Territory Points is Empty ❌
```
I/flutter: 🚀 _startRunRouteUpdates() START
I/flutter:    Current markers before: 0
I/flutter: 🗺️ _createTerritoryGuidanceRoute() START
I/flutter:    Territory: Test Territory
I/flutter:    Points count: 0
I/flutter: ❌ No territory or empty points in guidance route!
I/flutter:    Current markers after: 0
I/flutter: 🚀 _startRunRouteUpdates() COMPLETE
I/flutter: ✅ Run started with 0 markers visible
```

**Problem**: Territory has NO points!
**Fix**: Insert territory data with proper points (see TERRITORY_SAMPLE_DATA.sql)

---

### Scenario 4: Marker Creation Error ❌
```
I/flutter: 🚀 _startRunRouteUpdates() START
I/flutter:    Current markers before: 0
I/flutter: 🗺️ _createTerritoryGuidanceRoute() START
I/flutter:    Territory: Test Territory
I/flutter:    Points count: 4
I/flutter:    ✅ Guidance polyline created
I/flutter:    Calling _createCheckpointMarkers()...
I/flutter: 🔨 _createCheckpointMarkers() START
I/flutter:    Territory: Test Territory
I/flutter:    Points: 4
I/flutter: 📍 Creating markers for 4 points...
I/flutter:    Creating START marker...
[ERROR] ...
```

**Problem**: Error during marker creation (CustomMarkerHelper issue)
**Fix**: Check CustomMarkerHelper implementation

---

### Scenario 5: Markers Created but UI Not Updated ❌
```
I/flutter: 🔨 _createCheckpointMarkers() COMPLETE: 5 markers created
I/flutter: 🗺️ _createTerritoryGuidanceRoute() COMPLETE: 5 markers ready
I/flutter:    Current markers after: 5
I/flutter: 🚀 _startRunRouteUpdates() COMPLETE
I/flutter: ✅ Run started with 5 markers visible
(But UI still shows empty map!)
```

**Problem**: Markers created but UI not rebuilding
**Fix**: Check if `notifyListeners()` is being called AFTER await completes

---

## Testing Instructions

### Step 1: Run the App
```bash
flutter run
```

### Step 2: Select Territory & Start Run
1. Select a territory on map
2. Go to START location
3. Tap "MULAI LARI"

### Step 3: Watch Console Output

Filter logs to see marker creation:
```bash
adb logcat | grep -E "(🚀|🗺️|🔨|✅|❌|markers)"
```

Or in IDE, filter for:
- `_startRunRouteUpdates`
- `_createTerritoryGuidanceRoute`
- `_createCheckpointMarkers`
- `markers visible`

---

## Expected Log Flow

### Complete Successful Flow:
```
1. User taps "MULAI LARI"
   ↓
2. startRunSession() starts
   ↓
3. 🚀 _startRunRouteUpdates() START
   ↓
4. 🗺️ _createTerritoryGuidanceRoute() START
   ↓
5. 🔨 _createCheckpointMarkers() START
   ↓
6. Creating markers (START, Coins, FINISH)
   ↓
7. 🔨 COMPLETE: 5 markers created
   ↓
8. 🗺️ COMPLETE: 5 markers ready
   ↓
9. 🚀 COMPLETE
   ↓
10. ✅ Run started with 5 markers visible
    ↓
11. UI updates with all markers visible!
```

---

## Common Issues & Solutions

### Issue 1: "0 markers visible"
**Possible Causes**:
1. Territory is NULL
2. Territory points is empty
3. Marker creation error
4. Markers cleared after creation

**Debug**:
- Check log for territory name
- Check log for points count
- Look for error messages
- Check if multiple `_runMarkers.clear()` calls

### Issue 2: "Territory: null"
**Possible Causes**:
1. Territory not properly selected
2. Territory lost during navigation
3. State reset unexpectedly

**Debug**:
- Check `selectTerritory()` was called
- Check `_selectedTerritory` not cleared
- Check logs before `startRunSession()`

### Issue 3: "Points count: 0"
**Possible Causes**:
1. Database has empty points
2. Territory not loaded properly
3. JSON parsing error

**Debug**:
- Run SQL: `SELECT id, name, points FROM territories WHERE id = X`
- Check points format: `[{"lat": ..., "lng": ...}, ...]`
- Check territory loading logs

### Issue 4: Markers Created but UI Blank
**Possible Causes**:
1. UI not rebuilding after markers ready
2. GoogleMap widget not reading updated markers
3. Markers reference lost

**Debug**:
- Check `notifyListeners()` called AFTER await
- Check widget using `provider.runMarkers`
- Check no duplicate clear() calls

---

## Next Steps

1. **Run app with new logging**
2. **Copy ALL console output** when tapping "MULAI LARI"
3. **Send log output** for analysis
4. **Note**: What you see on screen vs what logs say

---

## Log Analysis Template

When reporting issue, provide:

```
### What I See:
- Tap "MULAI LARI"
- Map shows: [empty / markers visible / partial markers]

### Console Logs:
```
[paste full log output here from 🚀 START to ✅ Run started]
```

### Territory Info:
- Name: [territory name]
- Points count: [number]
- Database query result: [SQL output]

### Steps Taken:
1. Selected territory
2. Navigated to start
3. Tapped button
4. Result: [describe]
```

---

**Status**: ✅ Debug logging added
**Next**: Run app and analyze logs to find root cause
**Goal**: Identify why `_runMarkers` is 0 when should be 5+
