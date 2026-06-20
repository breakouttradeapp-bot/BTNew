import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/admob_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/chart_detail/chart_detail_screen.dart';
import 'features/home/home_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/premium/payment_pending_screen.dart';
import 'features/premium/premium_screen.dart';
import 'firebase_options.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // optionally handle background messages
  await NotificationService().showLocalNotification(
    title: message.notification?.title ?? 'BreakoutTrade',
    body: message.notification?.body ?? '',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await AdMobService.initialize();
  await NotificationService().init();
  runApp(const ProviderScope(child: BreakoutTradeApp()));
}

class BreakoutTradeApp extends ConsumerWidget {
  const BreakoutTradeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = buildLightTheme();
    return MaterialApp(
      title: 'BreakoutTrade',
      theme: theme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/premium': (context) => const PremiumScreen(),
        '/payment_pending': (context) => const PaymentPendingScreen(),
        '/chart_detail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is String) {
            return ChartDetailScreen(chartId: args);
          }
          return const Scaffold(body: Center(child: Text('Missing chart id')));
        },
      },
    );
  }
}
