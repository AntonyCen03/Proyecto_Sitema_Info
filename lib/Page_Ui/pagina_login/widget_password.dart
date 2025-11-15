import 'package:flutter/material.dart';

class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool showForgotLink;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;

  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Contraseña',
    this.showForgotLink = true,
    this.hintText,
    this.validator,
    this.textInputAction,
  });

  @override
  State<PasswordField> createState() => PasswordFieldState();
}

class PasswordFieldState extends State<PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (widget.showForgotLink)
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: olvidasteContrasena(context),
          ),
        Container(
          width: 500, // reduce width
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: TextFormField(
            style: TextStyle(fontSize: 16),
            obscureText: _obscureText,
            obscuringCharacter: '*',
            controller: widget.controller,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: widget.textInputAction,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: widget.validator ??
                (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'la contraseña no puede estar vacía';
                  }
                  if (value.trim().length < 6) {
                    return 'la contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText ?? 'Ingrese su contraseña',
              border: OutlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(Icons.lock),
              contentPadding: EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 10.0,
              ), // less inner padding
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Widget olvidasteContrasena(BuildContext context) {
  return TextButton(
    onPressed: () {
      // Navegar a la página de restablecimiento de contraseña
      Navigator.pushNamed(context, '/reset_password');
    },
    child: Text(
      "¿Olvidaste tu contraseña?",
      style: TextStyle(color: Colors.blue),
    ),
  );
}
