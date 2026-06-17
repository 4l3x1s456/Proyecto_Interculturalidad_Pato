import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../progress/progress_repository.dart';

/// Deriva el progreso del usuario a partir del registro de actividad
/// (`users/{uid}/activity`), que es la fuente de verdad ya persistida por el
/// servicio de trazabilidad. Asi el progreso sobrevive al cierre de la app y se
/// sincroniza entre dispositivos sin depender de un documento agregado aparte.
class FirestoreProgressRepository implements ProgressRepository {
  FirestoreProgressRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? _activity() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('activity');
  }

  ProgressSnapshot _aggregate(QuerySnapshot<Map<String, dynamic>> snap) {
    final viewed = <String>{};
    final detections = <String, int>{};
    for (final doc in snap.docs) {
      final data = doc.data();
      switch (data['type']) {
        case 'module_view':
          final id = data['cultureId'];
          if (id is String) viewed.add(id);
          break;
        case 'ar_detection':
          final label = data['label'];
          if (label is String) {
            detections[label] = (detections[label] ?? 0) + 1;
          }
          break;
      }
    }
    return ProgressSnapshot(
      viewedCultureIds: viewed.toList(),
      detections: detections,
    );
  }

  @override
  Future<ProgressSnapshot?> load() async {
    try {
      final activity = _activity();
      if (activity == null) return null;
      return _aggregate(await activity.get());
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<ProgressSnapshot?> watch() {
    final activity = _activity();
    if (activity == null) return const Stream.empty();
    return activity.snapshots().map(_aggregate).handleError((_) {});
  }

  // El progreso se reconstruye desde `activity`; no se persiste por separado.
  @override
  Future<void> save(ProgressSnapshot snapshot) async {}
}
