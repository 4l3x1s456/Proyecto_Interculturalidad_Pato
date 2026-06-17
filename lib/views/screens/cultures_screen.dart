import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../widgets/culture_card.dart';
import '../widgets/hero_banner.dart';
import '../widgets/section_header.dart';

class CulturesScreen extends StatefulWidget {
  const CulturesScreen({super.key});

  @override
  State<CulturesScreen> createState() => _CulturesScreenState();
}

class _CulturesScreenState extends State<CulturesScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Carga perezosa: enriquece el catalogo desde Wikipedia al abrirlo.
    AppScope.of(context).repository.enrich();
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final repository = scope.repository;
    final progress = scope.progress;

    // Se reconstruye al enriquecer contenido (Wikipedia) o al cambiar el
    // progreso personal del usuario.
    return ListenableBuilder(
      listenable: Listenable.merge([repository, progress]),
      builder: (context, _) {
        final cultures = repository.cultures;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const HeroBanner(),
            const SizedBox(height: 18),
            _ProgressSummary(
              explored: progress.exploredCount,
              total: progress.totalCultures,
            ),
            const SizedBox(height: 18),
            SectionHeader(
              title: 'Nacionalidades y pueblos',
              subtitle: repository.isEnriching
                  ? 'Cargando contenido desde Wikipedia...'
                  : 'Selecciona una cultura para ver tradiciones y legado.',
            ),
            const SizedBox(height: 12),
            ...List.generate(
              cultures.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CultureCard(
                  culture: cultures[index],
                  index: index,
                  explored: progress.hasViewed(cultures[index].id),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Barra compacta de progreso del catalogo (Funcionalidad Dos del ERS).
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.explored, required this.total});

  final int explored;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : explored / total;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu exploracion',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 8,
                    backgroundColor: AppColors.outline,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$explored/$total',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
