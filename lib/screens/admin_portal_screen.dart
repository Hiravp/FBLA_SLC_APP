// lib/screens/admin_portal_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPortalScreen extends StatefulWidget {
  const AdminPortalScreen({super.key});

  @override
  State<AdminPortalScreen> createState() => _AdminPortalScreenState();
}

class _AdminPortalScreenState extends State<AdminPortalScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> adminData = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await supabase.from('admin_portal').select();
      adminData = List<Map<String, dynamic>>.from(res as List);
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
        title: const Text('FBLA Admin Portal'),
        backgroundColor: const Color(0xFF0033A0),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0033A0),
              ),
            )
          : error != null
              ? Center(
                  child: Text(
                    "Error: $error",
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : RefreshIndicator(
                  color: const Color(0xFFFFB81C),
                  backgroundColor: const Color(0xFF0033A0),
                  onRefresh: _load,
                  child: adminData.isEmpty
                      ? const Center(
                          child: Text(
                            "No admin actions yet",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: adminData.length,
                          itemBuilder: (_, i) {
                            final entry = adminData[i];
                            return Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.blue.shade50,
                              child: ListTile(
                                leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF0033A0)),
                                title: Text(
                                  entry['action'] ?? 'No Action',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(entry['description'] ?? ''),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
