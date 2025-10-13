import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proyecto Sistema Info',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false, // 1. Quita el logo de debug
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        // 3. Centra todo el contenido
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400), // 3. Tamaño máximo
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildHeader(),
                _buildLoginSection(context),
                _buildDivider(),
                _buildCreateAccountSection(),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Column(
    children: [
      const SizedBox(height: 50.0),
      const Text(
        '¡Bienvenido/a!',
        style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 50.0),
    ],
  );

  Widget _buildLoginSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Iniciar Sesión',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 20.0),
      _buildTextField(Icons.email_outlined, 'Enter email'),
      const SizedBox(height: 16.0),
      _buildTextField(Icons.lock_outline, 'Create password', isPassword: true),
      const SizedBox(height: 8.0),
      Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () => _showSnackBar(context, 'Recuperación de contraseña'),
          child: const Text(
            'Forgot password?',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildTextField(
    IconData icon,
    String hint, {
    bool isPassword = false,
  }) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey[400]!),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600]),
          const SizedBox(width: 10.0),
          Expanded(
            child: TextFormField(
              obscureText: isPassword,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey[600]),
              ),
              keyboardType: hint.contains('email')
                  ? TextInputType.emailAddress
                  : TextInputType.text,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildDivider() => Column(
    children: [
      const SizedBox(height: 30.0),
      Divider(color: Colors.grey[400], thickness: 1.0),
      const SizedBox(height: 30.0),
    ],
  );

  Widget _buildCreateAccountSection() => const Column(
    children: [
      Text(
        'Iniciar Sesión',
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10.0),
      Text(
        'Crear cuentas',
        style: TextStyle(fontSize: 16.0, color: Colors.grey),
      ),
      SizedBox(height: 40.0),
    ],
  );

  Widget _buildFooter(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFooterColumn('Redes Sociales', [
          _buildSocialIcon(Icons.facebook, 'Facebook'),
          _buildSocialIcon(Icons.camera_alt, 'Instagram'),
          _buildSocialIcon(Icons.chat, 'Twitter'),
        ]),
        _buildFooterColumn('Contáctanos', [
          const Text(
            'Email: info@proyecto.com\nTel: +123456789',
            style: TextStyle(fontSize: 14.0),
          ),
        ]),
        _buildFooterColumn('Enlaces de interés', [
          _buildFooterLink(context, 'Términos y Condiciones'),
          _buildFooterLink(context, 'Política de Privacidad'),
        ]),
      ],
    ),
  );

  Widget _buildFooterColumn(String title, List<Widget> children) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10.0),
        ...children,
      ],
    ),
  );

  Widget _buildSocialIcon(IconData icon, String platform) => Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: GestureDetector(
      onTap: () => print('Abrir $platform'),
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Icon(icon, color: Colors.blue, size: 20.0),
      ),
    ),
  );

  Widget _buildFooterLink(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5.0),
    child: GestureDetector(
      onTap: () => _showSnackBar(context, text),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
          fontSize: 14.0,
        ),
      ),
    ),
  );

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
