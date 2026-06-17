import 'package:flutter/foundation.dart';

import '../data/culture_seed.dart';
import '../data/services/wiki_service.dart';
import '../models/culture.dart';

/// Repositorio de culturas. Mantiene el contenido base (offline) y lo enriquece
/// con la API publica de Wikipedia (resumen e imagenes reales).
///
/// Notifica a la UI cuando llega contenido nuevo, de modo que el catalogo se
/// actualiza progresivamente sin bloquear la primera carga (RNF-001).
class CultureController extends ChangeNotifier {
  CultureController({WikiService? wiki}) : _wiki = wiki ?? WikiService();

  final WikiService _wiki;

  final List<Culture> _cultures = List<Culture>.from(cultureSeed);
  List<Culture> get cultures => List<Culture>.unmodifiable(_cultures);

  bool _enriching = false;
  bool get isEnriching => _enriching;

  /// Evita relanzar el enriquecimiento (se dispara al abrir el catalogo).
  bool _enrichStarted = false;

  /// Busca una cultura por la etiqueta que devuelve el modelo de IA.
  Culture? byModelLabel(String label) {
    final normalized = label.trim().toLowerCase();
    for (final culture in _cultures) {
      if (culture.modelLabel.toLowerCase() == normalized) {
        return culture;
      }
    }
    return null;
  }

  Culture? byId(String id) {
    for (final culture in _cultures) {
      if (culture.id == id) return culture;
    }
    return null;
  }

  /// Descarga resumenes e imagenes de Wikipedia para cada cultura. Si una
  /// peticion falla, se conserva el contenido base correspondiente.
  Future<void> enrich() async {
    if (_enrichStarted || _enriching) return;
    _enrichStarted = true;
    _enriching = true;
    notifyListeners();

    for (var i = 0; i < _cultures.length; i++) {
      final culture = _cultures[i];
      final summary = await _wiki.fetchSummary(culture.wikiTitle);
      if (summary == null) continue;

      _cultures[i] = culture.copyWith(
        summary: summary.extract,
        imageUrl: summary.imageUrl,
        sourceUrl: summary.pageUrl,
      );
      notifyListeners();
    }

    _enriching = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _wiki.dispose();
    super.dispose();
  }
}
