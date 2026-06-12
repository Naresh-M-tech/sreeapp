import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/api_client.dart';

class FacultyDashboard extends ConsumerStatefulWidget {
  const FacultyDashboard({super.key});
  @override ConsumerState<FacultyDashboard> createState() => _State();
}

class _State extends ConsumerState<FacultyDashboard> {
  int _pendingCount = 0; bool _loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final r = await ref.read(dioProvider).get('/od/faculty/pending');
      if (r.data['success']==true) setState(()=> _pendingCount = (r.data['data'] as List).length); } catch(_){}
    setState(()=> _loading = false);
  }

  @override Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user; final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Faculty Dashboard'), actions: [
        IconButton(icon: const Icon(Icons.logout), onPressed: (){ ref.read(authProvider.notifier).logout(); context.go('/login'); })]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Welcome, ${user?.name ?? "Faculty"}!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.pending_actions, color: Colors.orange, size: 32)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_pendingCount', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            Text('Pending OD Requests', style: TextStyle(color: Colors.grey[500])),
          ]),
        ]))),
        const SizedBox(height: 20),
        Text('Quick Actions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Card(child: ListTile(leading: const Icon(Icons.assignment, color: Color(0xFF6C5CE7)), title: const Text('OD Requests'),
          subtitle: Text('$_pendingCount pending'), trailing: const Icon(Icons.chevron_right), onTap: ()=> context.push('/faculty/od-requests'))),
        Card(child: ListTile(leading: const Icon(Icons.event, color: Color(0xFF00CEC9)), title: const Text('View Events'),
          trailing: const Icon(Icons.chevron_right), onTap: ()=> context.go('/home'))),
      ])),
    );
  }
}
