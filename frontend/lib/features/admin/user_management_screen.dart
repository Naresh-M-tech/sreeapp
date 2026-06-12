import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../../models/user_model.dart';

final allUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final r = await ref.read(dioProvider).get('/admin/users');
  if (r.data['success']==true) return (r.data['data'] as List).map((e) => UserModel.fromJson(e)).toList();
  return [];
});

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: usersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (users) => ListView.builder(padding: const EdgeInsets.all(16), itemCount: users.length, itemBuilder: (_, i) {
          final u = users[i];
          return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
            leading: CircleAvatar(backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Text(u.name.substring(0,1).toUpperCase(), style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700))),
            title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(u.email, style: const TextStyle(fontSize: 12)),
              Wrap(spacing: 4, children: u.roles.map((r) => Chip(label: Text(r.replaceAll('ROLE_',''), style: const TextStyle(fontSize: 9)),
                padding: EdgeInsets.zero, visualDensity: VisualDensity.compact)).toList())]),
            trailing: PopupMenuButton(itemBuilder: (_) => [
              const PopupMenuItem(value: 'toggle', child: Text('Toggle Status')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ], onSelected: (v) async {
              if (v=='toggle') { await ref.read(dioProvider).put('/admin/users/${u.id}/toggle-status'); ref.invalidate(allUsersProvider); }
              if (v=='delete') { await ref.read(dioProvider).delete('/admin/users/${u.id}'); ref.invalidate(allUsersProvider); }
            }),
          ));
        }),
      ),
    );
  }
}
