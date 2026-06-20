import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _local.initialize(initSettings, onDidReceiveNotificationResponse: _onSelectNotification);

    final messaging = FirebaseMessaging.instance;
    if (Platform.isIOS) {
      await messaging.requestPermission(alert: true, badge: true, sound: true);
    }
    final token = await messaging.getToken();
    debugPrint('FCM token: $token');

    FirebaseMessaging.onMessage.listen((message) {
      showLocalNotification(title: message.notification?.title ?? 'BreakoutTrade', body: message.notification?.body ?? '');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // handle click
    });
  }

  Future<void> _onSelectNotification(NotificationResponse response) async {
    // parse payload, navigate if needed
  }

  Future<void> showLocalNotification({required String title, required String body}) async {
    const android = AndroidNotificationDetails('breakouttrade_channel', 'BreakoutTrade', importance: Importance.max, priority: Priority.high);
    const ios = DarwinNotificationDetails();
    const details = NotificationDetails(android: android, iOS: ios);
    await _local.show(0, title, body, details);
  }
}
