// lib/screens/officer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OfficerDashboard extends StatefulWidget {
  const OfficerDashboard({super.key});

  @override
  State<OfficerDashboard> createState() => _OfficerDashboardState();
}

class _OfficerDashboardState extends State<OfficerDashboard> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> events = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await supabase.from('events').select().order('start_at');
      events = List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _deleteEvent(String id) async {
    try {
      await supabase.from('events').delete().eq('id', id);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted'), backgroundColor: Color(0xFF0033A0)));
      _loadEvents();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _createEvent() async {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create FBLA Event', style: TextStyle(color: Color(0xFF0033A0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, {
              'title': titleCtrl.text,
              'description': descCtrl.text,
            }),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0033A0)),
            child: const Text('Create', style: TextStyle(color: Color(0xFFFFB81C))),
          ),
        ],
      ),
    );

    if (result != null && (result['title']?.trim().isNotEmpty ?? false)) {
      try {
        await supabase.from('events').insert({
          'title': result['title']!.trim(),
          'description': (result['description'] ?? '').trim(),
        });
        _loadEvents();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Create failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Officer Dashboard'),
        backgroundColor: const Color(0xFF0033A0),
        actions: [
          IconButton(onPressed: _loadEvents, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0033A0)))
          : error != null
              ? Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                )
              : events.isEmpty
                  ? const Center(
                      child: Text('No events', style: TextStyle(fontSize: 16, color: Colors.black54)))
                  : RefreshIndicator(
                      onRefresh: _loadEvents,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: events.length,
                        itemBuilder: (_, i) {
                          final e = events[i];
                          return Card(
                            color: Colors.lightBlue.shade50,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              title: Text(
                                e['title'] ?? 'Untitled',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0033A0)),
                              ),
                              subtitle: Text(e['start_at']?.toString() ?? '',
                                  style: const TextStyle(color: Colors.black87)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () => _deleteEvent(e['id'].toString()),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEvent,
        backgroundColor: const Color(0xFF0033A0),
        child: const Icon(Icons.add, color: Color(0xFFFFB81C)),
      ),
    );
  }
}
