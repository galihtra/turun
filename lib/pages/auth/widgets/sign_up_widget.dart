import 'package:flutter/material.dart';
import 'package:turun/base_widgets/button/gradient_button.dart';
import 'package:turun/resources/styles_app.dart';
import 'package:turun/resources/values_app.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  SignUpWidgetState createState() => SignUpWidgetState();
}

class SignUpWidgetState extends State<SignUpWidget> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _nameNode = FocusNode();
  final _emailNode = FocusNode();
  final _passNode = FocusNode();
  final _confirmNode = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _nameNode.dispose();
    _emailNode.dispose();
    _passNode.dispose();
    _confirmNode.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint, {Widget? suffix}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF1F6FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffix,
      );

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: sign up
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating account...')),
      );
    }
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
              controller: _name,
              focusNode: _nameNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.name,
              decoration: _dec('Name'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name required' : null,
              onFieldSubmitted: (_) => _emailNode.requestFocus(),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _email,
              focusNode: _emailNode,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              decoration: _dec('Email'),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Email required' : null,
              onFieldSubmitted: (_) => _passNode.requestFocus(),
            ),
            const SizedBox(height: 14),
            _Password(hint: 'Password', controller: _password, focusNode: _passNode, onSubmitted: (_) => _confirmNode.requestFocus()),
            const SizedBox(height: 14),
            _Password(hint: 'Password Confirmation', controller: _confirm, focusNode: _confirmNode, onSubmitted: (_) => _submit()),
            const SizedBox(height: 18),

            // Button
            GradientButton(
              text: 'Register',
              onTap: _submit,
            ),

            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Skip for Now',
                        style: AppStyles.label2SemiBold
                            .copyWith(color: Theme.of(context).primaryColor)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward,
                        size: 16, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Password extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onSubmitted;
  const _Password({
    Key? key,
    required this.hint,
    required this.controller,
    required this.focusNode,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<_Password> createState() => _PasswordState();
}

class _PasswordState extends State<_Password> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      textInputAction: TextInputAction.next,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: const Color(0xFFF1F6FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(
              _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
        ),
      ),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Required' : null,
      onFieldSubmitted: widget.onSubmitted,
    );
  }
}
