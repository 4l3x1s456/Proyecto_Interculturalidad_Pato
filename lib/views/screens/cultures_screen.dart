import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../widgets/culture_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/section_header.dart';

class CulturesScreen extends StatelessWidget {
  const CulturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cultures = AppScope.of(context).repository.cultures;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const HeroBanner(),
        const SizedBox(height: 18),
        const SectionHeader(
          title: 'Nacionalidades principales',
          subtitle: 'Selecciona una cultura para ver tradiciones y legado.',
        ),
        const SizedBox(height: 12),
        ...List.generate(
          cultures.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CultureCard(culture: cultures[index], index: index),
          ),
        ),
      ],
    );
  }
}
