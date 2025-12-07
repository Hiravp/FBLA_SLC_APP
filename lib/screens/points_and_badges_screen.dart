// lib/screens/points_and_badges_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PointsAndBadgesScreen extends StatefulWidget {
  const PointsAndBadgesScreen({super.key});

  @override
  State<PointsAndBadgesScreen> createState() => _PointsAndBadgesScreenState();
}

class _PointsAndBadgesScreenState extends State<PointsAndBadgesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> profiles = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await supabase
          .from('profiles')
          .select('id,display_name,points,badges')
          .order('points', ascending: false);
      profiles = List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Points & Badges'),
        backgroundColor: const Color(0xFF0033A0),
        actions: [
          IconButton(onPressed: _loadProfiles, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0033A0)))
          : error != null
              ? Center(
                  child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
                )
              : RefreshIndicator(
                  onRefresh: _loadProfiles,
                  child: profiles.isEmpty
                      ? const Center(
                          child: Text('No profiles found', style: TextStyle(color: Colors.black54)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: profiles.length,
                          itemBuilder: (_, i) {
                            final p = profiles[i];
                            final name = p['display_name'] ?? 'Unknown';
                            final points = p['points'] ?? 0;
                            final badgesList = (p['badges'] is List)
                                ? List<String>.from(p['badges'])
                                : <String>[];
                            return Card(
                              color: Colors.lightBlue.shade50,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFF0033A0),
                                  foregroundColor: const Color(0xFFFFB81C),
                                  child: Text(name[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0033A0))),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text('Points: $points', style: const TextStyle(color: Colors.black87)),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: badgesList.isEmpty
                                          ? [
                                              Chip(
                                                label: const Text('No Badges'),
                                                backgroundColor: Colors.grey.shade300,
                                              )
                                            ]
                                          : badgesList
                                              .map((b) => Chip(
                                                    label: Text(b),
                                                    backgroundColor: const Color(0xFFFFB81C),
                                                    labelStyle: const TextStyle(color: Color(0xFF0033A0)),
                                                  ))
                                              .toList(),
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
