import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../tracking/tracking_service.dart';

/// Implementacion de [TrackingService] sobre Cloud Firestore.
///
/// Registra eventos de auditoria y progreso en subcolecciones por usuario, de
/// modo que cada quien solo accede a su propio historial (regla del ERS:
/// "Usuarios ven solo su propio historial personalizado"). Lista para activarse
/// con Firebase; ver FIREBASE_SETUP.md para reglas de seguridad e indices.
class FirestoreTrackingService implements TrackingService {
  FirestoreTrackingService({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? _events() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('activity');
  }

  Future<void> _write(Map<String, dynamic> data) async {
    final events = _events();
    if (events == null) return;
    await events.add({...data, 'timestamp': FieldValue.serverTimestamp()});
  }

  @override
  Future<void> logModuleView(String cultureId) =>
      _write({'type': 'module_view', 'cultureId': cultureId});

  @override
  Future<void> logArDetection({
    required String label,
    required double confidence,
  }) => _write({
    'type': 'ar_detection',
    'label': label,
    'confidence': confidence,
  });

  @override
  Future<void> logArSession({required Duration duration}) =>
      _write({'type': 'ar_session', 'durationMs': duration.inMilliseconds});
}
