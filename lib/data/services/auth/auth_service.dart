import '../../../models/user_account.dart';

/// Resultado de una operacion de autenticacion.
///
/// Si [error] es `null` la operacion fue exitosa y [user] contiene la cuenta.
class AuthResult {
  const AuthResult.success(this.user) : error = null;
  const AuthResult.failure(this.error) : user = null;

  final UserAccount? user;
  final String? error;

  bool get isSuccess => error == null;
}

/// Contrato de autenticacion (Funcionalidad Uno del ERS).
///
/// Permite intercambiar la implementacion local (prototipo) por Firebase
/// Authentication sin tocar la capa de UI ni el [AuthController].
abstract class AuthService {
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AuthResult> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Usuario actualmente autenticado, si la implementacion lo persiste.
  UserAccount? get currentUser;
}
