// lib/screens/members_directory_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembersDirectoryScreen extends StatefulWidget {
  const MembersDirectoryScreen({super.key});

  @override
  State<MembersDirectoryScreen> createState() => _MembersDirectoryScreenState();
}

class _MembersDirectoryScreenState extends State<MembersDirectoryScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> members = [];
  String query = '';
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await supabase
          .from('profiles')
          .select('id,display_name,email,role,chapter')
          .order('display_name');
      members = List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  List<Map<String, dynamic>> get filtered {
    if (query.isEmpty) return members;
    final q = query.toLowerCase();
    return members.where((m) {
      final name = (m['display_name'] ?? '').toString().toLowerCase();
      final email = (m['email'] ?? '').toString().toLowerCase();
      final role = (m['role'] ?? '').toString().toLowerCase();
      final chapter = (m['chapter'] ?? '').toString().toLowerCase();
      return name.contains(q) || email.contains(q) || role.contains(q) || chapter.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FBLA Members Directory'),
        backgroundColor: const Color(0xFF0033A0),
        actions: [
          IconButton(onPressed: _loadMembers, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0033A0)))
          : error != null
              ? Center(
                  child: Text(
                    "Error: $error",
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF0033A0)),
                            hintText: 'Search name, email, role, chapter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (v) => setState(() => query = v),
                        ),
                      ),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(child: Text('No members found'))
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: filtered.length,
                                itemBuilder: (_, i) {
                                  final m = filtered[i];
                                  final name = m['display_name'] ?? 'No name';
                                  final email = m['email'] ?? '';
                                  final role = (m['role'] ?? 'member').toString().toUpperCase();
                                  final chapter = m['chapter'] ?? 'N/A';
                                  return Card(
                                    color: Colors.lightBlue.shade50,
                                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF0033A0),
                                        foregroundColor: const Color(0xFFFFB81C),
                                        child: Text(
                                          name.isNotEmpty ? name[0] : '?',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      title: Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0033A0)),
                                      ),
                                      subtitle: Text('$email • $role • $chapter'),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
