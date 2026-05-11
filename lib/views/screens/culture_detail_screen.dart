import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/culture.dart';
import '../widgets/ar_preview_card.dart';
import '../widgets/culture_section_card.dart';
import '../widgets/region_chip.dart';
import '../widgets/section_header.dart';

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
            flexibleSpace: FlexibleSpaceBar(
              title: Text(culture.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.header(culture.accentColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
                        Hero(
                          tag: culture.id,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.16),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              culture.icon,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            culture.region,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                      const RegionChip(
                        label: 'ARCore listo',
                        color: AppColors.secondary,
                        icon: Icons.camera,
                      ),
                      const RegionChip(
                        label: 'Firebase pendiente',
                        color: AppColors.primary,
                        icon: Icons.cloud_queue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  ARPreviewCard(culture: culture),
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
