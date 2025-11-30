import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turun/pages/auth/auth_page.dart';
import 'package:turun/pages/shell/root_shell.dart';

import '../../pages/auth/onboarding/onboarding_page.dart';
import '../providers/user/user_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _user;
  bool _isLoading = true;
  bool _hasCompletedOnboarding = false;

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  Future<void> _initAuth() async {
    setState(() {
      _isLoading = true;
    });

    final user = supabase.auth.currentUser;

    if (user != null) {
      // Load user data from database
      await _checkOnboardingStatus(user.id);
    }

    setState(() {
      _user = user;
      _isLoading = false;
    });

    // Listen to auth state changes
    supabase.auth.onAuthStateChange.listen((event) async {
      final user = event.session?.user;

      if (user != null && _user?.id != user.id) {
        // New user logged in, check onboarding status
        await _checkOnboardingStatus(user.id);
      }

      setState(() {
        _user = user;
      });
    });
  }

  void _onOnboardingComplete() {
    setState(() {
      _hasCompletedOnboarding = true;
    });
  }

  Future<void> _checkOnboardingStatus(String userId) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData(userId);

      setState(() {
        _hasCompletedOnboarding =
            userProvider.currentUser?.hasCompletedOnboarding ?? false;
      });
    } catch (e) {
      debugPrint('❌ Error checking onboarding status: $e');
      setState(() {
        _hasCompletedOnboarding = false;
      });
    }
  }

  final SupabaseClient supabase = Supabase.instance.client;

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
        onComplete: _onOnboardingComplete, // ✅ Pass callback
      );
    }

    // Logged in and completed onboarding
    return const RootShell();
  }
}
