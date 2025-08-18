import 'package:flutter/material.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _emailNode = FocusNode();
  final _passNode = FocusNode();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: sambungkan ke logic auth
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signing in...')),
      );
    }
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F6FF), // biru muda lembut seperti mockup
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide.none,
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.s20, vertical: 6),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 6),
            TextFormField(
              controller: _email,
              focusNode: _emailNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration('Email'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Email required' : null,
              onFieldSubmitted: (_) => _passNode.requestFocus(),
            ),
            const SizedBox(height: 14),
            StatefulBuilder(builder: (context, setSB) {
              bool obscure = true;
              return _PasswordField(
                controller: _password,
                focusNode: _passNode,
                onSubmitted: (_) => _login(),
              );
            }),

            // Forgot password
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {}, // TODO: route forgot
                style: TextButton.styleFrom(padding: const EdgeInsets.all(8)),
                child: Text('Forgot Password?',
                    style: AppStyles.body2Regular
                        .copyWith(color: Theme.of(context).primaryColor)),
              ),
            ),

            // Gradient button
            const SizedBox(height: 6),
            _GradientButton(
              text: 'Log In',
              onTap: _login,
            ),

            const SizedBox(height: 16),

            // Divider "Or continue with"
            Row(
              children: [
                const Expanded(child: Divider(thickness: 1, color: Color(0xFFE8ECF2))),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Or continue with', style: AppStyles.body3Regular),
                ),
                const Expanded(child: Divider(thickness: 1, color: Color(0xFFE8ECF2))),
              ],
            ),

            const SizedBox(height: 16),

            // Google button round
            Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {}, // TODO: Google sign-in
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        color: Color(0x11000000),
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  // Gantilah asset ini jika kamu punya ikon Google sendiri
                  child: Text('G',),
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onSubmitted;

  const _PasswordField({
    Key? key,
    required this.controller,
    required this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  InputDecoration _decoration(BuildContext context) => InputDecoration(
        hintText: 'Password',
        filled: true,
        fillColor: const Color(0xFFF1F6FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      decoration: _decoration(context),
      obscureText: _obscure,
      textInputAction: TextInputAction.done,
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Password required' : null,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _GradientButton({Key? key, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2F6BFF), Color(0xFF0F4CFF)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: AppStyles.title2SemiBold.copyWith(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
