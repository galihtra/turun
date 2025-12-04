import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _autoResetError() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_error != null) {
        _resetError();
      }
    });
  }

  void _resetError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _isLoading = false;
    notifyListeners();
    _autoResetError();
  }

  String _getUserFriendlyError(String errorMessage) {
    if (errorMessage.contains('Invalid login credentials')) {
      return 'The email or password you entered is incorrect. Please try again.';
    } else if (errorMessage.contains('Email not confirmed')) {
      return 'Email not confirmed. Please check your inbox for the confirmation email.';
    } else if (errorMessage.contains('User already registered')) {
      return 'This email is already registered. Please use a different email or login.';
    } else if (errorMessage.contains('Password should be at least')) {
      return 'Password must be at least 6 characters long.';
    } else if (errorMessage.contains('Invalid email')) {
      return 'Invalid email format. Please enter a valid email address.';
    } else if (errorMessage.contains('Email link is invalid or has expired')) {
      return 'Verification link is invalid or has expired.';
    } else if (errorMessage.contains('User not found')) {
      return 'Email not found. Please sign up first.';
    } else if (errorMessage.contains('Too many requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (errorMessage.contains('Network error')) {
      return 'Network connection issue. Please check your internet connection.';
    }
    return 'An error occurred. Please try again.';
  }

  // Email sign in
  Future<bool> signInWithEmail(String email, String password) async {
    _resetError();
    _setLoading(true);

    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      final userFriendlyError = _getUserFriendlyError(e.message);
      _setError(userFriendlyError);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Email sign up
  Future<bool> signUpWithEmail(
      String email, String password, String fullName) async {
    _resetError();
    _setLoading(true);

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName.trim()},
      );

      _setLoading(false);
      return response.user != null;
    } on AuthException catch (e) {
      final userFriendlyError = _getUserFriendlyError(e.message);
      _setError(userFriendlyError);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Google sign in - Using Supabase OAuth
// Google sign in - Using Supabase OAuth
  Future<bool> signInWithGoogle() async {
    _resetError();
    _setLoading(true);

    try {
      debugPrint('🔵 ===== SUPABASE OAUTH START =====');

      // Force Google account picker
      final bool result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'io.supabase.tehobenk.turun://login-callback',
        queryParams: {
          'prompt': 'select_account', 
        },
      );
      if (!result) {
        debugPrint('❌ OAuth returned false');
        _setLoading(false);
        return false;
      }
      debugPrint('✅ OAuth initiated - Opening Google account picker');
      return true;
    } catch (e) {
      debugPrint('❌ OAUTH ERROR: $e');
      _setError('Failed to sign in with Google. Please try again.');
      _setLoading(false);
      return false;
    }
  } 

  // Reset password
  Future<bool> resetPassword(String email) async {
    _resetError();
    _setLoading(true);

    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      final userFriendlyError = _getUserFriendlyError(e.message);
      _setError(userFriendlyError);
      return false;
    } catch (e) {
      _setError('Failed to send password reset email. Please try again.');
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      debugPrint('🔵 Signing out...');
      await _supabase.auth.signOut();
      debugPrint('✅ Signed out successfully');
      _resetError();
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      _setError('Failed to sign out. Please try again.');
    }
  }

  void clearError() {
    _resetError();
  }
}
