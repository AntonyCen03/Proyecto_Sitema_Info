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
  final TextEditingController _nuevaContrasenaController = TextEditingController();
  final TextEditingController _confirmarContrasenaController = TextEditingController();
  Text advertencia = const Text('Las contraseñas no coinciden.', style: TextStyle(color: Colors.red),);
  bool visibilidadAdvertencia = false;

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
                  Visibility(visible: visibilidadAdvertencia,child: advertencia),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorBoton,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                        ),
                        onPressed: (){},
                        child: const Text(
                          'Regresar',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorBoton,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          )
                        ),
                        onPressed:(){
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
        advertencia = const Text('Por favor, completa ambos campos.', style: TextStyle(color: Colors.red),);
        visibilidadAdvertencia = true;
        }
      );
      return; 
    }

    if (nueva != confirmar) {
      setState(() {
        advertencia = const Text('Las contraseñas no coinciden.', style: TextStyle(color: Colors.red),);
        visibilidadAdvertencia = true;
      });
      return; 
    }
    
    for(int i=0; i<nueva.length; i++){
      if(nueva[i]==' '){
        setState(() {
          advertencia = const Text('Contraseña actualizada con éxito.', style: TextStyle(color: Colors.green),);
          visibilidadAdvertencia = true;
        });
        return;
      }
      
      ingresarNuevaContrasena();
      regresar();
    }
    
  }

  void ingresarNuevaContrasena() {
    // Lógica para ingresar la nueva contraseña en el firebase
  }

  void regresar() {
    // Lógica para regresar a la pantalla de iniciar sesión
  }
}