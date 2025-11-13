import 'package:flutter/services.dart';

// RegExp para letras (incluye acentos y ñ/Ñ), números y espacios
final RegExp alfaNumEsCharRegExp = RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÜüÑñ0-9 ]');
final RegExp alfaNumEsFullRegExp = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÜüÑñ0-9 ]+$');

/// Formateadores para permitir solo letras, números y espacios mientras se escribe
final List<TextInputFormatter> kAlfaNumEsFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(alfaNumEsCharRegExp),
];

/// Genera formateadores con límite opcional de longitud
List<TextInputFormatter> alfaNumEsFormatters({int? maxLength}) {
  final list = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(alfaNumEsCharRegExp),
  ];
  if (maxLength != null && maxLength > 0) {
    list.add(LengthLimitingTextInputFormatter(maxLength));
  }
  return list;
}

/// Valida que el valor no esté vacío y que contenga solo letras/números/espacios.
/// Usa el nombre del campo en el mensaje de requerido.
/// Si [maxLength] se especifica, también valida la longitud máxima.
String? validarAlfaNum(
  String? value, {
  String campo = 'Este campo',
  int? maxLength,
}) {
  final raw = value ?? '';
  // Quitar NUL si algún teclado lo inserta
  final s = raw.trim().replaceAll('\u0000', '');
  if (s.isEmpty) return '$campo es obligatorio';
  if (!alfaNumEsFullRegExp.hasMatch(s)) return 'Solo letras y números';
  if (maxLength != null && maxLength > 0 && s.length > maxLength) {
    return 'Máximo $maxLength caracteres';
  }
  return null;
}
