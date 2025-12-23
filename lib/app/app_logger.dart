

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

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

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTime,
    ),
  );

  static void debug(LogLabel label, String msg) {
    if (!kReleaseMode) {
      _logger.d('🔵 [${label.value}] $msg');
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
      _logger.i('✅ [${label.value}] $msg');
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
      _logger.w('⚠️ [${label.value}] $msg');
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
      _logger.e('❌ [${label.value}] $msg', error: error, stackTrace: stack);
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
      _logger.i('✨ [${label.value}] $msg');
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
      _logger.i('🌐 [${label.value}] $msg');
    }
  }
}