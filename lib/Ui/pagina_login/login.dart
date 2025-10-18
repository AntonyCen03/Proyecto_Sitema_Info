import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:proyecto_final/services/firebase_services.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "MetroBox",
          style: TextStyle(
            color: const Color.fromARGB(255, 254, 143, 33),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/Logo.png', height: 200, width: 200),
        ),
      ),
      body: FutureBuilder(
        future: getUser(),
        builder: (context, asyncSnapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                textBienvenido(),
                SizedBox(height: 10),
                imagenUsuario(),
                SizedBox(height: 20),
                textoIniciar(),
                SizedBox(height: 20),
                UsernameField(controller: _usernameController),
                SizedBox(height: 10),
                PasswordField(controller: _passwordController),
                SizedBox(height: 20),
                iniciarSesion(_usernameController, _passwordController),
                SizedBox(height: 20),
                registrarse(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class UsernameField extends StatelessWidget {
  final TextEditingController controller;

  const UsernameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(fontSize: 16),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) {
          if (value == null || value.trim().isEmpty) return 'Ingrese un correo';
          final email = value.trim();
          if (!email.contains('@')) return 'El correo debe contener @';
          final domain = email.split('@').last.toLowerCase();
          final allowed = ['unimet.edu.ve', 'correo.unimet.edu.ve'];
          if (!allowed.contains(domain)) {
            return 'El correo debe pertenecer a unimet.edu.ve o correo.unimet.edu.ve';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Correo Electrónico",
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        ),
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  final TextEditingController controller;

  const PasswordField({super.key, required this.controller});

  @override
  State<PasswordField> createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: olvidasteContrasena(),
        ),
        Container(
          width: 500, // reduce width
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            style: TextStyle(fontSize: 16),
            obscureText: _obscureText,
            obscuringCharacter: '*',
            controller: widget.controller,
            keyboardType: TextInputType.visiblePassword,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'la contraseña no puede estar vacía';
              if (value.trim().length < 6)
                return 'la contraseña debe tener al menos 6 caracteres';
              return null;
            },
            decoration: InputDecoration(
              hintText: "Contraseña",
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10.0,
              ), // less inner padding
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget iniciarSesion(
  TextEditingController usernameController,
  TextEditingController passwordController,
) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 243, 138, 33),
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    onPressed: () async {
      final email = usernameController.text.trim();
      final password = passwordController.text;
      if (email.isEmpty || password.isEmpty) {
        print('Ingrese correo y contraseña');
        return;
      }
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Inicio de sesión exitoso: navegar o actualizar la UI según tu flujo
        print('Inicio de sesión correcto');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('Usuario no encontrado');
        } else if (e.code == 'wrong-password') {
          print('Contraseña incorrecta');
        } else {
          print('Error de autenticación: ${e.message}');
        }
      } catch (e) {
        print('Error inesperado: $e');
      }

      // Debug prints (puedes quitarlos)
      print(usernameController.text);
      print(passwordController.text);
    },
    child: Text("Iniciar Sesión", style: TextStyle(color: Colors.white)),
  );
}

Widget imagenUsuario() {
  // Usa CircleAvatar con Image.asset y un errorBuilder de respaldo para
  // que la interfaz muestre algo si la imagen no se carga correctamente.
  return CircleAvatar(
    radius: 40, // Más grande y visible por defecto
    backgroundColor: Colors.grey[200],
    backgroundImage: AssetImage('assets/images/user.jpg'),
    // En caso de que backgroundImage falle al cargar (raro en assets empaquetados),
    // también se proporciona un child como respaldo.
    child: ClipOval(
      child: Image.asset(
        'assets/images/user.jpg',
        fit: BoxFit.cover,
        width: 80,
        height: 80,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.person, size: 48, color: Colors.grey[600]),
      ),
    ),
  );
}

Widget registrarse() {
  return TextButton(
    onPressed: () {},
    child: Text("Registrarse", style: TextStyle(color: Colors.blue)),
  );
}

Widget olvidasteContrasena() {
  return TextButton(
    onPressed: () {},
    child: Text(
      "¿Olvidaste tu contraseña?",
      style: TextStyle(color: Colors.blue),
    ),
  );
}

Widget textoIniciar() {
  return Text(
    'Iniciar Sesión',
    style: TextStyle(
      color: const Color.fromARGB(255, 0, 0, 0),
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget textBienvenido() {
  return Text(
    'Bienvenido a MetroBox',
    style: TextStyle(
      color: const Color.fromARGB(255, 0, 0, 0),
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
