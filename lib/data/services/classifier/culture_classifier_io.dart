import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'detection.dart';

/// Envuelve el modelo de IA entrenado (Teachable Machine -> TFLite) ubicado en
/// `modelo/model_unquant.tflite`. Recibe frames de la camara, los preprocesa al
/// formato que espera el modelo (224x224, normalizado a [-1, 1]) y devuelve la
/// cultura detectada con su nivel de confianza.
///
/// Implementa la Funcionalidad Tres del ERS (Realidad Aumentada) usando el
/// reconocimiento visual como detector, en lugar de ingreso manual de datos.
class CultureClassifier {
  static const String _modelAsset = 'modelo/model_unquant.tflite';
  static const String _labelsAsset = 'modelo/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = const [];
  int _inputSize = 224;

  bool get isReady => _interpreter != null;
  List<String> get labels => _labels;

  /// Carga el interprete y las etiquetas desde los assets empaquetados.
  Future<void> load() async {
    final modelBytes = await rootBundle.load(_modelAsset);
    final interpreter = Interpreter.fromBuffer(
      modelBytes.buffer.asUint8List(),
      options: InterpreterOptions()..threads = 2,
    );

    final inputShape = interpreter.getInputTensor(0).shape; // [1, 224, 224, 3]
    if (inputShape.length == 4) {
      _inputSize = inputShape[1];
    }

    _labels = await _loadLabels();
    _interpreter = interpreter;
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelsAsset);
    return raw
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) {
          // Formato Teachable Machine: "0 Otavalo" -> "Otavalo".
          final parts = line.split(RegExp(r'\s+'));
          if (parts.length > 1 && int.tryParse(parts.first) != null) {
            return parts.sublist(1).join(' ');
          }
          return line;
        })
        .toList();
  }

  /// Clasifica un frame de la camara. Devuelve la deteccion mas probable o
  /// `null` si el modelo aun no esta listo o el frame no se pudo procesar.
  ///
  /// [sensorOrientation] (grados) endereza el frame: los sensores Android
  /// suelen entregar la imagen rotada 90, lo que degrada al modelo si no se
  /// corrige antes de la inferencia.
  Detection? classify(CameraImage frame, {int sensorOrientation = 0}) {
    final interpreter = _interpreter;
    if (interpreter == null || _labels.isEmpty) return null;

    var decoded = _frameToImage(frame);
    if (decoded == null) return null;

    if (sensorOrientation % 360 != 0) {
      decoded = img.copyRotate(decoded, angle: sensorOrientation);
    }

    final square = img.copyResizeCropSquare(decoded, size: _inputSize);
    final input = _normalize(square);
    final output = List<double>.filled(
      _labels.length,
      0,
    ).reshape([1, _labels.length]);

    interpreter.run(input, output);

    final raw = (output[0] as List).cast<double>();
    final scores = <String, double>{};
    var bestIndex = 0;
    var bestScore = raw[0];
    for (var i = 0; i < raw.length && i < _labels.length; i++) {
      scores[_labels[i]] = raw[i];
      if (raw[i] > bestScore) {
        bestScore = raw[i];
        bestIndex = i;
      }
    }

    return Detection(
      label: _labels[bestIndex],
      confidence: bestScore,
      scores: scores,
    );
  }

  /// Normaliza la imagen a un tensor [1, size, size, 3] en el rango [0, 1].
  /// (Verificado contra el modelo: da mejores predicciones que [-1, 1]).
  Object _normalize(img.Image image) {
    final buffer = Float32List(_inputSize * _inputSize * 3);
    var index = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[index++] = pixel.r / 255.0;
        buffer[index++] = pixel.g / 255.0;
        buffer[index++] = pixel.b / 255.0;
      }
    }
    return buffer.reshape([1, _inputSize, _inputSize, 3]);
  }

  /// Convierte un [CameraImage] a una imagen RGB segun el formato de la
  /// plataforma (YUV420 en Android, BGRA8888 en iOS).
  img.Image? _frameToImage(CameraImage frame) {
    switch (frame.format.group) {
      case ImageFormatGroup.yuv420:
        return _yuv420ToImage(frame);
      case ImageFormatGroup.bgra8888:
        return _bgra8888ToImage(frame);
      default:
        return null;
    }
  }

  img.Image _bgra8888ToImage(CameraImage frame) {
    return img.Image.fromBytes(
      width: frame.width,
      height: frame.height,
      bytes: frame.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  img.Image _yuv420ToImage(CameraImage frame) {
    final width = frame.width;
    final height = frame.height;
    final yPlane = frame.planes[0];
    final uPlane = frame.planes[1];
    final vPlane = frame.planes[2];

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    final image = img.Image(width: width, height: height);

    for (var y = 0; y < height; y++) {
      final yOffset = y * yRowStride;
      final uvOffset = (y >> 1) * uvRowStride;
      for (var x = 0; x < width; x++) {
        final yValue = yPlane.bytes[yOffset + x];
        final uvIndex = uvOffset + (x >> 1) * uvPixelStride;
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        final r = (yValue + 1.402 * (vValue - 128)).round();
        final g =
            (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
                .round();
        final b = (yValue + 1.772 * (uValue - 128)).round();

        image.setPixelRgb(
          x,
          y,
          r.clamp(0, 255),
          g.clamp(0, 255),
          b.clamp(0, 255),
        );
      }
    }
    return image;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
