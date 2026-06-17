import 'package:flutter/material.dart';

/// Seccion tematica del catalogo cultural: Tradiciones, Vestimenta,
/// Gastronomia e Historia (Funcionalidad Dos del ERS).
class CultureSection {
  const CultureSection({
    required this.title,
    required this.body,
    this.icon = Icons.auto_stories,
  });

  final String title;
  final String body;
  final IconData icon;
}
