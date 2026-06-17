import '../../app/config.dart';

/// Provee URLs de imagenes desde una API publica (Lorem Picsum) para dar
/// dinamismo a la interfaz: fondos, banners y ornamentos.
///
/// El uso de "seed" garantiza que cada pantalla muestre siempre la misma
/// imagen (estabilidad visual) sin almacenar archivos en el repositorio.
class ImageService {
  const ImageService();

  /// Imagen de fondo dinamica y estable para una semilla dada.
  String background(String seed, {int width = 1080, int height = 720}) {
    final safeSeed = Uri.encodeComponent(seed.isEmpty ? 'ecuador' : seed);
    return '${AppConfig.picsumBase}/$safeSeed/$width/$height';
  }

  /// Fondo apaisado pensado para banners/heros.
  String banner(String seed) => background(seed, width: 1200, height: 600);

  /// Miniatura cuadrada para tarjetas y avatares de cultura.
  String thumb(String seed, {int size = 320}) =>
      background(seed, width: size, height: size);
}
