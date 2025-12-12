# 🏁 Start Point Update

## Perubahan

Sistem sekarang mengharuskan user **memulai lari dari titik START (koordinat pertama)** bukan dari mana saja di dalam territory.

## Fitur Baru

### 1. **Navigation ke Start Point**
- Ketika tap "Go to Location", sistem navigasi ke **koordinat pertama** (bukan center)
- Route akan mengarahkan user ke start point

### 2. **Start Point Marker**
- Marker hijau 🏁 muncul di start point ketika territory dipilih
- Info window: "START POINT - Begin your run here"

### 3. **Validation Check**
- User harus berada dalam **radius 20 meter** dari start point
- Jika belum sampai, muncul pesan: "Please go to the START POINT first!"
- Menampilkan jarak yang tersisa ke start point

## Cara Kerja

### Flow Baru:

```
1. User pilih territory
   ↓
2. Marker 🏁 muncul di start point (koordinat pertama)
   ↓
3. Tap "Go to Location" → Navigasi ke start point
   ↓
4. User follow route ke start point
   ↓
5. Ketika dalam radius 20m dari start point:
   → "Start Run" button aktif
   ↓
6. Tap "Start Run" → Begin tracking
```

### Koordinat Example:

```json
{
  "points": [
    {"lat": 1.1831280244895381, "lng": 104.0173393444038},  // ← START POINT (index 0)
    {"lat": 1.1828008647334491, "lng": 104.01741444625621},
    {"lat": 1.1826882359560347, "lng": 104.01706575908428},
    // ... dst
  ]
}
```

User **HARUS** mulai dari koordinat index 0 (pertama dalam array).

## Code Changes

### 1. RunningProvider - New Methods

```dart
// Check if user at start point (within 20m)
bool isAtTerritoryStartPoint(LatLng userLocation, Territory territory)

// Get distance to start point
double? getDistanceToStartPoint(LatLng? userLocation, Territory? territory)
```

### 2. Navigation Logic Update

```dart
// Navigate to first coordinate instead of center
final destination = territory.points.isNotEmpty
    ? territory.points.first  // ← Start point
    : _getCenterPoint(territory.points);
```

### 3. Start Run Validation

```dart
// Check if at start point
final isAtStartPoint = runningProvider.isAtTerritoryStartPoint(
  runningProvider.currentLatLng!,
  selectedTerritory,
);

if (isAtStartPoint) {
  // ✅ Can start run
} else {
  // ❌ Show distance to start point
}
```

### 4. Visual Marker

```dart
// Green marker at start point
Marker(
  markerId: MarkerId('start_${territory.id}'),
  position: territory.points.first,
  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  infoWindow: const InfoWindow(
    title: '🏁 START POINT',
    snippet: 'Begin your run here',
  ),
)
```

## Testing

### Test Case 1: At Start Point
```
1. Navigate to territory start point
2. Get within 20 meters
3. Tap "Start Run"
Expected: ✅ Run begins successfully
```

### Test Case 2: Not at Start Point
```
1. Navigate to territory
2. Stay more than 20 meters from start point
3. Tap "Start Run"
Expected: ⚠️ Message: "Please go to the START POINT first! X m remaining"
```

### Test Case 3: Visual Confirmation
```
1. Select a territory
2. Look at map
Expected: ✅ Green marker 🏁 visible at start point
```

## Configuration

### Adjust Start Point Radius

Di `running_provider.dart`:

```dart
bool isAtTerritoryStartPoint(LatLng userLocation, Territory territory) {
  // Change this value to adjust radius
  return distanceToStart <= 20; // ← Currently 20 meters
}
```

**Recommended values:**
- **10m** - Very strict (only for precise GPS)
- **20m** - Balanced (current setting) ✅
- **50m** - Lenient (for areas with poor GPS)

## User Messages

### Success (at start point):
```
🎉 You're at the start point! Starting run...
```

### Warning (not at start point):
```
⚠️ Please go to the START POINT first!
X m remaining
```

## Benefits

✅ **Fair Competition**: Everyone starts from same point
✅ **Consistent Routes**: All runs follow same path
✅ **Clear Instructions**: Visual marker shows where to go
✅ **Better Tracking**: GPS has time to stabilize at start
✅ **Professional**: Matches real running events

## Notes

- Start point adalah **koordinat pertama** dalam array `points`
- Marker hijau otomatis muncul ketika territory dipilih
- Radius 20 meter memberikan margin error untuk GPS
- Distance to start point ditampilkan real-time
- Navigation route mengarahkan langsung ke start point

## Troubleshooting

### Issue: "Start Run" tidak muncul
**Solution:**
- Pastikan GPS aktif dan akurat
- Tunggu 10-20 detik untuk GPS stabilize
- Bergerak lebih dekat ke marker hijau 🏁
- Check jarak: harus < 20 meter

### Issue: Marker tidak terlihat
**Solution:**
- Pastikan territory sudah dipilih (highlighted hijau)
- Zoom in ke territory
- Check territory.points tidak kosong

### Issue: Selalu "not at start point"
**Solution:**
- Check GPS accuracy (Settings → Location → High Accuracy)
- Move outdoors untuk better GPS signal
- Increase radius di code jika perlu (50m)

## Summary

Sistem sekarang **lebih strict dan fair**:
- ✅ User harus mulai dari start point
- ✅ Visual marker menunjukkan lokasi
- ✅ Distance validation (20m radius)
- ✅ Clear error messages
- ✅ Professional running experience

Perubahan ini membuat sistem lebih mirip dengan **real running events** dimana semua peserta start dari garis yang sama! 🏁
