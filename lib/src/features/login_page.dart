import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? selectedRole;
  bool isLoading = false;

  Future<void> _login() async {
    if (selectedRole == null) {
      _showError('Silakan pilih role terlebih dahulu');
      return;
    }

    setState(() => isLoading = true);

    try {
      // 🔹 Login ke Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;
      if (user == null) {
        _showError('Gagal mendapatkan data pengguna');
        return;
      }

      // 🔹 Ambil data role dari Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        _showError('Data pengguna tidak ditemukan di Firestore');
        return;
      }

      String role = userDoc['role'];

      // 🔹 Cek apakah role di Firestore sesuai dengan pilihan login
      if (role != selectedRole) {
        _showError(
            'Role akun tidak sesuai! Akun ini terdaftar sebagai $role, bukan $selectedRole.');
        return;
      }

      // 🔹 Arahkan ke dashboard sesuai role
      if (role == 'admin') {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard_admin');
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard_user');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showError('Akun tidak ditemukan');
      } else if (e.code == 'wrong-password') {
        _showError('Password salah');
      } else {
        _showError('Login gagal: ${e.message}');
      }
    } catch (e) {
      _showError('Terjadi kesalahan: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kesalahan'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.account_circle_rounded, size: 80, color: Color(0xFF8B0000)),
              const SizedBox(height: 12),
              const Text(
                'Selamat Datang',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
              ),
              const Text(
                'MyDistro App',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF8B0000)),
              ),
              const SizedBox(height: 24),

              // Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Role dropdown
              DropdownButtonFormField<String>(
                value: selectedRole,
                hint: const Text('Pilih Role'),
                items: const [
                  DropdownMenuItem(
                      value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(
                      value: 'user', child: Text('User')),
                ],
                onChanged: (value) => setState(() => selectedRole = value),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                ),
              ),
              const SizedBox(height: 24),

              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8B0000),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
