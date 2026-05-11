import 'package:flutter/material.dart';

import '../models/culture.dart';
import '../models/culture_section.dart';

const List<Culture> cultureSeed = [
  Culture(
    id: 'kichwa',
    name: 'Kichwa',
    region: 'Sierra',
    summary:
        'La nacionalidad mas grande del pais, con lengua kichwa y fuerte identidad andina.',
    accentColor: Color(0xFF0F766E),
    icon: Icons.terrain,
    sections: [
      CultureSection(
        title: 'Tradiciones',
        body:
            'Inti Raymi, mingas comunitarias, musica andina y ferias locales.',
      ),
      CultureSection(
        title: 'Vestimenta',
        body: 'Anaco, poncho, sombrero de fieltro y fajas tejidas a mano.',
      ),
      CultureSection(
        title: 'Gastronomia',
        body: 'Mote, cuy asado, papas con queso y chicha de jora.',
      ),
      CultureSection(
        title: 'Historia',
        body:
            'Pueblos andinos con organizacion comunitaria y resistencia cultural.',
      ),
    ],
  ),
  Culture(
    id: 'shuar',
    name: 'Shuar',
    region: 'Amazonia',
    summary:
        'Conocidos por su presencia en la selva y su fuerte identidad territorial.',
    accentColor: Color(0xFFB45309),
    icon: Icons.local_florist,
    sections: [
      CultureSection(
        title: 'Tradiciones',
        body:
            'Ceremonias de la chonta, artesania con semillas y cantos rituales.',
      ),
      CultureSection(
        title: 'Vestimenta',
        body: 'Coronas, collares, pinturas con achiote y fibras naturales.',
      ),
      CultureSection(
        title: 'Gastronomia',
        body: 'Yuca, pescado de rio y bebidas tradicionales fermentadas.',
      ),
      CultureSection(
        title: 'Historia',
        body: 'Pueblo amazonico con memoria guerrera y defensa del territorio.',
      ),
    ],
  ),
  Culture(
    id: 'waorani',
    name: 'Waorani',
    region: 'Amazonia',
    summary:
        'Cultura ancestral con relacion profunda con la selva y sus recursos.',
    accentColor: Color(0xFF1D4ED8),
    icon: Icons.opacity,
    sections: [
      CultureSection(
        title: 'Tradiciones',
        body: 'Vida en clanes, caza con cerbatana y rituales de la selva.',
      ),
      CultureSection(
        title: 'Vestimenta',
        body: 'Adornos con plumas, fibras y pinturas corporales.',
      ),
      CultureSection(
        title: 'Gastronomia',
        body: 'Caza y pesca de la selva, frutos y tuberculos.',
      ),
      CultureSection(
        title: 'Historia',
        body: 'Contacto reciente con el exterior y defensa del territorio.',
      ),
    ],
  ),
  Culture(
    id: 'achuar',
    name: 'Achuar',
    region: 'Amazonia',
    summary:
        'Cultura emparentada con los Shuar, con identidad propia y saberes ancestrales.',
    accentColor: Color(0xFF047857),
    icon: Icons.eco,
    sections: [
      CultureSection(
        title: 'Tradiciones',
        body: 'Ceremonias de armonia, artesania en barro y tejidos.',
      ),
      CultureSection(
        title: 'Vestimenta',
        body: 'Fibras naturales, pinturas y accesorios de semillas.',
      ),
      CultureSection(
        title: 'Gastronomia',
        body: 'Yuca, maiz, pescado y bebidas fermentadas.',
      ),
      CultureSection(
        title: 'Historia',
        body:
            'Pueblo amazonico con fuerte identidad y organizacion comunitaria.',
      ),
    ],
  ),
  Culture(
    id: 'tsachila',
    name: 'Tsachila',
    region: 'Costa',
    summary:
        'Reconocidos por su vestimenta y practicas de medicina tradicional.',
    accentColor: Color(0xFFDC2626),
    icon: Icons.beach_access,
    sections: [
      CultureSection(
        title: 'Tradiciones',
        body: 'Fiestas comunitarias, musica local y medicina ancestral.',
      ),
      CultureSection(
        title: 'Vestimenta',
        body: 'Tunica rayada, collares y peinado con achiote.',
      ),
      CultureSection(
        title: 'Gastronomia',
        body: 'Platillos con verde, pescado, yuca y hierbas de la costa.',
      ),
      CultureSection(
        title: 'Historia',
        body: 'Pueblo de la costa con identidad unica y legado ancestral.',
      ),
    ],
  ),
];
