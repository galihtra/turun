import 'package:flutter/material.dart';
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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(
                20.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image.network(
                  //   'https://seeklogo.com/images/S/supabase-logo-DCC676FFE2-seeklogo.com.png',
                  //   height: 150.0,
                  // ),
                  const SizedBox(height: 25.0),
                   //Email field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    controller: _emailController,
                    decoration: const InputDecoration(label: Text("Email")),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  //Password field
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Field is required';
                      }
                      return null;
                    },
                    controller: _passwordController,
                    decoration: const InputDecoration(label: Text("Password")),
                    obscureText: true,
                  ),
                  const SizedBox(height: 25.0),
                  //Sign In Button
                  //Sign In Button
                  _signInLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signInLoading = true;
                            });
                            try {
                              await supabase.auth.signInWithPassword(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text.trim());
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Oops!Sign IN Failed!"),
                                  backgroundColor:
                                      Color.fromARGB(255, 243, 49, 6),
                                ),
                              );
                              setState(() {
                                _signInLoading = false;
                              });
                            }
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                  const Divider(),
                 //SignUp Button
                  _signInLoading
                      ? const Center(child: CircularProgressIndicator())
                      : OutlinedButton(
                          onPressed: () async {
                            final isValid = _formKey.currentState?.validate();
                            if (isValid != true) {
                              return;
                            }
                            setState(() {
                              _signUpLoading = true;
                            });
                            try {
                              await supabase.auth.signUp(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Sucess!Confirmtion mail send"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              setState(() {
                                _signUpLoading = false;
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Oops!Sign up Failed!"),
                                  backgroundColor:
                                      Color.fromARGB(255, 243, 49, 6),
                                ),
                              );
                              setState(() {
                                _signUpLoading = false;
                              });
                            }
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                  const SizedBox(height: 25.0),
                ],
              ),
            ),
          ),
        ),
      ),    
  );
  }
}