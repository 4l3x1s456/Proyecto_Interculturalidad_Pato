import 'dart:async';

import 'package:flutter/material.dart';

import '../data/services/progress/progress_repository.dart';

/// Un logro desbloqueable por el usuario.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
}

/// Una entrada del historial de actividad.
class ActivityEntry {
  ActivityEntry({required this.title, required this.icon, required this.time});

  final String title;
  final IconData icon;
  final DateTime time;
}

/// Seguimiento de progreso de aprendizaje (Funcionalidad Cuatro del ERS).
///
/// Mantiene en memoria las culturas exploradas, las detecciones AR realizadas,
/// los logros alcanzados y un historial reciente. Tambien alimenta el
/// "indicador de progreso personal" del catalogo (Funcionalidad Dos). Cuando se
/// active Firebase, estos mismos eventos se persisten via Firestore.
class ProgressController extends ChangeNotifier {
  ProgressController({
    int totalCultures = 0,
    ProgressRepository repository = const LocalProgressRepository(),
  }) : _totalCultures = totalCultures,
       _repository = repository;

  final ProgressRepository _repository;
  final Set<String> _viewedCultureIds = {};
  final Map<String, int> _detections = {};
  final List<ActivityEntry> _recent = [];
  int _totalCultures;
  StreamSubscription<ProgressSnapshot?>? _subscription;

  /// Suscribe el progreso en tiempo real (al iniciar sesion). El listener de
  /// Firestore emite el estado actual de inmediato y en cada cambio, lo que
  /// resuelve los problemas de sincronizacion entre web y movil.
  Future<void> startSync() async {
    await _subscription?.cancel();
    _subscription = _repository.watch().listen(_applyRemote);
  }

  /// Fusiona el estado remoto con el local (no borra avances locales recientes).
  void _applyRemote(ProgressSnapshot? snapshot) {
    if (snapshot == null) return;
    _viewedCultureIds.addAll(snapshot.viewedCultureIds);
    snapshot.detections.forEach((label, count) {
      final current = _detections[label] ?? 0;
      if (count > current) _detections[label] = count;
    });
    notifyListeners();
  }

  /// Carga unica del progreso persistido (alternativa a [startSync]).
  Future<void> load() async {
    final snapshot = await _repository.load();
    if (snapshot != null) _applyRemote(snapshot);
  }

  /// Limpia el progreso en memoria y detiene la sincronizacion (al cerrar
  /// sesion).
  void clear() {
    _subscription?.cancel();
    _subscription = null;
    _viewedCultureIds.clear();
    _detections.clear();
    _recent.clear();
    notifyListeners();
  }

  void _persist() {
    _repository.save(
      ProgressSnapshot(
        viewedCultureIds: _viewedCultureIds.toList(),
        detections: Map<String, int>.from(_detections),
      ),
    );
  }

  int get totalCultures => _totalCultures;
  set totalCultures(int value) {
    if (value == _totalCultures) return;
    _totalCultures = value;
    notifyListeners();
  }

  int get exploredCount => _viewedCultureIds.length;
  double get explorationProgress =>
      _totalCultures == 0 ? 0 : exploredCount / _totalCultures;

  int get totalDetections =>
      _detections.values.fold(0, (sum, count) => sum + count);
  int get distinctDetections => _detections.length;

  List<ActivityEntry> get recentActivity => List.unmodifiable(_recent);

  bool hasViewed(String cultureId) => _viewedCultureIds.contains(cultureId);

  void recordModuleView(String cultureId, String cultureName) {
    final isNew = _viewedCultureIds.add(cultureId);
    if (isNew) {
      _addActivity('Exploraste $cultureName', Icons.menu_book);
    }
    notifyListeners();
    _persist();
  }

  void recordArDetection(String label) {
    _detections[label] = (_detections[label] ?? 0) + 1;
    _addActivity('Detectaste "$label" con la camara', Icons.camera_alt);
    notifyListeners();
    _persist();
  }

  void _addActivity(String title, IconData icon) {
    _recent.insert(
      0,
      ActivityEntry(title: title, icon: icon, time: DateTime.now()),
    );
    if (_recent.length > 15) {
      _recent.removeRange(15, _recent.length);
    }
  }

  List<Achievement> get achievements => [
    Achievement(
      id: 'first_contact',
      title: 'Primer contacto',
      description: 'Explora tu primera cultura',
      icon: Icons.flag,
      unlocked: exploredCount >= 1,
    ),
    Achievement(
      id: 'explorer',
      title: 'Explorador',
      description: 'Explora 3 culturas',
      icon: Icons.explore,
      unlocked: exploredCount >= 3,
    ),
    Achievement(
      id: 'guardian',
      title: 'Guardian de la diversidad',
      description: 'Explora todas las culturas',
      icon: Icons.workspace_premium,
      unlocked: _totalCultures > 0 && exploredCount >= _totalCultures,
    ),
    Achievement(
      id: 'ar_first',
      title: 'Detector AR',
      description: 'Reconoce una cultura con la camara',
      icon: Icons.camera_alt,
      unlocked: totalDetections >= 1,
    ),
    Achievement(
      id: 'ar_trained',
      title: 'Ojo entrenado',
      description: 'Realiza 5 detecciones AR',
      icon: Icons.visibility,
      unlocked: totalDetections >= 5,
    ),
  ];

  int get unlockedAchievements =>
      achievements.where((a) => a.unlocked).length;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
