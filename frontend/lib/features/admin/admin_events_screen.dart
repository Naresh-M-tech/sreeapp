import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../../models/event_model.dart';

final pendingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final r = await ref.read(dioProvider).get('/admin/events/pending');
  if (r.data['success']==true) return (r.data['data'] as List).map((e) => EventModel.fromJson(e)).toList();
  return [];
});

class AdminEventsScreen extends ConsumerWidget {
  const AdminEventsScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(pendingEventsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Event Management')),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (events) {
          if (events.isEmpty) return const Center(child: Text('No pending events'));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: events.length, itemBuilder: (_, i) {
            final e = events[i];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text('By: ${e.organizerName ?? "Unknown"}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text('Category: ${e.categoryDisplay}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check, size: 18), label: const Text('Approve'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async { await ref.read(dioProvider).put('/admin/events/${e.id}/approve'); ref.invalidate(pendingEventsProvider); })),
                const SizedBox(width: 8),
                Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.close, size: 18, color: Colors.red), label: const Text('Reject', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  onPressed: () async { await ref.read(dioProvider).put('/admin/events/${e.id}/reject', queryParameters: {'reason': 'Not approved'}); ref.invalidate(pendingEventsProvider); })),
              ]),
            ])));
          });
        }),
    );
  }
}
