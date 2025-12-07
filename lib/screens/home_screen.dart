import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'attendance_qr_screen.dart';
import 'announcements_screen.dart';
import 'chat_screen.dart';
import 'members_directory_screen.dart';
import 'points_and_badges_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart'; // <-- make sure you have this

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _navTile(BuildContext context, String title, Widget page, IconData icon) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[900]),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      // Clear navigation stack and go to LoginScreen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FBLA Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _navTile(context, "Announcements", const AnnouncementsScreen(), Icons.announcement),
          _navTile(context, "Attendance", const AttendanceQRScreen(), Icons.qr_code),
          _navTile(context, "Chat", const ChatScreen(), Icons.chat),
          _navTile(context, "Members", const MembersDirectoryScreen(), Icons.people),
          _navTile(context, "Points & Badges", const PointsAndBadgesScreen(), Icons.star),
          _navTile(context, "Profile", const ProfileScreen(), Icons.person),
        ],
      ),
    );
  }
}
