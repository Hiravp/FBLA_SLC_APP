// lib/screens/events_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
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
      final res = await supabase.from('events').select();
      events = List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _registerEvent(Map<String, dynamic> event) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to register')),
        );
        return;
      }
      await supabase.from('attendance').insert({
        'id': const Uuid().v4(),
        'event_id': event['id'],
        'profile_id': userId,
        'qr_code': 'Manual Registration',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registered for ${event['title']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FBLA Events'),
        backgroundColor: const Color(0xFF0033A0),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0033A0)),
            )
          : error != null
              ? Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red)))
              : RefreshIndicator(
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (_, index) {
                      final event = events[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event['title'] ?? 'Untitled Event',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0033A0)),
                              ),
                              const SizedBox(height: 4),
                              Text(event['start_at']?.toString() ?? 'No date'),
                              Text(event['location'] ?? 'No location'),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFB81C),
                                  foregroundColor: Colors.black,
                                ),
                                onPressed: () => _registerEvent(event),
                                child: const Text('Register'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
