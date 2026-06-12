import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(Icons.lock_reset, size: 80, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            Text('Forgot Password?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("Enter your email and we'll send you a reset link", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            if (!_sent) ...[
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
              const SizedBox(height: 24),
              SizedBox(height: 56, child: ElevatedButton(
                onPressed: _loading ? null : () async {
                  setState(() => _loading = true);
                  await ref.read(authProvider.notifier).forgotPassword(_emailCtrl.text.trim());
                  setState(() { _loading = false; _sent = true; });
                },
                child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Send Reset Link'),
              )),
            ] else ...[
              Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
                child: Column(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 12),
                  Text('Reset link sent!', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Check your email for the password reset link.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
                ]),
              ),
              const SizedBox(height: 24),
              OutlinedButton(onPressed: () => context.pop(), child: const Text('Back to Login')),
            ],
          ],
        ),
      ),
    );
  }
}
