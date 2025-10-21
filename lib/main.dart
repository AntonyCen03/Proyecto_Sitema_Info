import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        appBar: AppBar(
          toolbarHeight: 145,
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          leading: Image.asset('images/Logo.png', width: 164, height: 231),
          leadingWidth: 300,
          title: const Text(
            'MetroBox',
            style: TextStyle(
              fontSize: 64,
              color: Color.fromRGBO(240, 83, 43, 1),
            ),
          ),
          centerTitle: true,
        ),
        body: const Column(
          children: [
            Divider(
              color: Color.fromRGBO(65, 64, 64, 1),
              height: 4,
              thickness: 10,
              indent: 0,
              endIndent: 0,
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Comprueba si has recibido en el correo el código de verificación y escríbelo en el campo correspondiente para continuar con el proceso de registro.',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromRGBO(248, 131, 49, 1),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Código de verificación',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
