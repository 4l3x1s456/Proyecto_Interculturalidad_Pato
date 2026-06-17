import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show DeviceOrientation, SystemChrome;
import 'package:permission_handler/permission_handler.dart';

import '../../app/app_scope.dart';
import '../../app/config.dart';
import '../../app/theme.dart';
import '../../controllers/progress_controller.dart';
import '../../data/services/classifier/culture_classifier.dart';
import '../../data/services/tracking/noop_tracking_service.dart';
import '../../data/services/tracking/tracking_service.dart';
import '../../models/culture.dart';
import 'culture_detail_screen.dart';

/// Pantalla de Realidad Aumentada (Funcionalidad Tres del ERS).
///
/// Activa la camara y ejecuta el modelo de IA sobre el stream de video.
///
/// - Modo **general** ([targetCulture] == null): clasifica entre las 5 culturas
///   (se abre desde la pestana Camara del menu principal).
/// - Modo **dirigido** ([targetCulture] != null): solo confirma si lo que ve la
///   camara corresponde a esa cultura (se abre desde "Abrir detector AR").
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.targetCulture});

  /// Cultura a confirmar en modo dirigido. Si es null, el modo es general.
  final Culture? targetCulture;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final CultureClassifier _classifier = CultureClassifier();

  CameraController? _controller;
  bool _initializing = true;
  bool _streaming = false;
  bool _busy = false;
  String? _error;

  Detection? _detection;
  DateTime _lastRun = DateTime.fromMillisecondsSinceEpoch(0);
  int _sensorOrientation = 0;

  // Suaviza la deteccion promediando las ultimas N inferencias: evita el
  // parpadeo entre culturas y da un resultado mas estable.
  final List<Map<String, double>> _scoreHistory = [];
  static const int _historySize = 5;

  // Etiquetas validas (las 5 culturas del catalogo). Se excluyen clases del
  // modelo que no son culturas objetivo (p. ej. "chachi"), que actuan como
  // ruido y solian ganar la prediccion.
  Set<String> _validLabels = const {};

  TrackingService _tracking = const NoopTrackingService();
  ProgressController? _progress;
  String? _lastLoggedLabel;
  DateTime? _sessionStart;

  static const Duration _throttle = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    // Fija la orientacion vertical: el usuario apunta sin girar el telefono y
    // el modelo recibe siempre la imagen en la misma orientacion.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _bootstrap();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scope = AppScope.of(context);
    _tracking = scope.tracking;
    _progress = scope.progress;
    _validLabels = scope.repository.cultures
        .map((c) => c.modelLabel.toLowerCase())
        .toSet();
  }

  Future<void> _bootstrap() async {
    try {
      // En Web el navegador gestiona el permiso de camara; permission_handler
      // no soporta la camara en Web, por lo que se omite ahi.
      if (!kIsWeb) {
        final status = await Permission.camera.request();
        if (!mounted) return;
        if (!status.isGranted) {
          setState(() {
            _error = 'Se necesita permiso de camara para la experiencia AR.';
            _initializing = false;
          });
          return;
        }
      }

      await _classifier.load();

      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        setState(() {
          _error = 'No se encontraron camaras disponibles.';
          _initializing = false;
        });
        return;
      }

      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      _controller = controller;
      _sensorOrientation = controller.description.sensorOrientation;
      setState(() => _initializing = false);
      await _startDetection();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo iniciar la camara o el modelo de IA.';
        _initializing = false;
      });
    }
  }

  Future<void> _startDetection() async {
    final controller = _controller;
    if (controller == null || _streaming || !_classifier.isReady) return;

    await controller.startImageStream(_onFrame);
    _sessionStart = DateTime.now();
    if (mounted) setState(() => _streaming = true);
  }

  void _onFrame(CameraImage frame) {
    if (_busy) return;
    final now = DateTime.now();
    if (now.difference(_lastRun) < _throttle) return;

    _busy = true;
    _lastRun = now;

    // La inferencia es sincrona; el throttle evita saturar el hilo de UI.
    Detection? result;
    try {
      result = _classifier.classify(
        frame,
        sensorOrientation: _sensorOrientation,
      );
    } catch (_) {
      result = null;
    }

    if (mounted && result != null && result.scores.isNotEmpty) {
      final smoothed = _pushAndSmooth(result.scores);
      setState(() => _detection = smoothed);
      _maybeRecord(smoothed);
    }
    _busy = false;
  }

  /// Promedia las ultimas inferencias, descarta clases que no son culturas
  /// objetivo (p. ej. "chachi") y renormaliza sobre las 5 culturas. Esto
  /// estabiliza el resultado y vuelve la confianza interpretable.
  Detection _pushAndSmooth(Map<String, double> scores) {
    _scoreHistory.add(scores);
    if (_scoreHistory.length > _historySize) {
      _scoreHistory.removeAt(0);
    }

    final averaged = <String, double>{};
    for (final entry in _scoreHistory) {
      entry.forEach((label, value) {
        averaged[label] = (averaged[label] ?? 0) + value;
      });
    }
    final count = _scoreHistory.length;
    averaged.updateAll((label, value) => value / count);

    // Conserva solo las culturas del catalogo y renormaliza a suma 1.
    final filtered = <String, double>{};
    var sum = 0.0;
    averaged.forEach((label, value) {
      if (_validLabels.isEmpty || _validLabels.contains(label.toLowerCase())) {
        filtered[label] = value;
        sum += value;
      }
    });
    if (sum > 0) {
      filtered.updateAll((label, value) => value / sum);
    }

    final source = filtered.isEmpty ? averaged : filtered;
    var topLabel = source.keys.first;
    var topScore = -1.0;
    source.forEach((label, value) {
      if (value > topScore) {
        topScore = value;
        topLabel = label;
      }
    });

    return Detection(label: topLabel, confidence: topScore, scores: source);
  }

  /// Registra una deteccion (progreso + trazabilidad) segun el modo activo.
  void _maybeRecord(Detection result) {
    final target = widget.targetCulture;

    if (target != null) {
      // Modo dirigido: solo cuenta si confirma la cultura enfocada.
      final score = result.scoreFor(target.modelLabel);
      final matched =
          result.label.toLowerCase() == target.modelLabel.toLowerCase() &&
          score >= AppConfig.targetThreshold;
      if (matched && _lastLoggedLabel != target.modelLabel) {
        _lastLoggedLabel = target.modelLabel;
        _progress?.recordArDetection(target.modelLabel);
        _tracking.logArDetection(label: target.modelLabel, confidence: score);
      }
      return;
    }

    // Modo general: cualquiera de las 5 culturas por encima del umbral.
    if (result.confidence >= AppConfig.detectionThreshold &&
        result.label != _lastLoggedLabel) {
      _lastLoggedLabel = result.label;
      _progress?.recordArDetection(result.label);
      _tracking.logArDetection(
        label: result.label,
        confidence: result.confidence,
      );
    }
  }

  @override
  void dispose() {
    // Restaura las orientaciones al salir de la camara.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    final sessionStart = _sessionStart;
    if (sessionStart != null) {
      _tracking.logArSession(
        duration: DateTime.now().difference(sessionStart),
      );
    }
    final controller = _controller;
    if (controller != null) {
      if (_streaming && controller.value.isStreamingImages) {
        controller.stopImageStream();
      }
      controller.dispose();
    }
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializing) {
      return const _CameraMessage(
        icon: Icons.camera,
        message: 'Preparando camara y modelo de IA...',
        showSpinner: true,
      );
    }

    if (_error != null) {
      return _CameraMessage(
        icon: Icons.no_photography,
        message: _error!,
        action: TextButton.icon(
          onPressed: openAppSettings,
          icon: const Icon(Icons.settings),
          label: const Text('Abrir ajustes'),
        ),
      );
    }

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const _CameraMessage(
        icon: Icons.camera,
        message: 'Inicializando vista...',
        showSpinner: true,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        const _ScannerFrame(),
        _DetectionOverlay(
          detection: _detection,
          aiAvailable: _classifier.isReady,
          targetCulture: widget.targetCulture,
        ),
      ],
    );
  }
}

/// Marco tipo "scanner" para guiar al usuario sobre donde apuntar.
class _ScannerFrame extends StatelessWidget {
  const _ScannerFrame();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

/// Tarjeta inferior que muestra la deteccion del modelo en tiempo real.
class _DetectionOverlay extends StatelessWidget {
  const _DetectionOverlay({
    required this.detection,
    required this.aiAvailable,
    this.targetCulture,
  });

  final Detection? detection;
  final bool aiAvailable;
  final Culture? targetCulture;

  @override
  Widget build(BuildContext context) {
    final detection = this.detection;
    final repository = AppScope.of(context).repository;

    if (!aiAvailable) {
      return Positioned(
        left: 16,
        right: 16,
        bottom: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.white70),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La deteccion con IA esta disponible en Android/iOS. '
                  'En Web puedes explorar el catalogo y el resto de la app.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Modo dirigido: confirmar una sola cultura.
    final target = targetCulture;
    if (target != null) {
      final score = detection?.scoreFor(target.modelLabel) ?? 0;
      final isTarget =
          detection != null &&
          detection.label.toLowerCase() == target.modelLabel.toLowerCase();
      final matched = isTarget && score >= AppConfig.targetThreshold;

      return Positioned(
        left: 16,
        right: 16,
        bottom: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    matched ? Icons.check_circle : Icons.center_focus_weak,
                    color: matched ? const Color(0xFF22C55E) : Colors.white70,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      detection == null
                          ? 'Apunta a una escena de ${target.name}'
                          : matched
                          ? '¡Es ${target.name}!'
                          : 'Buscando ${target.name}...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: score.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: matched ? const Color(0xFF22C55E) : AppColors.secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Coincidencia con ${target.name}: '
                '${(score * 100).toStringAsFixed(0)}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    final bool confident =
        detection != null && detection.confidence >= AppConfig.detectionThreshold;
    // Mejor candidato entre las 5 culturas (siempre disponible para avanzar).
    final Culture? top =
        detection != null ? repository.byModelLabel(detection.label) : null;

    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  confident ? Icons.auto_awesome : Icons.center_focus_weak,
                  color: confident ? AppColors.secondary : Colors.white70,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    detection == null
                        ? 'Apunta la camara a una vestimenta o escena cultural'
                        : confident
                        ? 'Cultura detectada: ${top?.name ?? detection.label}'
                        : 'Posible: ${top?.name ?? detection.label}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            if (detection != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: detection.confidence.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: confident ? AppColors.secondary : Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Confianza: ${(detection.confidence * 100).toStringAsFixed(0)}%',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
            if (top != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CultureDetailScreen(culture: top),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book),
                  label: Text('Ver modulo: ${top.name}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({
    required this.icon,
    required this.message,
    this.action,
    this.showSpinner = false,
  });

  final IconData icon;
  final String message;
  final Widget? action;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSoft),
            ),
            if (showSpinner) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
