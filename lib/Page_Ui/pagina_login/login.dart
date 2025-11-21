import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/widget_password.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/services/firebase_services.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/widget_iniciar_sesion.dart';

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
      appBar: MetroAppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: primaryOrange,
          ),
          onPressed: () => Navigator.pushNamed(context, '/principal'),
          tooltip: 'Volver',
        ),
        title: "Login",
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset('assets/images/Logo.png', height: 36, width: 36),
          ),
        ],
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getUser(context),
        builder: (context, asyncSnapshot) {
          return Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 3,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    textBienvenido(),
                    SizedBox(height: 10),
                    imagenUsuario(context),
                    SizedBox(height: 20),
                    textoIniciar(),
                    SizedBox(height: 20),
                    UsernameField(controller: _usernameController),
                    SizedBox(height: 10),
                    PasswordField(controller: _passwordController),
                    SizedBox(height: 20),
                    IniciarSesion(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                    ),
                    SizedBox(height: 20),
                    registrarse(context),
                  ],
                ),
              ),
            ),
          ));
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
          labelText: "Correo Electrónico",
          hintText: "Ingrese su correo institucional",
          border: OutlineInputBorder(),
          fillColor: Theme.of(context).cardColor,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
          prefixIcon: Icon(Icons.email),
        ),
      ),
    );
  }
}

Widget imagenUsuario(BuildContext context) {
  return CircleAvatar(
    radius: 40,
    backgroundColor: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey[800]
        : Colors.grey[200],
    backgroundImage: AssetImage('assets/images/user.jpg'),
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

Widget registrarse(BuildContext context) {
  return TextButton(
    onPressed: () {
      Navigator.pushNamed(context, '/registrar');
    },
    child: Text("Registrarse", style: TextStyle(color: primaryBlue)),
  );
}

Widget textoIniciar() {
  return Text(
    'Iniciar Sesión',
    style: TextStyle(
      color: primaryOrange,
      fontSize: 30,
      fontWeight: FontWeight.bold,
    ),
  );
}

Widget textBienvenido() {
  return Text(
    'Bienvenido a MetroBox',
    style: TextStyle(
      color: primaryOrange,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
