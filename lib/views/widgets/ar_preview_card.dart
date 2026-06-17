import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/culture.dart';
import '../screens/camera_screen.dart';

class ARPreviewCard extends StatelessWidget {
  const ARPreviewCard({super.key, required this.culture});

  final Culture culture;

  @override
  Widget build(BuildContext context) {
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
              child: Icon(Icons.view_in_ar, color: culture.accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Experiencia de Realidad Aumentada',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Apunta la camara a una vestimenta o escena de ${culture.name} '
                    'y el modelo confirmara si corresponde a esta cultura.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textSoft),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: Text('Detector AR - ${culture.name}'),
                            ),
                            // Modo dirigido: limitado a esta cultura.
                            body: CameraScreen(targetCulture: culture),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Abrir detector AR'),
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
