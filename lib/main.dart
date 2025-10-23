import 'package:flutter/material.dart';
import 'ventanas/olvidecontrasena.dart';
import 'ventanas/usuario.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metrobox',
      debugShowCheckedModeBanner: false,
      home: PerfilUsuario(),
    );
  }
}
