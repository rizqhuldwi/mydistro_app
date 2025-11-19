import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projek/firebase_options.dart';
import 'package:projek/src/features/admin/dashboard/admin_dashboard.dart';
import 'package:projek/src/features/login_page.dart';
import 'package:projek/src/features/register_page.dart';
import 'package:projek/src/features/users/dashboard/dashboard_page.dart';
import 'src/services/firebase_service.dart';
import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initializeFirebase();
  runApp(const DistroApp());
}


class DistroApp extends StatelessWidget {
  const DistroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Role App',
      routes: routes,
      initialRoute: '/login',
      home: const LoginPage(),
    );
  }
}



final Map<String, WidgetBuilder> routes = {
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/dashboard_admin': (context) => const AdminDashboardPage(),
  '/dashboard_user': (context) => const DashboardPage(),
};
