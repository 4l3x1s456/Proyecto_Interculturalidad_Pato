import 'package:flutter/material.dart';

import '../data/services/auth/auth_service.dart';
import '../data/services/auth/local_auth_service.dart';
import '../models/user_account.dart';

/// Fachada de autenticacion para la UI (Funcionalidad Uno del ERS).
///
/// Delega en un [AuthService] intercambiable: [LocalAuthService] en el
/// prototipo y `FirebaseAuthService` al activar `AppConfig.useFirebase`. Expone
/// una API asincrona, lista para el backend real, y notifica cambios de sesion.
class AuthController extends ChangeNotifier {
  AuthController({AuthService? service})
    : _service = service ?? LocalAuthService() {
    _currentUser = _service.currentUser;
  }

  final AuthService _service;
  UserAccount? _currentUser;

  UserAccount? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _service.register(
      name: name,
      email: email,
      password: password,
    );
    if (result.isSuccess) {
      _currentUser = result.user;
      notifyListeners();
    }
    return result.error;
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _service.signIn(email: email, password: password);
    if (result.isSuccess) {
      _currentUser = result.user;
      notifyListeners();
    }
    return result.error;
  }

  Future<void> signOut() async {
    await _service.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
