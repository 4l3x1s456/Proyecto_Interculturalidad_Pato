import 'package:firebase_core/firebase_core.dart';

import '../../../app/config.dart';
import '../../../firebase_options.dart';

/// Inicializa Firebase de forma segura.
///
/// Mientras `AppConfig.useFirebase` sea `false`, es un no-op y la app funciona
/// con la implementacion local. Al crear el proyecto Firebase y generar
/// `firebase_options.dart` con `flutterfire configure`, basta con cambiar el
/// flag a `true` (ver FIREBASE_SETUP.md).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> ensureInitialized() async {
    if (!AppConfig.useFirebase || _initialized) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _initialized = true;
  }
}
