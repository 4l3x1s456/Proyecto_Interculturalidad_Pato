import 'tracking_service.dart';

/// Implementacion sin backend usada mientras Firebase esta desactivado.
///
/// Acepta y descarta los eventos para que la UI pueda registrar trazabilidad
/// sin condicionales; al activar Firebase se sustituye por la version Firestore.
class NoopTrackingService implements TrackingService {
  const NoopTrackingService();

  @override
  Future<void> logModuleView(String cultureId) async {}

  @override
  Future<void> logArDetection({
    required String label,
    required double confidence,
  }) async {}

  @override
  Future<void> logArSession({required Duration duration}) async {}
}
