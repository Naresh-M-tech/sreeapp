import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../../models/other_models.dart';

final myRegistrationsProvider = FutureProvider<List<RegistrationModel>>((ref) async {
  final r = await ref.read(dioProvider).get('/registrations/my');
  if (r.data['success']==true) return (r.data['data'] as List).map((e) => RegistrationModel.fromJson(e)).toList();
  return [];
});

class MyEventsScreen extends ConsumerWidget {
  const MyEventsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final regsAsync = ref.watch(myRegistrationsProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: regsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.error_outline, size: 48), const Text('Failed to load'), ElevatedButton(onPressed: ()=>ref.invalidate(myRegistrationsProvider), child: const Text('Retry'))])),
        data: (regs) {
          if (regs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]), const SizedBox(height: 12),
            Text('No registered events', style: TextStyle(color: Colors.grey[500]))]));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: regs.length, itemBuilder: (_, i) {
            final r = regs[i];
            Color statusColor = r.status=='ATTENDED' ? Colors.green : r.status=='CANCELLED' ? Colors.red : theme.colorScheme.primary;
            return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.event, color: statusColor)),
              title: Text(r.eventTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('Status: ${r.status}', style: TextStyle(color: statusColor, fontSize: 12)),
              trailing: r.attended ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.chevron_right),
            ));
          });
        },
      ),
    );
  }
}
