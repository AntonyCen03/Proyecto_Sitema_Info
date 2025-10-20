import 'package:firebase_auth/firebase_auth.dart';

/// AuthService proporciona métodos utilitarios para operar con
/// Firebase Authentication desde la aplicación.
///
/// Métodos disponibles:
/// - signIn(email, password)
/// - register(email, password)
/// - signOut()
/// - sendPasswordReset(email)
/// - authStateChanges (Stream<User?>)
/// - currentUser (User?)

class AuthService {
  // Instancia singleton para acceder al servicio desde cualquier lugar.
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream que notifica sobre cambios en el estado de autenticación (login/logout).
  ///
  /// Úsalo con un StreamBuilder para actualizar la UI automáticamente.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Devuelve el usuario actualmente autenticado, o null si no hay ninguno.
  User? get currentUser => _auth.currentUser;

  /// Inicia sesión con correo y contraseña.
  ///
  /// Lanza [FirebaseAuthException] si la autenticación falla, para que la UI
  /// pueda mostrar un mensaje de error específico.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException {
      // Re-lanzar para que la UI lo maneje y muestre mensajes apropiados.
      rethrow;
    }
  }

  /// Registra un nuevo usuario con correo y contraseña.
  ///
  /// Lanza [FirebaseAuthException] si el registro falla (ej: email ya en uso).
  Future<UserCredential> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return credential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Envía un correo para restablecer la contraseña.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
