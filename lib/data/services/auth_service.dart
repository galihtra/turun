import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../app/finite_state.dart';
import '../../app/app_logger.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  MyState _state = MyState.initial;
  String? _error;

  MyState get state => _state;
  String? get error => _error;
  bool get isLoading => _state.isLoading;

  void _setState(MyState newState) {
    _state = newState;
    notifyListeners();
    AppLogger.debug(LogLabel.auth, 'State changed to: $newState');
  }

  void _setError(String errorMessage) {
    _error = _getUserFriendlyError(errorMessage);
    _setState(MyState.failed);
    AppLogger.error(LogLabel.auth, 'Error occurred: $_error');
  }

  void clearError() {
    _error = null;
    if (_state.isFailed) {
      _setState(MyState.initial);
    }
    AppLogger.debug(LogLabel.auth, 'Error cleared');
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
    if (_state.isLoading) {
      AppLogger.warning(LogLabel.auth, 'Sign in already in progress');
      return false;
    }

    clearError();
    _setState(MyState.loading);
    AppLogger.info(LogLabel.auth, 'Starting email sign in for: $email');

    try {
      await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      AppLogger.success(LogLabel.auth, 'Email sign in successful');
      _setState(MyState.loaded);
      return true;
    } on AuthException catch (e) {
      AppLogger.error(LogLabel.auth, 'Auth exception during sign in', e);
      _setError(e.message);
      return false;
    } catch (e) {
      AppLogger.error(LogLabel.auth, 'Unexpected error during sign in', e);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Email sign up
  Future<bool> signUpWithEmail(
      String email, String password, String fullName) async {
    if (_state.isLoading) {
      AppLogger.warning(LogLabel.auth, 'Sign up already in progress');
      return false;
    }

    clearError();
    _setState(MyState.loading);
    AppLogger.info(LogLabel.auth, 'Starting email sign up for: $email');

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
        data: {'full_name': fullName.trim()},
      );

      AppLogger.success(LogLabel.auth, 'Email sign up successful');
      _setState(MyState.loaded);
      return response.user != null;
    } on AuthException catch (e) {
      AppLogger.error(LogLabel.auth, 'Auth exception during sign up', e);
      _setError(e.message);
      return false;
    } catch (e) {
      AppLogger.error(LogLabel.auth, 'Unexpected error during sign up', e);
      _setError('An unexpected error occurred. Please try again.');
      return false;
    }
  }

  // Google sign in
  Future<bool> signInWithGoogle() async {
    if (_state.isLoading) {
      AppLogger.warning(LogLabel.google, 'Google sign in already in progress');
      return false;
    }

    clearError();
    _setState(MyState.loading);
    AppLogger.info(LogLabel.google, 'Starting Google OAuth...');

    try {
      final bool result = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            kIsWeb ? null : 'io.supabase.tehobenk.turun://login-callback',
        queryParams: {
          'prompt': 'select_account',
        },
      );

      if (!result) {
        AppLogger.error(LogLabel.google, 'OAuth returned false');
        _setError('Failed to initiate Google sign-in');
        return false;
      }

      AppLogger.success(LogLabel.google, 'OAuth initiated successfully');
      // State akan diupdate oleh auth listener di AuthWrapper
      return true;
    } catch (e) {
      AppLogger.error(LogLabel.google, 'Google OAuth error', e);
      _setError('Failed to sign in with Google. Please try again.');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    if (_state.isLoading) {
      AppLogger.warning(LogLabel.auth, 'Reset password already in progress');
      return false;
    }

    clearError();
    _setState(MyState.loading);
    AppLogger.info(LogLabel.auth, 'Sending password reset email to: $email');

    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      AppLogger.success(LogLabel.auth, 'Password reset email sent');
      _setState(MyState.loaded);
      return true;
    } on AuthException catch (e) {
      AppLogger.error(LogLabel.auth, 'Auth exception during password reset', e);
      _setError(e.message);
      return false;
    } catch (e) {
      AppLogger.error(LogLabel.auth, 'Unexpected error during password reset', e);
      _setError('Failed to send password reset email. Please try again.');
      return false;
    }
  }

  // Sign out
  Future<bool> signOut() async {
    if (_state.isLoading) {
      AppLogger.warning(LogLabel.auth, 'Sign out already in progress');
      return false;
    }

    _setState(MyState.loading);
    AppLogger.info(LogLabel.auth, 'Signing out...');

    try {
      await _supabase.auth.signOut();
      AppLogger.success(LogLabel.auth, 'Signed out successfully');
      
      _setState(MyState.loaded);
      clearError();
      return true;
    } catch (e) {
      AppLogger.error(LogLabel.auth, 'Sign out error', e);
      _setError('Failed to sign out. Please try again.');
      return false;
    }
  }

  @override
  void dispose() {
    _state = MyState.initial;
    _error = null;
    super.dispose();
  }
}