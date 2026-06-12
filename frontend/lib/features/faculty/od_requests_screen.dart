import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';
import '../../models/other_models.dart';

final odRequestsProvider = FutureProvider<List<OdRequestModel>>((ref) async {
  final r = await ref.read(dioProvider).get('/od/faculty');
  if (r.data['success']==true) return (r.data['data'] as List).map((e) => OdRequestModel.fromJson(e)).toList();
  return [];
});

class OdRequestsScreen extends ConsumerWidget {
  const OdRequestsScreen({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final odsAsync = ref.watch(odRequestsProvider); final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('OD Requests')),
      body: odsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e,_) => Center(child: Text('Error: $e')),
        data: (ods) {
          if (ods.isEmpty) return const Center(child: Text('No OD requests'));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: ods.length, itemBuilder: (_, i) {
            final od = ods[i];
            Color sc = od.status=='APPROVED' ? Colors.green : od.status=='REJECTED' ? Colors.red : Colors.orange;
            return Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(od.studentName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const Spacer(), Chip(label: Text(od.status, style: TextStyle(color: sc, fontSize: 11)), backgroundColor: sc.withOpacity(0.1), padding: EdgeInsets.zero, visualDensity: VisualDensity.compact)]),
              const SizedBox(height: 4),
              Text('Event: ${od.eventTitle}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              if (od.fromDate!=null) Text('${od.fromDate} - ${od.toDate}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              if (od.status=='PENDING') ...[const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.check, size: 18), label: const Text('Approve'), style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () async { await ref.read(dioProvider).put('/od/${od.id}/approve'); ref.invalidate(odRequestsProvider); })),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.close, size: 18, color: Colors.red), label: const Text('Reject', style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                    onPressed: () async { await ref.read(dioProvider).put('/od/${od.id}/reject', queryParameters: {'remarks': 'Not approved'}); ref.invalidate(odRequestsProvider); })),
                ])],
            ])));
          });
        }),
    );
  }
}
