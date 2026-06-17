import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../models/culture.dart';
import '../screens/culture_detail_screen.dart';
import 'region_chip.dart';
import 'remote_image.dart';

class CultureCard extends StatelessWidget {
  const CultureCard({
    super.key,
    required this.culture,
    required this.index,
    this.explored = false,
  });

  final Culture culture;
  final int index;

  /// Indicador de progreso personal (Funcionalidad Dos del ERS).
  final bool explored;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            final scope = AppScope.of(context);
            // Progreso personal + trazabilidad (no-op sin Firebase).
            scope.progress.recordModuleView(culture.id, culture.name);
            scope.tracking.logModuleView(culture.id);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CultureDetailScreen(culture: culture),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: culture.id,
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: culture.imageUrl != null
                              ? RemoteImage(
                                  url: culture.imageUrl,
                                  fallbackColor: culture.accentColor,
                                  fallbackIcon: culture.icon,
                                )
                              : Container(
                                  color: culture.accentColor.withOpacity(0.15),
                                  child: Icon(
                                    culture.icon,
                                    color: culture.accentColor,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            culture.motif,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        culture.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        culture.summary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSoft,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          RegionChip(
                            label: culture.region,
                            color: culture.accentColor,
                          ),
                          if (explored)
                            const RegionChip(
                              label: 'Explorado',
                              color: Color(0xFF16A34A),
                              icon: Icons.check_circle,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
