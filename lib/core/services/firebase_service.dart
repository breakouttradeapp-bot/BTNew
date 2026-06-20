import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCharts({int limit = 20}) {
    return _db
        .collection('charts')
        .where('isActive', isEqualTo: true)
        .orderBy('uploadedAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<String> uploadChartImage(String chartId, Uint8List bytes, String path) async {
    final ref = _storage.ref().child('charts/$chartId/$path');
    final task = await ref.putData(bytes);
    return await ref.getDownloadURL();
  }

  Future<void> createChart(Map<String, dynamic> data) async {
    await _db.collection('charts').add(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getAppConfig() {
    return _db.collection('appConfig').doc('config').get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPremiumUser(String deviceId) {
    return _db.collection('premiumUsers').doc(deviceId).get();
  }
}
