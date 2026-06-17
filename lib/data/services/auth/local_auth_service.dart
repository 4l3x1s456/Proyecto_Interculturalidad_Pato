import '../../../models/user_account.dart';
import 'auth_service.dart';

/// Implementacion local (en memoria) de [AuthService] para el prototipo.
///
/// Replica las reglas de la Funcionalidad Uno del ERS: correos unicos,
/// validacion de credenciales y rechazo de datos invalidos. Se reemplazara por
/// [FirebaseAuthService] al activar `AppConfig.useFirebase`.
class LocalAuthService implements AuthService {
  LocalAuthService() {
    const seedUser = UserAccount(
      name: 'Usuario Demo',
      email: 'demo@raices.app',
      password: 'demo123',
    );
    _usersByEmail[seedUser.email.toLowerCase()] = seedUser;
  }

  final Map<String, UserAccount> _usersByEmail = {};
  UserAccount? _currentUser;

  @override
  UserAccount? get currentUser => _currentUser;

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final cleanName = name.trim();

    if (cleanName.isEmpty) {
      return const AuthResult.failure('Nombre requerido');
    }
    if (!normalized.contains('@')) {
      return const AuthResult.failure('Correo no valido');
    }
    if (password.length < 6) {
      return const AuthResult.failure('Contrasena muy corta');
    }
    if (_usersByEmail.containsKey(normalized)) {
      return const AuthResult.failure('El correo ya esta registrado');
    }

    final user = UserAccount(
      name: cleanName,
      email: normalized,
      password: password,
    );
    _usersByEmail[normalized] = user;
    _currentUser = user;
    return AuthResult.success(user);
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final user = _usersByEmail[normalized];

    if (user == null) {
      return const AuthResult.failure('Usuario no encontrado');
    }
    if (user.password != password) {
      return const AuthResult.failure('Contrasena incorrecta');
    }

    _currentUser = user;
    return AuthResult.success(user);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}
