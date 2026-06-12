import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/api_client.dart';

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});
  @override ConsumerState<AdminAnalyticsScreen> createState() => _State();
}

class _State extends ConsumerState<AdminAnalyticsScreen> {
  Map<String, dynamic>? _data; bool _loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try { final r = await ref.read(dioProvider).get('/admin/analytics');
      if (r.data['success']==true) setState(()=> _data = r.data['data']); } catch(_){}
    setState(()=> _loading = false);
  }

  @override Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Analytics')), body: const Center(child: CircularProgressIndicator()));
    final theme = Theme.of(context);
    final usersByRole = Map<String, dynamic>.from(_data?['usersByRole'] ?? {});
    final eventsByCat = Map<String, dynamic>.from(_data?['eventsByCategory'] ?? {});
    final colors = [const Color(0xFF6C5CE7), const Color(0xFF00CEC9), const Color(0xFFE84393), const Color(0xFFFDAA5B), const Color(0xFF00B894), Colors.blue, Colors.red];

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Users by Role', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (usersByRole.isNotEmpty) SizedBox(height: 200, child: PieChart(PieChartData(
          sections: usersByRole.entries.toList().asMap().entries.map((e) => PieChartSectionData(
            value: (e.value.value as num).toDouble(), title: '${e.value.key.toString().replaceAll("ROLE_", "")}\n${e.value.value}',
            color: colors[e.key % colors.length], radius: 80, titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
          )).toList(),
        ))),
        const SizedBox(height: 24),
        Text('Events by Category', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        if (eventsByCat.isNotEmpty) SizedBox(height: 250, child: BarChart(BarChartData(
          barGroups: eventsByCat.entries.toList().asMap().entries.map((e) =>
            BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: (e.value.value as num).toDouble(), color: colors[e.key % colors.length], width: 16, borderRadius: BorderRadius.circular(4))])
          ).toList(),
          titlesData: FlTitlesData(bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
            final keys = eventsByCat.keys.toList();
            return v.toInt() < keys.length ? Padding(padding: const EdgeInsets.only(top: 8), child: RotatedBox(quarterTurns: 1, child: Text(keys[v.toInt()].replaceAll('_',' '), style: const TextStyle(fontSize: 8)))) : const SizedBox();
          }))),
        ))),
      ])),
    );
  }
}
