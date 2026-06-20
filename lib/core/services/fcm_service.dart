import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> getToken() => _messaging.getToken();

  Future<void> subscribeToAll() => _messaging.subscribeToTopic('all_users');

  Future<void> subscribeToPremium() => _messaging.subscribeToTopic('premium_users');

  Future<void> unsubscribeFromPremium() => _messaging.unsubscribeFromTopic('premium_users');
}
