/// Resultado de una deteccion del modelo de IA.
///
/// Tipo compartido entre la implementacion nativa (TFLite) y el stub web.
class Detection {
  const Detection({
    required this.label,
    required this.confidence,
    this.scores = const {},
  });

  /// Etiqueta con mayor probabilidad.
  final String label;

  /// Probabilidad de la etiqueta ganadora (0..1).
  final double confidence;

  /// Probabilidad de cada etiqueta del modelo (label -> 0..1). Permite el modo
  /// dirigido (confianza de una cultura concreta) ademas del modo general.
  final Map<String, double> scores;

  /// Confianza para una etiqueta concreta (busqueda sin distinguir mayusculas).
  double scoreFor(String targetLabel) {
    final lower = targetLabel.toLowerCase();
    for (final entry in scores.entries) {
      if (entry.key.toLowerCase() == lower) return entry.value;
    }
    return 0;
  }
}
