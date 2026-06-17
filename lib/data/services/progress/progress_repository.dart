/// Estado de progreso persistible del usuario.
class ProgressSnapshot {
  const ProgressSnapshot({
    required this.viewedCultureIds,
    required this.detections,
  });

  final List<String> viewedCultureIds;
  final Map<String, int> detections;
}

/// Persistencia del progreso (Funcionalidad Cuatro del ERS).
///
/// Implementacion local (sin backend) por defecto; con Firebase activo se usa
/// `FirestoreProgressRepository`, lo que permite sincronizar el progreso entre
/// dispositivos (web y movil) con la misma cuenta.
abstract class ProgressRepository {
  Future<ProgressSnapshot?> load();
  Future<void> save(ProgressSnapshot snapshot);

  /// Emite el progreso del usuario en tiempo real (cambios desde cualquier
  /// dispositivo). Las implementaciones sin backend pueden no emitir nada.
  Stream<ProgressSnapshot?> watch();
}

/// No persiste nada (prototipo sin Firebase).
class LocalProgressRepository implements ProgressRepository {
  const LocalProgressRepository();

  @override
  Future<ProgressSnapshot?> load() async => null;

  @override
  Future<void> save(ProgressSnapshot snapshot) async {}

  @override
  Stream<ProgressSnapshot?> watch() => const Stream.empty();
}
