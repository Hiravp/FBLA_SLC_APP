import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final supabase = Supabase.instance.client;
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String message = '';
  bool loading = false;

  Future<void> _login() async {
    setState(() => loading = true);
    final response = await supabase.auth.signInWithPassword(
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
    );

    if (response.session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => message = 'Login failed');
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FBLA Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login')),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.red)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('No account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
