// lib/screens/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final supabase = Supabase.instance.client;
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Real-time subscription
    supabase.from('messages').stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> newMessages) {
      setState(() {
        messages = newMessages.reversed.toList();
      });
      _scrollToBottom();
    });
  }

  Future<void> _loadMessages() async {
    setState(() => loading = true);
    try {
      final res = await supabase.from('messages').select().order('created_at', ascending: true);
      messages = List<Map<String, dynamic>>.from(res as List).reversed.toList();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => loading = false);
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await supabase.from('messages').insert({
        'content': text,
        'sender_profile': supabase.auth.currentUser?.id, // associate with logged-in user
        'room_id': 'global', // can be changed for chapters or rooms
      });
      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 60,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FBLA Chat'),
        backgroundColor: const Color(0xFF0033A0),
        actions: [
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0033A0)))
                : error != null
                    ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) {
                          final msg = messages[i];
                          final isMe = msg['sender_profile'] == supabase.auth.currentUser?.id;
                          final senderName = isMe ? 'You' : (msg['sender_name'] ?? 'Member');
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _MessageBubble(sender: senderName, message: msg['content'] ?? '', isMe: isMe),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB81C),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isMe;

  const _MessageBubble({required this.sender, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 260),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF0033A0) : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? const Color(0xFFFFB81C) : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
