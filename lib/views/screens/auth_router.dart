import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import 'auth_screen.dart';
import 'home_screen.dart';

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).auth;
    return AnimatedBuilder(
      animation: auth,
      builder: (context, _) {
        if (auth.isSignedIn) {
          return const HomeScreen();
        }
        return const AuthScreen();
      },
    );
  }
}
