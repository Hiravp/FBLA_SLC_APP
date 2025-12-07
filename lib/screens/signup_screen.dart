import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final supabase = Supabase.instance.client;
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  String message = '';
  bool loading = false;

  Future<void> _signup() async {
    setState(() => loading = true);
    final response = await supabase.auth.signUp(
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text,
    );

    if (response.session != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => message = 'Signup failed');
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FBLA Signup")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: passwordCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _signup, child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Signup')),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
