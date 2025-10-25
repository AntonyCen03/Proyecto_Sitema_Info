import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/pagina_crear_cuenta/registrar_usuario.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:proyecto_final/Page_Ui/pagina_login/reset_password/olvidecontrasena.dart';
import 'package:proyecto_final/ventanas/usuario.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MetroBox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(250, 250, 250, 250), 
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const PageLogin(),
        '/registrar': (context) => const PageSignUp(),
        '/reset_password': (context) => const Olvidecontrasena(),
        '/perfil': (context) => const PerfilUsuario(),
      },
    );
  }
}

