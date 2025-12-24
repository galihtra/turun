# Goals Feature - Setup Guide

Fitur Goals memungkinkan user untuk menetapkan target distance dan calories untuk lari mereka, dengan progress tracking otomatis berdasarkan riwayat lari dalam periode yang dapat dipilih (harian, mingguan, atau bulanan).

## ✨ UI/UX Features (100% Match Design)

### Circular Progress Indicators
- ✅ Dual circular progress untuk Distance & Calories
- ✅ Stroke width: 16px dengan rounded caps
- ✅ Color scheme:
  - Distance: `#2563EB` (Blue) dengan background `#DCE7F7`
  - Calories: `#FF6B6B` (Red) dengan background `#FFE5E5`
- ✅ Center display: Current value, unit, target, dan period label
- ✅ Smooth animation dengan custom painter

### Latest Activities
- ✅ Real-time fetch dari database (run_sessions table)
- ✅ Display 3 aktivitas terbaru
- ✅ Card layout dengan shadow dan border
- ✅ Menampilkan: Distance, Duration, Average Pace
- ✅ Auto format date: "dd MMMM yyyy HH:mm a"
- ✅ Empty state dengan friendly message
- ✅ Pull-to-refresh support

### Design System
- ✅ Primary text: `#0D1B2A` (Navy)
- ✅ Secondary text: `#6B7280` (Gray)
- ✅ Tertiary text: `#9CA3AF` (Light Gray)
- ✅ Background: `#FFFFFF` (White)
- ✅ Spacing: Consistent 24px padding
- ✅ Border radius: 16px untuk cards
- ✅ Font weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

## 📋 Setup Instructions

### 1. Database Migration

Jalankan SQL migration untuk membuat tabel `goals` di Supabase:

```bash
# Buka Supabase SQL Editor dan jalankan file:
supabase_migrations/create_goals_table.sql
```

Atau copy-paste SQL berikut ke Supabase SQL Editor:

```sql
-- Create goals table for user running goals
CREATE TABLE IF NOT EXISTS goals (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN ('distance', 'calories')),
    target_value NUMERIC NOT NULL CHECK (target_value > 0),
    current_value NUMERIC DEFAULT 0 CHECK (current_value >= 0),
    unit TEXT NOT NULL CHECK (unit IN ('km', 'mile', 'kcal')),
    period TEXT NOT NULL DEFAULT 'daily' CHECK (period IN ('daily', 'weekly', 'monthly')),
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_goals_user_id ON goals(user_id);
CREATE INDEX idx_goals_is_active ON goals(is_active);
CREATE INDEX idx_goals_type ON goals(type);

-- Enable RLS
ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own goals"
    ON goals FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own goals"
    ON goals FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own goals"
    ON goals FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own goals"
    ON goals FOR DELETE USING (auth.uid() = user_id);
```

### 2. File Structure

Fitur ini sudah mencakup:

```
lib/
├── data/
│   ├── model/
│   │   └── goals/
│   │       └── goal_model.dart          # Goal data model
│   └── providers/
│       └── goals/
│           └── goal_provider.dart       # Goal state management
└── pages/
    └── goals/
        ├── my_goals_screen.dart         # Home screen dengan circular progress
        └── goal_setting_screen.dart     # Screen untuk set goals
```

### 3. Navigation Integration

Tambahkan navigasi ke My Goals Screen di bottom navigation atau home screen:

```dart
// Contoh: Di home screen atau bottom nav
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyGoalsScreen(),
      ),
    );
  },
  child: Text('My Goals'),
)
```

## 🎯 Features

### 1. My Goals Screen
- **Circular Progress Indicators**: Menampilkan progress distance dan calories
- **Period Display**: Menampilkan label periode (Today/This Week/This Month)
- **Goal Setting Button**: Akses cepat untuk mengubah goals
- **Latest Activities**: Menampilkan riwayat lari terbaru
- **Auto Progress Update**: Progress otomatis ter-update dari run history berdasarkan periode

### 2. Goal Setting Screen
- **Tab Selection**: Distance atau Calories
- **Period Selection**: Daily, Weekly, atau Monthly
- **Unit Selection**:
  - Distance: Km atau Mile
  - Calories: kcal (fixed)
- **Wheel Picker**: Scroll picker untuk pilih target value
  - Distance: 1-50 km
  - Calories: 100-2000 kcal (steps of 50)
- **Real-time Preview**: Lihat value yang dipilih secara real-time

### 3. Goal Model
```dart
class Goal {
  final GoalType type;           // distance atau calories
  final double targetValue;      // Target yang ingin dicapai
  final double currentValue;     // Progress saat ini
  final GoalUnit unit;           // Satuan (km, mile, kcal)
  final GoalPeriod period;       // Periode (daily, weekly, monthly)
  final bool isActive;           // Status goal aktif

  // Helper properties
  double get progressPercentage; // Persentase progress (0-100)
  bool get isCompleted;          // Apakah goal sudah tercapai
  double get remainingValue;     // Sisa untuk mencapai target
  String get periodLabel;        // Label periode untuk display
}
```

## 📊 Goal Progress Calculation

Progress goals dihitung otomatis berdasarkan periode yang dipilih:

### Period-based Calculation
- **Daily**: Menghitung progress dari jam 00:00 hari ini
- **Weekly**: Menghitung progress dari hari Senin minggu ini
- **Monthly**: Menghitung progress dari tanggal 1 bulan ini

### Distance Goal
- Menjumlahkan semua `distance_meters` dari `run_sessions` dengan status `completed` dalam periode
- Dikonversi ke Km atau Mile sesuai unit yang dipilih

### Calories Goal
- Menjumlahkan semua `calories_burned` dari `run_sessions` dengan status `completed` dalam periode
- Ditampilkan dalam kcal

## 🔄 Data Flow

1. **User Sets Goal**:
   ```
   GoalSettingScreen → GoalProvider.setGoal() → Supabase goals table
   ```

2. **Load Goals**:
   ```
   MyGoalsScreen → GoalProvider.loadActiveGoals() → Fetch from Supabase
   ```

3. **Update Progress**:
   ```
   GoalProvider._updateGoalProgress() → Query run_sessions → Update goal current_value
   ```

## 🎨 UI Components

### Circular Progress
- Custom painter untuk menggambar circular progress ring
- Progress bar berwarna sesuai dengan goal type
- Menampilkan current value di tengah dengan target di bawahnya

### Wheel Picker
- ListWheelScrollView untuk smooth scrolling
- Auto-select dengan highlight pada nilai yang dipilih
- Support unit yang berbeda

## 📝 Usage Examples

### 1. Set Distance Goal (Daily)
```dart
final goalProvider = context.read<GoalProvider>();
await goalProvider.setGoal(
  type: GoalType.distance,
  targetValue: 5.0,
  unit: GoalUnit.km,
  period: GoalPeriod.daily,
);
```

### 2. Set Calories Goal (Weekly)
```dart
final goalProvider = context.read<GoalProvider>();
await goalProvider.setGoal(
  type: GoalType.calories,
  targetValue: 3000.0,
  unit: GoalUnit.kcal,
  period: GoalPeriod.weekly,
);
```

### 3. Check Progress
```dart
final distanceGoal = goalProvider.activeDistanceGoal;
if (distanceGoal != null) {
  print('Period: ${distanceGoal.periodLabel}'); // "Today", "This Week", etc
  print('Progress: ${distanceGoal.progressPercentage}%');
  print('Current: ${distanceGoal.currentValue} / ${distanceGoal.targetValue}');
  print('Completed: ${distanceGoal.isCompleted}');
}
```

## 🔧 Customization

### Colors
Edit di `resources/colors_app.dart`:
```dart
static const blueLogo = Color(0xFF2979FF);  // Primary color for goals
static final navy = {
  900: Color(0xFF1A237E),  // Text color
};
```

### Target Ranges
Edit di `goal_setting_screen.dart`:
```dart
// Distance: 1-50 km
for (int i = 1; i <= 50; i++) {
  values.add(i.toDouble());
}

// Calories: 100-2000 kcal (steps of 50)
for (int i = 100; i <= 2000; i += 50) {
  values.add(i.toDouble());
}
```

## ⚡ Performance Tips

1. **Lazy Loading**: Goals hanya di-load saat `MyGoalsScreen` dibuka
2. **Progress Caching**: Current value di-cache di database untuk menghindari query berulang
3. **Efficient Queries**: Menggunakan index dan filter berdasarkan periode untuk query yang cepat
4. **Period-based Filtering**: Hanya menghitung run sessions dalam periode yang relevan

## 🐛 Troubleshooting

### Goals tidak muncul
- Pastikan user sudah login
- Check RLS policies di Supabase
- Verify tabel goals sudah dibuat

### Progress tidak update
- Pastikan run sessions memiliki status `completed`
- Check territory_id sudah ter-link dengan benar
- Refresh dengan memanggil `loadActiveGoals()`

### Unit tidak sesuai
- Pastikan unit tersimpan dengan benar di database
- Check enum mapping di `GoalUnit`

## 📚 Next Steps

1. **Notifications**: Tambahkan notifikasi saat goal tercapai
2. **History**: Track goal completion history
3. **Achievements**: Badge system untuk milestone goals
4. **Weekly/Monthly Goals**: Support untuk timeframe yang berbeda
5. **Goal Templates**: Pre-defined goals untuk beginner/intermediate/advanced

## 🎉 Done!

Fitur Goals siap digunakan! User sekarang bisa:
- ✅ Set distance dan area goals
- ✅ Track progress secara real-time
- ✅ Lihat visualisasi circular progress
- ✅ Update goals kapan saja
