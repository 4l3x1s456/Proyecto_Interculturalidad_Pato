import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/culture_section.dart';

class CultureSectionCard extends StatelessWidget {
  const CultureSectionCard({super.key, required this.section});

  final CultureSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              section.body,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
