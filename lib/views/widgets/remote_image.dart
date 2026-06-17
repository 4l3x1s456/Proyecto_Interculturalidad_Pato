import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// Imagen de red con estados de carga y error.
///
/// Centraliza el consumo de imagenes de APIs publicas (Wikipedia / Lorem
/// Picsum) y degrada de forma elegante a un marcador cuando no hay conexion
/// (RNF-005: modo offline).
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.fallbackColor,
    this.fallbackIcon = Icons.image_not_supported_outlined,
  });

  final String? url;
  final BoxFit fit;
  final Color? fallbackColor;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final url = this.url;
    if (url == null || url.isEmpty) {
      return _placeholder(context);
    }

    return Image.network(
      url,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _placeholder(context, loading: true);
      },
      errorBuilder: (context, error, stackTrace) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context, {bool loading = false}) {
    final color = fallbackColor ?? AppColors.primary;
    return Container(
      color: color.withOpacity(0.12),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(fallbackIcon, color: color.withOpacity(0.5), size: 32),
    );
  }
}
