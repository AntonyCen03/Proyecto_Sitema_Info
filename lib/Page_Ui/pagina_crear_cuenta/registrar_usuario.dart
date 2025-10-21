import 'package:flutter/material.dart';
import 'package:proyecto_final/Page_Ui/validator/validar_email.dart';
import 'package:proyecto_final/services/firebase_services.dart';
import 'package:proyecto_final/services/auth_service.dart';

class PageSignUp extends StatefulWidget {
  const PageSignUp({super.key});

  @override
  State<PageSignUp> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<PageSignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _agreedToPrivacyPolicy = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _carnetController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _carnetController.dispose();
    _nombreController.dispose();
    _cedulaController.dispose();
    super.dispose();
  }

  void _registrarUsuarior() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final contrasena = _passwordController.text;
      final carnet = _carnetController.text;
      final nombre = _nombreController.text;
      final cedula = _cedulaController.text;
      bool isadmin = false;

      final users = await getUser(context);
      Map<String, dynamic>? existingUser;
      for (final u in users) {
        final uemail = (u['email'] ?? '').toString().trim();
        final ucedula = (u['cedula'] ?? '').toString().trim();
        final ucarnet = (u['carnet'] ?? '').toString().trim();
        if (uemail == email || ucedula == cedula || ucarnet == carnet) {
          existingUser = u;
          break;
        }
      }

      if (existingUser != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('El usuario ya existe')));
        return;
      } else {
        if (isUnimetEmail(email)) {
          isadmin = true;
        }
        addUser(nombre, email, isadmin, int.parse(carnet), cedula, DateTime.now(), DateTime.now());
        AuthService().register(email, contrasena);
      }

      Navigator.pushNamed(context, '/login');
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado con éxito')),
        );
      });
    }
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nombreController,
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        labelText: 'Nombre Completo',
        hintText: 'Ingrese su nombre',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su nombre completo';
        }
        return null;
      },
    );
  }

  Widget _buildCedulaField() {
    return TextFormField(
      controller: _cedulaController,
      keyboardType: TextInputType.number,
      maxLength: 8,
      decoration: const InputDecoration(
        labelText: 'Cédula de Identidad',
        hintText: '6 a 8 dígitos',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.credit_card),
        counterText: '',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, ingrese su Cédula';
        }
        // Validación de 6 a 8 dígitos numéricos
        if (value.length < 6 || value.length > 8) {
          return 'La Cédula debe tener entre 6 y 8 dígitos.';
        }
        final isNumeric = RegExp(r'^[0-9]+$').hasMatch(value);
        if (!isNumeric) {
          return 'La Cédula solo puede contener números.';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Correo Electrónico',
        hintText: 'Ingrese su correo',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (validateUnimetEmail(value) != null) {
          return 'El email debe ser unimet.edu.ve o correo.unimet.edu.ve';
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
        prefixIcon: const Icon(Icons.lock),
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
        prefixIcon: Icon(Icons.badge),
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
                      color: Colors.deepOrange,
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
          backgroundColor: Color.fromARGB(255, 254, 143, 33),
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 254, 143, 33),
          ),
          onPressed: () => Navigator.pushNamed(context, '/login'),
          tooltip: 'Volver',
        ),
        title: const Text(
          'Registro de Usuario',
          style: TextStyle(
            color: Color.fromARGB(255, 254, 143, 33),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 254, 143, 33),
        ),
      ),
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
                        color: Color.fromARGB(255, 254, 143, 33),
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildNameField(),
                    const SizedBox(height: 25),
                    _buildCedulaField(),
                    const SizedBox(height: 25),
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
