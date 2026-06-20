import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<bool> isDevicePremium(String deviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'premium_$deviceId';
    if (prefs.containsKey(cacheKey)) {
      final cached = prefs.getBool(cacheKey) ?? false;
      // still check server in background in real app; here return cached
      return cached;
    }
    final doc = await _db.collection('premiumUsers').doc(deviceId).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    final verified = data['verifiedByAdmin'] as bool? ?? false;
    final expiresAt = (data['expiresAt'] as Timestamp?)?.toDate();
    final now = DateTime.now();
    final active = verified && (expiresAt == null || expiresAt.isAfter(now));
    await prefs.setBool(cacheKey, active);
    return active;
  }

  Future<void> submitPremiumApplication({
    required String deviceId,
    required String upiTransactionId,
    required String planType,
    String? screenshotUrl,
  }) async {
    final docRef = _db.collection('premiumUsers').doc(deviceId);
    await docRef.set({
      'upiTransactionId': upiTransactionId,
      'planType': planType,
      'activatedAt': FieldValue.serverTimestamp(),
      'expiresAt': FieldValue.serverTimestamp(), // admin will set real expiry
      'verifiedByAdmin': false,
      'deviceId': deviceId,
      'screenshotUrl': screenshotUrl,
    });
  }
}
