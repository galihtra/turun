# 🗺️ Visual Guidance - Penjelasan Lengkap

## Masalah di Screenshot

Dari screenshot yang Anda kirim, map terlihat "polos" tanpa visual guidance karena:

1. ❌ **Territory belum dipilih** atau **tidak punya points data**
2. ❌ **Polygon tidak muncul** karena points array kosong
3. ❌ **Markers tidak terlihat** karena tidak ada checkpoint

## Apa Yang Seharusnya Terlihat

### SEBELUM Mulai Lari (Preview Mode):

```
┌──────────────────────────────────────┐
│  🏁 Territory Name                   │
│                                      │
│     🟢 START                         │
│      ╲                               │
│       ╲ ─ ─ ─ ─ (territory border)  │ ← Polygon outline
│        ╲                             │
│         🔵 Corner 1                  │ ← Preview markers
│          ╲                           │
│           ╲ ─ ─ ─                    │
│            ╲                         │
│             🔵 Corner 2              │
│              ╲                       │
│               ╲ ─ ─ ─               │
│                ╲                     │
│                 🔵 Corner 3          │
│                  ╲                   │
│                   ╲ ─ ─ ─           │
│                    ╲                 │
│  [Shaded polygon area]               │ ← Semi-transparent fill
│                                      │
│  [MULAI LARI Button]                 │
└──────────────────────────────────────┘
```

**Yang terlihat:**
- ✅ **Green START marker** (🟢) - titik mulai
- ✅ **Blue corner markers** (🔵) - preview checkpoints
- ✅ **Territory polygon** - area berwarna semi-transparent
- ✅ **Border line** - garis keliling territory

### SAAT Mulai Lari (Active Run Mode):

```
┌──────────────────────────────────────┐
│  🏁 Territory Name                   │
│     Route Progress  25%              │
│     ▓▓▓▓▓░░░░░░░░░░                 │
│                                      │
│     🔵 START (faded)                 │
│      ═════════ (user's path)        │ ← Solid colored line
│       ╲ ─ ─ ─ (guidance)            │ ← Dashed blue line
│        ═════                         │
│         🟡 Checkpoint 1 (NEXT!)      │ ← Yellow = current target
│          ╲                           │
│           ╲ ─ ─ ─                    │
│            ╲                         │
│             🔵 Checkpoint 2          │
│              ╲                       │
│               ╲ ─ ─ ─               │
│                ╲                     │
│                 🔵 Checkpoint 3      │
│                                      │
│  00:05:23 │ 1.2 km │ 4'28"/km       │
│  [⏸] [✓] [✕]                        │
└──────────────────────────────────────┘
```

**Yang terlihat:**
- ✅ **Progress bar** di atas
- ✅ **Dashed blue guidance line** - rute yang harus diikuti
- ✅ **Solid colored user path** - jejak GPS user (warna profile)
- ✅ **Yellow current checkpoint** - target selanjutnya
- ✅ **Blue future checkpoints** - yang belum dicapai
- ✅ **Faded passed checkpoints** - yang sudah dilewati

---

## Kenapa Map Anda "Polos"?

### Kemungkinan 1: Territory Tidak Punya Points

Cek database Anda:
```sql
SELECT id, name, points FROM territories WHERE id = YOUR_TERRITORY_ID;
```

Jika `points` = `[]` atau `null` → **INILAH MASALAHNYA!**

**Solusi**: Insert territory dengan points yang benar (gunakan `TERRITORY_SAMPLE_DATA.sql`)

### Kemungkinan 2: Territory Belum Dipilih

Pastikan user sudah:
1. Tap pada territory di map
2. Klik "Navigate" button
3. Territory polygon akan highlight jadi hijau
4. Markers akan muncul

### Kemungkinan 3: Points Format Salah

Points harus format JSONB array of objects:
```json
[
  {"lat": 1.13000, "lng": 104.05000},
  {"lat": 1.13000, "lng": 104.05500},
  {"lat": 1.12500, "lng": 104.05500}
]
```

**BUKAN:**
```json
// ❌ SALAH - array of arrays
[[1.13000, 104.05000], [1.13000, 104.05500]]

// ❌ SALAH - string
"1.13000,104.05000;1.13000,104.05500"

// ❌ SALAH - missing keys
[{1.13000, 104.05000}, {1.13000, 104.05500}]
```

---

## Cara Mendapatkan Coordinates

### Method 1: Google Maps (Manual)

1. Buka https://www.google.com/maps
2. Cari lokasi area yang mau dijadikan territory
3. Right-click di pojok pertama → "What's here?"
4. Copy lat/lng (contoh: `1.13000, 104.05000`)
5. Ulangi untuk setiap pojok polygon
6. Buat array JSONB

**Example untuk area persegi:**
```
Pojok 1 (top-left):     1.13000, 104.05000
Pojok 2 (top-right):    1.13000, 104.05500
Pojok 3 (bottom-right): 1.12500, 104.05500
Pojok 4 (bottom-left):  1.12500, 104.05000
```

Insert ke database:
```sql
INSERT INTO territories (name, region, points)
VALUES (
  'Test Territory',
  'Batam City',
  '[
    {"lat": 1.13000, "lng": 104.05000},
    {"lat": 1.13000, "lng": 104.05500},
    {"lat": 1.12500, "lng": 104.05500},
    {"lat": 1.12500, "lng": 104.05000}
  ]'::jsonb
);
```

### Method 2: Flutter App (Programmatic)

Tambahkan temporary code untuk record coordinates:

```dart
// Di running_page.dart, tambahkan floating button
FloatingActionButton(
  onPressed: () {
    final pos = runningProvider.currentLatLng;
    print('{"lat": ${pos!.latitude}, "lng": ${pos.longitude}}');
    // Copy output dari console
  },
  child: Icon(Icons.add_location),
)
```

**Steps:**
1. Buka app
2. Jalan ke pojok pertama territory
3. Tap button → copy coordinate
4. Jalan ke pojok kedua
5. Tap button → copy coordinate
6. Ulangi untuk semua pojok
7. Combine jadi array JSONB

---

## Testing Visual Guidance

### Step 1: Insert Sample Territory

Jalankan SQL dari `TERRITORY_SAMPLE_DATA.sql`:

```sql
INSERT INTO territories (name, region, points, difficulty, reward_points)
VALUES (
  'Test Loop',
  'Batam City',
  '[
    {"lat": 1.12180, "lng": 104.04820},
    {"lat": 1.12200, "lng": 104.04950},
    {"lat": 1.12080, "lng": 104.04970},
    {"lat": 1.12060, "lng": 104.04840}
  ]'::jsonb,
  'Easy',
  100
);
```

### Step 2: Verify in Database

```sql
-- Check points exist
SELECT
  id,
  name,
  jsonb_array_length(points) as num_points
FROM territories
WHERE name = 'Test Loop';

-- Should show: num_points = 4
```

### Step 3: Open App & Navigate

1. **Refresh territory list** - pull to refresh
2. **Tap territory** - polygon akan highlight
3. **Lihat markers** - green START + blue corners
4. **Tap "Navigate"** - route akan muncul
5. **Pergi ke START point** - dalam radius 20m
6. **Tap "MULAI LARI"** - guidance route activated!

### Step 4: Verify Visual Elements

Checklist apa yang harus terlihat:

**BEFORE Run (Preview):**
- [ ] Territory polygon terlihat (shaded area)
- [ ] Border line jelas (stroke around polygon)
- [ ] Green START marker di pojok pertama
- [ ] Blue corner markers di pojok lainnya
- [ ] Territory name badge di atas

**DURING Run (Active):**
- [ ] Blue dashed guidance line (rute yang harus diikuti)
- [ ] User's colored path (jejak GPS)
- [ ] Yellow current checkpoint marker
- [ ] Blue future checkpoints
- [ ] Faded passed checkpoints
- [ ] Progress bar dengan percentage
- [ ] Checkpoint counter (e.g., "2 of 4")

---

## Troubleshooting

### Q: "Map masih polos setelah insert territory"
**A**: Restart app atau pull-to-refresh territory list

### Q: "Polygon muncul tapi markers tidak"
**A**: Pastikan territory sudah di-select (tap polygon terlebih dahulu)

### Q: "Guidance line tidak muncul saat run"
**A**: Pastikan sudah tap "MULAI LARI" button setelah arrive di start point

### Q: "Checkpoint markers semua warna biru"
**A**: Normal - yellow hanya untuk checkpoint yang sedang dituju

### Q: "Progress bar stuck di 0%"
**A**: User belum mencapai checkpoint pertama (harus dalam radius 15m)

---

## Visual Layers (Z-Order)

Urutan dari bawah ke atas:

1. **Map background** (Google Maps tiles)
2. **Territory polygons** (filled + stroked)
3. **Blue guidance polyline** (dashed)
4. **User path polyline** (solid, colored)
5. **Checkpoint markers** (pins)
6. **UI overlays** (buttons, stats)

```
     ┌─── UI Overlays (6)
     │ ┌─ Markers (5)
     │ │ ┌ User Path (4)
     │ │ │ ╱─ Guidance (3)
     │ │ │ │ ▓ Polygon (2)
     │ │ │ │ │ Map (1)
     ↓ ↓ ↓ ↓ ↓ ↓
```

---

## Expected Behavior

### Scenario 1: User Selects Territory
1. User taps grey polygon on map
2. Polygon turns **green** (highlighted)
3. **Green START marker** appears at first point
4. **Blue corner markers** appear at other points
5. "Navigate" button becomes available

### Scenario 2: User Starts Navigation
1. User taps "Navigate" button
2. Route line draws from user → start point
3. Navigation card shows distance & ETA
4. When user arrives at start (< 20m):
   - Navigation card **hides**
   - "MULAI LARI" button **appears**

### Scenario 3: User Starts Run
1. User taps "MULAI LARI"
2. **Blue dashed guidance line** appears (full loop)
3. **All checkpoint markers** appear:
   - START = green (faded after passing)
   - Checkpoint 1 = **yellow** (current target)
   - Checkpoints 2-N = blue (future)
   - FINISH = red (at start point)
4. **Progress bar** appears (starts at 0%)
5. **User's path** starts recording (colored line)

### Scenario 4: User Reaches Checkpoint
1. User runs within 15m of yellow checkpoint
2. Yellow checkpoint turns **blue** (passed)
3. **Next checkpoint** turns **yellow** (new target)
4. **Progress bar** updates (e.g., 25% → 50%)
5. Console log: "✅ Checkpoint 2 reached! 50% complete"

### Scenario 5: User Completes Loop
1. User returns to start point (finish)
2. Red FINISH marker becomes bright (100% progress)
3. All checkpoints are faded (passed)
4. Progress bar = **100%**
5. User can tap "Finish" button
6. Navigate to completion screen with stats

---

## Summary

**Untuk mendapatkan visual guidance yang jelas:**

1. ✅ **Territory HARUS punya points** (min 3 points)
2. ✅ **Points format JSONB** array of objects dengan "lat" & "lng"
3. ✅ **User harus select territory** (tap polygon)
4. ✅ **Markers akan auto-generate** saat select/run
5. ✅ **Guidance line muncul** saat mulai lari
6. ✅ **Progress tracking** real-time setiap checkpoint

**Kalau masih "polos":**
- 🔍 Cek `SELECT points FROM territories` - pastikan ada data
- 🔍 Cek console logs - ada error territory loading?
- 🔍 Restart app - fresh load dari database
- 🔍 Gunakan sample data dari `TERRITORY_SAMPLE_DATA.sql`

---

**File Terkait:**
- [TERRITORY_SAMPLE_DATA.sql](TERRITORY_SAMPLE_DATA.sql) - Sample territory dengan points
- [TERRITORY_GUIDANCE_ROUTE.md](TERRITORY_GUIDANCE_ROUTE.md) - Technical documentation
- [UI_REDESIGN_SUMMARY.md](UI_REDESIGN_SUMMARY.md) - UI visual comparison

**Status**: ✅ Visual guidance system complete - tinggal ensure territory punya points data!
