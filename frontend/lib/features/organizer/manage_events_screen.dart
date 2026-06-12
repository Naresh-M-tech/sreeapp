import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../../models/event_model.dart';

final organizerEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final r = await ref.read(dioProvider).get('/organizer/events');
  if (r.data['success']==true) return (r.data['data'] as List).map((e) => EventModel.fromJson(e)).toList();
  return [];
});

class ManageEventsScreen extends ConsumerWidget {
  const ManageEventsScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(organizerEventsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Events')),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (events) {
          if (events.isEmpty) return const Center(child: Text('No events created yet'));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: events.length, itemBuilder: (_, i) {
            final e = events[i]; Color sc = e.status=='PUBLISHED' ? Colors.green : e.status=='PENDING_APPROVAL' ? Colors.orange : Colors.grey;
            return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: sc.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.event, color: sc)),
              title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Row(children: [Chip(label: Text(e.status, style: TextStyle(fontSize: 10, color: sc)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                const SizedBox(width: 8), Text('${e.registeredCount} registrations', style: const TextStyle(fontSize: 11))]),
              trailing: PopupMenuButton(itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
              ], onSelected: (v) async {
                if (v=='delete') { await ref.read(dioProvider).delete('/events/${e.id}'); ref.invalidate(organizerEventsProvider); }
              }),
            ));
          });
        }),
    );
  }
}
