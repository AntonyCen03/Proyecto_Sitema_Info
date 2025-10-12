import 'package:flutter/material.dart';

const Color colorPrimario = Color(0xFF6200EE);
const Color colorFondo = Color(0xFFF5F5F5);
const Color colorTextoPrincipal = Colors.black;
const Color colorTextoSecundario = Colors.grey;

class Olvidecontrasena extends StatefulWidget {
  const Olvidecontrasena({super.key});

  @override
  State<Olvidecontrasena> createState() => _OlvidecontrasenaState();
}

class _OlvidecontrasenaState extends State<Olvidecontrasena> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendRecoveryCode() {
    final email = _emailController.text.trim();

    if (email.isNotEmpty && email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Se ha enviado un código a $email'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un correo electrónico válido.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorFondo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/usuario.png.webp', height: 120),

                const SizedBox(height: 32), // Espacio

                const Text(
                  'Ingresa tu correo electrónico',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorTextoPrincipal,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Te enviaremos un código para reestablecer tu contraseña.',
                  style: TextStyle(fontSize: 16, color: colorTextoSecundario),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                Container(
                  width: 300,
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo Electrónico',
                      hintText: 'ejemplo@correo.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: const BorderSide(
                          color: colorPrimario,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: _sendRecoveryCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 217, 130, 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Enviar Código',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
