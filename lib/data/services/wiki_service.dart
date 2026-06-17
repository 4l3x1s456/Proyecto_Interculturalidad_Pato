import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../app/config.dart';

/// Resultado del enriquecimiento de una cultura desde Wikipedia.
class WikiSummary {
  const WikiSummary({
    required this.title,
    required this.extract,
    this.imageUrl,
    this.pageUrl,
  });

  final String title;
  final String extract;
  final String? imageUrl;
  final String? pageUrl;
}

/// Cliente de la API publica de Wikipedia (REST v1, espanol).
///
/// Cumple con la regla del ERS de no permitir el ingreso manual de datos sobre
/// las culturas: el contenido descriptivo y las imagenes provienen de una
/// fuente publica verificable. Ante un fallo de red devuelve `null` y la app
/// continua con el contenido base (modo offline, RNF-005).
class WikiService {
  WikiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<WikiSummary?> fetchSummary(String title) async {
    final encoded = Uri.encodeComponent(title.replaceAll(' ', '_'));
    final uri = Uri.parse('${AppConfig.wikipediaRestBase}/$encoded');

    try {
      final response = await _client
          .get(uri, headers: const {'accept': 'application/json'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;

      final extract = (data['extract'] as String?)?.trim();
      if (extract == null || extract.isEmpty) {
        return null;
      }

      final originalImage =
          (data['originalimage'] as Map<String, dynamic>?)?['source'] as String?;
      final thumbnail =
          (data['thumbnail'] as Map<String, dynamic>?)?['source'] as String?;
      final pageUrl = ((data['content_urls'] as Map<String, dynamic>?)?['desktop']
              as Map<String, dynamic>?)?['page']
          as String?;

      return WikiSummary(
        title: (data['title'] as String?) ?? title,
        extract: extract,
        imageUrl: originalImage ?? thumbnail,
        pageUrl: pageUrl,
      );
    } catch (_) {
      // Sin conexion o respuesta invalida: se mantiene el contenido base.
      return null;
    }
  }

  void dispose() => _client.close();
}
