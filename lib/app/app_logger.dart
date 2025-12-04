import 'package:flutter/foundation.dart';

/// Enum untuk menandai kategori atau modul log yang berbeda dalam aplikasi.
///
/// Digunakan sebagai label untuk mempermudah klasifikasi dan pencarian
/// log sesuai fitur atau area yang terkait.
enum LogLabel {
  auth,
  network,
  general,
  provider,
  navigation,
  supabase,
  google,
}

/// Extension untuk mendapatkan nama label
extension LogLabelExtension on LogLabel {
  /// Return nama dari loglabel
  /// Misalnya LogLabel.auth => "AUTH"
  String get value => (toString().split('.').last).toUpperCase();
}

class AppLogger {
  /// Logs general debug information useful for developers.
  ///
  /// Use for logging function calls, variable states, or step completions.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.debug(LogLabel.auth, 'User pressed submit button');
  /// ```
  static void debug(LogLabel label, String msg) {
    if (!kReleaseMode) {
      debugPrint('🔵 [${label.value}] $msg');
    }
  }

  /// Logs informational messages representing normal app flow.
  ///
  /// Examples: successful login, completed booking, network connected.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.info(LogLabel.auth, 'User logged in successfully');
  /// ```
  static void info(LogLabel label, String msg) {
    if (!kReleaseMode) {
      debugPrint('✅ [${label.value}] $msg');
    }
  }

  /// Logs warnings about unexpected situations that don't cause app failure.
  ///
  /// Examples: missing cache, slow API response.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.warning(LogLabel.network, 'Cache expired, fetching fresh data');
  /// ```
  static void warning(LogLabel label, String msg) {
    if (!kReleaseMode) {
      debugPrint('⚠️ [${label.value}] $msg');
    }
  }

  /// Logs errors and exceptions that occur during app execution.
  ///
  /// Should be used inside try-catch blocks or where errors may happen.
  ///
  /// Example:
  /// ```dart
  /// try {
  ///   await fetchData();
  /// } catch (e, stack) {
  ///   AppLogger.error(LogLabel.network, 'Failed to fetch data', e, stack);
  /// }
  /// ```
  static void error(LogLabel label, String msg,
      [Object? error, StackTrace? stack]) {
    if (!kReleaseMode) {
      debugPrint('❌ [${label.value}] $msg');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stack != null) {
        debugPrint('   Stack: $stack');
      }
    }
  }

  /// Logs success messages for important operations.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.success(LogLabel.auth, 'Login successful');
  /// ```
  static void success(LogLabel label, String msg) {
    if (!kReleaseMode) {
      debugPrint('✨ [${label.value}] $msg');
    }
  }

  /// Logs API or network related messages.
  ///
  /// Example:
  /// ```dart
  /// AppLogger.network(LogLabel.network, 'POST /api/login - 200 OK');
  /// ```
  static void network(LogLabel label, String msg) {
    if (!kReleaseMode) {
      debugPrint('🌐 [${label.value}] $msg');
    }
  }
}