import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../data/services/model_cache/model_cache.dart';
import '../../models/culture.dart';
import '../widgets/ar_preview_card.dart';
import '../widgets/culture_section_card.dart';
import '../widgets/region_chip.dart';
import '../widgets/remote_image.dart';
import '../widgets/section_header.dart';
import 'model_3d_screen.dart';

class CultureDetailScreen extends StatelessWidget {
  const CultureDetailScreen({super.key, required this.culture});

  final Culture culture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: culture.accentColor,
            foregroundColor: Colors.white,
            title: Text(culture.name),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen real del pueblo obtenida de Wikipedia.
                  RemoteImage(
                    url: culture.imageUrl,
                    fallbackColor: culture.accentColor,
                    fallbackIcon: culture.icon,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.header(culture.accentColor),
                    ),
                  ),
                  Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: culture.id,
                          child: Stack(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: RemoteImage(
                                  url: culture.imageUrl,
                                  fallbackColor: culture.accentColor,
                                  fallbackIcon: culture.icon,
                                ),
                              ),
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    culture.motif,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                culture.region,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                culture.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    culture.summary,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      RegionChip(
                        label: culture.region,
                        color: culture.accentColor,
                      ),
                      if (culture.language != null)
                        RegionChip(
                          label: 'Lengua: ${culture.language}',
                          color: culture.accentColor,
                          icon: Icons.translate,
                        ),
                      const RegionChip(
                        label: 'Deteccion AR',
                        color: AppColors.secondary,
                        icon: Icons.camera,
                      ),
                    ],
                  ),
                  if (culture.sourceUrl != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.public,
                          size: 14,
                          color: AppColors.textSoft,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Fuente: Wikipedia',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSoft),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  ARPreviewCard(culture: culture),
                  if (culture.model3dUrl != null) ...[
                    const SizedBox(height: 12),
                    _Model3DCard(culture: culture),
                  ],
                  const SizedBox(height: 18),
                  const SectionHeader(
                    title: 'Contenido cultural',
                    subtitle:
                        'Tradiciones, vestimenta, gastronomia e historia.',
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CultureSectionCard(section: culture.sections[index]),
                ),
                childCount: culture.sections.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta que abre el visor de modelos 3D / AR (RNF-007).
///
/// Al mostrarse, precarga el modelo en segundo plano para que el visor abra
/// de inmediato (clave con modelos grandes alojados en Firebase Storage).
class _Model3DCard extends StatefulWidget {
  const _Model3DCard({required this.culture});

  final Culture culture;

  @override
  State<_Model3DCard> createState() => _Model3DCardState();
}

class _Model3DCardState extends State<_Model3DCard> {
  @override
  void initState() {
    super.initState();
    final url = widget.culture.model3dUrl;
    if (url != null) {
      const ModelCache().preload(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    final culture = widget.culture;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: culture.accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.threed_rotation, color: culture.accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modelo 3D interactivo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explora un objeto en 3D y proyectalo en tu entorno con '
                    'Realidad Aumentada. (Modelo de demostracion).',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Model3DScreen(culture: culture),
                        ),
                      );
                    },
                    icon: const Icon(Icons.view_in_ar),
                    label: const Text('Ver en 3D / AR'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
