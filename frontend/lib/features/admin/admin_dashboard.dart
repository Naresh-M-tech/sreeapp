import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/api_client.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});
  @override ConsumerState<AdminDashboard> createState() => _State();
}

class _State extends ConsumerState<AdminDashboard> {
  Map<String, dynamic>? _data; bool _loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final r = await ref.read(dioProvider).get('/admin/analytics');
      if (r.data['success']==true) setState(()=> _data = r.data['data']); } catch(_){}
    setState(()=> _loading = false);
  }

  @override Widget build(BuildContext context) {
    final theme = Theme.of(context); final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.notifications), onPressed: ()=> context.push('/notifications')),
        IconButton(icon: const Icon(Icons.logout), onPressed: (){ ref.read(authProvider.notifier).logout(); context.go('/login'); })]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)]),
          borderRadius: BorderRadius.circular(20)),
          child: Row(children: [
            CircleAvatar(radius: 28, backgroundColor: Colors.white24, child: Text(user?.name.substring(0,1)??'A', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Welcome back!', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
              Text(user?.name ?? 'Admin', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ])),
        const SizedBox(height: 20),
        GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 12, mainAxisSpacing: 12, children: [
          _StatCard('Total Users', '${_data?['totalUsers']??0}', Icons.people, const Color(0xFF6C5CE7)),
          _StatCard('Total Events', '${_data?['totalEvents']??0}', Icons.event, const Color(0xFF00CEC9)),
          _StatCard('Registrations', '${_data?['totalRegistrations']??0}', Icons.how_to_reg, const Color(0xFF00B894)),
          _StatCard('Revenue', '₹${_data?['totalRevenue']??0}', Icons.currency_rupee, const Color(0xFFFDAA5B)),
          _StatCard('Active Users', '${_data?['activeUsers']??0}', Icons.person, Colors.blue),
          _StatCard('Pending', '${_data?['pendingApprovals']??0}', Icons.pending, Colors.orange),
        ]),
        const SizedBox(height: 20),
        Text('Management', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _NavCard(Icons.people, 'User Management', 'Manage all users', ()=> context.push('/admin/users')),
        _NavCard(Icons.event, 'Event Management', 'Approve & manage events', ()=> context.push('/admin/events')),
        _NavCard(Icons.analytics, 'Analytics', 'View detailed analytics', ()=> context.push('/admin/analytics')),
        _NavCard(Icons.assessment, 'Reports', 'Generate reports', ()=> context.push('/admin/reports')),
        _NavCard(Icons.home, 'Participant View', 'Switch to participant mode', ()=> context.go('/home')),
      ])),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, color: color, size: 28), const SizedBox(height: 8),
    Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
    Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
  ])));
}

class _NavCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  const _NavCard(this.icon, this.title, this.subtitle, this.onTap);
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(title),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
