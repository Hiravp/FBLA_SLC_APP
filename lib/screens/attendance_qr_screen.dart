// lib/screens/attendance_qr_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class AttendanceQRScreen extends StatefulWidget {
  const AttendanceQRScreen({super.key});
  @override
  State<AttendanceQRScreen> createState() => _AttendanceQRScreenState();
}

class _AttendanceQRScreenState extends State<AttendanceQRScreen> {
  final supabase = Supabase.instance.client;
  final _manualCtrl = TextEditingController();
  List<Map<String, dynamic>> records = [];
  bool loading = false;
  String? error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      // Your schema uses 'timestamp' for attendance time
      final res = await supabase.from('attendance').select().order('timestamp', ascending: false);
      records = List<Map<String, dynamic>>.from(res as List);
    } catch (e) { error = e.toString(); }
    if (!mounted) return;
    setState(() { loading = false; });
  }

  Future<void> _manualCheckIn() async {
    final val = _manualCtrl.text.trim();
    if (val.isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      await supabase.from('attendance').insert({
        'id': const Uuid().v4(),
        // If you want to attach to specific event/profile, include event_id and profile_id here
        // For MVP manual entry, store a ref in qr_code or a text field
        'qr_code': val,
      });
      _manualCtrl.clear();
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked in')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Check-in failed: $e')));
    } finally { if (mounted) setState(() { loading = false; }); }
  }

  @override
  void dispose() { _manualCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                const Text('Scan QR or use manual entry', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _manualCtrl,
                      decoration: const InputDecoration(hintText: 'Enter member id/email or code', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _manualCheckIn, child: const Text('Check-in')),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                ? Center(child: Text('Error: $error'))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (_, i) {
                        final r = records[i];
                        final code = r['qr_code']?.toString() ?? 'Manual';
                        final at = r['timestamp']?.toString() ?? '';
                        return ListTile(leading: const Icon(Icons.check), title: Text(code), subtitle: Text(at));
                      },
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
