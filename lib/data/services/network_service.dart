import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:turun/components/network_error/network_error_widget.dart';

/// Service to monitor network connectivity and show gamified errors
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isConnected = true;
  bool _isSlowConnection = false;
  DateTime? _lastSpeedCheck;
  
  // Callbacks
  Function(bool isConnected)? onConnectionChanged;
  
  /// Current connection status
  bool get isConnected => _isConnected;
  bool get isSlowConnection => _isSlowConnection;

  /// Initialize network monitoring
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
    
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.isNotEmpty && 
        !results.contains(ConnectivityResult.none);
    
    if (_isConnected != hasConnection) {
      _isConnected = hasConnection;
      onConnectionChanged?.call(_isConnected);
    }
  }

  /// Check if we can reach the internet (actual connectivity test)
  Future<bool> hasInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      _isSlowConnection = true;
      return false;
    }
  }

  /// Measure connection speed (simplified)
  Future<NetworkErrorType?> checkConnectionQuality() async {
    // Don't check too frequently
    if (_lastSpeedCheck != null && 
        DateTime.now().difference(_lastSpeedCheck!) < const Duration(seconds: 10)) {
      if (!_isConnected) return NetworkErrorType.noConnection;
      if (_isSlowConnection) return NetworkErrorType.slowConnection;
      return null;
    }
    
    _lastSpeedCheck = DateTime.now();
    
    // First check connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult.isEmpty || connectivityResult.contains(ConnectivityResult.none)) {
      _isConnected = false;
      return NetworkErrorType.noConnection;
    }
    
    // Then check actual internet access with timing
    final stopwatch = Stopwatch()..start();
    final hasAccess = await hasInternetAccess();
    stopwatch.stop();
    
    if (!hasAccess) {
      if (stopwatch.elapsedMilliseconds > 4000) {
        _isSlowConnection = true;
        return NetworkErrorType.slowConnection;
      }
      _isConnected = false;
      return NetworkErrorType.noConnection;
    }
    
    // Check if response was slow
    if (stopwatch.elapsedMilliseconds > 2000) {
      _isSlowConnection = true;
      return NetworkErrorType.slowConnection;
    }
    
    _isSlowConnection = false;
    _isConnected = true;
    return null;
  }

  /// Show appropriate error widget based on current network state
  Future<void> showNetworkError(
    BuildContext context, {
    VoidCallback? onRetry,
    bool useBottomSheet = false,
  }) async {
    final errorType = await checkConnectionQuality();
    if (errorType == null) return; // No error
    
    if (!context.mounted) return;
    
    if (useBottomSheet) {
      await NetworkErrorBottomSheet.show(
        context,
        errorType: errorType,
        onRetry: onRetry,
      );
    } else {
      await NetworkErrorDialog.show(
        context,
        errorType: errorType,
        onRetry: onRetry,
      );
    }
  }

  /// Show snackbar error
  Future<void> showNetworkErrorSnackbar(
    BuildContext context, {
    VoidCallback? onRetry,
  }) async {
    final errorType = await checkConnectionQuality();
    if (errorType == null) return;
    
    if (!context.mounted) return;
    
    NetworkErrorDialog.showSnackbar(
      context,
      errorType: errorType,
      onRetry: onRetry,
    );
  }

  /// Execute a function with network error handling
  Future<T?> withNetworkErrorHandling<T>(
    BuildContext context, {
    required Future<T> Function() action,
    VoidCallback? onRetry,
    bool showDialogOnError = true,
  }) async {
    try {
      // Check connection first
      final errorType = await checkConnectionQuality();
      if (errorType != null) {
        if (showDialogOnError && context.mounted) {
          await NetworkErrorDialog.show(
            context,
            errorType: errorType,
            onRetry: onRetry,
          );
        }
        return null;
      }
      
      return await action();
    } on SocketException catch (_) {
      if (showDialogOnError && context.mounted) {
        await NetworkErrorDialog.show(
          context,
          errorType: NetworkErrorType.noConnection,
          onRetry: onRetry,
        );
      }
      return null;
    } on TimeoutException catch (_) {
      if (showDialogOnError && context.mounted) {
        await NetworkErrorDialog.show(
          context,
          errorType: NetworkErrorType.timeout,
          onRetry: onRetry,
        );
      }
      return null;
    } catch (e) {
      // Check if it's a network-related error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused') ||
          e.toString().contains('Network is unreachable')) {
        if (showDialogOnError && context.mounted) {
          await NetworkErrorDialog.show(
            context,
            errorType: NetworkErrorType.noConnection,
            onRetry: onRetry,
          );
        }
        return null;
      }
      rethrow;
    }
  }

  /// Dispose the service
  void dispose() {
    _subscription?.cancel();
  }
}

/// Mixin for easy network error handling in StatefulWidgets
mixin NetworkErrorMixin<T extends StatefulWidget> on State<T> {
  final NetworkService _networkService = NetworkService();

  /// Check connection and show error if needed
  Future<bool> checkConnectionAndShowError({VoidCallback? onRetry}) async {
    final error = await _networkService.checkConnectionQuality();
    if (error != null && mounted) {
      await NetworkErrorDialog.show(
        context,
        errorType: error,
        onRetry: onRetry,
      );
      return false;
    }
    return true;
  }

  /// Show network error snackbar
  void showNetworkErrorSnackbar({
    required NetworkErrorType errorType,
    VoidCallback? onRetry,
  }) {
    if (mounted) {
      NetworkErrorDialog.showSnackbar(
        context,
        errorType: errorType,
        onRetry: onRetry,
      );
    }
  }

  /// Execute with error handling
  Future<R?> executeWithNetworkCheck<R>(
    Future<R> Function() action, {
    VoidCallback? onRetry,
  }) async {
    return _networkService.withNetworkErrorHandling(
      context,
      action: action,
      onRetry: onRetry,
    );
  }
}
