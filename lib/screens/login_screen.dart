// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and signup
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      } else {
        await _authService.signUpWithEmail(
          _emailController.text,
          _passwordController.text,
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(_emailController.text);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Icon
                  Icon(
                    Icons.timer_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    _isLogin
                        ? 'Sign in to manage your lunch breaks'
                        : 'Sign up to start managing your lunch breaks',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: _isLoading ? null : () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enabled: !_isLoading,
                    onFieldSubmitted: (_) => _submitForm(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (!_isLogin && value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login/Signup Button
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    FilledButton(
                      onPressed: _submitForm,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Google Sign In Button
                  OutlinedButton.icon(
                    onPressed: _isLoading ? null : () async {
                      setState(() => _isLoading = true);
                      try {
                        await _authService.signInWithGoogle();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Theme.of(context).colorScheme.error,
                          ),
                        );
                      } finally {
                        if (mounted) {
                          setState(() => _isLoading = false);
                        }
                      }
                    },
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                      ),
                    ),
                    label: const Text('Continue with Google'),
                  ),
                  const SizedBox(height: 16),

                  // Toggle Login/Signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? 'Don\'t have an account?'
                            : 'Already have an account?',
                      ),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => setState(() => _isLogin = !_isLogin),
                        child: Text(_isLogin ? 'Sign up' : 'Login'),
                      ),
                    ],
                  ),

                  // Forgot Password
                  if (_isLogin)
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: _isLoading ? null : _resetPassword,
                        child: const Text('Forgot Password?'),
                      ),
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