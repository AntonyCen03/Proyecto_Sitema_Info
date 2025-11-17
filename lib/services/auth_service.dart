import 'dart:async';
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

  /// Envía un correo de verificación al usuario actualmente autenticado.
  ///
  /// No depende de datos de Firestore ni de `getUser()`. Usa únicamente
  /// `FirebaseAuth.currentUser`.
  ///
  /// Lanza [FirebaseAuthException] con código `no-current-user` si no hay
  /// sesión activa.
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hay un usuario autenticado actualmente.',
      );
    }
    await user.sendEmailVerification();
  }

  /// Verifica si el correo del usuario autenticado ya fue confirmado.
  ///
  /// Realiza `user.reload()` para asegurar estado fresco antes de leer
  /// `emailVerified`. No depende de Firestore ni de `getUser()`.
  ///
  /// Retorna `true` si el email está verificado.
  /// Lanza [FirebaseAuthException] con código `no-current-user` si no hay sesión.
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hay un usuario autenticado actualmente.',
      );
    }
    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  /// Cambia la contraseña del usuario actualmente autenticado.
  ///
  /// Requiere la contraseña actual (`currentPassword`) para reautenticar al
  /// usuario antes de llamar a `updatePassword`. Si el usuario no tiene sesión
  /// activa, lanzará un [FirebaseAuthException] con código `no-current-user`.
  ///
  /// Errores comunes a capturar en la UI:
  /// - `wrong-password`: la contraseña actual es incorrecta.
  /// - `requires-recent-login`: la sesión no es "reciente" (puede ocurrir también);
  ///   la reautenticación suele resolverlo.
  /// - `weak-password`: Firebase rechaza la nueva contraseña (p. ej. muy corta).
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hay un usuario autenticado actualmente.',
      );
    }
    try {
      // Reautenticar con las credenciales de correo/contraseña.
      final credential = EmailAuthProvider.credential(
        email: user.email!.trim(),
        password: currentPassword,
      );
      // un timeout para evitar que la llamada quede bloqueada indefinidamente
      try {
        await user
            .reauthenticateWithCredential(credential)
            .timeout(const Duration(seconds: 10));
      } on FirebaseAuthException catch (e) {
        // Normalizar y relanzar con un código consistente
        final code = (e.code);
        throw FirebaseAuthException(
            code: code, message: e.message ?? 'Error al reautenticar');
      }

      // Actualizar la contraseña (también con timeout por seguridad de red)
      try {
        if (newPassword == currentPassword) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'La nueva contraseña debe ser diferente a la anterior.',
          );
        } else if (newPassword.length < 6) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'La nueva contraseña es demasiado débil.',
          );
        } else if (newPassword.length > 30) {
          throw FirebaseAuthException(
            code: 'weak-password',
            message: 'La nueva contraseña es demasiado larga.',
          );
        } else {
          await user
              .updatePassword(newPassword)
              .timeout(const Duration(seconds: 10));
        }
      } on FirebaseAuthException catch (e) {
        final code = (e.code);
        throw FirebaseAuthException(
            code: code,
            message: e.message ?? 'Error al actualizar la contraseña');
      }
    } on FirebaseAuthException {
      // Re-lanzar para que la UI lo maneje (mostrar mensajes adecuados al usuario).
      rethrow;
    } on TimeoutException catch (_) {
      // Convertir timeout a FirebaseAuthException para que la UI lo maneje igual
      throw FirebaseAuthException(
        code: 'timeout',
        message:
            'La operación tardó demasiado. Verifica tu conexión e intenta de nuevo.',
      );
    } catch (e) {
      // En caso de otro error inesperado, envolverlo para la UI
      throw FirebaseAuthException(
        code: 'unknown-error',
        message: e.toString(),
      );
    }
  }

  /// Elimina (borra) el usuario actualmente autenticado en Firebase Auth.
  ///
  /// Lanza [FirebaseAuthException] con código `no-current-user` si no hay
  /// una sesión activa. Tenga en cuenta que Firebase puede solicitar una
  /// reautenticación si la sesión no es reciente; ese error llegará como
  /// una [FirebaseAuthException] desde la llamada a `delete()`.
  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No hay un usuario autenticado actualmente.',
      );
    }
    try {
      await user.delete();
    } on FirebaseAuthException {
      rethrow;
    }
  }

  /// Reenvía el correo de verificación al usuario actual.
  ///
  /// Si no existe una sesión activa, y se proporcionan `email` y `password`,
  /// intentará iniciar sesión con esas credenciales y luego reenviar el correo.
  /// Lanza [FirebaseAuthException] para que la UI lo muestre si algo falla.
  Future<void> resendEmailVerification(
      {String? email, String? password}) async {
    try {
      await sendEmailVerification();
      return;
    } on FirebaseAuthException catch (e) {
      // Si no hay usuario actual, intentar autenticar con email/password si los dieron
      if ((e.code == 'no-current-user' || e.code == 'user-not-found') &&
          email != null &&
          password != null) {
        // Intentar iniciar sesión y reenviar
        await signIn(email, password);
        await sendEmailVerification();
        return;
      }
      rethrow;
    }
  }
}
