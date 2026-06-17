import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../models/user_account.dart';
import '../auth/auth_service.dart';

/// Implementacion de [AuthService] sobre Firebase Authentication + Firestore.
///
/// Queda lista para activarse con `AppConfig.useFirebase = true` una vez creado
/// el proyecto Firebase (ver FIREBASE_SETUP.md). Crea un documento de usuario en
/// la coleccion `users` para soportar el control de acceso por roles (RNF-003).
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? fb.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  UserAccount? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return UserAccount(
      name: user.displayName ?? '',
      email: user.email ?? '',
      password: '',
    );
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const AuthResult.failure('No se pudo crear la cuenta');
      }

      await user.updateDisplayName(name.trim());
      await _firestore.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'estudiante',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(
        UserAccount(
          name: name.trim(),
          email: email.trim().toLowerCase(),
          password: '',
        ),
      );
    } on fb.FirebaseAuthException catch (error) {
      return AuthResult.failure(_messageFor(error));
    } catch (_) {
      return const AuthResult.failure('No se pudo completar el registro');
    }
  }

  @override
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const AuthResult.failure('Usuario no encontrado');
      }
      return AuthResult.success(
        UserAccount(
          name: user.displayName ?? '',
          email: user.email ?? '',
          password: '',
        ),
      );
    } on fb.FirebaseAuthException catch (error) {
      return AuthResult.failure(_messageFor(error));
    } catch (_) {
      return const AuthResult.failure('No se pudo iniciar sesion');
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _messageFor(fb.FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'El correo ya esta registrado';
      case 'invalid-email':
        return 'Correo no valido';
      case 'weak-password':
        return 'Contrasena muy corta';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Credenciales incorrectas';
      case 'user-disabled':
        return 'La cuenta esta desactivada';
      default:
        return 'Error de autenticacion (${error.code})';
    }
  }
}
