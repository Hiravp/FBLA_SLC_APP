// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? profile;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('user_id', user.id)
          .single();

      if (!mounted) return;
      setState(() {
        profile = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF0033A0), // FBLA blue
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0033A0)))
          : profile == null
              ? const Center(child: Text("No profile found"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: Colors.lightBlue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: const Color(0xFF0033A0),
                            foregroundColor: const Color(0xFFFFB81C),
                            child: Text(
                              profile?['display_name']?.toString()[0] ?? '?',
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            profile?['display_name'] ?? 'Unknown',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0033A0)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.email, size: 20, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(profile?['email'] ?? 'N/A'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.school, size: 20, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('Chapter: ${profile?['chapter'] ?? 'N/A'}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 20, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text('Role: ${profile?['role'] ?? 'Member'}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
