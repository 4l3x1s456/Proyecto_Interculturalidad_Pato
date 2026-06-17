import 'package:camera/camera.dart';

import 'detection.dart';

/// Stub para Web: la deteccion con TFLite no esta disponible en el navegador
/// (depende de `dart:ffi`). La app sigue funcionando: catalogo, APIs publicas y
/// Firebase operan normalmente, pero la deteccion AR queda inactiva.
class CultureClassifier {
  bool get isReady => false;
  List<String> get labels => const [];

  Future<void> load() async {}

  Detection? classify(CameraImage frame, {int sensorOrientation = 0}) => null;

  void dispose() {}
}
