import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _agreedToPrivacyPolicy = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _carnetController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _carnetController.dispose();
    super.dispose();
  }

  void _registrarUsuarior() {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final contrasena = _passwordController.text;
      final carnet = _carnetController.text;

      //Aqui iria la logica del firebase para crear el usuario, puse un mensaje para mostrar algo mientras
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'MENSAJE DE PRUEBA (Falta conectar con firbebase)'
            'Registro Exitoso!\n'
            'Email: $email\n'
            'Carnet: $carnet\n'
            'Contraseña: $contrasena',
          ),
        ),
      );
    }
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Correo Electrónico',
        hintText: 'Ingrese su correo',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese un email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Ingrese un email válido';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: 'Contraseña',
        hintText: 'Cree una contraseña',
        border: const OutlineInputBorder(),
        helperText: 'Mínimo 8 caracteres',
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 8) {
          return 'La contraseña debe tener al menos 8 caracteres';
        }
        return null;
      },
    );
  }

  Widget _buildCarnetField() {
    return TextFormField(
      controller: _carnetController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: 'Carnet',
        hintText: 'Ingrese su Carnet (11 dígitos)',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su Carnet';
        }
        if (value.length != 11) {
          return 'El Carnet debe tener exactamente 11 dígitos.';
        }
        final isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
        if (!isNumeric) {
          return 'El Carnet solo puede contener números.';
        }
        return null;
      },
    );
  }

  Widget _buildPrivacyPolicyCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreedToPrivacyPolicy,
          onChanged: (bool? newValue) {
            setState(() {
              _agreedToPrivacyPolicy = newValue ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: const Text.rich(
              TextSpan(
                text: 'Acepto la ',
                style: TextStyle(color: Colors.black54),
                children: [
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 5,
        ),
        onPressed: _agreedToPrivacyPolicy ? _registrarUsuarior : null,
        child: const Text(
          'Crear Cuenta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 3,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildEmailField(),
                    const SizedBox(height: 25),
                    _buildPasswordField(),
                    const SizedBox(height: 25),
                    _buildCarnetField(),
                    const SizedBox(height: 25),
                    _buildPrivacyPolicyCheckbox(),
                    const SizedBox(height: 40),
                    _buildSignUpButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
