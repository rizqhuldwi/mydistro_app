import 'package:flutter/material.dart';
import 'features/login_page.dart'; // opsional, tergantung strukturmu

class DistroApp extends StatelessWidget {
  const DistroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DistroApp',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const LoginPage(), // ganti dengan halaman awalmu
    );
  }
}
