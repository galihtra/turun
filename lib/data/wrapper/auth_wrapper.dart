import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  
  User? _user;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    AppLogger.info(LogLabel.auth, 'AuthWrapper initialized');
    _initAuth();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _supabase.auth.onAuthStateChange.listen((event) async {
      if (!mounted) return;

      AppLogger.debug(LogLabel.auth, 'Auth event: ${event.event}');
      
      final user = event.session?.user;

      if (user != null && _user?.id != user.id) {
        AppLogger.info(LogLabel.auth, 'New user logged in: ${user.email}');
        await _checkOnboardingStatus(user.id);
      } else if (user == null && _user != null) {
        AppLogger.info(LogLabel.auth, 'User logged out');
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
    final user = _supabase.auth.currentUser;

    if (user != null) {
      AppLogger.info(LogLabel.auth, 'Current user found: ${user.email}');
      await _checkOnboardingStatus(user.id);
    } else {
      AppLogger.debug(LogLabel.auth, 'No current user');
    }

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
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
          child: CircularProgressIndicator(),
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