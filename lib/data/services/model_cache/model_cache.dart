// Cache de modelos 3D (.glb).
//
// Importacion condicional: en Web no hay sistema de archivos, asi que se usa la
// URL de red directamente; en Android/iOS/escritorio se descarga una sola vez a
// disco y luego se sirve como archivo local (carga rapida, sin re-descargar).
export 'model_cache_stub.dart'
    if (dart.library.io) 'model_cache_io.dart';
