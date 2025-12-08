import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/app/app_logger.dart';

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
    AppLogger.info(LogLabel.provider, 'Loading user data for ID: $userId');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

      AppLogger.network(LogLabel.supabase, 'User data fetched from database');
      debugPrint('Response: $response');

      _currentUser = UserModel.fromJson(response);

      AppLogger.success(LogLabel.provider, 'User data loaded successfully');
      debugPrint('User: ${_currentUser?.fullName} (${_currentUser?.email})');
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Failed to load user data', e, stackTrace);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    AppLogger.info(LogLabel.provider, 'Updating user profile');
    debugPrint('Update data: $updates');

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      AppLogger.debug(LogLabel.provider, 'User ID: $userId');

      await _supabase.from('users').update(updates).eq('id', userId);

      AppLogger.success(LogLabel.supabase, 'Profile updated in database');

      // Reload user data
      await loadUserData(userId);

      AppLogger.success(LogLabel.provider, 'User profile updated successfully');
      return true;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Failed to update profile', e, stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ======================================================================
  // Avatar Upload to Supabase Storage
  // ======================================================================
  Future<String?> uploadAvatar(File imageFile, String userId) async {
    AppLogger.info(LogLabel.supabase, 'Starting avatar upload');

    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$userId-$timestamp.jpg';
      final filePath = 'avatars/$fileName';

      AppLogger.debug(LogLabel.supabase, 'Uploading to: $filePath');

      // Upload to Supabase Storage
      await _supabase.storage.from('avatars').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      AppLogger.success(LogLabel.supabase, 'File uploaded successfully');

      // Get public URL
      final avatarUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);

      AppLogger.success(LogLabel.supabase, 'Avatar URL: $avatarUrl');

      return avatarUrl;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.supabase, 'Failed to upload avatar', e, stackTrace);
      return null;
    }
  }

  // ======================================================================
  // Complete Onboarding with Avatar Handling
  // ======================================================================
  Future<bool> completeOnboarding(Map<String, dynamic> profileData) async {
    AppLogger.info(LogLabel.provider, 'Starting onboarding completion');
    debugPrint('Onboarding data received: $profileData');

    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      AppLogger.error(LogLabel.auth, 'User not authenticated');
      _error = 'User not authenticated';
      return false;
    }

    // ======================================================================
    // Handle Avatar
    // ======================================================================
    final avatarSource = profileData['_avatar_source'] as String?;
    
    if (avatarSource == 'upload') {
      // ✅ User uploaded new image - upload to Storage
      final avatarFilePath = profileData['_avatar_file_path'] as String?;
      
      if (avatarFilePath != null) {
        AppLogger.info(LogLabel.supabase, 'Uploading new avatar to Storage...');
        
        final avatarFile = File(avatarFilePath);
        final avatarUrl = await uploadAvatar(avatarFile, userId);

        if (avatarUrl != null) {
          profileData['avatar_url'] = avatarUrl;
          AppLogger.success(LogLabel.supabase, 'New avatar uploaded');
          debugPrint('Avatar URL: $avatarUrl');
        } else {
          AppLogger.warning(LogLabel.supabase, 'Avatar upload failed, continuing without avatar');
        }
      }
    } else if (avatarSource == 'google') {
      // ✅ User keeping Google avatar - use existing URL
      final googleAvatarUrl = profileData['_google_avatar_url'] as String?;
      
      if (googleAvatarUrl != null) {
        profileData['avatar_url'] = googleAvatarUrl;
        AppLogger.info(LogLabel.google, 'Using Google avatar');
        debugPrint('Google avatar URL: $googleAvatarUrl');
      }
    }

    // ✅ Remove temporary fields (don't send to database)
    profileData.remove('_avatar_source');
    profileData.remove('_avatar_file_path');
    profileData.remove('_google_avatar_url');

    // Add system fields
    profileData['has_completed_onboarding'] = true;
    profileData['updated_at'] = DateTime.now().toIso8601String();

    debugPrint('Final data to send: $profileData');

    final result = await updateUserProfile(profileData);

    if (result) {
      AppLogger.success(LogLabel.provider, 'Onboarding completed successfully! 🎉');
    } else {
      AppLogger.error(LogLabel.provider, 'Onboarding completion failed');
    }

    return result;
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    AppLogger.debug(LogLabel.provider, 'Checking username: $username');

    try {
      final response = await _supabase
          .from('users')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      final isAvailable = response == null;

      if (isAvailable) {
        AppLogger.success(LogLabel.provider, 'Username "$username" is available');
      } else {
        AppLogger.warning(LogLabel.provider, 'Username "$username" is taken');
      }

      return isAvailable;
    } catch (e, stackTrace) {
      AppLogger.error(LogLabel.provider, 'Error checking username', e, stackTrace);
      return false;
    }
  }

  void clearError() {
    AppLogger.debug(LogLabel.provider, 'Clearing error');
    _error = null;
    notifyListeners();
  }
}