import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/components/loading/running_loader.dart';
import 'package:turun/components/network_error/network_error_widget.dart';
import 'package:turun/data/services/network_service.dart';
import 'package:turun/data/services/push_notification_service.dart';
import 'package:turun/pages/auth/auth_page.dart';
import 'package:turun/pages/shell/root_shell.dart';
import '../../pages/auth/onboarding/onboarding_page.dart';
import '../../app/app_logger.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PushNotificationService _pushNotificationService = PushNotificationService();
  final NetworkService _networkService = NetworkService();
  
  User? _user;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;
  bool _hasNetworkError = false;
  NetworkErrorType? _networkErrorType;

  @override
  void initState() {
    super.initState();
    AppLogger.info(LogLabel.auth, 'AuthWrapper initialized');
    _initNetworkService();
    _initAuth();
    _setupAuthListener();
  }

  Future<void> _initNetworkService() async {
    await _networkService.initialize();
    _networkService.onConnectionChanged = (isConnected) {
      if (isConnected && _hasNetworkError) {
        // Connection restored, retry auth
        _retryAuth();
      }
    };
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((event) async {
      if (!mounted) return;

      AppLogger.debug(LogLabel.auth, 'Auth event: ${event.event}');
      
      final user = event.session?.user;

      if (user != null && _user?.id != user.id) {
        AppLogger.info(LogLabel.auth, 'New user logged in: ${user.email}');
        await _checkOnboardingStatus(user.id);
        // Initialize push notifications for the logged-in user
        await _pushNotificationService.initialize();
      } else if (user == null && _user != null) {
        AppLogger.info(LogLabel.auth, 'User logged out');
        // Delete FCM token on logout
        await _pushNotificationService.deleteToken();
        if (mounted) {
          setState(() {
            _user = null;
            _hasCompletedOnboarding = false;
          });
        }
      }

      if (mounted && _user?.id != user?.id) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  Future<void> _initAuth() async {
    // First check network connectivity
    final hasInternet = await _networkService.hasInternetAccess();
    
    if (!hasInternet) {
      if (mounted) {
        setState(() {
          _hasNetworkError = true;
          _networkErrorType = NetworkErrorType.noConnection;
          _isLoading = false;
        });
      }
      return;
    }

    final user = _supabase.auth.currentUser;

    if (user != null) {
      AppLogger.info(LogLabel.auth, 'Current user found: ${user.email}');
      await _checkOnboardingStatus(user.id);
      // Initialize push notifications for existing user
      await _pushNotificationService.initialize();
    } else {
      AppLogger.debug(LogLabel.auth, 'No current user');
    }

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
        _hasNetworkError = false;
      });
    }
  }

  Future<void> _retryAuth() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasNetworkError = false;
        _networkErrorType = null;
      });
    }
    await _initAuth();
  }

  void _onOnboardingComplete() {
    AppLogger.success(LogLabel.auth, 'Onboarding completed!');
    if (mounted) {
      setState(() {
        _hasCompletedOnboarding = true;
      });
    }
  }

  Future<void> _checkOnboardingStatus(String userId) async {
    try {
      AppLogger.debug(LogLabel.auth, 'Checking onboarding status for: $userId');
      
      final response = await _supabase
          .from('users')
          .select('has_completed_onboarding')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        AppLogger.warning(LogLabel.auth, 'User not found in database, needs onboarding');
        if (mounted) {
          setState(() {
            _hasCompletedOnboarding = false;
          });
        }
        return;
      }

      final hasCompleted = response['has_completed_onboarding'] as bool? ?? false;
      AppLogger.info(LogLabel.auth, 'Onboarding status: $hasCompleted');

      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = hasCompleted;
        });
      }
    } catch (e) {
      AppLogger.error(LogLabel.auth, 'Error checking onboarding', e);
      
      // Check if it's a network error
      final hasInternet = await _networkService.hasInternetAccess();
      if (!hasInternet) {
        if (mounted) {
          setState(() {
            _hasNetworkError = true;
            _networkErrorType = NetworkErrorType.noConnection;
          });
        }
        return;
      }
      
      // If we have internet but still got an error, it might be a server issue
      if (e.toString().contains('timeout') || e.toString().contains('Timeout')) {
        if (mounted) {
          setState(() {
            _hasNetworkError = true;
            _networkErrorType = NetworkErrorType.timeout;
          });
        }
        return;
      }
      
      // For other errors, default to assuming not onboarded
      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: RunningLoader(
            message: 'Getting ready...',
          ),
        ),
      );
    }

    // Network error - show gamified error screen
    if (_hasNetworkError && _networkErrorType != null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: NetworkErrorWidget(
              errorType: _networkErrorType!,
              onRetry: _retryAuth,
              showRetryButton: true,
            ),
          ),
        ),
      );
    }

    // Not logged in
    if (_user == null) {
      return const AuthPage();
    }

    // Logged in but haven't completed onboarding
    if (!_hasCompletedOnboarding) {
      return OnboardingPage(
        onComplete: _onOnboardingComplete,
      );
    }

    // Logged in and completed onboarding
    return const RootShell();
  }
}