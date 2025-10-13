import 'package:flutter/material.dart';

class PageLogin extends StatefulWidget {
  const PageLogin({super.key});

  @override
  State<PageLogin> createState() => _PageLoginState();
}

class _PageLoginState extends State<PageLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inicio de Sesión",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 243, 138, 33),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset(
        'assets/images/user.jpg',
        height: 32,
        width: 32,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            textBienvenido(),
            SizedBox(height: 10),
            imagenUsuario(),
            SizedBox(height: 20),
            textoIniciar(),
            SizedBox(height: 20),
            username(),
            SizedBox(height: 10),
            PasswordField(),
            SizedBox(height: 20),
            iniciarSesion(),
            SizedBox(height: 20),
            registrarse(),
          ],
        ),
      ),
    );
  }
}

Widget username() {
  return Container(
    width: 500, // reduce width
    padding: EdgeInsets.symmetric(
      horizontal: 10.0,
      vertical: 5.0,
    ), // less padding
    child: TextField(
      style: TextStyle(fontSize: 16), // smaller text
      decoration: InputDecoration(
        hintText: "Correo Electrónico",
        fillColor: Colors.white,
        filled: true,
        contentPadding: EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 10.0,
        ), // less inner padding
      ),
    ),
  );
}

class PasswordField extends StatefulWidget {
  const PasswordField({super.key});

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
          child: TextField(
            style: TextStyle(fontSize: 16), // smaller text
            obscureText: _obscureText,
            obscuringCharacter: '*',
            decoration: InputDecoration(
              hintText: "Contraseña",
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10.0,
              ), // less inner padding
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
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

Widget iniciarSesion() {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 243, 138, 33),
      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),
    onPressed: () {},
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
    child: Text("¿Olvidaste tu contraseña?", style: TextStyle(color: Colors.blue)),
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
