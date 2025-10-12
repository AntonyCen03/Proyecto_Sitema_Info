import 'package:flutter/material.dart';
import 'ventanas/olvidecontrasena.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App de Recuperación',
      debugShowCheckedModeBanner: false,
      home: Olvidecontrasena(),
    );
  }
}
