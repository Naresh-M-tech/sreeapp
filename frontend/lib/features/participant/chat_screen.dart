import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/api_client.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _msgCtrl = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> _rooms = [];
  String? _selectedRoomId;
  bool _loading = true;

  @override void initState() { super.initState(); _loadRooms(); }

  Future<void> _loadRooms() async {
    try { final r = await ref.read(dioProvider).get('/chat/rooms');
      if (r.data['success']==true) setState(()=> _rooms = List<Map<String,dynamic>>.from(r.data['data']));
    } catch(_){} setState(()=> _loading=false);
  }

  Future<void> _loadMessages(String roomId) async {
    try { final r = await ref.read(dioProvider).get('/chat/rooms/$roomId/messages');
      if (r.data['success']==true) setState(()=> _messages = List<Map<String,dynamic>>.from(r.data['data']).reversed.toList());
    } catch(_){}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Chat')), body: const Center(child: CircularProgressIndicator()));

    if (_selectedRoomId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat Rooms')),
        body: _rooms.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 12), Text('No chat rooms yet', style: TextStyle(color: Colors.grey[500]))]))
          : ListView.builder(itemCount: _rooms.length, itemBuilder: (_, i) {
              final room = _rooms[i];
              return ListTile(
                leading: CircleAvatar(backgroundColor: theme.colorScheme.primary.withOpacity(0.1), child: Icon(Icons.chat, color: theme.colorScheme.primary)),
                title: Text(room['name'] ?? 'Chat Room'), subtitle: Text(room['type'] ?? '', style: const TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () { setState(()=> _selectedRoomId = room['id']); _loadMessages(room['id']); },
              );
            }),
      );
    }

    return Scaffold(
      appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: ()=> setState(()=> _selectedRoomId=null)), title: const Text('Chat')),
      body: Column(children: [
        Expanded(child: _messages.isEmpty
          ? const Center(child: Text('No messages yet'))
          : ListView.builder(reverse: false, padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (_, i) {
              final m = _messages[i];
              return Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m['senderName']??'', style: TextStyle(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(m['content']??'')),
              ]));
            })),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: theme.cardColor, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
          child: Row(children: [
            Expanded(child: TextField(controller: _msgCtrl, decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none))),
            IconButton(icon: Icon(Icons.send, color: theme.colorScheme.primary), onPressed: () {
              if (_msgCtrl.text.trim().isNotEmpty) { _msgCtrl.clear(); }
            }),
          ])),
      ]),
    );
  }
}
