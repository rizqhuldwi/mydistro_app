import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // LOGIN
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint("✅ Login berhasil: ${userCredential.user?.email}");
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("❌ Login gagal: ${e.message}");
      rethrow;
    }
  }

  // LOGOUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      debugPrint("👋 Logout berhasil");
    } catch (e) {
      debugPrint("❌ Logout gagal: $e");
      rethrow;
    }
  }

  // CEK USER AKTIF
  User? get currentUser => _auth.currentUser;

  // STREAM PERUBAHAN STATUS USER
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
