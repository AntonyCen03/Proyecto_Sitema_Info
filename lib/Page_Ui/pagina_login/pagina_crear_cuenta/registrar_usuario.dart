import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proyecto_final/Color/Color.dart';
import 'package:proyecto_final/Page_Ui/validator/validar_alfa_num.dart';
import 'package:proyecto_final/Page_Ui/validator/validar_email.dart';
import 'package:proyecto_final/Page_Ui/widgets/metro_app_bar.dart';
import 'package:proyecto_final/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:proyecto_final/services/auth_service.dart';
import 'package:proyecto_final/Page_Ui/widgets/custom_message_dialog.dart';

class PageSignUp extends StatefulWidget {
  const PageSignUp({super.key});

  @override
  State<PageSignUp> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<PageSignUp> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _agreedToPrivacyPolicy = false;
  bool _awaitingVerification = false;
  Timer? _verificationTimer;
  int _verificationAttempts = 0;
  static const int _maxVerificationAttempts = 12; // 12 * 5s = 1 minute
  Timer? _countdownTimer;
  int _remainingSeconds = 60;
  bool _isResending = false;

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
      final email = _emailController.text.trim().toLowerCase();
      final contrasena = _passwordController.text;
      final carnet = _carnetController.text;
      final cedula = _cedulaController.text;

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
        showMessageDialog(context, 'El usuario ya existe', isError: true);
        return;
      } else {
        try {
          final auth = AuthService();
          await auth.register(email, contrasena);
          await auth.sendEmailVerification();
          setState(() {
            _awaitingVerification = true;
            _verificationAttempts = 0;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Te enviamos un correo de verificación. Confírmalo y luego presiona "Ya verifiqué" o espera que el sistema lo detecte automáticamente.'),
            ),
          );

          _startVerificationPolling(email,
              nombre: _nombreController.text,
              carnet: _carnetController.text,
              cedula: _cedulaController.text);
          // No creamos el documento de usuario en Firestore hasta que verifique el email.
        } catch (e) {
          showMessageDialog(context, 'Error al registrar: ${e.toString()}',
              isError: true);
          return;
        }
      }
    }
  }

  void _startVerificationPolling(String email,
      {required String nombre,
      required String carnet,
      required String cedula}) {
    _verificationTimer?.cancel();
    _verificationAttempts = 0;
    _countdownTimer?.cancel();
    setState(() {
      _remainingSeconds = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        t.cancel();
      }
    });
    _verificationTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) async {
      _verificationAttempts++;
      try {
        final verified = await AuthService().isEmailVerified();
        if (verified) {
          timer.cancel();
          _countdownTimer?.cancel();
          setState(() => _awaitingVerification = false);
          final isadmin = isUnimetEmail(email);
          await addUser(
            nombre,
            email,
            isadmin,
            int.parse(carnet),
            cedula,
            DateTime.now(),
            DateTime.now(),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Usuario registrado con éxito')),
            );
            Navigator.pushNamed(context, '/principal');
          }
        } else if (_verificationAttempts >= _maxVerificationAttempts) {
          timer.cancel();
          _countdownTimer?.cancel();
          setState(() => _awaitingVerification = false);
          try {
            await AuthService().deleteCurrentUser();
          } catch (e) {
            try {
              await AuthService().signOut();
            } catch (_) {}
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'No se detectó la verificación. Se eliminó la cuenta temporal.')),
          );
        }
      } catch (e) {
        timer.cancel();
        setState(() => _awaitingVerification = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error comprobando verificación: ${e.toString()}')),
        );
      }
    });
  }

  Future<void> _stopVerificationPolling({bool deleteAccount = false}) async {
    _verificationTimer?.cancel();
    _verificationTimer = null;
    _verificationAttempts = 0;
    _countdownTimer?.cancel();
    _countdownTimer = null;
    if (deleteAccount) {
      try {
        await AuthService().deleteCurrentUser();
      } catch (e) {
        try {
          await AuthService().signOut();
        } catch (_) {}
      }
    } else {
      try {
        await AuthService().signOut();
      } catch (_) {}
    }
  }

  Future<void> _confirmarVerificacion() async {
    final email = _emailController.text.trim().toLowerCase();
    final carnet = _carnetController.text;
    final nombre = _nombreController.text;
    final cedula = _cedulaController.text;
    bool isadmin = isUnimetEmail(email);

    try {
      final verified = await AuthService().isEmailVerified();
      if (!verified) {
        showMessageDialog(context, 'Tu correo aún no está verificado.',
            isError: true);
        return;
      }

      // Crear el documento del usuario una vez verificado
      _stopVerificationPolling();

      await addUser(
        nombre,
        email,
        isadmin,
        int.parse(carnet),
        cedula,
        DateTime.now(),
        DateTime.now(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario registrado con éxito')),
        );
        Navigator.pushNamed(context, '/principal');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No se pudo completar el registro: ${e.toString()}')),
      );
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
      validator: (value) => validarSoloLetras(value,
          campo: 'Nombre', maxLength: 100, minLength: 3),
      inputFormatters: soloLetrasFormatters(maxLength: 100),
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
      validator: (value) => validarSoloNumeros(value,
          campo: 'Cédula', maxLength: 8, minLength: 6),
      inputFormatters: soloNumerosFormatters(maxLength: 8),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      onChanged: (value) {
        final lower = value.toLowerCase();
        if (value != lower) {
          // Reemplazar el texto por su versión en minúsculas y mover el cursor al final
          _emailController.value = TextEditingValue(
            text: lower,
            selection: TextSelection.collapsed(offset: lower.length),
          );
        }
      },
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
        return validarContrasenaCompleja(value);
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
      validator: (value) => validarSoloNumeros(value,
          campo: 'Carnet', maxLength: 11, minLength: 11),
      inputFormatters: soloNumerosFormatters(maxLength: 11),
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
        onPressed: _agreedToPrivacyPolicy && !_awaitingVerification
            ? _registrarUsuarior
            : null,
        child: const Text(
          'Crear Cuenta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(BuildContext context) {
    if (!_awaitingVerification) return const SizedBox.shrink();
    return Column(
      children: [
        if (_remainingSeconds > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Tiempo restante: ${_formatDuration(_remainingSeconds)}',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.mark_email_read),
            label: const Text('Ya verifiqué mi correo'),
            onPressed: _confirmarVerificacion,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: _isResending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: const Text('Reenviar correo'),
                onPressed: _isResending
                    ? null
                    : () async {
                        setState(() {
                          _isResending = true;
                        });
                        final email =
                            _emailController.text.trim().toLowerCase();
                        final password = _passwordController.text;
                        try {
                          await AuthService().resendEmailVerification(
                              email: email, password: password);
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Correo reenviado')));
                        } on FirebaseAuthException catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'No se pudo reenviar: ${e.message ?? e.code}')));
                        } catch (e) {
                          if (mounted)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Error al reenviar: ${e.toString()}')));
                        } finally {
                          if (mounted)
                            setState(() {
                              _isResending = false;
                            });
                        }
                      },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cancel),
                label: const Text('Cancelar'),
                onPressed: () async {
                  await _stopVerificationPolling(deleteAccount: true);
                  setState(() {
                    _awaitingVerification = false;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_awaitingVerification) {
          final shouldExit = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Cancelar registro'),
              content: const Text(
                  'Estás en proceso de verificación. Volver cancelará el registro y eliminará la cuenta temporal. ¿Deseas continuar?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Sí, cancelar'),
                ),
              ],
            ),
          );
          if (shouldExit == true) {
            await _stopVerificationPolling(deleteAccount: true);
            return true; // allow pop
          }
          return false; // prevent pop
        }
        return true;
      },
      child: Scaffold(
        appBar: MetroAppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: primaryOrange,
            ),
            onPressed: () async {
              if (_awaitingVerification) {
                final shouldExit = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Cancelar registro'),
                    content: const Text(
                        'Estás en proceso de verificación. Volver cancelará el registro y eliminará la cuenta temporal. ¿Deseas continuar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Sí, cancelar'),
                      ),
                    ],
                  ),
                );
                if (shouldExit == true) {
                  await _stopVerificationPolling(deleteAccount: true);
                  if (mounted) Navigator.pushNamed(context, '/principal');
                }
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
            tooltip: 'Volver',
          ),
          title: 'Registro de Usuario',
          backgroundColor: Colors.white,
          centerTitle: true,
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
                      _buildVerifyButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
