import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/api_client.dart';

class OrganizerAnalyticsScreen extends ConsumerStatefulWidget {
  const OrganizerAnalyticsScreen({super.key});
  @override ConsumerState<OrganizerAnalyticsScreen> createState() => _State();
}

class _State extends ConsumerState<OrganizerAnalyticsScreen> {
  Map<String, dynamic>? _data; bool _loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final r = await ref.read(dioProvider).get('/organizer/analytics');
      if (r.data['success']==true) setState(()=> _data = r.data['data']); } catch(_){}
    setState(()=> _loading = false);
  }

  @override Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Analytics')), body: const Center(child: CircularProgressIndicator()));
    final theme = Theme.of(context);
    final regsByEvent = Map<String, dynamic>.from(_data?['registrationsByEvent'] ?? {});

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Event Performance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (regsByEvent.isNotEmpty) SizedBox(height: 300, child: BarChart(BarChartData(
          barGroups: regsByEvent.entries.toList().asMap().entries.map((e) =>
            BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: (e.value.value as num).toDouble(), color: const Color(0xFF6C5CE7), width: 20, borderRadius: BorderRadius.circular(4))])
          ).toList(),
          titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
            final keys = regsByEvent.keys.toList();
            return v.toInt() < keys.length ? Padding(padding: const EdgeInsets.only(top: 8), child: Text(keys[v.toInt()].length > 8 ? '${keys[v.toInt()].substring(0, 8)}...' : keys[v.toInt()], style: const TextStyle(fontSize: 10))) : const SizedBox();
          })), leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40))),
        ))) else const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No event data available'))),
      ])),
    );
  }
}
