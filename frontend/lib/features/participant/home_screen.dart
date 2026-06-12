import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/api_client.dart';
import '../../models/event_model.dart';

final upcomingEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final dio = ref.read(dioProvider);
  final response = await dio.get('/events/public/upcoming');
  if (response.data['success'] == true) {
    return (response.data['data'] as List).map((e) => EventModel.fromJson(e)).toList();
  }
  return [];
});

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final eventsAsync = ref.watch(upcomingEventsProvider);
    final theme = Theme.of(context);
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false, pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('Hello, ${user?.name ?? 'User'} 👋', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('Discover amazing events', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () => context.push('/notifications')),
            ],
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: () => context.push('/events'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(children: [Icon(Icons.search, color: Colors.grey[400]), const SizedBox(width: 12), Text('Search events...', style: TextStyle(color: Colors.grey[400]))]),
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _CategoryCard(icon: Icons.code, label: 'Technical', color: const Color(0xFF6C5CE7)),
                        _CategoryCard(icon: Icons.palette, label: 'Cultural', color: const Color(0xFFE84393)),
                        _CategoryCard(icon: Icons.computer, label: 'Workshop', color: const Color(0xFF00CEC9)),
                        _CategoryCard(icon: Icons.emoji_events, label: 'Hackathon', color: const Color(0xFFFDAA5B)),
                        _CategoryCard(icon: Icons.sports, label: 'Sports', color: const Color(0xFF00B894)),
                        _CategoryCard(icon: Icons.school, label: 'Seminar', color: const Color(0xFF0984E3)),
                      ],
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ),
          ),

          // Upcoming Events header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Events', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton(onPressed: () => context.push('/events'), child: const Text('See All')),
                ],
              ),
            ),
          ),

          // Events list
          eventsAsync.when(
            loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverFillRemaining(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('Could not load events', style: theme.textTheme.bodyLarge),
              const SizedBox(height: 8),
              ElevatedButton(onPressed: () => ref.invalidate(upcomingEventsProvider), child: const Text('Retry')),
            ]))),
            data: (events) {
              if (events.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Column(children: [
                    const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('No upcoming events', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                  ]))),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _EventCard(event: events[index]).animate().slideX(begin: 0.3, delay: (100 * index).ms).fadeIn(),
                  childCount: events.length,
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _CategoryCard({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, margin: const EdgeInsets.only(right: 12),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push('/events/${event.id}'),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF00CEC9)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.venue ?? 'TBD', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]), overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    Chip(label: Text(event.categoryDisplay, style: const TextStyle(fontSize: 10)), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                    const Spacer(),
                    if (event.registrationFee > 0) Text('₹${event.registrationFee.toStringAsFixed(0)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: theme.colorScheme.primary)),
                    if (event.registrationFee == 0) Text('FREE', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: Colors.green)),
                  ]),
                ],
              )),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
