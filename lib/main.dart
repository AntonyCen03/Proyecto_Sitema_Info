import 'package:flutter/material.dart';
import 'Ui/pagina_login/login.dart';
import 'package:firebase_core/firebase_core.dart';
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
      // Use a theme to change the scaffold background color globally.
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 224, 224, 224), // light grey-blue background
      ),
      home: const PageLogin(),
    );
  }
}
