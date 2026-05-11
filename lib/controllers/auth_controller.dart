import 'package:flutter/material.dart';

import '../models/user_account.dart';

class AuthController extends ChangeNotifier {
  AuthController() {
    const seedUser = UserAccount(
      name: 'Usuario Demo',
      email: 'demo@raices.app',
      password: 'demo123',
    );
    _usersByEmail[seedUser.email.toLowerCase()] = seedUser;
  }

  final Map<String, UserAccount> _usersByEmail = {};
  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  String? register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalized = email.trim().toLowerCase();
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return 'Nombre requerido';
    }
    if (!normalized.contains('@')) {
      return 'Correo no valido';
    }
    if (password.length < 6) {
      return 'Contrasena muy corta';
    }
    if (_usersByEmail.containsKey(normalized)) {
      return 'El correo ya esta registrado';
    }

    final user = UserAccount(
      name: cleanName,
      email: normalized,
      password: password,
    );
    _usersByEmail[normalized] = user;
    _currentUser = user;
    notifyListeners();
    return null;
  }

  String? signIn({required String email, required String password}) {
    final normalized = email.trim().toLowerCase();
    final user = _usersByEmail[normalized];

    if (user == null) {
      return 'Usuario no encontrado';
    }
    if (user.password != password) {
      return 'Contrasena incorrecta';
    }

    _currentUser = user;
    notifyListeners();
    return null;
  }

  void signOut() {
    _currentUser = null;
    notifyListeners();
  }
}
