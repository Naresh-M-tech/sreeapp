import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/api_client.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});
  @override ConsumerState<CreateEventScreen> createState() => _State();
}

class _State extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '100');
  final _feeCtrl = TextEditingController(text: '0');
  final _eligCtrl = TextEditingController();
  String _category = 'TECHNICAL';
  bool _teamEvent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Event Title', prefixIcon: Icon(Icons.title)),
          validator: (v) => v==null||v.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _descCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
          validator: (v) => v==null||v.isEmpty ? 'Required' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(value: _category,
          decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
          items: ['TECHNICAL','NON_TECHNICAL','WORKSHOP','HACKATHON','SEMINAR','CULTURAL','SPORTS'].map((c) => DropdownMenuItem(value: c, child: Text(c.replaceAll('_',' ')))).toList(),
          onChanged: (v) => setState(() => _category = v!)),
        const SizedBox(height: 12),
        TextFormField(controller: _venueCtrl, decoration: const InputDecoration(labelText: 'Venue', prefixIcon: Icon(Icons.location_on))),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: TextFormField(controller: _capacityCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Capacity', prefixIcon: Icon(Icons.people)))),
          const SizedBox(width: 12),
          Expanded(child: TextFormField(controller: _feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Fee (₹)', prefixIcon: Icon(Icons.currency_rupee)))),
        ]),
        const SizedBox(height: 12),
        TextFormField(controller: _eligCtrl, decoration: const InputDecoration(labelText: 'Eligibility', prefixIcon: Icon(Icons.checklist))),
        const SizedBox(height: 12),
        SwitchListTile(title: const Text('Team Event'), value: _teamEvent, onChanged: (v) => setState(()=> _teamEvent = v)),
        const SizedBox(height: 24),
        SizedBox(height: 56, child: ElevatedButton.icon(
          icon: _loading ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)) : const Icon(Icons.add),
          label: const Text('Create Event'),
          onPressed: _loading ? null : () async {
            if (_formKey.currentState!.validate()) {
              setState(()=> _loading = true);
              try {
                await ref.read(dioProvider).post('/events', data: {
                  'title': _titleCtrl.text, 'description': _descCtrl.text, 'category': _category,
                  'venue': _venueCtrl.text, 'capacity': int.tryParse(_capacityCtrl.text)??100,
                  'registrationFee': double.tryParse(_feeCtrl.text)??0, 'eligibility': _eligCtrl.text,
                  'teamEvent': _teamEvent, 'minTeamSize': 1, 'maxTeamSize': 4, 'rules': [], 'tags': [],
                });
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event created! Pending approval.'), backgroundColor: Colors.green));
                context.pop();
              } catch(e) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to create event'), backgroundColor: Colors.red)); }
              setState(()=> _loading = false);
            }
          },
        )),
      ]))),
    );
  }
}
