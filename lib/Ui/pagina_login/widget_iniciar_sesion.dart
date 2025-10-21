import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/services/firebase_services.dart';

class IniciarSesion extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const IniciarSesion({
    Key? key,
    required this.usernameController,
    required this.passwordController,
  }) : super(key: key);

  @override
  State<IniciarSesion> createState() => _IniciarSesionState();
}

class _IniciarSesionState extends State<IniciarSesion> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 243, 138, 33),
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      onPressed: _loading
          ? null
          : () async {
              final email = widget.usernameController.text.trim();
              final password = widget.passwordController.text;
              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ingrese correo y contraseña')),
                );
                return;
              }

              setState(() => _loading = true);
              try {
                await AuthService().signIn(email, password);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Inicio de sesión correcto')),
                );
                final users = await getUser(context);
                final isAdmin = users.any((u) => (u['email'] ?? '').toString().trim() == email && (u['isadmin'] ?? false) as bool);
                final uid= users.firstWhere((u) => (u['email'] ?? '').toString().trim() == email)['uid'].toString();
                await updateUserLoginDate(DateTime.now(), uid);// Actualiza la fecha de último login
                if (isAdmin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario administrador')),
                  );
                  //Navigator.of(context).pushReplacementNamed('/admin_home');

                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario normal')),
                  );
                  //Navigator.of(context).pushReplacementNamed('/home');
                }
                // Navigator.of(context).pushReplacementNamed('/home');
              } on FirebaseAuthException catch (e) {
                String message = 'Error de autenticación';
                if (e.code == 'user-not-found' || e.code == 'wrong-password') {
                  message = 'Correo o contraseña incorrectos';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al iniciar sesión: $e')),
                );
              } finally {
                setState(() => _loading = false);
              }
              /*try {
                final users = await getUser();
                Map<String, dynamic>? matched;
                for (final u in users) {
                  final uemail = (u['email'] ?? '').toString().trim();
                  final upassword = (u['password'] ?? '').toString();
                  if (uemail == email && upassword == password) {
                    matched = u;
                    break;
                  }
                }

                if (matched != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Inicio de sesión correcto')),
                  );
                  // Navigator.of(context).pushReplacementNamed('/home');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Correo o contraseña incorrectos'),
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al comprobar usuarios: $e')),
                );
              } finally {
                setState(() => _loading = false);
              }*/
            },
      child: _loading
          ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
    );
  }
}