// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static const _webClientId = '392657528338-l6jkm0kah6lm5qsquslpggku02b87ric.apps.googleusercontent.com';
  
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile', 'openid'],
    serverClientId: _webClientId,
  );

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Auto-reset error setelah beberapa waktu
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
    _autoResetError(); // Auto-reset setelah 5 detik
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
    _resetError(); // Reset error sebelum operasi baru
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
  Future<bool> signUpWithEmail(String email, String password, String fullName) async {
    _resetError(); // Reset error sebelum operasi baru
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

  // Google sign in
  Future<bool> signInWithGoogle() async {
    _resetError(); // Reset error sebelum operasi baru
    _setLoading(true);

    try {
      if (kIsWeb) {
        await _supabase.auth.signInWithOAuth(OAuthProvider.google);
        return true;
      }

      await _googleSignIn.signOut();
      final acct = await _googleSignIn.signIn();
      if (acct == null) {
        _setLoading(false);
        return false;
      }

      final auth = await acct.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        throw Exception('Google ID Token is null');
      }

      await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      final userFriendlyError = _getUserFriendlyError(e.message);
      _setError(userFriendlyError);
      return false;
    } catch (e) {
      _setError('Failed to sign in with Google. Please try again.');
      return false;
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _resetError(); // Reset error sebelum operasi baru
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
      await _supabase.auth.signOut();
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      _resetError(); // Reset error saat logout
    } catch (e) {
      _setError('Failed to sign out. Please try again.');
    }
  }

  // Manual reset error - bisa dipanggil dari widget
  void clearError() {
    _resetError();
  }
}