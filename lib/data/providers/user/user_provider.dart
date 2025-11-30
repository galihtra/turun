import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/user/user_model.dart';

class UserProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load user data
  Future<void> loadUserData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      _currentUser = UserModel.fromJson(response);
      debugPrint('✅ User data loaded: ${_currentUser?.fullName}');
    } catch (e) {
      debugPrint('❌ Error loading user data: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);

      // Reload user data
      await loadUserData(userId);
      
      debugPrint('✅ User profile updated');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Complete onboarding
  Future<bool> completeOnboarding(Map<String, dynamic> profileData) async {
    profileData['has_completed_onboarding'] = true;
    profileData['updated_at'] = DateTime.now().toIso8601String();
    
    return await updateUserProfile(profileData);
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      final response = await _supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      return response == null;
    } catch (e) {
      debugPrint('❌ Error checking username: $e');
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}