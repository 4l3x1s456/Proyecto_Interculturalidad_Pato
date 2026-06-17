/// Registro de trazabilidad y progreso de aprendizaje.
///
/// Cubre la Funcionalidad Cuatro (Seguimiento de Progreso) y la regla de
/// auditoria del ERS ("Registro de trazabilidad de operaciones relevantes... en
/// FireBase"). La implementacion por defecto es [NoopTrackingService]; al
/// activar Firebase se usa la version basada en Firestore.
abstract class TrackingService {
  /// El usuario abrio el modulo de una cultura del catalogo.
  Future<void> logModuleView(String cultureId);

  /// El detector AR reconocio una cultura con confianza suficiente.
  Future<void> logArDetection({
    required String label,
    required double confidence,
  });

  /// Finalizo una sesion de Realidad Aumentada.
  Future<void> logArSession({required Duration duration});
}
