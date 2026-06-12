import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Generate Reports', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        _ReportCard('User Report', 'Summary of all registered users', Icons.people, () {}),
        _ReportCard('Event Report', 'Summary of all events and registrations', Icons.event, () {}),
        _ReportCard('Revenue Report', 'Financial summary of all events', Icons.currency_rupee, () {}),
        _ReportCard('Attendance Report', 'Attendance statistics across events', Icons.check_circle, () {}),
        _ReportCard('Audit Log', 'System activity log', Icons.history, () async {
          final r = await ref.read(dioProvider).get('/admin/audit-logs');
          if (context.mounted && r.data['success']==true) {
            showDialog(context: context, builder: (_) => AlertDialog(
              title: const Text('Recent Audit Logs'),
              content: SizedBox(width: double.maxFinite, child: ListView(shrinkWrap: true,
                children: (r.data['data'] as List).take(20).map((l) => ListTile(
                  dense: true, title: Text(l['action']??'', style: const TextStyle(fontSize: 13)),
                  subtitle: Text('${l['userName']??''} - ${l['details']??''}', style: const TextStyle(fontSize: 11)),
                )).toList())),
              actions: [TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Close'))],
            ));
          }
        }),
      ])),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, subtitle; final IconData icon; final VoidCallback onTap;
  const _ReportCard(this.title, this.subtitle, this.icon, this.onTap);
  @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
    leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, color: Theme.of(context).colorScheme.primary)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    trailing: const Icon(Icons.download), onTap: onTap,
  ));
}
