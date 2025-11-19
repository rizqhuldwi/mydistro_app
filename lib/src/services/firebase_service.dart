import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint("🔥 Firebase berhasil diinisialisasi");
    } catch (e) {
      debugPrint("❌ Gagal inisialisasi Firebase: $e");
      rethrow;
    }
  }
}
