import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance_qr_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/officer_dashboard.dart';
import 'screens/members_directory_screen.dart';
import 'screens/points_and_badges_screen.dart';
import 'screens/announcements_screen.dart';
import 'screens/admin_portal_screen.dart';
import 'screens/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FBLA Member App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
            .copyWith(secondary: Colors.orangeAccent),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF003366),
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          elevation: 4,
          margin: EdgeInsets.all(12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFFA500),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.indigo),
          bodyMedium: TextStyle(fontSize: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/attendance': (context) => const AttendanceQRScreen(),
        '/chat': (context) => const ChatScreen(),
        '/officer': (context) => const OfficerDashboard(),
        '/members': (context) => const MembersDirectoryScreen(),
        '/points': (context) => const PointsAndBadgesScreen(),
        '/announcements': (context) => const AnnouncementsScreen(),
        '/admin': (context) => const AdminPortalScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
