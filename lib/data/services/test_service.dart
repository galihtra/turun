import 'package:supabase_flutter/supabase_flutter.dart';

class TestService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> insertTestData() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.from('test_items').insert({
      'title': 'Item Percobaan',
      'description': 'Ini adalah data test Supabase pertama saya',
    });

    print(response);
  }

  Future<void> fetchTestData() async {
    final response = await _supabase.from('test_items').select();
    print('Fetch response: $response');
  }
}
