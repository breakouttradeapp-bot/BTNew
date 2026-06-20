import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/firebase_service.dart';

final firebaseServiceProvider = Provider((ref) => FirebaseService());

final chartsStreamProvider = StreamProvider.autoDispose<
    List<QueryDocumentSnapshot<Map<String, dynamic>>>>((ref) {
  final service = ref.watch(firebaseServiceProvider);
  final stream = service.streamCharts();
  final sub = stream;
  return sub.map((snap) => snap.docs).asBroadcastStream().first.then((v) => v).asStream().asyncExpand((_) => stream).map((s) => s.docs).asBroadcastStream();
});
