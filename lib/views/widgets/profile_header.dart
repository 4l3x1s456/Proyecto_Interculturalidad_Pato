import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/user_account.dart';
import '../../utils/text_utils.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.user});

  final UserAccount? user;

  @override
  Widget build(BuildContext context) {
    final initials = initialsFromName(user?.name ?? 'Usuario');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                initials,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Usuario invitado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'sin correo',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
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
