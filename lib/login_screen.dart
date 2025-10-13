import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco
      body: SingleChildScrollView(
        // Para scroll si es necesario
        padding: EdgeInsets.all(20.0), // Margen general
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Centrado vertical si cabe
          children: [
            // Encabezado Principal
            SizedBox(height: 50.0), // Espacio superior
            Text(
              '¡Bienvenido/a!',
              style: TextStyle(
                fontSize: 32.0, // Tamaño grande y prominente
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50.0), // Espaciado generoso
            // Sección de Inicio de Sesión
            Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),

            // Campo de Email
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email',
                labelStyle: TextStyle(color: Colors.black),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0), // Espaciado entre campos
            // Campo de Contraseña
            TextFormField(
              obscureText: true, // Oculta la contraseña
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter password', // Corregido
                labelStyle: TextStyle(color: Colors.black),
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
            ),
            SizedBox(height: 8.0),

            // Enlace "Forgot password?"
            GestureDetector(
              onTap: () {
                // Aquí puedes agregar navegación a una pantalla de recuperación
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Funcionalidad de recuperación de contraseña',
                    ),
                  ),
                );
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  color: Colors.blue, // Color para indicar enlace
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            SizedBox(height: 30.0), // Espaciado antes del divisor
            // Elemento Divisor (Línea horizontal)
            Divider(
              color: Colors.black,
              thickness: 1.0,
              height: 20.0, // Altura del divisor con espaciado
            ),
            SizedBox(height: 30.0),

            // Sección de Registro
            Text(
              'Registrarse', // Corregido para que sea lógico
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            Text(
              'Crear cuentas', // Subtítulo
              style: TextStyle(fontSize: 16.0, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                // Aquí navega a la pantalla de registro
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Navegar a registro')));
              },
              child: Text('Crear Cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Color básico
                foregroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 50.0), // Espacio antes del pie
            // Pie de Página (Tres columnas)
            Row(
              children: [
                // Columna 1: Redes Sociales
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Redes Sociales',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.facebook, color: Colors.blue),
                            onPressed: () => _showSocialSnack('Facebook'),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.document_scanner,
                              color: Colors.blue,
                            ),
                            onPressed: () => _showSocialSnack('Twitter'),
                          ),
                          // Agrega más iconos si necesitas (Instagram, etc.)
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.0), // Espacio entre columnas
                // Columna 2: Contáctanos
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Contáctanos',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        'Email: info@proyecto.com\nTel: +123456789',
                        style: TextStyle(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20.0),

                // Columna 3: Enlaces de interés
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Enlaces de Interés',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () => _showSocialSnack('Términos'),
                        child: Text('Términos y Condiciones'),
                      ),
                      TextButton(
                        onPressed: () => _showSocialSnack('Privacidad'),
                        child: Text('Política de Privacidad'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0), // Espacio inferior
          ],
        ),
      ),
    );
  }

  // Función helper para mostrar un SnackBar en enlaces (placeholder)
  void _showSocialSnack(String platform) {
    // Reemplaza con navegación real o acciones
    print('Abrir $platform'); // Para debugging
  }
}
