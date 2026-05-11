import 'package:flutter/material.dart';

import 'culture_section.dart';

class Culture {
  const Culture({
    required this.id,
    required this.name,
    required this.region,
    required this.summary,
    required this.accentColor,
    required this.icon,
    required this.sections,
  });

  final String id;
  final String name;
  final String region;
  final String summary;
  final Color accentColor;
  final IconData icon;
  final List<CultureSection> sections;
}
