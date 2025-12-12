# Run Tracking UI Update - Compact & User-Friendly Design

## Summary
Redesigned run tracking screen UI untuk lebih compact, user-friendly, dan adjustable agar rute lari terlihat jelas di map.

## Key Changes

### 1. **Draggable Bottom Sheet** ✅
- Stats sekarang menggunakan `DraggableScrollableSheet`
- **Collapsed Mode (25%)**: Menampilkan stats compact horizontal
- **Expanded Mode (70%)**: Menampilkan stats detail lengkap
- User bisa drag up/down untuk adjust ukuran

### 2. **Compact Stats View** ✅
Ketika collapsed, stats ditampilkan secara horizontal:
```
┌─────────────────────────────────────────┐
│  00:13      0 m       --'--"/km         │
│ Duration  Distance      Pace            │
│                                         │
│   [⏸]      [✓]         [✕]             │
└─────────────────────────────────────────┘
```
- Hanya 3 metrics penting: Duration, Distance, Pace
- Button controls dalam bentuk icon circular
- **Total height ~25% screen** - map terlihat jelas!

### 3. **Expanded Stats View** ✅
Ketika di-drag up (>40% screen), menampilkan detail lengkap:
```
┌─────────────────────────────────────────┐
│            00:13:45                     │
│             Duration                    │
│                                         │
│  ┌──────────┐    ┌──────────┐         │
│  │ Distance │    │   Pace   │         │
│  │  245 m   │    │ 5'23"/km │         │
│  └──────────┘    └──────────┘         │
│                                         │
│  ┌────────────────────────────┐        │
│  │    Current Speed            │        │
│  │      12.5 km/h              │        │
│  └────────────────────────────┘        │
│                                         │
│  [Pause]    [Finish]    [Cancel]      │
└─────────────────────────────────────────┘
```

### 4. **User Profile Color Integration** 🎨
- Polyline rute lari sekarang menggunakan **warna profile user** (dari `profile_color` di database)
- Territory name badge juga mengikuti warna user
- Icon dan accent colors match dengan profile color
- Fallback ke `AppColors.blueLogo` jika profile_color null

### 5. **Map Visibility** ✅
- Map sekarang **full screen** - tidak ada blockage
- Stats hanya occupy 25-70% dari bawah
- User bisa lihat rute dengan jelas sambil lari
- Territory polygon tetap visible

### 6. **No Bottom Overflow** ✅
- Semua widgets di dalam `DraggableScrollableSheet`
- Proper SafeArea handling
- Bottom buttons adjust dengan sheet size
- Yellow/black stripes (overflow indicator) fixed

## Widget Architecture

### New Widgets Created:

1. **`_CompactMetric`** - Small horizontal metric display
   - Untuk collapsed mode
   - Hanya value + label

2. **`_DetailedMetricCard`** - Card dengan icon untuk expanded mode
   - Icon, label, dan value
   - Support `isWide` untuk horizontal layout

3. **`_CompactButton`** - Circular icon button
   - Untuk collapsed mode
   - Icon only, no label

4. **`_ControlButton`** - Full button dengan icon + label (existing)
   - Untuk expanded mode
   - Icon + text label

## User Flow

1. **Saat Mulai Lari**:
   - Bottom sheet muncul dalam collapsed mode (25%)
   - Map terlihat jelas dengan rute berwarna sesuai profile user
   - Territory name badge di atas (compact)

2. **Saat Butuh Detail**:
   - User drag up bottom sheet
   - Stats expand menampilkan semua metrics
   - Masih bisa lihat sebagian map

3. **Saat Ingin Fokus Rute**:
   - User drag down kembali ke collapsed
   - Map jadi dominan
   - Stats tetap visible tapi tidak mengganggu

## Color System

```dart
// User profile color diambil dari database
final userColor = _parseColor(userProvider.currentUser?.profileColor);

// Digunakan untuk:
- Polyline rute lari ✅
- Territory badge background & icon ✅
- Metric values color ✅
- Control buttons accent ✅
- Duration text color ✅
```

## Technical Implementation

### Polyline Color Override
```dart
Set<Polyline> _buildRunPolylines(RunningProvider provider, Color userColor) {
  final polylines = <Polyline>{};
  final points = provider.runRoutePolylines;

  for (var polyline in points) {
    polylines.add(
      polyline.copyWith(
        colorParam: userColor,  // Override dengan warna user
        widthParam: 6,
      ),
    );
  }

  return polylines;
}
```

### Sheet Size Detection
```dart
NotificationListener<DraggableScrollableNotification>(
  onNotification: (notification) {
    setState(() {
      _sheetSize = notification.extent;  // Track current size
    });
    return true;
  },
  // ...
)

// Conditional rendering based on size
final isExpanded = _sheetSize > 0.4;
if (!isExpanded) {
  return _buildCompactStats();  // Horizontal compact
} else {
  return _buildExpandedStats();  // Full detailed
}
```

## Benefits

✅ **Map Visibility**: Rute terlihat jelas selama berlari
✅ **Adjustable**: User kontrol berapa banyak info yang ditampilkan
✅ **No Overflow**: UI fit sempurna di semua screen sizes
✅ **Personal**: Warna rute match dengan profile user
✅ **Clean**: UI modern dan tidak berantakan
✅ **Responsive**: Smooth drag interaction

## Files Modified

- `lib/pages/running/run_tracking_screen.dart` - Complete redesign
  - Added draggable bottom sheet
  - Added compact/expanded modes
  - Added user color integration
  - Fixed overflow issues

## Next Steps (Optional Enhancements)

- [ ] Add haptic feedback saat drag sheet
- [ ] Add animation untuk transition compact ↔ expanded
- [ ] Add snap points untuk intermediate sizes
- [ ] Add gesture untuk swipe down to dismiss (cancel run)
- [ ] Add blur effect di map area yang tertutup sheet

## Testing Notes

Test dengan berbagai kondisi:
- ✅ Map terlihat dengan jelas
- ✅ Stats readable di collapsed mode
- ✅ Drag smooth up and down
- ✅ Buttons accessible di kedua mode
- ✅ Warna user applied correctly
- ✅ No overflow di bottom
- ✅ Territory badge visible
- ✅ Location button accessible

---

**Updated**: 2025-12-12
**Status**: ✅ Complete
