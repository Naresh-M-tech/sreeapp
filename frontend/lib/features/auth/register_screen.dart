import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _deptCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();
  String _selectedRole = 'PARTICIPANT';
  bool _obscure = true;

  @override
  void dispose() { for (var c in [_nameCtrl, _emailCtrl, _passwordCtrl, _phoneCtrl, _deptCtrl, _collegeCtrl, _rollCtrl]) c.dispose(); super.dispose(); }

  void _register() {
    if (_formKey.currentState!.validate()) {
      ref.read(authProvider.notifier).register({
        'name': _nameCtrl.text.trim(), 'email': _emailCtrl.text.trim(), 'password': _passwordCtrl.text,
        'phone': _phoneCtrl.text.trim(), 'department': _deptCtrl.text.trim(), 'college': _collegeCtrl.text.trim(),
        'rollNumber': _rollCtrl.text.trim(), 'role': _selectedRole,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    ref.listen(authProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!), backgroundColor: Colors.red));
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text('Create Account', style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)).animate().fadeIn(),
                const SizedBox(height: 8),
                Text('Join Event Bridge today', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70)).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 24),
                Card(
                  elevation: 12, shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
                            validator: (v) => v == null || v.length < 3 ? 'Min 3 characters' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _passwordCtrl, obscureText: _obscure,
                            decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))),
                            validator: (v) => v == null || v.length < 8 ? 'Min 8 characters' : null),
                          const SizedBox(height: 12),
                          TextFormField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined))),
                          const SizedBox(height: 12),
                          TextFormField(controller: _deptCtrl, decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.school_outlined))),
                          const SizedBox(height: 12),
                          TextFormField(controller: _collegeCtrl, decoration: const InputDecoration(labelText: 'College', prefixIcon: Icon(Icons.account_balance_outlined))),
                          const SizedBox(height: 12),
                          TextFormField(controller: _rollCtrl, decoration: const InputDecoration(labelText: 'Roll Number', prefixIcon: Icon(Icons.badge_outlined))),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.assignment_ind_outlined)),
                            items: const [
                              DropdownMenuItem(value: 'PARTICIPANT', child: Text('Participant')),
                              DropdownMenuItem(value: 'ORGANIZER', child: Text('Organizer')),
                              DropdownMenuItem(value: 'FACULTY', child: Text('Faculty')),
                            ],
                            onChanged: (v) => setState(() => _selectedRole = v!),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(height: 56, child: ElevatedButton(
                            onPressed: authState.status == AuthStatus.loading ? null : _register,
                            child: authState.status == AuthStatus.loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Create Account'),
                          )),
                          const SizedBox(height: 12),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('Already have an account? '),
                            TextButton(onPressed: () => context.pop(), child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w700))),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.2, duration: 500.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
