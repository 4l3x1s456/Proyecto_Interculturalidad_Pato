import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/culture_controller.dart';
import '../controllers/progress_controller.dart';
import '../data/services/auth/auth_service.dart';
import '../data/services/firebase/firebase_auth_service.dart';
import '../data/services/firebase/firestore_progress_repository.dart';
import '../data/services/firebase/firestore_tracking_service.dart';
import '../data/services/progress/progress_repository.dart';
import '../data/services/tracking/noop_tracking_service.dart';
import '../data/services/tracking/tracking_service.dart';
import '../views/screens/auth_router.dart';
import 'app_scope.dart';
import 'config.dart';
import 'theme.dart';

class CulturaApp extends StatefulWidget {
  const CulturaApp({super.key});

  @override
  State<CulturaApp> createState() => _CulturaAppState();
}

class _CulturaAppState extends State<CulturaApp> {
  late final AuthController _auth;
  late final CultureController _repository;
  late final ProgressController _progress;
  late final TrackingService _tracking;
  StreamSubscription<fb.User?>? _authSub;

  @override
  void initState() {
    super.initState();
    // Usa Firebase solo si el flag esta activo Y la app fue inicializada
    // (FirebaseBootstrap en main). Asi, en pruebas o si Firebase no arranca,
    // cae con seguridad a la implementacion local.
    final useFirebase = AppConfig.useFirebase && Firebase.apps.isNotEmpty;
    final AuthService? authService =
        useFirebase ? FirebaseAuthService() : null;
    _tracking = useFirebase
        ? FirestoreTrackingService()
        : const NoopTrackingService();
    final ProgressRepository progressRepository = useFirebase
        ? FirestoreProgressRepository()
        : const LocalProgressRepository();
    _auth = AuthController(service: authService);
    _repository = CultureController();
    _progress = ProgressController(
      totalCultures: _repository.cultures.length,
      repository: progressRepository,
    );

    // Sincroniza el progreso con Firestore cuando hay sesion (incluye la
    // restauracion automatica al reabrir la app) y lo limpia al cerrarla.
    if (useFirebase) {
      _authSub = fb.FirebaseAuth.instance.authStateChanges().listen((user) {
        if (user != null) {
          _progress.startSync();
        } else {
          _progress.clear();
        }
      });
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _auth.dispose();
    _repository.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return AppScope(
      auth: _auth,
      repository: _repository,
      progress: _progress,
      tracking: _tracking,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Culturas del Ecuador',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: 'serif',
          fontFamilyFallback: const ['Georgia', 'Times New Roman', 'serif'],
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textStrong,
            elevation: 0,
            centerTitle: false,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0.6,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        home: const AuthRouter(),
      ),
    );
  }
}
