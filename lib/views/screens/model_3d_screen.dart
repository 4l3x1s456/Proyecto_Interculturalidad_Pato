import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../data/services/model_cache/model_cache.dart';
import '../../models/culture.dart';

/// Visor de modelos 3D con opcion de Realidad Aumentada (RNF-007 del ERS).
///
/// El modelo `.glb` se cachea en disco la primera vez (descarga con progreso) y
/// luego se carga localmente, de modo que abrir el visor de nuevo es inmediato
/// aunque el modelo sea grande (30-40 MB en Firebase Storage).
class Model3DScreen extends StatefulWidget {
  const Model3DScreen({super.key, required this.culture});

  final Culture culture;

  @override
  State<Model3DScreen> createState() => _Model3DScreenState();
}

class _Model3DScreenState extends State<Model3DScreen> {
  final ModelCache _cache = const ModelCache();
  String? _src;
  double _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final url = widget.culture.model3dUrl;
    if (url == null) {
      setState(() => _failed = true);
      return;
    }
    final resolved = await _cache.resolve(
      url,
      onProgress: (value) {
        if (mounted) setState(() => _progress = value);
      },
    );
    if (mounted) setState(() => _src = resolved);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modelo 3D - ${widget.culture.name}')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_failed) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Esta cultura aun no tiene un modelo 3D asignado.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final src = _src;
    if (src == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(
                value: _progress > 0 ? _progress : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _progress > 0
                  ? 'Descargando modelo... ${(_progress * 100).toStringAsFixed(0)}%'
                  : 'Preparando modelo 3D...',
            ),
          ],
        ),
      );
    }

    return ModelViewer(
      src: src,
      alt: 'Modelo 3D de ${widget.culture.name}',
      ar: true,
      arModes: const ['scene-viewer', 'webxr', 'quick-look'],
      autoRotate: true,
      cameraControls: true,
      disableZoom: false,
      backgroundColor: const Color(0xFFEFE9DE),
    );
  }
}
