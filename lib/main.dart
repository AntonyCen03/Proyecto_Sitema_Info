import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
        scaffoldBackgroundColor: const Color(
          0xFFF5F7FA,
        ), // light grey-blue background
      ),
      //home: const SignUpScreen(),
    );
  }
}
