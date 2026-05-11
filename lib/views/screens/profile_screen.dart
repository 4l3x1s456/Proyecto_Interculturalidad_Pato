import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../widgets/info_tile.dart';
import '../widgets/profile_header.dart';
import '../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    final user = auth.currentUser;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ProfileHeader(user: user),
        const SizedBox(height: 16),
        const SectionHeader(
          title: 'Estado del prototipo',
          subtitle: 'Datos locales con estructura lista para Firebase.',
        ),
        const SizedBox(height: 12),
        const InfoTile(
          icon: Icons.storage,
          title: 'Base de datos',
          subtitle: 'Prototipo en memoria; Firestore pendiente.',
        ),
        const SizedBox(height: 10),
        const InfoTile(
          icon: Icons.photo_library,
          title: 'Contenido multimedia',
          subtitle: 'Imagenes locales; listo para Storage.',
        ),
        const SizedBox(height: 10),
        const InfoTile(
          icon: Icons.login,
          title: 'Autenticacion',
          subtitle: 'Registro y acceso local; Firebase Auth despues.',
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: auth.signOut,
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesion'),
        ),
      ],
    );
  }
}
