-- ============================================
-- SAMPLE TERRITORY DATA FOR TESTING
-- Contoh data territory dengan polygon points
-- ============================================

-- Territory 1: Example around Batam Center
-- Polygon berbentuk persegi dengan 4 titik
INSERT INTO territories (name, region, points, difficulty, reward_points, area_size_km, description)
VALUES (
  'Batam Center Square',
  'Batam City',
  '[
    {"lat": 1.13000, "lng": 104.05000},
    {"lat": 1.13000, "lng": 104.05500},
    {"lat": 1.12500, "lng": 104.05500},
    {"lat": 1.12500, "lng": 104.05000}
  ]'::jsonb,
  'Easy',
  100,
  0.5,
  'A square route around Batam Center area'
) ON CONFLICT DO NOTHING;

-- Territory 2: Example around current location (based on screenshot)
-- Polygon sekitar area Perumahan GMP / Andy Tailor
INSERT INTO territories (name, region, points, difficulty, reward_points, area_size_km, description)
VALUES (
  'GMP Neighborhood Loop',
  'Batam City',
  '[
    {"lat": 1.12180, "lng": 104.04820},
    {"lat": 1.12200, "lng": 104.04950},
    {"lat": 1.12080, "lng": 104.04970},
    {"lat": 1.12060, "lng": 104.04840}
  ]'::jsonb,
  'Easy',
  80,
  0.3,
  'Loop around GMP residential area'
) ON CONFLICT DO NOTHING;

-- Territory 3: Larger polygon with 6 points
INSERT INTO territories (name, region, points, difficulty, reward_points, area_size_km, description)
VALUES (
  'Harvestaa Commercial Loop',
  'Batam City',
  '[
    {"lat": 1.12150, "lng": 104.04700},
    {"lat": 1.12250, "lng": 104.04800},
    {"lat": 1.12300, "lng": 104.04950},
    {"lat": 1.12200, "lng": 104.05050},
    {"lat": 1.12050, "lng": 104.05000},
    {"lat": 1.12000, "lng": 104.04850}
  ]'::jsonb,
  'Medium',
  150,
  0.8,
  'Longer route through commercial area'
) ON CONFLICT DO NOTHING;

-- ============================================
-- IMPORTANT NOTES:
-- ============================================

-- 1. Points Format:
--    - JSONB array of objects
--    - Each object has "lat" and "lng" keys
--    - First point = START/FINISH (closed loop)
--    - Minimum 3 points untuk polygon

-- 2. Coordinate System:
--    - lat = Latitude (1.xxx untuk Batam area)
--    - lng = Longitude (104.xxx untuk Batam area)

-- 3. Testing:
--    - Adjust coordinates based on your actual location
--    - Use Google Maps to get accurate coordinates
--    - Right-click on map → "What's here?" untuk get coordinates

-- 4. Visual Representation:
--    Polygon akan muncul di map sebagai:
--    - Filled area (semi-transparent)
--    - Border line (solid stroke)
--    - Corner markers (pins at each point)

-- ============================================
-- HOW TO GET COORDINATES FOR YOUR AREA:
-- ============================================

-- Method 1: Google Maps
-- 1. Open https://www.google.com/maps
-- 2. Right-click on map location
-- 3. Click "What's here?"
-- 4. Copy lat, lng values

-- Method 2: From your Flutter app
-- 1. Print current location: print('${position.latitude}, ${position.longitude}')
-- 2. Walk around territory boundaries
-- 3. Record coordinates at each corner
-- 4. Create polygon from those points

-- ============================================
-- VERIFY DATA:
-- ============================================

-- Check if territories have points
SELECT
  id,
  name,
  jsonb_array_length(points) as num_points,
  points
FROM territories
ORDER BY id;

-- Should show:
-- id | name                      | num_points | points
-- 1  | Batam Center Square       | 4          | [{"lat": ...}, ...]
-- 2  | GMP Neighborhood Loop     | 4          | [{"lat": ...}, ...]
-- 3  | Harvestaa Commercial Loop | 6          | [{"lat": ...}, ...]
