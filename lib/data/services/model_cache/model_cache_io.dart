import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Cachea modelos 3D (.glb) en disco para no descargarlos en cada apertura.
///
/// Pensado para modelos grandes (30-40 MB) alojados en Firebase Storage: la
/// primera vez se descargan (con progreso) y se guardan; despues se cargan
/// localmente como `file://...`, que `model_viewer_plus` sirve directamente.
class ModelCache {
  const ModelCache();

  Future<File> _fileFor(String url) async {
    final dir = await getApplicationSupportDirectory();
    final name = '${url.hashCode.toUnsigned(32).toRadixString(16)}.glb';
    return File('${dir.path}/models/$name');
  }

  bool _isRemote(String url) =>
      url.startsWith('http://') || url.startsWith('https://');

  /// Devuelve la fuente lista para el visor. Para assets locales o rutas no-http
  /// la devuelve tal cual (el visor las carga directamente). Para URLs remotas,
  /// descarga una sola vez a disco y devuelve un `file://`.
  Future<String> resolve(String url, {void Function(double)? onProgress}) async {
    if (!_isRemote(url)) return url;
    try {
      final file = await _fileFor(url);
      if (await file.exists() && await file.length() > 0) {
        return Uri.file(file.path).toString();
      }

      await file.parent.create(recursive: true);
      final client = http.Client();
      try {
        final response = await client.send(http.Request('GET', Uri.parse(url)));
        if (response.statusCode != 200) return url;

        final total = response.contentLength ?? 0;
        final sink = file.openWrite();
        var received = 0;
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) onProgress?.call(received / total);
        }
        await sink.close();
        return Uri.file(file.path).toString();
      } finally {
        client.close();
      }
    } catch (_) {
      return url;
    }
  }

  /// Descarga el modelo remoto en segundo plano (precarga). Los assets locales
  /// no requieren precarga.
  Future<void> preload(String url) async {
    if (!_isRemote(url)) return;
    try {
      final file = await _fileFor(url);
      if (await file.exists() && await file.length() > 0) return;
      await resolve(url);
    } catch (_) {}
  }
}
