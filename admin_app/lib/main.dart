import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/login_screen.dart';
import 'screens/upload_chart_screen.dart';
import 'screens/send_notification_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptionsAdmin.currentPlatform);
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreakoutTrade Admin',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C853))),
      initialRoute: '/login',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/login': (context) => const LoginScreen(),
        '/upload': (context) => const UploadChartScreen(),
        '/send': (context) => const SendNotificationScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/upload'),
            child: const Text('Upload Chart'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.pushNamed(context, '/send'), child: const Text('Send Notification')),
        ]),
      ),
    );
  }
}
