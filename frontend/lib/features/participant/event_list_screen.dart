import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_client.dart';
import '../../models/event_model.dart';

final allEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/events/public/published');
  if (response.data['success'] == true) return (response.data['data'] as List).map((e) => EventModel.fromJson(e)).toList();
  return [];
});

class EventListScreen extends ConsumerStatefulWidget {
  const EventListScreen({super.key});
  @override ConsumerState<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends ConsumerState<EventListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _categories = ['All', 'TECHNICAL', 'NON_TECHNICAL', 'WORKSHOP', 'HACKATHON', 'SEMINAR', 'CULTURAL', 'SPORTS'];

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(allEventsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore Events')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(hintText: 'Search events...', prefixIcon: const Icon(Icons.search), suffixIcon: _searchQuery.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = '')) : null),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(_categories[i].replaceAll('_', ' ')),
                  selected: _selectedCategory == _categories[i],
                  onSelected: (_) => setState(() => _selectedCategory = _categories[i]),
                ),
              ),
            ),
          ),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 8),
                const Text('Failed to load events'),
                ElevatedButton(onPressed: () => ref.invalidate(allEventsProvider), child: const Text('Retry')),
              ])),
              data: (events) {
                var filtered = events.where((e) {
                  final matchesSearch = _searchQuery.isEmpty || e.title.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCategory = _selectedCategory == 'All' || e.category == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                if (filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('No events found', style: TextStyle(color: Colors.grey[500])),
                ]));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final event = filtered[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => context.push('/events/${event.id}'),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Container(width: 48, height: 48, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)]), borderRadius: BorderRadius.circular(12)),
                                  child: const Icon(Icons.event, color: Colors.white, size: 24)),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  Text(event.organizerName ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                ])),
                                if (event.registrationFee > 0) Chip(label: Text('₹${event.registrationFee.toStringAsFixed(0)}'), backgroundColor: theme.colorScheme.primary.withOpacity(0.1))
                                else Chip(label: const Text('FREE'), backgroundColor: Colors.green.withOpacity(0.1)),
                              ]),
                              const SizedBox(height: 12),
                              Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                              const SizedBox(height: 12),
                              Wrap(spacing: 8, children: [
                                _InfoChip(Icons.location_on_outlined, event.venue ?? 'TBD'),
                                _InfoChip(Icons.category_outlined, event.categoryDisplay),
                                if (event.capacity > 0) _InfoChip(Icons.people_outline, '${event.registeredCount}/${event.capacity}'),
                              ]),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: Colors.grey[500]), const SizedBox(width: 4),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
  ]);
}
