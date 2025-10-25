import 'package:flutter/material.dart';
import 'pagina_principal.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metro Box',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primaryColor: const Color(0xFFF57C00),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const PaginaPrincipal(),
    );
  }
}
