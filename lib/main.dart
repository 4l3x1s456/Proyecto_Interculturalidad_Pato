import 'package:flutter/material.dart';

import 'app/app.dart';
import 'data/services/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // No-op mientras AppConfig.useFirebase sea false (ver FIREBASE_SETUP.md).
  await FirebaseBootstrap.ensureInitialized();
  runApp(const CulturaApp());
}
