import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/theme.dart';
import '../../controllers/progress_controller.dart';
import '../widgets/info_tile.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_header.dart';

/// Perfil con seguimiento de progreso (Funcionalidad Cuatro del ERS):
/// porcentaje de exploracion, logros, estadisticas y actividad reciente.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final auth = scope.auth;
    final progress = scope.progress;

    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            ProfileHeader(user: auth.currentUser),
            const SizedBox(height: 18),

            const SectionHeader(
              title: 'Seguimiento de progreso',
              subtitle: 'Tu avance explorando las culturas del Ecuador.',
            ),
            const SizedBox(height: 12),
            _ProgressCard(progress: progress),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.travel_explore,
                    value: '${progress.exploredCount}/${progress.totalCultures}',
                    label: 'Culturas',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.camera_alt,
                    value: '${progress.totalDetections}',
                    label: 'Detecciones AR',
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.workspace_premium,
                    value:
                        '${progress.unlockedAchievements}/${progress.achievements.length}',
                    label: 'Logros',
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const SectionHeader(
              title: 'Logros',
              subtitle: 'Desbloquea insignias al explorar y usar la camara AR.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final achievement in progress.achievements)
                  _AchievementBadge(achievement: achievement),
              ],
            ),

            const SizedBox(height: 20),
            const SectionHeader(
              title: 'Actividad reciente',
              subtitle: 'Tu historial personal de exploracion.',
            ),
            const SizedBox(height: 12),
            if (progress.recentActivity.isEmpty)
              const InfoTile(
                icon: Icons.history,
                title: 'Sin actividad todavia',
                subtitle:
                    'Explora una cultura o usa la camara AR para comenzar.',
              )
            else
              for (final entry in progress.recentActivity)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActivityTile(entry: entry),
                ),

            const SizedBox(height: 20),
            const SectionHeader(
              title: 'Estado del sistema',
              subtitle: 'Integraciones activas del prototipo.',
            ),
            const SizedBox(height: 12),
            const InfoTile(
              icon: Icons.camera_enhance,
              title: 'Deteccion AR con IA',
              subtitle:
                  'Modelo entrenado integrado en la camara; reconoce Otavalo, '
                  'Saraguro, Shuar, Tsachila y Waorani.',
            ),
            const SizedBox(height: 10),
            const InfoTile(
              icon: Icons.view_in_ar,
              title: 'Modelos 3D / AR',
              subtitle:
                  'Visualizacion de modelos .glb con opcion de verlos en '
                  'Realidad Aumentada (RNF-007).',
            ),
            const SizedBox(height: 10),
            const InfoTile(
              icon: Icons.public,
              title: 'Contenido desde APIs publicas',
              subtitle:
                  'Resumenes e imagenes reales via Wikipedia; fondos dinamicos '
                  'con una API publica de imagenes.',
            ),

            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                progress.clear();
                auth.signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar sesion'),
            ),
          ],
        );
      },
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.progress});

  final ProgressController progress;

  @override
  Widget build(BuildContext context) {
    final percent = (progress.explorationProgress * 100).round();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: progress.explorationProgress,
                    strokeWidth: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.secondary,
                    ),
                  ),
                ),
                Text(
                  '$percent%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Diversidad explorada',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Has explorado ${progress.exploredCount} de '
                  '${progress.totalCultures} culturas.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;
    final color = unlocked ? AppColors.secondary : AppColors.textSoft;
    return Tooltip(
      message: achievement.description,
      child: Container(
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: unlocked ? AppColors.secondary.withOpacity(0.10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? AppColors.secondary : AppColors.outline,
          ),
        ),
        child: Column(
          children: [
            Icon(
              unlocked ? achievement.icon : Icons.lock_outline,
              color: color,
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: unlocked ? AppColors.textStrong : AppColors.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});

  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(entry.icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _relativeTime(entry.time),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSoft),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'ahora';
    if (diff.inHours < 1) return 'hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }
}
