import 'package:flutter/material.dart';
import 'package:proyecto_final/services/auth_service.dart';

const Color colorFondo = Color(0xFFF5F5F5);
const Color colorTextoPrincipal = Colors.black;
const Color colorTextoSecundario = Colors.grey;
const Color colorBoton = Color.fromARGB(255, 238, 143, 0);

class NuevaContrasenaScreen extends StatefulWidget {
  const NuevaContrasenaScreen({super.key});

  @override
  State<NuevaContrasenaScreen> createState() => _NuevaContrasenaScreenState();
}

class _NuevaContrasenaScreenState extends State<NuevaContrasenaScreen> {
  final TextEditingController _nuevaContrasenaController =
      TextEditingController();
  final TextEditingController _confirmarContrasenaController =
      TextEditingController();
  final TextEditingController _viejaContrasena = TextEditingController();
  Text advertencia = const Text(
    '',
    style: TextStyle(color: Color.fromARGB(255, 255, 17, 0)),
  );
  bool visibilidadAdvertencia = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          title: const Text(
            "MetroBox",
            style: TextStyle(
              color: Color.fromRGBO(240, 83, 43, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('images/Logo.png', height: 200, width: 200),
          ),
        ),
        body: Column(
          children: <Widget>[
            const Divider(
              color: Color.fromRGBO(65, 64, 64, 95),
              height: 4,
              thickness: 10,
              indent: 0,
              endIndent: 0,
            ),
            const SizedBox(height: 100),
            Container(
              width: 400.0,
              margin: const EdgeInsets.all(30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      'Nueva Contraseña',
                      style: TextStyle(
                        fontSize: 50,
                        color: Color.fromRGBO(240, 83, 43, 1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color.fromRGBO(65, 64, 64, 95),
                    height: 4,
                    thickness: 4,
                    indent: 0,
                    endIndent: 0,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _viejaContrasena,
                    obscureText: true,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Contraseña Anterior',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nuevaContrasenaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmarContrasenaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirmar contraseña',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Visibility(
                      visible: visibilidadAdvertencia, child: advertencia),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorBoton,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            )),
                        onPressed: () {
                          Navigator.pushNamed(context, '/perfil');
                        },
                        child: const Text(
                          'Regresar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorBoton,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            )),
                        onPressed: () {
                          _guardarNuevaContrasena();
                        },
                        child: const Text(
                          'Guardar contraseña',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  void _guardarNuevaContrasena() {
    final nueva = _nuevaContrasenaController.text;
    final confirmar = _confirmarContrasenaController.text;

    if (nueva.isEmpty || confirmar.isEmpty) {
      setState(() {
        advertencia = const Text(
          'Completa ambos campos.',
          style:
              TextStyle(fontSize: 24, color: Color.fromARGB(255, 255, 17, 0)),
        );
        visibilidadAdvertencia = true;
      });
      return;
    }

    if (nueva != confirmar) {
      setState(() {
        advertencia = const Text(
          'Las contraseñas no coinciden.',
          style:
              TextStyle(fontSize: 24, color: Color.fromARGB(255, 255, 17, 0)),
        );
        visibilidadAdvertencia = true;
      });
      return;
    }

    for (int i = 0; i < nueva.length; i++) {
      if (nueva[i] == ' ') {
        setState(() {
          advertencia = const Text(
            'No debe de tener espacios.',
            style:
                TextStyle(fontSize: 24, color: Color.fromARGB(255, 255, 17, 0)),
          );
          visibilidadAdvertencia = true;
        });
        return;
      }

      ingresarNuevaContrasena();
      regresar();
    }
  }

  void ingresarNuevaContrasena() async {
    // Lógica para ingresar la nueva contraseña en el firebase
    await AuthService().changePassword(
      currentPassword: _viejaContrasena.text,
      newPassword: _nuevaContrasenaController.text,
    );
  }

  void regresar() async{
    // Lógica para regresar a la pantalla de iniciar sesión
    setState(() {
      advertencia = const Text(
        'Contraseña cambiada con éxito.',
        style: TextStyle(fontSize: 24, color: Colors.green),
      );
      visibilidadAdvertencia = true;
    });
    Navigator.popAndPushNamed(context, 'principal');
    await AuthService().signOut();
    setState(() {
      advertencia = const Text(
        'Por favor, inicie sesión con su nueva contraseña.',
        style: TextStyle(fontSize: 24, color: Colors.green),
      );
      visibilidadAdvertencia = true;
    });
  }
}
