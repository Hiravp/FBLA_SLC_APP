import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> announcements = [];
  bool loading = true;
  String? error;

  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String category = 'General';

  final List<String> categories = ['General', 'Event', 'Reminder', 'News'];

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await supabase
          .from('announcements')
          .select()
          .order('created_at', ascending: false);
      announcements = List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      loading = false;
    });
  }

  Future<void> _postAnnouncement() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() => loading = true);

    try {
      await supabase.from('announcements').insert({
        'title': title,
        'body': content,      // ✅ match DB column name
        'category': category, // ✅ now exists in DB
      });
      _titleCtrl.clear();
      _contentCtrl.clear();
      category = 'General';
      await _loadAnnouncements();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Announcement posted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Post Announcement Section
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<String>(
                      value: category,
                      items: categories
                          .map((c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => category = v);
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _postAnnouncement,
                      child: const Text('Post Announcement'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Announcements List
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Text('Error: $error'))
                      : announcements.isEmpty
                          ? const Center(child: Text('No announcements yet'))
                          : RefreshIndicator(
                              onRefresh: _loadAnnouncements,
                              child: ListView.builder(
                                itemCount: announcements.length,
                                itemBuilder: (_, i) {
                                  final ann = announcements[i];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    child: ListTile(
                                      title: Text(ann['title'] ?? 'Untitled'),
                                      subtitle: Text(
                                        '${ann['body'] ?? ''}\nCategory: ${ann['category'] ?? 'General'}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
