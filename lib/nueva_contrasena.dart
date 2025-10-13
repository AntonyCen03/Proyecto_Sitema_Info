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

  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();


  bool _nuevaContrasenaVisible = false;

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
    
    print('Contraseña actualizada correctamente a "$nueva"');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ontraseña guardada con éxito!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }
  //falta el build