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

// ==============================
// Solo letras (con longitud opcional)
// ==============================

final RegExp soloLetrasCharRegExp = RegExp(r'[A-Za-zÁÉÍÓÚáéíóúÜüÑñ ]');
final RegExp soloLetrasFullRegExp = RegExp(r'^[A-Za-zÁÉÍÓÚáéíóúÜüÑñ ]+$');

/// Formateadores para permitir solo letras (con espacios) mientras se escribe
final List<TextInputFormatter> kSoloLetrasFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(soloLetrasCharRegExp),
];

/// Genera formateadores de solo letras con límite opcional de longitud
List<TextInputFormatter> soloLetrasFormatters({int? maxLength}) {
  final list = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(soloLetrasCharRegExp),
  ];
  if (maxLength != null && maxLength > 0) {
    list.add(LengthLimitingTextInputFormatter(maxLength));
  }
  return list;
}

/// Valida que el valor no esté vacío, contenga solo letras (y espacios) y respete una longitud máxima opcional.
String? validarSoloLetras(
  String? value, {
  String campo = 'Este campo',
  int? maxLength,
  int? minLength,
}) {
  final raw = value ?? '';
  final s = raw.trim().replaceAll('\u0000', '');
  if (s.isEmpty) return '$campo es obligatorio';
  if (!soloLetrasFullRegExp.hasMatch(s)) return 'Solo letras';
  if (maxLength != null && maxLength > 0 && s.length > maxLength) {
    return 'Máximo $maxLength caracteres';
  }
  if (minLength != null && minLength > 0 && s.length < minLength) {
    return 'Mínimo $minLength caracteres';
  }
  return null;
}

// ==============================
// Solo números (con longitud opcional)
// ==============================

final RegExp soloNumerosCharRegExp = RegExp(r'[0-9]');
final RegExp soloNumerosFullRegExp = RegExp(r'^[0-9]+$');

/// Formateadores para permitir solo números mientras se escribe
final List<TextInputFormatter> kSoloNumerosFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(soloNumerosCharRegExp),
];

/// Genera formateadores numéricos con límite opcional de longitud
List<TextInputFormatter> soloNumerosFormatters({int? maxLength}) {
  final list = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(soloNumerosCharRegExp),
  ];
  if (maxLength != null && maxLength > 0) {
    list.add(LengthLimitingTextInputFormatter(maxLength));
  }
  return list;
}

/// Formateadores para permitir números decimales (.,) con 1 separador y opcional límite de longitud y decimales.
List<TextInputFormatter> soloNumerosDoubleFormatters({
  int? maxLength, // longitud total máxima (incluye punto/coma)
  int? maxDecimals, // cantidad máxima de decimales
}) {
  final list = <TextInputFormatter>[
    _DoubleInputFormatter(maxDecimals: maxDecimals),
  ];
  if (maxLength != null && maxLength > 0) {
    list.add(LengthLimitingTextInputFormatter(maxLength));
  }
  return list;
}

/// Formatter personalizado para permitir solo dígitos y un único punto/coma.
/// Normaliza la coma a punto. Controla decimales máximos.
class _DoubleInputFormatter extends TextInputFormatter {
  final int? maxDecimals;
  _DoubleInputFormatter({this.maxDecimals});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(',', '.');

    // Quitar caracteres no permitidos
    text = text.replaceAll(RegExp(r'[^0-9.]'), '');

    // Mantener solo un punto
    final firstDotIndex = text.indexOf('.');
    if (firstDotIndex != -1) {
      // Eliminar puntos adicionales
      final withoutFirst = text.substring(0, firstDotIndex + 1) +
          text.substring(firstDotIndex + 1).replaceAll('.', '');
      text = withoutFirst;
    }

    // Limitar decimales
    if (maxDecimals != null && maxDecimals! >= 0) {
      final parts = text.split('.');
      if (parts.length == 2 && parts[1].length > maxDecimals!) {
        text = parts[0] + '.' + parts[1].substring(0, maxDecimals);
      }
    }

    // Prefijo 0 si empieza con punto
    if (text.startsWith('.')) {
      text = '0$text';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Valida número double (acepta coma o punto). Opcional decimales máximos.
String? validarDouble(
  String? value, {
  String campo = 'Este campo',
  int? maxDecimals,
}) {
  final raw =
      (value ?? '').trim().replaceAll('\u0000', '').replaceAll(',', '.');
  if (raw.isEmpty) return '$campo es obligatorio';
  if (!RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(raw)) return 'Formato inválido';
  if (maxDecimals != null && maxDecimals >= 0) {
    final parts = raw.split('.');
    if (parts.length == 2 && parts[1].length > maxDecimals) {
      return 'Máximo $maxDecimals decimales';
    }
  }
  return null;
}

/// Valida que el valor no esté vacío, sea numérico y (opcionalmente) respete una longitud máxima.
String? validarSoloNumeros(
  String? value, {
  String campo = 'Este campo',
  int? maxLength,
  int? minLength,
}) {
  final raw = value ?? '';
  final s = raw.trim().replaceAll('\u0000', '');
  if (s.isEmpty) return '$campo es obligatorio';
  if (!soloNumerosFullRegExp.hasMatch(s)) return 'Solo números';
  if (maxLength != null && maxLength > 0 && s.length > maxLength) {
    return 'Máximo $maxLength caracteres';
  }
  if (minLength != null && minLength > 0 && s.length < minLength) {
    return 'Mínimo $minLength caracteres';
  }
  return null;
}

// ==============================
// Validación de Contraseña Compleja
// ==============================

/// Valida que la contraseña tenga al menos una letra, un número y un símbolo.
/// También verifica la longitud mínima (por defecto 8).
String? validarContrasenaCompleja(String? value, {int minLength = 8}) {
  final password = value ?? '';
  if (password.isEmpty) return 'La contraseña es obligatoria';
  if (password.length < minLength) return 'Mínimo $minLength caracteres';

  // Verificar letra
  if (!password.contains(RegExp(r'[a-zA-Z]'))) {
    return 'Debe contener al menos una letra';
  }
  // Verificar número
  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Debe contener al menos un número';
  }
  // Verificar símbolo (caracteres especiales comunes)
  if (!password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_+=\[\]/\\`~]'))) {
    return 'Debe contener al menos un símbolo';
  }

  return null;
}
