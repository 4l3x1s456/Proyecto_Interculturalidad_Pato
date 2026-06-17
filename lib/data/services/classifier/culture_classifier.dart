// Punto de entrada del clasificador de culturas.
//
// Usa importacion condicional: en plataformas con `dart:io` (Android, iOS,
// escritorio) carga la implementacion real basada en TFLite; en Web carga un
// stub vacio, ya que `tflite_flutter` depende de `dart:ffi`, que no existe en
// el navegador. Asi el proyecto compila y se ejecuta en Web.
export 'detection.dart';
export 'culture_classifier_stub.dart'
    if (dart.library.io) 'culture_classifier_io.dart';
