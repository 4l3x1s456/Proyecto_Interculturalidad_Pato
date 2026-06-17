import 'package:flutter/material.dart';

import 'culture_section.dart';

/// Representa una cultura/nacionalidad del Ecuador dentro del catalogo.
///
/// Los campos [wikiTitle] y [modelLabel] conectan la entidad con las fuentes
/// externas del sistema: la API publica de Wikipedia (enriquecimiento de
/// contenido e imagenes) y el modelo de IA entrenado (deteccion por camara).
class Culture {
  const Culture({
    required this.id,
    required this.name,
    required this.region,
    required this.summary,
    required this.accentColor,
    required this.icon,
    required this.sections,
    required this.wikiTitle,
    required this.modelLabel,
    required this.motif,
    this.language,
    this.imageUrl,
    this.sourceUrl,
    this.model3dUrl,
  });

  final String id;
  final String name;
  final String region;
  final String summary;
  final Color accentColor;
  final IconData icon;
  final List<CultureSection> sections;

  /// Titulo del articulo en la Wikipedia en espanol usado para enriquecer
  /// el contenido y obtener imagenes reales del pueblo.
  final String wikiTitle;

  /// Etiqueta que produce el modelo de IA (`modelo/labels.txt`) al detectar
  /// esta cultura mediante la camara.
  final String modelLabel;

  /// Emoji representativo de la cultura usado como emblema visual.
  final String motif;

  /// URL de un modelo 3D (.glb) para visualizacion 3D/AR (RNF-007).
  /// Nullable: una cultura puede no tener modelo asignado todavia.
  final String? model3dUrl;

  /// Lengua ancestral asociada (para internacionalizacion, RNF-008).
  final String? language;

  /// Imagen remota obtenida de la API publica (se completa en tiempo de
  /// ejecucion). Es nullable para soportar el modo offline (RNF-005).
  final String? imageUrl;

  /// Enlace a la fuente publica del contenido (Wikipedia).
  final String? sourceUrl;

  Culture copyWith({
    String? summary,
    String? imageUrl,
    String? sourceUrl,
    List<CultureSection>? sections,
  }) {
    return Culture(
      id: id,
      name: name,
      region: region,
      summary: summary ?? this.summary,
      accentColor: accentColor,
      icon: icon,
      sections: sections ?? this.sections,
      wikiTitle: wikiTitle,
      modelLabel: modelLabel,
      motif: motif,
      model3dUrl: model3dUrl,
      language: language,
      imageUrl: imageUrl ?? this.imageUrl,
      sourceUrl: sourceUrl ?? this.sourceUrl,
    );
  }
}
