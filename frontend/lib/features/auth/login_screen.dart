import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() { _emailController.dispose(); _passwordController.dispose(); super.dispose(); }

  void _login() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).login(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            children: [
              // Gradient header
              Container(
                height: size.height * 0.4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.event, size: 48, color: Colors.white),
                      ).animate().scale(duration: 500.ms),
                      const SizedBox(height: 16),
                      Text('Welcome Back', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800))
                        .animate().fadeIn(delay: 200.ms),
                      Text('Sign in to continue', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70))
                        .animate().fadeIn(delay: 300.ms),
                    ],
                  ),
                ),
              ),
              // Login form
              Positioned(
                top: size.height * 0.32,
                left: 24, right: 24,
                child: Card(
                  elevation: 12,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Login', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                            ),
                            validator: (v) => v == null || v.length < 8 ? 'Min 8 characters' : null,
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(onPressed: () => context.push('/forgot-password'), child: const Text('Forgot Password?')),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authState.status == AuthStatus.loading ? null : _login,
                              child: authState.status == AuthStatus.loading
                                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                                  : const Text('Sign In'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account? "),
                              TextButton(onPressed: () => context.push('/register'), child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w700))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.3, duration: 500.ms, curve: Curves.easeOutCubic).fadeIn(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
