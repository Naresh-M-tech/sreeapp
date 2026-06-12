import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/api_client.dart';

class OrganizerDashboard extends ConsumerStatefulWidget {
  const OrganizerDashboard({super.key});
  @override ConsumerState<OrganizerDashboard> createState() => _State();
}

class _State extends ConsumerState<OrganizerDashboard> {
  Map<String, dynamic>? _analytics; bool _loading = true;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final r = await ref.read(dioProvider).get('/organizer/analytics');
      if (r.data['success']==true) setState(()=> _analytics = r.data['data']); } catch(_){}
    setState(()=> _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); final user = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: const Text('Organizer Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.notifications), onPressed: ()=> context.push('/notifications')),
        IconButton(icon: const Icon(Icons.logout), onPressed: (){ ref.read(authProvider.notifier).logout(); context.go('/login'); }),
      ]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome, ${user?.name ?? "Organizer"}!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Row(children: [
          _StatCard('Events', '${_analytics?['totalEvents']??0}', Icons.event, const Color(0xFF6C5CE7)),
          const SizedBox(width: 12),
          _StatCard('Registrations', '${_analytics?['totalRegistrations']??0}', Icons.people, const Color(0xFF00CEC9)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _StatCard('Attendees', '${_analytics?['totalAttendees']??0}', Icons.check_circle, const Color(0xFF00B894)),
          const SizedBox(width: 12),
          _StatCard('Revenue', '₹${_analytics?['totalRevenue']??0}', Icons.currency_rupee, const Color(0xFFFDAA5B)),
        ]),
        const SizedBox(height: 24),
        Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _ActionTile(Icons.add_circle, 'Create Event', ()=> context.push('/organizer/create-event')),
        _ActionTile(Icons.list, 'Manage Events', ()=> context.push('/organizer/manage-events')),
        _ActionTile(Icons.analytics, 'Analytics', ()=> context.push('/organizer/analytics')),
        _ActionTile(Icons.home, 'Participant View', ()=> context.go('/home')),
      ])),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon; final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
  @override Widget build(BuildContext context) => Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Icon(icon, color: color, size: 28), const SizedBox(height: 8),
    Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
    Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
  ]))));
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.onTap);
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary), title: Text(label),
    trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
