import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/pages/auth/auth_page.dart';
import 'package:turun/pages/shell/root_shell.dart';
import '../../pages/auth/onboarding/onboarding_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SupabaseClient supabase = Supabase.instance.client;
  
  User? _user;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    // Listen to auth state changes (for OAuth redirect)
    supabase.auth.onAuthStateChange.listen((event) async {
      debugPrint('🔵 Auth event: ${event.event}');
      
      final user = event.session?.user;

      if (user != null && _user?.id != user.id) {
        debugPrint('✅ New user logged in: ${user.email}');
        // New user logged in, check onboarding status
        await _checkOnboardingStatus(user.id);
      } else if (user == null && _user != null) {
        debugPrint('🔵 User logged out');
        // User logged out
        setState(() {
          _user = null;
          _hasCompletedOnboarding = false;
        });
      }

      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });
  }

  Future<void> _initAuth() async {
    setState(() {
      _isLoading = true;
    });

    final user = supabase.auth.currentUser;

    if (user != null) {
      debugPrint('🔵 Current user found: ${user.email}');
      await _checkOnboardingStatus(user.id);
    } else {
      debugPrint('🔵 No current user');
    }

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _onOnboardingComplete() {
    debugPrint('✅ Onboarding completed!');
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  Future<void> _checkOnboardingStatus(String userId) async {
    try {
      debugPrint('🔵 Checking onboarding status for: $userId');
      
      final response = await supabase
          .from('users')
          .select('has_completed_onboarding')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        debugPrint('⚠️ User not found in database, needs onboarding');
        if (mounted) {
          setState(() {
            _hasCompletedOnboarding = false;
          });
        }
        return;
      }

      final hasCompleted = response['has_completed_onboarding'] as bool? ?? false;
      debugPrint('✅ Onboarding status: $hasCompleted');

      if (mounted) {
        setState(() {
          _hasCompletedOnboarding = hasCompleted;
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking onboarding: $e');
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