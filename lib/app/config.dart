/// Configuracion global y banderas de funcionalidad del prototipo.
///
/// Centraliza endpoints de APIs publicas y el interruptor de Firebase, de modo
/// que activar el backend real sea un cambio de una sola linea una vez creado
/// el proyecto (ver FIREBASE_SETUP.md).
class AppConfig {
  AppConfig._();

  /// Cuando sea `true`, la app inicializa Firebase y usa autenticacion +
  /// Firestore reales. Se mantiene en `false` hasta registrar el proyecto y
  /// generar `firebase_options.dart` con valores validos.
  static const bool useFirebase = true;

  /// API publica de Wikipedia (REST v1) en espanol: resumen e imagenes.
  /// No requiere clave de acceso.
  static const String wikipediaRestBase =
      'https://es.wikipedia.org/api/rest_v1/page/summary';

  /// API publica de imagenes (Lorem Picsum) para fondos dinamicos. Sin clave.
  /// Formato: /seed/{semilla}/{ancho}/{alto}
  static const String picsumBase = 'https://picsum.photos/seed';

  /// Umbral de confianza (sobre las 5 culturas, ya renormalizado) para marcar
  /// una deteccion como "confirmada" en modo general. El modelo entregado es
  /// modesto, por lo que el umbral es permisivo.
  static const double detectionThreshold = 0.45;

  /// Umbral para el modo dirigido (confirmar una unica cultura).
  static const double targetThreshold = 0.40;
}
