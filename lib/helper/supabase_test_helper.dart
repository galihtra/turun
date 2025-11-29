import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseTestHelper {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Test koneksi ke Supabase
  static Future<void> testConnection() async {
    debugPrint('🔍 Testing Supabase connection...');
    
    try {
      // Test 1: Check if Supabase is initialized
      debugPrint('✅ Supabase initialized');
      
      // Test 2: Try to fetch data
      final response = await _supabase
          .from('territories')
          .select()
          .limit(5);
      
      debugPrint('✅ Query successful!');
      debugPrint('📦 Response type: ${response.runtimeType}');
      debugPrint('📦 Response: $response');
      
      if (response is List) {
        debugPrint('📋 Found ${response.length} territories');
        for (var item in response) {
          debugPrint('   - Territory: $item');
        }
      }
      
    } catch (e, stackTrace) {
      debugPrint('❌ Supabase test failed: $e');
      debugPrint('Stack: $stackTrace');
    }
  }

  // Test insert dummy data (untuk testing)
  static Future<void> insertDummyTerritory() async {
    try {
      debugPrint('🔄 Inserting dummy territory...');
      
      final dummyData = {
        'name': 'Test Territory',
        'region': 'Test Region',
        'points': [
          {'lat': 1.18376, 'lng': 104.01703},
          {'lat': 1.18400, 'lng': 104.01703},
          {'lat': 1.18400, 'lng': 104.01750},
          {'lat': 1.18376, 'lng': 104.01750},
        ],
      };
      
      await _supabase
          .from('territories')
          .insert(dummyData);
      
      debugPrint('✅ Dummy territory inserted');
    } catch (e) {
      debugPrint('❌ Insert failed: $e');
    }
  }

  // Check table structure
  static Future<void> checkTableStructure() async {
    try {
      debugPrint('🔍 Checking table structure...');
      
      final response = await _supabase
          .from('territories')
          .select()
          .limit(1)
          .single();
      
      debugPrint('📋 Table columns:');
      if (response is Map) {
        response.forEach((key, value) {
          debugPrint('   - $key: ${value.runtimeType} = $value');
        });
      }
    } catch (e) {
      debugPrint('❌ Check structure failed: $e');
    }
  }
}