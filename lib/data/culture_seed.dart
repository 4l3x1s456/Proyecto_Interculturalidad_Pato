import 'package:flutter/material.dart';

import '../models/culture.dart';
import '../models/culture_section.dart';

/// Datos base (offline) de las culturas. Sirven como respaldo cuando no hay
/// conexion (RNF-005: modo offline) y se enriquecen en tiempo de ejecucion
/// con la API publica de Wikipedia.
///
/// `modelLabel` corresponde a las etiquetas del modelo de IA entrenado
/// (`modelo/labels.txt`): Otavalo, tsachila, shuar, waorani, saraguro.
const List<Culture> cultureSeed = [
  Culture(
    id: 'otavalo',
    name: 'Kichwa Otavalo',
    region: 'Sierra',
    wikiTitle: 'Kichwa Otavalo',
    modelLabel: 'Otavalo',
    motif: '🧵',
    language: 'Kichwa',
    accentColor: Color(0xFF0F766E),
    icon: Icons.terrain,
    // Modelo 3D local. Coloca el archivo en assets/models/ (ver README ahi).
    model3dUrl:
        'https://alexgames-app-cultuar.web.app/models/otavalo_personaje.glb',
    summary:
        'Pueblo kichwa de Imbabura reconocido mundialmente por sus textiles, '
        'el mercado de artesanias y su tradicion mindalae de comercio.',
    sections: [
      CultureSection(
        icon: Icons.celebration,
        title: 'Tradiciones',
        body:
            'Inti Raymi, Pawkar Raymi, mingas comunitarias y musica andina con '
            'instrumentos de viento y cuerda.',
      ),
      CultureSection(
        icon: Icons.checkroom,
        title: 'Vestimenta',
        body:
            'Mujeres con anaco, blusa bordada, fachalina y collares dorados; '
            'hombres con poncho, pantalon blanco y sombrero de pano.',
      ),
      CultureSection(
        icon: Icons.restaurant,
        title: 'Gastronomia',
        body:
            'Mote, fritada, tortillas de papa, chicha de jora y el tradicional '
            'caldo de gallina de campo.',
      ),
      CultureSection(
        icon: Icons.account_balance,
        title: 'Historia',
        body:
            'Herederos de los caranquis; comerciantes "mindalaes" que hoy llevan '
            'sus tejidos a mercados de America, Europa y Asia.',
      ),
    ],
  ),
  Culture(
    id: 'saraguro',
    name: 'Saraguro',
    region: 'Sierra',
    wikiTitle: 'Saraguro',
    modelLabel: 'saraguro',
    motif: '⚫',
    language: 'Kichwa',
    accentColor: Color(0xFF7C3AED),
    icon: Icons.landscape,
    model3dUrl:
        'https://alexgames-app-cultuar.web.app/models/saraguro_personaje.glb',
    summary:
        'Pueblo de la nacionalidad kichwa del sur del Ecuador (Loja), conocido '
        'por su vestimenta negra ritual y su fuerte organizacion comunitaria.',
    sections: [
      CultureSection(
        icon: Icons.celebration,
        title: 'Tradiciones',
        body:
            'Fiestas del Kapak Raymi y Pawkar Raymi, danzas con los "wikis" y '
            'mingas que sostienen la vida comunitaria.',
      ),
      CultureSection(
        icon: Icons.checkroom,
        title: 'Vestimenta',
        body:
            'Indumentaria negra de lana, sombrero blanco de ala ancha con '
            'manchas negras, y joyeria de plata trabajada a mano.',
      ),
      CultureSection(
        icon: Icons.restaurant,
        title: 'Gastronomia',
        body:
            'Mote, cuy asado, gallina criolla, quesillo y bebidas de maiz '
            'preparadas para las celebraciones.',
      ),
      CultureSection(
        icon: Icons.account_balance,
        title: 'Historia',
        body:
            'Posibles mitimaes trasladados por los incas; mantienen el kichwa y '
            'una identidad andina viva en la provincia de Loja.',
      ),
    ],
  ),
  Culture(
    id: 'shuar',
    name: 'Shuar',
    region: 'Amazonia',
    wikiTitle: 'Shuar',
    modelLabel: 'shuar',
    motif: '🪶',
    language: 'Shuar Chicham',
    accentColor: Color(0xFFB45309),
    icon: Icons.forest,
    model3dUrl:
        'https://alexgames-app-cultuar.web.app/models/shuar-personaje.glb',
    summary:
        'Pueblo amazonico del sur oriente ecuatoriano, de fuerte identidad '
        'guerrera y profundo conocimiento de la selva.',
    sections: [
      CultureSection(
        icon: Icons.celebration,
        title: 'Tradiciones',
        body:
            'Ceremonia de la chonta (Uwi), ritos del ayahuasca, cantos "anent" '
            'y artesania con semillas y plumas.',
      ),
      CultureSection(
        icon: Icons.checkroom,
        title: 'Vestimenta',
        body:
            'Coronas de plumas (tawasap), collares de semillas, pintura facial '
            'con achiote y faldas de fibras naturales (itip).',
      ),
      CultureSection(
        icon: Icons.restaurant,
        title: 'Gastronomia',
        body:
            'Yuca, platano, pescado de rio, ayampaco y chicha de yuca '
            'fermentada.',
      ),
      CultureSection(
        icon: Icons.account_balance,
        title: 'Historia',
        body:
            'Conocidos por su resistencia ante incas y colonizadores; hoy '
            'organizados en federaciones que defienden su territorio.',
      ),
    ],
  ),
  Culture(
    id: 'tsachila',
    name: 'Tsachila',
    region: 'Costa',
    wikiTitle: 'Tsáchila',
    modelLabel: 'tsachila',
    motif: '💧',
    language: 'Tsafiki',
    accentColor: Color(0xFFDC2626),
    icon: Icons.water_drop,
    model3dUrl:
        'https://alexgames-app-cultuar.web.app/models/tsachila_personaje.glb',
    summary:
        'Nacionalidad de Santo Domingo conocida como "los colorados" por el '
        'achiote en el cabello; herederos de una medicina ancestral renombrada.',
    sections: [
      CultureSection(
        icon: Icons.celebration,
        title: 'Tradiciones',
        body:
            'Fiesta del Kasama (ano nuevo tsachila), marimba, ritos de sanacion '
            'y saberes de los poneras (chamanes).',
      ),
      CultureSection(
        icon: Icons.checkroom,
        title: 'Vestimenta',
        body:
            'Hombres con cabello moldeado con achiote y manto a rayas; mujeres '
            'con faldas multicolor (tunan) y pinturas de huito.',
      ),
      CultureSection(
        icon: Icons.restaurant,
        title: 'Gastronomia',
        body:
            'Pandado (pescado envuelto en hoja de bijao), maito, verde, yuca y '
            'bebidas de la zona subtropical.',
      ),
      CultureSection(
        icon: Icons.account_balance,
        title: 'Historia',
        body:
            'Pueblo de la lengua tsafiki; su medicina tradicional les dio fama '
            'nacional e internacional como sanadores.',
      ),
    ],
  ),
  Culture(
    id: 'waorani',
    name: 'Waorani',
    region: 'Amazonia',
    wikiTitle: 'Waorani',
    modelLabel: 'waorani',
    motif: '🏹',
    language: 'Wao Terero',
    accentColor: Color(0xFF1D4ED8),
    icon: Icons.eco,
    model3dUrl:
        'https://alexgames-app-cultuar.web.app/models/waorani_personaje.glb',
    summary:
        'Pueblo amazonico del Yasuni con una de las relaciones mas profundas '
        'con la selva; contacto reciente con la sociedad nacional.',
    sections: [
      CultureSection(
        icon: Icons.celebration,
        title: 'Tradiciones',
        body:
            'Vida en clanes (nanicabo), caza con cerbatana y lanza, cantos '
            'ancestrales y conocimiento botanico de la selva.',
      ),
      CultureSection(
        icon: Icons.checkroom,
        title: 'Vestimenta',
        body:
            'Adornos de plumas, coronas, collares de semillas y pinturas '
            'corporales con tintes naturales.',
      ),
      CultureSection(
        icon: Icons.restaurant,
        title: 'Gastronomia',
        body:
            'Caza y pesca de la selva, yuca, platano, frutos silvestres y '
            'chicha de yuca.',
      ),
      CultureSection(
        icon: Icons.account_balance,
        title: 'Historia',
        body:
            'Habitantes del Yasuni; defienden su territorio frente a la '
            'extraccion petrolera y mantienen grupos en aislamiento voluntario.',
      ),
    ],
  ),
];
