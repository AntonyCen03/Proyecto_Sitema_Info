import 'package:flutter/material.dart';

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
  // Aquí va el código del estado (variables, métodos, etc.)
  
  @override
  Widget build(BuildContext context) {
    // Aquí va la interfaz de usuario
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          toolbarHeight: 145,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          leading: Image.asset(
              'images/Logo.png',
              width: 164,
              height: 231
              ,),
              leadingWidth: 300,
          title:
           const Text(
            'MetroBox',
            style: TextStyle(
              fontSize: 64,
              color: Color.fromRGBO(240, 83, 43, 1),
              fontWeight: FontWeight.bold,
              ),
            ),
          centerTitle: true,
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
                width: 1000.0,
                margin: const EdgeInsets.all(30),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(208, 215, 255, 1),
                  border: Border.all(
                    color: const Color.fromRGBO(65, 64, 64, 0.95),
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                        'Nuevas Contraseña',
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
                        controller: _nuevaContrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Nueva contraseña',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmarContrasenaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Confirmar contraseña',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorBoton,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: _guardarNuevaContrasena,
                        child: const Text(
                          'Guardar contraseña',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();


  
  

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa ambos campos.'),
          backgroundColor: Colors.orange,
        ),
      );
      return; 
    }

    if (nueva != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden.'),
          backgroundColor: Colors.red,
        ),
      );
      return; 
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ontraseña guardada con éxito!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }
}