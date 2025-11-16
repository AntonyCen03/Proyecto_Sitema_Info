import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/login.dart';

// Widget de protección de rutas: si no hay usuario autenticado, muestra la pantalla de login.
class RequireAuth extends StatelessWidget {
  final Widget child;
  const RequireAuth({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          // Sin sesión: mostrar login directamente para evitar volver a esta ruta por pop.
          return const PageLogin();
        }
        return child;
      },
    );
  }
}