import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../../models/other_models.dart';

final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final r = await ref.read(dioProvider).get('/notifications');
  if (r.data['success']==true) return (r.data['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
  return [];
});

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), actions: [
        TextButton(onPressed: () async { await ref.read(dioProvider).put('/notifications/read-all'); ref.invalidate(notificationsProvider); }, child: const Text('Read All')),
      ]),
      body: notifsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => const Center(child: Text('Failed to load notifications')),
        data: (notifs) {
          if (notifs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey[300]), const SizedBox(height: 12),
            Text('No notifications', style: TextStyle(color: Colors.grey[500]))]));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: notifs.length, itemBuilder: (_, i) {
            final n = notifs[i];
            return Card(margin: const EdgeInsets.only(bottom: 8),
              color: n.read ? null : Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(_getIcon(n.type), color: Theme.of(context).colorScheme.primary, size: 20)),
                title: Text(n.title, style: TextStyle(fontWeight: n.read ? FontWeight.w400 : FontWeight.w700)),
                subtitle: Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                onTap: () async { await ref.read(dioProvider).put('/notifications/${n.id}/read'); ref.invalidate(notificationsProvider); },
            ));
          });
        },
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) { case 'EVENT': return Icons.event; case 'REGISTRATION': return Icons.how_to_reg;
      case 'OD_REQUEST': return Icons.assignment; case 'CHAT': return Icons.chat; default: return Icons.notifications; }
  }
}
