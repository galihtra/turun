import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  bool _signInLoading = false;
  bool _signUpLoading = false;
  bool _googleSignInLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // >>> GANTI dengan Web OAuth Client ID dari Google Cloud (bukan Android/iOS) <<<
  static const _webClientId = '392657528338-l6jkm0kah6lm5qsquslpggku02b87ric.apps.googleusercontent.com';

  // GoogleSignIn hanya dipakai di mobile (Android/iOS)
  late final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: const ['email', 'profile', 'openid'],
    serverClientId: _webClientId,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _emailSignIn() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _signInLoading = true);
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signed in!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _signInLoading = false);
    }
  }

  Future<void> _emailSignUp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _signUpLoading = true);
    try {
      await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Success! Confirmation email sent'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-up failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _signUpLoading = false);
    }
  }

  Future<void> _googleSignInFlow() async {
    setState(() => _googleSignInLoading = true);
    try {
      if (kIsWeb) {
        // WEB: tetap pakai OAuth bawaan Supabase (redirect/callback)
        await supabase.auth.signInWithOAuth(OAuthProvider.google);
        return;
      }

      // MOBILE (Android/iOS): native Google Sign-In → idToken → Supabase
      await _googleSignIn.signOut(); // bersihkan sesi lama (opsional)
      final acct = await _googleSignIn.signIn();
      if (acct == null) return; // user cancel

      final auth = await acct.authentication;
      final idToken = auth.idToken;
      final accessToken = auth.accessToken;

      if (idToken == null) {
        throw Exception(
          'Google ID Token is null. Pastikan serverClientId = Web Client ID dan scopes mengandung "openid".',
        );
      }

      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Signed in with Google!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _googleSignInLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Field is required' : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Field is required' : null,
                  ),

                  const SizedBox(height: 24),

                  _signInLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _emailSignIn,
                          child: const Text('Sign In',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),

                  const Divider(),

                  _signUpLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton(
                          onPressed: _emailSignUp,
                          child: const Text('Sign Up',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),

                  const SizedBox(height: 24),

                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.all(12), child: Text('OR')),
                      Expanded(child: Divider()),
                    ],
                  ),

                  _googleSignInLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton.icon(
                          onPressed: _googleSignInFlow,
                          icon: Image.network(
                            'https://cdn.freebiesupply.com/logos/large/2x/google-icon-logo-png-transparent.png',
                            height: 20,
                          ),
                          label: const Text('Continue with Google'),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
