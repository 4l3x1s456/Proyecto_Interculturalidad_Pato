import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../controllers/culture_controller.dart';
import '../views/screens/auth_router.dart';
import 'app_scope.dart';
import 'theme.dart';

class CulturaApp extends StatefulWidget {
  const CulturaApp({super.key});

  @override
  State<CulturaApp> createState() => _CulturaAppState();
}

class _CulturaAppState extends State<CulturaApp> {
  late final AuthController _auth;
  late final CultureController _repository;

  @override
  void initState() {
    super.initState();
    _auth = AuthController();
    _repository = CultureController();
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
