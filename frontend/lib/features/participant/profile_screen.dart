import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_provider.dart';
import '../../main.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          CircleAvatar(radius: 50, backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Text(user?.name.substring(0,1).toUpperCase() ?? 'U', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: theme.colorScheme.primary))),
          const SizedBox(height: 16),
          Text(user?.name ?? '', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          Text(user?.email ?? '', style: TextStyle(color: Colors.grey[500])),
          const SizedBox(height: 8),
          Chip(label: Text(user?.primaryRole ?? 'User'), backgroundColor: theme.colorScheme.primary.withOpacity(0.1)),
          const SizedBox(height: 24),

          _ProfileTile(Icons.school, 'Department', user?.department ?? '-'),
          _ProfileTile(Icons.account_balance, 'College', user?.college ?? '-'),
          _ProfileTile(Icons.badge, 'Roll Number', user?.rollNumber ?? '-'),
          _ProfileTile(Icons.phone, 'Phone', user?.phone ?? '-'),
          _ProfileTile(Icons.verified, 'Email Verified', user?.emailVerified == true ? 'Yes' : 'No'),
          const SizedBox(height: 24),

          // Theme toggle
          Card(child: SwitchListTile(
            title: const Text('Dark Mode'), secondary: const Icon(Icons.dark_mode),
            value: isDark,
            onChanged: (v) => ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light,
          )),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 56, child: OutlinedButton.icon(
            icon: const Icon(Icons.logout, color: Colors.red), label: const Text('Logout', style: TextStyle(color: Colors.red)),
            onPressed: () { ref.read(authProvider.notifier).logout(); context.go('/login'); },
            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
          )),
        ]),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _ProfileTile(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
  ));
}
