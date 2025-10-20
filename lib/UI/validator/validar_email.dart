import 'package:flutter/material.dart';


String? validateUnimetEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Ingrese un correo';
  final email = value.trim();
  if (!email.contains('@')) return 'El correo debe contener @';
  final domain = email.split('@').last.toLowerCase();
  const allowed = ['unimet.edu.ve', 'correo.unimet.edu.ve'];
  if (!allowed.contains(domain)) {
    return 'El correo debe pertenecer a unimet.edu.ve o correo.unimet.edu.ve';
  }
  return null;
}

Widget emailField() {
  return TextFormField(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    validator: validateUnimetEmail,
    keyboardType: TextInputType.emailAddress,
    decoration: InputDecoration(labelText: 'Correo institucional'),
  );
}

bool isUnimetEmail(String? value) {
  if (value == null) return false;
  final email = value.trim();
  if (!email.contains('@')) return false;
  final domain = email.split('@').last.toLowerCase();
  return domain == 'unimet.edu.ve';
}

