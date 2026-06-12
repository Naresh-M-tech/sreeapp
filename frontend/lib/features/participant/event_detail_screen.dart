import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/api_client.dart';
import '../../models/event_model.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});
  @override ConsumerState<EventDetailScreen> createState() => _State();
}

class _State extends ConsumerState<EventDetailScreen> {
  EventModel? _event; bool _loading = true; bool _registering = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try { final r = await ref.read(dioProvider).get('/events/${widget.eventId}');
      if (r.data['success']==true) setState(()=> _event=EventModel.fromJson(r.data['data']));
    } catch(_){} setState(()=> _loading=false);
  }

  Future<void> _register() async {
    setState(()=> _registering=true);
    try { await ref.read(dioProvider).post('/registrations/${widget.eventId}');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered!'),backgroundColor: Colors.green)); _load();
    } catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed'),backgroundColor: Colors.red)); }
    setState(()=> _registering=false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_event==null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('Event not found')));
    final e = _event!;
    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(expandedHeight: 180, pinned: true, flexibleSpace: FlexibleSpaceBar(
          background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C5CE7),Color(0xFF00CEC9)])),
            child: Center(child: Icon(Icons.event, size: 48, color: Colors.white))))),
        SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)).animate().fadeIn(),
          const SizedBox(height: 8),
          if (e.organizerName!=null) Text('By ${e.organizerName}', style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [Chip(label: Text(e.categoryDisplay)), if(e.teamEvent) const Chip(label: Text('Team')),
            if(e.registrationFee==0) const Chip(label: Text('FREE')) else Chip(label: Text('₹${e.registrationFee.toStringAsFixed(0)}'))]),
          const SizedBox(height: 16),
          _tile(Icons.location_on, 'Venue', e.venue??'TBD'),
          _tile(Icons.calendar_today, 'Date', e.startDate??'TBD'),
          if(e.capacity>0) _tile(Icons.people, 'Spots', '${e.registeredCount}/${e.capacity}'),
          const SizedBox(height: 16),
          Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8), Text(e.description, style: theme.textTheme.bodyMedium?.copyWith(height: 1.6)),
          if(e.rules.isNotEmpty) ...[ const SizedBox(height: 16), Text('Rules', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ...e.rules.map((r)=> Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.check,size:16,color:Color(0xFF6C5CE7)), const SizedBox(width: 8), Expanded(child: Text(r))])))],
          const SizedBox(height: 80),
        ])))]),
      bottomSheet: Container(padding: const EdgeInsets.all(16), child: SafeArea(child: SizedBox(width: double.infinity, height: 56,
        child: e.isRegistered ? OutlinedButton.icon(icon: const Icon(Icons.check), label: const Text('Registered'), onPressed: null)
          : ElevatedButton.icon(icon: _registering?const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):const Icon(Icons.how_to_reg),
              label: Text(e.isFull?'Full':'Register Now'), onPressed: e.isFull||_registering?null:_register)))));
  }

  Widget _tile(IconData i, String l, String v) => Padding(padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:const Color(0xFF6C5CE7).withOpacity(0.1),borderRadius:BorderRadius.circular(8)),
      child: Icon(i,color:const Color(0xFF6C5CE7),size:18)), const SizedBox(width:10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l,style:TextStyle(fontSize:11,color:Colors.grey[500])), Text(v,style:const TextStyle(fontWeight:FontWeight.w600))])]));
}
