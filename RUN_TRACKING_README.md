# 🏃 TuRun - Run Tracking & Territory System

## Overview
Sistem tracking lari yang canggih dengan fitur territory conquest berbasis pace (kecepatan lari). User dapat claim territory dengan menjadi pelari tercepat di lokasi tersebut.

## 🎯 Features

### 1. **Real-Time GPS Tracking**
- Tracking posisi real-time dengan akurasi tinggi
- Recording route yang akurat mengikuti jalan (via Google Directions API)
- Filter noise GPS untuk data yang lebih bersih

### 2. **Live Running Metrics**
- ⏱️ **Duration**: Real-time durasi lari
- 📏 **Distance**: Total jarak tempuh (meter/km)
- ⚡ **Pace**: Kecepatan lari dalam menit per kilometer
- 🏃 **Current Speed**: Kecepatan real-time (km/h)
- 🔥 **Calories**: Estimasi kalori terbakar

### 3. **Territory Conquest System**
- User dapat claim territory dengan berlari di lokasi tersebut
- **Pace-Based Leaderboard**: Pemilik territory ditentukan oleh pelari tercepat
- **Territory Takeover**: User lain dapat merebut territory dengan pace yang lebih baik
- **Automatic Ownership**: Sistem otomatis update pemilik territory

### 4. **Beautiful UI/UX**
- Modern gradient design dengan animasi smooth
- Real-time metric cards dengan color coding
- Animated completion screen
- Celebration effects untuk territory conquest
- Responsive dan mobile-friendly

## 📱 User Flow

### 1. Navigate to Territory
```
User selects territory → Tap "Go to Location" →
System shows route → User follows navigation
```

### 2. Arrive at Territory
```
User arrives → "You've arrived!" notification →
Tap "Start Run" → Run tracking begins
```

### 3. During Run
```
Real-time tracking:
├── GPS recording setiap 5 meter
├── Live pace calculation
├── Distance accumulation
├── Route visualization on map
└── Pause/Resume/Cancel controls
```

### 4. Complete Run
```
Tap "Finish" → Confirmation dialog →
System calculates final metrics →
Check if pace beats current record →
Show completion screen with results
```

### 5. Territory Conquest
```
IF user_pace < current_best_pace:
    ├── 🏆 Territory conquered!
    ├── Update territory owner
    ├── Show celebration animation
    └── Add to leaderboard
ELSE:
    └── Show "Keep improving!" message
```

## 🗂️ File Structure

```
lib/
├── data/
│   ├── model/
│   │   └── running/
│   │       └── run_session_model.dart       # Run session data model
│   ├── services/
│   │   └── run_tracking_service.dart        # Core tracking logic
│   └── providers/
│       └── running/
│           └── running_provider.dart         # State management (updated)
│
└── pages/
    └── running/
        ├── running_page.dart                 # Main map & territory selection
        ├── run_tracking_screen.dart          # Active run tracking UI
        └── run_completion_screen.dart        # Results & conquest screen
```

## 🔧 Technical Implementation

### GPS Tracking
```dart
// High accuracy GPS with noise filtering
LocationSettings(
  accuracy: LocationAccuracy.bestForNavigation,
  distanceFilter: 5, // Update every 5 meters
)
```

### Pace Calculation
```dart
pace (min/km) = (duration_minutes / distance_km)

// Faster pace = lower number = better ranking
// Example: 5'30" per km is better than 6'00" per km
```

### Territory Conquest Logic
```dart
bool canConquerTerritory(RunSession newRun, RunSession? currentBest) {
  if (currentBest == null) return true; // Unclaimed territory
  if (currentBest.userId == newRun.userId) return false; // Own territory
  return newRun.averagePaceMinPerKm < currentBest.averagePaceMinPerKm;
}
```

### Database Schema
```sql
run_sessions:
- id (UUID)
- user_id (UUID)
- territory_id (INTEGER)
- distance_meters (DOUBLE)
- duration_seconds (INTEGER)
- average_pace_min_per_km (DOUBLE) ← Key metric!
- route_points (JSONB)
- territory_conquered (BOOLEAN)
- status (TEXT)
```

## 🚀 Setup Instructions

### 1. Database Setup
```bash
# Run the SQL schema in Supabase SQL Editor
cat SUPABASE_SCHEMA.sql
# Copy and execute in Supabase dashboard
```

### 2. Permissions
Pastikan permissions di AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.INTERNET" />
```

### 3. Google Maps API
Pastikan Google Directions API sudah enabled di Google Cloud Console.

## 📊 Leaderboard Queries

### Get Territory Leaderboard
```dart
final leaderboard = await runTrackingService.getTerritoryLeaderboard(
  territoryId: territory.id,
  limit: 10,
);
```

### Get User's Best Run
```dart
final bestRun = await runTrackingService.getBestRunForTerritory(
  territoryId: territory.id,
);
```

### Get User's Territories
```dart
final myTerritories = runningProvider.territories
    .where((t) => t.ownerId == currentUserId)
    .toList();
```

## 🎨 UI Components

### 1. Run Tracking Screen
- **Full-screen map** dengan route visualization
- **Large duration display** di center
- **Metric cards**: Distance, Pace, Speed
- **Control buttons**: Pause/Resume, Finish, Cancel

### 2. Completion Screen
- **Gradient background** dengan animasi
- **Trophy icon** untuk conquest, check icon untuk completion
- **Stats cards** dengan semua metrics
- **Conquest message** jika berhasil claim territory

### 3. Navigation Info Card
- **Destination name** & distance
- **ETA** (estimated time arrival)
- **Start Run button** (appears when at location)
- **Stop Navigation** button

## 🔐 Security Features

### Row Level Security (RLS)
```sql
-- Users can only modify their own run sessions
CREATE POLICY "Users can update own run sessions"
  ON run_sessions FOR UPDATE
  USING (auth.uid() = user_id);

-- Everyone can view completed runs (for leaderboards)
CREATE POLICY "Anyone can view completed run sessions"
  ON run_sessions FOR SELECT
  USING (status = 'completed');
```

## 🐛 Error Handling

### GPS Errors
```dart
try {
  await getCurrentLocation();
} catch (e) {
  // Fallback to default location
  _currentLatLng = const LatLng(1.18376, 104.01703);
}
```

### Network Errors
```dart
// Fallback to straight line if Directions API fails
if (directionsResult == null) {
  _routePoints = [currentLocation, destination];
  _calculateRouteMetricsFallback();
}
```

## 📈 Performance Optimizations

1. **GPS Updates**: Only update when moved >5 meters
2. **UI Updates**: Timer updates every 1-2 seconds
3. **Route Points**: Filtered to avoid excessive data
4. **Database Queries**: Indexed columns for fast lookups

## 🎯 Best Practices

### Running Best Practices
1. **Start at territory**: User harus berada di dalam territory
2. **Complete full route**: Minimal distance untuk valid run
3. **Fair competition**: Pace-based ranking ensures fairness
4. **Real-time feedback**: User dapat lihat progress secara langsung

### Code Best Practices
1. **State Management**: Using Provider pattern
2. **Separation of Concerns**: Service layer terpisah dari UI
3. **Error Handling**: Try-catch di semua async operations
4. **Logging**: AppLogger untuk debugging
5. **Type Safety**: Strong typing dengan Dart

## 🔄 Future Enhancements

1. **Social Features**
   - Challenge friends
   - Share achievements
   - Group runs

2. **Advanced Analytics**
   - Speed graphs
   - Pace analysis
   - Progress tracking

3. **Gamification**
   - Achievements/badges
   - Streak tracking
   - Rewards system

4. **Weather Integration**
   - Weather conditions
   - Temperature tracking
   - Safety alerts

## 📞 Support

Jika ada masalah atau pertanyaan:
1. Check logs di `AppLogger`
2. Verify GPS permissions
3. Check network connectivity
4. Verify Supabase connection

## 🎉 Conclusion

Sistem run tracking ini memberikan experience yang menarik dan competitive untuk users. Dengan pace-based leaderboard system, setiap user punya kesempatan untuk claim territory dengan improve performance mereka.

**Happy Running! 🏃‍♂️💨**
